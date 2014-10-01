! Poisson 方程求解改进四: 利用 MPI I/O 函数输出近似解。作者: 莫则尧
      INCLUDE  'mpif.h'
      PARAMETER(DW=2.0, DH=3.0)  ! 问题求解区域沿 X、Y 方向的大小
      PARAMETER(IM=30, JM=60)    ! 沿 X、Y 方向的全局网格规模
      PARAMETER(NPX=1,  NPY=1)   ! 沿 X、Y 方向的进程个数
      PARAMETER(IML=IM/NPX, JML=JM/NPY)
         ! 各进程沿 X、Y 方向的局部网格规模, 仅为全局网格规模的 1/(NPX*NPY)
      REAL  U(0:IML+1, 0:JML+1)  ! 定义在网格结点的近似解
      REAL  US(0:IML+1, 0:JML+1) ! 定义在网格结点的精确解
      REAL  U0(IML, JML)         ! Jacobi 迭代辅助变量
      REAL  F(IML, JML)          ! 函数$f(x,y)$在网格结点上的值
      INTEGER  NPROC             ! mpirun 启动的进程个数, 必须等于 NPX*NPY
      INTEGER  MYRANK,MYLEFT,MYRIGHT,MYUPPER,MYLOWER
                                 ! 各进程自身的进程号, 4 个相邻进程的进程号
      INTEGER  MEPX,MEPY         ! 各进程自身的进程号沿 X、Y 方向的坐标
      REAL  XST,YST              ! 各进程拥有的子区域沿 X、Y 方向的起始坐标
      REAL  HX, HY               ! 沿 X、Y 方向的网格离散步长
      REAL  HX2,HY2,HXY2,RHXY
      INTEGER  IST,IEND,JST,JEND
                      ! 各进程沿 X、Y 方向的内部网格结点的起始和终止坐标
      INTEGER  HTYPE, VTYPE
                      ! MPI 用户自定义数据类型, 表示各进程沿 X、Y 方向
                      ! 与相邻进程交换的数据单元
      INTEGER  REQ(8), STATUS(MPI_STATUS_SIZE,8)
      DOUBLE PRECISION T0, T1
      INTEGER COMM, DIMS(2),COORD(2)
      LOGICAL PERIOD(2),REORDER
      INTEGER FH, FILETYPE, MEMTYPE, GSIZE(2), LSIZE(2), START(2)
! 注意: 从下面三种形式的变量声明中根据所使用的 MPI 系统选择一个正确的
! (可以参考文件 mpiof.h 或 mpif.h 中 MPI_OFFSET_KIND 的定义)
!     INTEGER(kind=MPI_OFFSET_KIND) OFFSET    ! 适用于 Fortran 90
      INTEGER*8 OFFSET                        ! 适用于 64 位系统
!     INTEGER*4 OFFSET                        ! 适用于某些 32 位系统
! In-line functions
      solution(x,y)=x**2+y**2    ! 解析解
      rhs(x,y)=-4.0              ! Poisson 方程源项 (右端项)
! 程序可执行语句开始
      CALL MPI_Init(IERR)
      CALL MPI_Comm_size(MPI_COMM_WORLD,NPROC,IERR)
      IF (NPROC.NE.NPX*NPY.OR.MOD(IM,NPX).NE.0.OR.MOD(JM,NPY).NE.0) THEN
         PRINT *, '+++ mpirun -np xxx error OR grid scale error, ',
     &            'exit out +++'
         CALL MPI_Finalize(IERR)
         STOP
      ENDIF
! 定义拓扑结构
      DIMS(1)=NPY            ! 拓扑结构中 Y 方向的进程个数
      DIMS(2)=NPX            ! 拓扑结构中 X 方向的进程个数
      PERIOD(1)=.FALSE.      ! 沿 Y 方向, 拓扑结构非周期连接
      PERIOD(2)=.FALSE.      ! 沿 X 方向, 拓扑结构非周期连接
      REORDER=.TRUE.         ! 在新通信器中, 允许进程重新排序
      CALL MPI_Cart_create(MPI_COMM_WORLD, 2, DIMS, PERIOD, REORDER,
     &                     COMM, IERR)
      CALL MPI_Comm_rank(COMM,MYRANK,IERR)
      CALL MPI_Cart_coords(COMM,MYRANK,2,COORD,IERR)
      MEPY=COORD(1)
      MEPX=COORD(2)
      CALL MPI_Cart_shift(COMM, 0, 1, MYLOWER, MYUPPER, IERR)   ! Y 方向
      CALL MPI_Cart_shift(COMM, 1, 1, MYLEFT,  MYRIGHT, IERR)   ! X 方向
