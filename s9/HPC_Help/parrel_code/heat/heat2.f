! 二维热传导方程：Peaceman-Rachford 格式，分块流水线算法
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE  'mpif.h'
      PARAMETER(DW=2.D0, DH=3.D0) ! 问题求解区域沿 X、Y 方向的大小
      PARAMETER(DT=.05D0)         ! 时间步长
      PARAMETER(IM=50, JM=100)    ! 沿 X、Y 方向的全局网格规模
      PARAMETER(NPX=1, NPY=1)     ! 沿 X、Y 方向的进程个数
      PARAMETER(IML=IM/NPX, JML=JM/NPY)
	! 各进程沿 X、Y 方向的局部网格规模, 仅为全局网格规模的 1/(NPX*NPY)
      DIMENSION U (0:IML+1,0:JML+1) ! 当前时间层的近似解
      DIMENSION U0(0:IML+1,0:JML+1) ! 中间变量
      DOUBLE PRECISION KX, KY     ! $\Delta t/h_x^2$和$\Delta t/h_y^2$
      DOUBLE PRECISION T0, T1     ! 用于统计运行时间
      INTEGER  NPROC              ! mpirun 启动的进程个数, 必须等于 NPX*NPY
      INTEGER  MYRANK, MYLEFT, MYRIGHT, MYUPPER, MYLOWER
                                  ! 各进程自身的进程号, 4 个相邻进程的进程号
      INTEGER  MEPX,MEPY          ! 各进程自身的进程号沿 X、Y 方向的坐标
      INTEGER  IST,IEND,JST,JEND
                      ! 各进程沿 X、Y 方向的内部网格结点的起始和终止坐标
      INTEGER  HTYPE, VTYPE
                      ! MPI 用户自定义数据类型, 表示各进程沿 X、Y 方向
                      ! 与相邻进程交换的数据单元
! 用于求解三对角线性方程组的变量
      PARAMETER(NBX=50, NBY=50)   ! 分块流水线方法沿 X、Y 方向分块大小
      DOUBLE PRECISION LX(0:IML-1),DX(IML),UX(IML) ! 沿 X 方向的 LU 分解系数
      DOUBLE PRECISION LY(0:JML-1),DY(JML),UY(JML) ! 沿 Y 方向的 LU 分解系数
      INTEGER  LENS(2), DISPS(2), TYPES(2) ! 用于定义 VTYPE 的辅助数组
                      ! 注：某些 64 位机器上可能需要将 DISPS 声明成 INTEGER*8
      INTEGER  STATUS(MPI_STATUS_SIZE)
! Constants
      DATA ONE/1.D0/, TWO/2.D0/, ZERO/0.D0/, HALF/.5D0/
      DATA LENS/1,1/, TYPES/MPI_DOUBLE_PRECISION, MPI_UB/
! In-line functions
      solution(x,y,t) = EXP(-t-t)*SIN(x)*COS(y) ! 解析解：$e^{-2t}\sin x\cos y$
! 程序可执行语句开始
      CALL MPI_Init(IERR)
      CALL MPI_Comm_size(MPI_COMM_WORLD,NPROC,IERR)
      IF (NPROC.NE.NPX*NPY.OR.MOD(IM,NPX).NE.0.OR.MOD(JM,NPY).NE.0) THEN
         PRINT *, '+++ Incorrect parameters, abort +++'
	 CALL MPI_Finalize(IERR)
         STOP
      ENDIF
! 按自然序 (先沿 X 方向, 后沿 Y 方向) 确定各进程自身及其 4 个相邻进程的进程号
      CALL MPI_Comm_rank(MPI_COMM_WORLD,MYRANK,IERR)
      MYLEFT  = MYRANK - 1
      IF (MOD(MYRANK,NPX).EQ.0)   MYLEFT=MPI_PROC_NULL
      MYRIGHT = MYRANK + 1
      IF (MOD(MYRIGHT,NPX).EQ.0)  MYRIGHT=MPI_PROC_NULL
      MYUPPER = MYRANK + NPX
      IF (MYUPPER.GE.NPROC)       MYUPPER=MPI_PROC_NULL
      MYLOWER = MYRANK - NPX
      IF (MYLOWER.LT.0)           MYLOWER=MPI_PROC_NULL
      MEPY=MYRANK/NPX
      MEPX=MYRANK-MEPY*NPX
! 基本变量赋值, 确定各进程负责的子区域
      HX = DW/IM		! X 方向网格步长$h_x$
      KX = DT/(HX*HX)           ! $\Delta t/h_x^2$
      HY = DH/JM		! Y 方向网格步长$h_y$
      KY = DT/(HY*HY)		! $\Delta t/h_y^2$
! 各子区域负责计算的范围
      IST=1
      IEND=IML
      IF (MEPX.EQ.NPX-1) IEND=IEND-1   ! 最右边的区域 X 方向少一个点
      JST=1
      JEND=JML
      IF (MEPY.EQ.NPY-1) JEND=JEND-1   ! 最上边的区域 Y 方向少一个点
