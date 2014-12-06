! 二维热传导方程：显式欧拉格式 (基于莫则尧的 poisson1.f)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE  'mpif.h'
      PARAMETER(DW=2.D0,DH=3.D0)  ! 问题求解区域沿 X、Y 方向的大小
      PARAMETER(DT=.0008D0)	  ! 时间步长，要求满足：$\Delta t(1/h_x^2+1/h_y^2)<1/2$
      PARAMETER(IM=30, JM=60)     ! 沿 X、Y 方向的全局网格规模
      PARAMETER(NPX=1, NPY=1)     ! 沿 X、Y 方向的进程个数
      PARAMETER(IML=IM/NPX, JML=JM/NPY)
	! 各进程沿 X、Y 方向的局部网格规模, 仅为全局网格规模的 1/(NPX*NPY)
      DIMENSION U (0:IML+1,0:JML+1) ! 当前时间层的近似解
      DIMENSION U0(0:IML+1,0:JML+1) ! 前一时间层的近似解
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
      INTEGER  REQ(8), STATUS(MPI_STATUS_SIZE,8)
! Constants
      DATA TWO/2.D0/, ZERO/0.D0/
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
! 初始条件
      DO J=JST-1, JEND+1
         yy=(J+MEPY*JML)*HY
         DO I=IST-1, IEND+1
            xx=(I+MEPX*IML)*HX
            U(I,J)=solution(xx,yy,ZERO) ! 初始解
         ENDDO
      ENDDO
! 数据类型定义
      CALL MPI_Type_contiguous(IEND-IST+1, MPI_DOUBLE_PRECISION,
     &                         HTYPE, IERR)
      CALL MPI_Type_commit(HTYPE, IERR)
                 ! 沿 X 方向的连续 IEND-IST+1 个 MPI_DOUBLE_PRECISION 数据单元,
                 ! 可用于表示该进程与其上、下进程交换的数据单元
      CALL MPI_Type_vector(JEND-JST+1, 1, IML+2, MPI_DOUBLE_PRECISION,
     &                     VTYPE, IERR)
      CALL MPI_Type_commit(VTYPE, IERR)
                 ! 沿 Y 方向的连续 JEND-JST+1 个 MPI_DOUBLE_PRECISION 数据单元,
                 ! 可用于表示该进程与其左、右进程交换的数据单元
! 时间推进
      NT=0
      T0 = MPI_Wtime()
100   CONTINUE   ! 主循环
      NT=NT+1
      T=NT*DT
! 拷贝 U -> U0
      DO J=JST-1,JEND+1
      DO I=IST-1,IEND+1
         U0(I,J)=U(I,J)
      ENDDO
      ENDDO
! 边界条件
      IF (MEPX.EQ.0) THEN
         xx = ZERO
         DO J=JST,JEND
            yy=(J+MEPY*JML)*HY
            U(0,J)=solution(xx,yy,T)
         ENDDO
      ENDIF
      IF (MEPX.EQ.NPX-1) THEN
         xx = DW
         DO J=JST,JEND
            yy=(J+MEPY*JML)*HY
            U(IEND+1,J)=solution(xx,yy,T)
         ENDDO
      ENDIF
      IF (MEPY.EQ.0) THEN
         yy = ZERO
         DO I=IST,IEND
            xx=(I+MEPX*IML)*HX
            U(I,0)=solution(xx,yy,T)
         ENDDO
      ENDIF
      IF (MEPY.EQ.NPY-1) THEN
         yy = DH
         DO I=IST,IEND
            xx=(I+MEPX*IML)*HX
            U(I,JEND+1)=solution(xx,yy,T)
         ENDDO
      ENDIF
! 显式欧拉格式推进
      DO J=JST,JEND
      DO I=IST,IEND
         U(I,J)=U0(I,J)
     &              - KX * (TWO*U0(I,J) - U0(I-1,J) - U0(I+1,J))
     &              - KY * (TWO*U0(I,J) - U0(I,J-1) - U0(I,J+1))
      ENDDO
      ENDDO
! 交换定义在辅助网格结点上的近似解
      CALL MPI_Isend(U(1,1),      1, VTYPE, MYLEFT,  NT+100,
     &               MPI_COMM_WORLD,REQ(1),IERR)            ! 发送左边界
      CALL MPI_Isend(U(IEND,1),   1, VTYPE, MYRIGHT, NT+100,
     &               MPI_COMM_WORLD,REQ(2),IERR)            ! 发送右边界
      CALL MPI_Isend(U(1,1),      1, HTYPE, MYLOWER, NT+100,
     &               MPI_COMM_WORLD,REQ(3),IERR)            ! 发送下边界
      CALL MPI_Isend(U(1,JEND),   1, HTYPE, MYUPPER, NT+100,
     &               MPI_COMM_WORLD,REQ(4),IERR)            ! 发送上边界
      CALL MPI_Irecv(U(IEND+1,1), 1, VTYPE, MYRIGHT, NT+100,
     &               MPI_COMM_WORLD, REQ(5),IERR)           ! 接收右边界
      CALL MPI_Irecv(U(0,1),      1, VTYPE, MYLEFT,  NT+100,
     &               MPI_COMM_WORLD, REQ(6),IERR)           ! 接收左边界
      CALL MPI_Irecv(U(1,JEND+1), 1, HTYPE, MYUPPER, NT+100,
     &               MPI_COMM_WORLD, REQ(7),IERR)           ! 接收上边界
      CALL MPI_Irecv(U(1,0),      1, HTYPE, MYLOWER, NT+100,
     &               MPI_COMM_WORLD, REQ(8),IERR)           ! 接收下边界
      CALL MPI_Waitall(8,REQ,STATUS,IERR)     ! 阻塞式等待消息传递的结束
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