! 基本变量赋值, 确定各进程负责的子区域
      HX =DW/IM
      HX2=HX*HX
      HY =DH/JM
      HY2=HY*HY
      HXY2=HX2*HY2
      RHXY=0.5/(HX2+HY2)
      DX=HX2*RHXY
      DY=HY2*RHXY
      DD=RHXY*HXY2
      XST=MEPX*DW/NPX
      YST=MEPY*DH/NPY
      IST=1
      IEND=IML
      IF (MEPX.EQ.NPX-1) IEND=IEND-1   ! 最右边的区域 X 方向少一个点
      JST=1
      JEND=JML
      IF (MEPY.EQ.NPY-1) JEND=JEND-1   ! 最上边的区域 Y 方向少一个点
! 数据类型定义
      CALL MPI_Type_contiguous(IEND-IST+1, MPI_REAL, HTYPE, IERR)
      CALL MPI_Type_commit(HTYPE, IERR)
                 ! 沿 X 方向的连续 IEND-IST+1 个 MPI_REAL 数据单元,
                 ! 可用于表示该进程与其上、下进程交换的数据单元
      CALL MPI_Type_vector(JEND-JST+1, 1, IML+2, MPI_REAL, VTYPE, IERR)
      CALL MPI_Type_commit(VTYPE, IERR)
                 ! 沿 Y 方向的连续 JEND-JST+1 个 MPI_REAL 数据单元,
                 ! 可用于表示该进程与其左、右进程交换的数据单元
! 初始化
      DO J=JST-1, JEND+1
      DO I=IST-1, IEND+1
         xx=(I+MEPX*IML)*HX           ! xx=XST+I*HX
         yy=(J+MEPY*JML)*HY           ! yy=YST+J*HY
         IF (I.GE.IST.AND.I.LE.IEND .AND. J.GE.JST.AND.J.LE.JEND) THEN
            U(I,J)  = 0.0             ! 近似解赋初值
            US(I,J) = solution(xx,yy) ! 解析解
            F(I,J)  = DD*rhs(xx,yy)   ! 右端项
         ELSE IF ((I.EQ.IST-1  .AND. MEPX.EQ.0) .OR. 
     &            (J.EQ.JST-1  .AND. MEPY.EQ.0) .OR.
     &            (I.EQ.IEND+1 .AND. MEPX.EQ.NPX-1) .OR.
     &            (J.EQ.JEND+1 .AND. MEPY.EQ.NPY-1)) THEN
            U(I,J) = solution(xx,yy)  ! 边界值
         ENDIF
      ENDDO
      ENDDO
! Jacobi 迭代求解
      NITER=0
      T0 = MPI_Wtime()
100   CONTINUE
      NITER=NITER+1
! 非阻塞地交换定义在辅助网格结点上的近似解
      CALL MPI_Isend(U(1,1),      1, VTYPE, MYLEFT,  NITER+100,
     &               COMM, REQ(1),IERR)            ! 发送左边界
      CALL MPI_Isend(U(IEND,1),   1, VTYPE, MYRIGHT, NITER+100,
     &               COMM, REQ(2),IERR)            ! 发送右边界
      CALL MPI_Isend(U(1,1),      1, HTYPE, MYLOWER, NITER+100,
     &               COMM, REQ(3),IERR)            ! 发送下边界
      CALL MPI_Isend(U(1,JEND),   1, HTYPE, MYUPPER, NITER+100,
     &               COMM, REQ(4),IERR)            ! 发送上边界
      CALL MPI_Irecv(U(IEND+1,1), 1, VTYPE, MYRIGHT, NITER+100,
     &               COMM,  REQ(5),IERR)           ! 接收右边界
      CALL MPI_Irecv(U(0,1),      1, VTYPE, MYLEFT,  NITER+100,
     &               COMM,  REQ(6),IERR)           ! 接收左边界
      CALL MPI_Irecv(U(1,JEND+1), 1, HTYPE, MYUPPER, NITER+100,
     &               COMM,  REQ(7),IERR)           ! 接收上边界
      CALL MPI_Irecv(U(1,0),      1, HTYPE, MYLOWER, NITER+100,
     &               COMM,  REQ(8),IERR)           ! 接收下边界
      DO J=JST+1,JEND-1
      DO I=IST+1,IEND-1
         U0(I,J)=F(I,J)+DX*(U(I,J-1)+U(I,J+1))+DY*(U(I-1,J)+U(I+1,J))
      ENDDO
      ENDDO
      CALL MPI_Waitall(8,REQ,STATUS,IERR)     ! 阻塞式等待消息传递的结束
      DO J=JST, JEND, JEND-JST
      DO I=IST, IEND
         U0(I,J)=F(I,J)+DX*(U(I,J-1)+U(I,J+1))+DY*(U(I-1,J)+U(I+1,J))
      ENDDO
      ENDDO
      DO J=JST, JEND
      DO I=IST, IEND, IEND-IST
         U0(I,J)=F(I,J)+DX*(U(I,J-1)+U(I,J+1))+DY*(U(I-1,J)+U(I+1,J))
      ENDDO
      ENDDO