! 初始条件 (注意我们需要区域角点处的值)
      DO J=JST-1, JEND+1
         yy=(J+MEPY*JML)*HY
         DO I=IST-1, IEND+1
            xx=(I+MEPX*IML)*HX
            U(I,J)=solution(xx,yy,ZERO) ! 初始解
         ENDDO
      ENDDO
! X 方向三对角矩阵的 LU 分解，各处理器独立计算自己需要的那部分系数
! (跳过前面 MEPX*IML 个不属于自己的系数)
      AX = TWO * (ONE + KX)
      BX = -KX
      DD = ONE / AX
      DO I = 1, MEPX*IML
         DU = BX
         DL = BX * DD
         DD = ONE / (AX - DL * DU)
      ENDDO
      IF (MEPX.EQ.0) THEN
         LX(0) = BX
      ELSE
         LX(0) = DL
      ENDIF
      DX(1) = DD
      DO I = IST, IEND-1
         UX(I) = BX
         LX(I) = BX * DX(I)
         DX(I+1) = ONE / (AX - LX(I) * UX(I))
      ENDDO
      UX(IEND) = BX
! Y 方向三对角矩阵的 LU 分解，各处理器独立计算自己需要的那部分系数
! (跳过前面 MEPY*JML 个不属于自己的系数)
      AY = TWO * (ONE + KY)
      BY = -KY
      DD = ONE / AY
      DO J = 1, MEPY*JML
         DU = BY
         DL = BY * DD
         DD = ONE / (AY - DL * DU)
      ENDDO
      IF (MEPY.EQ.0) THEN
         LY(0) = BY
      ELSE
         LY(0) = DL
      ENDIF
      DY(1) = DD
      DO J = JST, JEND-1
         UY(J) = BY
         LY(J) = BY * DY(J)
         DY(J+1) = ONE / (AY - LY(J) * UY(J))
      ENDDO
      UY(JEND) = BY
! 数据类型定义
      HTYPE=MPI_DOUBLE_PRECISION
                 ! HTYPE 用于发送沿 X 方向一条线上的一段数据
      DISPS(1) = 0
      CALL MPI_Type_extent(MPI_DOUBLE_PRECISION, DISPS(2), IERR)
      DISPS(2) = DISPS(2) * (IML+2)
      CALL MPI_Type_struct(2, LENS, DISPS, TYPES, VTYPE, IERR)
      CALL MPI_Type_commit(VTYPE, IERR)
                 ! VTYPE 用于发送沿 Y 方向一条线上的一段数据
! 时间推进
      NT=0
      T0 = MPI_Wtime()
100   CONTINUE   ! 主循环
      NT=NT+1
      T=NT*DT
!---- X 方向求解：方程 (\ref{heat:eq10a})
      DO J=JST,JEND
      DO I=IST,IEND
         U0(I,J)=TWO*(U(I,J)-KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1)))) ! 右端项
      ENDDO
      ENDDO
!     X 方向边界条件
      IF (MEPX.EQ.0) THEN
!        中间解$\tilde{u}^{n+\frac12}$的边界条件前半部分 (保存于 U0)
         I=IST-1
         DO J=JST,JEND
            U0(I,J)=U(I,J)-KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1)))
         ENDDO
!        $u^{n+1}$的边界条件
         xx = ZERO
         DO J=JST-1,JEND+1
            yy=(J+MEPY*JML)*HY
            U(I,J)=solution(xx,yy,T)
         ENDDO
!        中间解$\tilde{u}^{n+\frac12}$的边界条件后半部分
         DO J=JST,JEND
            U0(I,J)=HALF*(U0(I,J) +
     &                    U(I,J)+KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1))))
         ENDDO
      ENDIF
      IF (MEPX.EQ.NPX-1) THEN
!        中间解$\tilde{u}^{n+\frac12}$的边界条件前半部分 (存在 U0 中)
         I=IEND+1
         DO J=JST,JEND
            U0(I,J)=U(I,J)-KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1)))
         ENDDO
!        $u^{n+1}$的边界条件
         xx = DW
         DO J=JST-1,JEND+1
            yy=(J+MEPY*JML)*HY
            U(I,J)=solution(xx,yy,T)
         ENDDO
!        中间解$\tilde{u}^{n+\frac12}$的边界条件后半部分
         DO J=JST,JEND
            U0(I,J)=HALF*(U0(I,J) +
     &                    U(I,J)+KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1))))
         ENDDO
      ENDIF
!     下三角求解
      DO JJ = JST, JEND, NBY
         JE = MIN(JEND, JJ+NBY-1)
         CALL MPI_Recv(U0(IST-1,JJ), JE-JJ+1, VTYPE, MYLEFT, 11,
     &                 MPI_COMM_WORLD, STATUS, IERR)
         DO J = JJ, JE
         DO I = IST, IEND
            U0(I,J) = U0(I,J) - LX(I-1) * U0(I-1,J)
         ENDDO
         ENDDO
         CALL MPI_Send(U0(IEND,JJ),  JE-JJ+1, VTYPE, MYRIGHT, 11,
     &                 MPI_COMM_WORLD, IERR)
      ENDDO