! 计算与精确解间的误差
      ERR=0.0
      DO J=JST,JEND
      DO I=IST,IEND
         U(I,J)=U0(I,J)
         ERR=MAX(ERR, ABS(U(I,J)-US(I,J))) ! 用$L^\infty$模以使误差与NP无关
      ENDDO
      ENDDO
      ERR0=ERR
      CALL MPI_Allreduce(ERR0,ERR,1,MPI_REAL,MPI_MAX,
     &                   COMM, IERR)
      IF (MYRANK.EQ.0 .AND. MOD(NITER,100).EQ.0) THEN
         PRINT *, 'NITER = ', NITER, ',    ERR = ', ERR
      ENDIF
      IF (ERR.GT.1.E-3)  THEN     ! 收敛性判断
         GOTO 100                 ! 没有收敛, 进入下次迭代
      ENDIF
      T1 = MPI_Wtime()
      IF (MYRANK.EQ.0) THEN
         PRINT *, ' !!! Successfully converged after ', 
     &            NITER, ' iterations'
         PRINT *, ' !!! error = ', ERR, '   wtime = ', T1 - T0
      ENDIF
! 输出近似解
      GSIZE(1)=IM+1
      GSIZE(2)=JM+1
      LSIZE(1)=IEND-IST+1
      IF (MEPX.EQ.0) LSIZE(1)=LSIZE(1)+1
      IF (MEPX.EQ.NPX-1) LSIZE(1)=LSIZE(1)+1
      LSIZE(2)=JEND-JST+1
      IF (MEPY.EQ.0) LSIZE(2)=LSIZE(2)+1
      IF (MEPY.EQ.NPY-1) LSIZE(2)=LSIZE(2)+1
      START(1)=IML*MEPX
      IF (MEPX.NE.0) START(1)=START(1)+1
      START(2)=JML*MEPY
      IF (MEPY.NE.0) START(2)=START(2)+1
! 定义局部子数组数据类型
      CALL MPI_Type_create_subarray(2, GSIZE, LSIZE, START,
     &          MPI_ORDER_FORTRAN, MPI_REAL, FILETYPE, IERR)
      CALL MPI_Type_commit(FILETYPE, IERR)
! 打开二进制文件
      CALL MPI_File_open(COMM,'result.dat',
     &          MPI_MODE_CREATE + MPI_MODE_WRONLY,
     &          MPI_INFO_NULL, FH, IERR)
      OFFSET=0         ! 注意使用正确的变量类型 (INTEGER*4 或 INTEGER*8)
                       ! (参考文件 mpif.h 中 MPI_OFFSET_KIND 的定义)
      CALL MPI_File_set_view(FH, OFFSET, MPI_REAL, FILETYPE,
     &          'native', MPI_INFO_NULL, IERR)
! 定义数据类型, 描述子数组在内存中的分布
      GSIZE(1)=IML+2
      GSIZE(2)=JML+2
      START(1)=1
      IF (MEPX.EQ.0) START(1)=0
      START(2)=1
      IF (MEPY.EQ.0) START(2)=0
      CALL MPI_Type_create_subarray(2, GSIZE, LSIZE, START,
     &          MPI_ORDER_FORTRAN, MPI_REAL, MEMTYPE, IERR)
      CALL MPI_Type_commit(MEMTYPE, IERR)
! 输出近似解 (含物理边界结点)
      CALL MPI_File_write_all(FH, U, 1, MEMTYPE, STATUS, IERR)
      CALL MPI_File_close(FH, IERR)
      CALL MPI_Finalize(IERR)
      END