!     上三角求解
      DO JJ = JST, JEND, NBY
         JE = MIN(JEND, JJ+NBY-1)
         CALL MPI_Recv(U0(IEND+1,JJ), JE-JJ+1, VTYPE, MYRIGHT, 22,
     &                 MPI_COMM_WORLD, STATUS, IERR)
         DO J = JJ, JE
         DO I = IEND, 1, -1
            U0(I,J) = (U0(I,J) - UX(I) * U0(I+1,J)) * DX(I)
         ENDDO
         ENDDO
         CALL MPI_Send(U0(IST,JJ),    JE-JJ+1, VTYPE, MYLEFT, 22,
     &                 MPI_COMM_WORLD, IERR)
      ENDDO
!     沿 X 方向交换定义在辅助网格结点上的近似解
      CALL MPI_Sendrecv(U0(IEND,1), JEND-JST+1, VTYPE, MYRIGHT, 33,
     &                  U0(0,1),    JEND-JST+1, VTYPE, MYLEFT,  33,
     &                  MPI_COMM_WORLD, STATUS, IERR)
!---- Y 方向求解：方程 (\ref{heat:eq10b})
      DO J=JST,JEND
      DO I=IST,IEND
	 U(I,J)=TWO*(U0(I,J)-KX*(U0(I,J)-HALF*(U0(I-1,J)+U0(I+1,J)))) ! 右端项
      ENDDO
      ENDDO
!     Y 方向边界条件
      IF (MEPY.EQ.0) THEN
         J=JST-1
         yy = ZERO
         DO I=IST,IEND
            xx=(I+MEPX*IML)*HX
            U(I,J)=solution(xx,yy,T)
         ENDDO
      ENDIF
      IF (MEPY.EQ.NPY-1) THEN
         J=JEND+1
         yy = DH
         DO I=IST,IEND
            xx=(I+MEPX*IML)*HX
            U(I,J)=solution(xx,yy,T)
         ENDDO
      ENDIF
!     下三角求解
      DO II = IST, IEND, NBX
         IE = MIN(IEND, II+NBX-1)
         CALL MPI_Recv(U(II,JST-1), IE-II+1, HTYPE, MYLOWER, 44,
     &                 MPI_COMM_WORLD, STATUS, IERR)
         DO J = JST, JEND
         DO I = II, IE
            U(I,J) = U(I,J) - LY(J-1) * U(I,J-1)
         ENDDO
         ENDDO
         CALL MPI_Send(U(II,JEND),  IE-II+1, HTYPE, MYUPPER, 44,
     &                 MPI_COMM_WORLD, IERR)
      ENDDO
!     上三角求解
      DO II = IST, IEND, NBX
         IE = MIN(IEND, II+NBX-1)
         CALL MPI_Recv(U(II,JEND+1), IE-II+1, HTYPE, MYUPPER, 55,
     &                 MPI_COMM_WORLD, STATUS, IERR)
         DO J = JEND, 1, -1
         DO I = II, IE
            U(I,J) = (U(I,J) - UY(J) * U(I,J+1)) * DY(J)
         ENDDO
         ENDDO
         CALL MPI_Send(U(II,JST),    IE-II+1, HTYPE, MYLOWER, 55,
     &                 MPI_COMM_WORLD, IERR)
      ENDDO
!     沿 Y 方向交换定义在辅助网格结点上的近似解
      CALL MPI_Sendrecv(U(1,JEND),  IEND-IST+1, HTYPE, MYUPPER, 66,
     &                  U(1,0),     IEND-IST+1, HTYPE, MYLOWER, 66,
     &                  MPI_COMM_WORLD, STATUS, IERR)
! 注：沿 X 方向辅助网格结点上的近似解没有更新 (下一个时间层的计算不需要它)
      T1 = MPI_Wtime()
      IF (MYRANK.EQ.0) PRINT *, 'T=', T, '   wtime=', T1 - T0
      IF (T.LT.1.0) GOTO 100
! 计算与精确解间的误差
      ERR0=ZERO
      DO J=JST, JEND
         yy=(J+MEPY*JML)*HY
         DO I=IST, IEND
            xx=(I+MEPX*IML)*HX
            ERR0=MAX(ERR0,ABS(U(I,J)-solution(xx,yy,T)))
         ENDDO
      ENDDO
      CALL MPI_Reduce(ERR0, ERR, 1, MPI_DOUBLE_PRECISION, MPI_MAX, 0,
     &                MPI_COMM_WORLD, IERR)
      IF (MYRANK.EQ.0) THEN
         PRINT *, 'Error: ', ERR
         PRINT *, 'Wall time: ', T1 - T0
      ENDIF
      CALL MPI_Finalize(IERR)
      STOP
      END
