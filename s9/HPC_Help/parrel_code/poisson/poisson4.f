! Poisson �������Ľ���: ���� MPI I/O ����������ƽ⡣����: Ī��Ң
      INCLUDE  'mpif.h'
      PARAMETER(DW=2.0, DH=3.0)  ! ������������� X��Y ����Ĵ�С
      PARAMETER(IM=30, JM=60)    ! �� X��Y �����ȫ�������ģ
      PARAMETER(NPX=1,  NPY=1)   ! �� X��Y ����Ľ��̸���
      PARAMETER(IML=IM/NPX, JML=JM/NPY)
         ! �������� X��Y ����ľֲ������ģ, ��Ϊȫ�������ģ�� 1/(NPX*NPY)
      REAL  U(0:IML+1, 0:JML+1)  ! ������������Ľ��ƽ�
      REAL  US(0:IML+1, 0:JML+1) ! ������������ľ�ȷ��
      REAL  U0(IML, JML)         ! Jacobi ������������
      REAL  F(IML, JML)          ! ����$f(x,y)$���������ϵ�ֵ
      INTEGER  NPROC             ! mpirun �����Ľ��̸���, ������� NPX*NPY
      INTEGER  MYRANK,MYLEFT,MYRIGHT,MYUPPER,MYLOWER
                                 ! ����������Ľ��̺�, 4 �����ڽ��̵Ľ��̺�
      INTEGER  MEPX,MEPY         ! ����������Ľ��̺��� X��Y ���������
      REAL  XST,YST              ! ������ӵ�е��������� X��Y �������ʼ����
      REAL  HX, HY               ! �� X��Y �����������ɢ����
      REAL  HX2,HY2,HXY2,RHXY
      INTEGER  IST,IEND,JST,JEND
                      ! �������� X��Y ������ڲ����������ʼ����ֹ����
      INTEGER  HTYPE, VTYPE
                      ! MPI �û��Զ�����������, ��ʾ�������� X��Y ����
                      ! �����ڽ��̽��������ݵ�Ԫ
      INTEGER  REQ(8), STATUS(MPI_STATUS_SIZE,8)
      DOUBLE PRECISION T0, T1
      INTEGER COMM, DIMS(2),COORD(2)
      LOGICAL PERIOD(2),REORDER
      INTEGER FH, FILETYPE, MEMTYPE, GSIZE(2), LSIZE(2), START(2)
! ע��: ������������ʽ�ı��������и�����ʹ�õ� MPI ϵͳѡ��һ����ȷ��
! (���Բο��ļ� mpiof.h �� mpif.h �� MPI_OFFSET_KIND �Ķ���)
!     INTEGER(kind=MPI_OFFSET_KIND) OFFSET    ! ������ Fortran 90
      INTEGER*8 OFFSET                        ! ������ 64 λϵͳ
!     INTEGER*4 OFFSET                        ! ������ĳЩ 32 λϵͳ
! In-line functions
      solution(x,y)=x**2+y**2    ! ������
      rhs(x,y)=-4.0              ! Poisson ����Դ�� (�Ҷ���)
! �����ִ����俪ʼ
      CALL MPI_Init(IERR)
      CALL MPI_Comm_size(MPI_COMM_WORLD,NPROC,IERR)
      IF (NPROC.NE.NPX*NPY.OR.MOD(IM,NPX).NE.0.OR.MOD(JM,NPY).NE.0) THEN
         PRINT *, '+++ mpirun -np xxx error OR grid scale error, ',
     &            'exit out +++'
         CALL MPI_Finalize(IERR)
         STOP
      ENDIF
! �������˽ṹ
      DIMS(1)=NPY            ! ���˽ṹ�� Y ����Ľ��̸���
      DIMS(2)=NPX            ! ���˽ṹ�� X ����Ľ��̸���
      PERIOD(1)=.FALSE.      ! �� Y ����, ���˽ṹ����������
      PERIOD(2)=.FALSE.      ! �� X ����, ���˽ṹ����������
      REORDER=.TRUE.         ! ����ͨ������, ���������������
      CALL MPI_Cart_create(MPI_COMM_WORLD, 2, DIMS, PERIOD, REORDER,
     &                     COMM, IERR)
      CALL MPI_Comm_rank(COMM,MYRANK,IERR)
      CALL MPI_Cart_coords(COMM,MYRANK,2,COORD,IERR)
      MEPY=COORD(1)
      MEPX=COORD(2)
      CALL MPI_Cart_shift(COMM, 0, 1, MYLOWER, MYUPPER, IERR)   ! Y ����
      CALL MPI_Cart_shift(COMM, 1, 1, MYLEFT,  MYRIGHT, IERR)   ! X ����
! ����������ֵ, ȷ�������̸����������
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
      IF (MEPX.EQ.NPX-1) IEND=IEND-1   ! ���ұߵ����� X ������һ����
      JST=1
      JEND=JML
      IF (MEPY.EQ.NPY-1) JEND=JEND-1   ! ���ϱߵ����� Y ������һ����
! �������Ͷ���
      CALL MPI_Type_contiguous(IEND-IST+1, MPI_REAL, HTYPE, IERR)
      CALL MPI_Type_commit(HTYPE, IERR)
                 ! �� X ��������� IEND-IST+1 �� MPI_REAL ���ݵ�Ԫ,
                 ! �����ڱ�ʾ�ý��������ϡ��½��̽��������ݵ�Ԫ
      CALL MPI_Type_vector(JEND-JST+1, 1, IML+2, MPI_REAL, VTYPE, IERR)
      CALL MPI_Type_commit(VTYPE, IERR)
                 ! �� Y ��������� JEND-JST+1 �� MPI_REAL ���ݵ�Ԫ,
                 ! �����ڱ�ʾ�ý����������ҽ��̽��������ݵ�Ԫ
! ��ʼ��
      DO J=JST-1, JEND+1
      DO I=IST-1, IEND+1
         xx=(I+MEPX*IML)*HX           ! xx=XST+I*HX
         yy=(J+MEPY*JML)*HY           ! yy=YST+J*HY
         IF (I.GE.IST.AND.I.LE.IEND .AND. J.GE.JST.AND.J.LE.JEND) THEN
            U(I,J)  = 0.0             ! ���ƽ⸳��ֵ
            US(I,J) = solution(xx,yy) ! ������
            F(I,J)  = DD*rhs(xx,yy)   ! �Ҷ���
         ELSE IF ((I.EQ.IST-1  .AND. MEPX.EQ.0) .OR. 
     &            (J.EQ.JST-1  .AND. MEPY.EQ.0) .OR.
     &            (I.EQ.IEND+1 .AND. MEPX.EQ.NPX-1) .OR.
     &            (J.EQ.JEND+1 .AND. MEPY.EQ.NPY-1)) THEN
            U(I,J) = solution(xx,yy)  ! �߽�ֵ
         ENDIF
      ENDDO
      ENDDO
! Jacobi �������
      NITER=0
      T0 = MPI_Wtime()
100   CONTINUE
      NITER=NITER+1
! �������ؽ��������ڸ����������ϵĽ��ƽ�
      CALL MPI_Isend(U(1,1),      1, VTYPE, MYLEFT,  NITER+100,
     &               COMM, REQ(1),IERR)            ! ������߽�
      CALL MPI_Isend(U(IEND,1),   1, VTYPE, MYRIGHT, NITER+100,
     &               COMM, REQ(2),IERR)            ! �����ұ߽�
      CALL MPI_Isend(U(1,1),      1, HTYPE, MYLOWER, NITER+100,
     &               COMM, REQ(3),IERR)            ! �����±߽�
      CALL MPI_Isend(U(1,JEND),   1, HTYPE, MYUPPER, NITER+100,
     &               COMM, REQ(4),IERR)            ! �����ϱ߽�
      CALL MPI_Irecv(U(IEND+1,1), 1, VTYPE, MYRIGHT, NITER+100,
     &               COMM,  REQ(5),IERR)           ! �����ұ߽�
      CALL MPI_Irecv(U(0,1),      1, VTYPE, MYLEFT,  NITER+100,
     &               COMM,  REQ(6),IERR)           ! ������߽�
      CALL MPI_Irecv(U(1,JEND+1), 1, HTYPE, MYUPPER, NITER+100,
     &               COMM,  REQ(7),IERR)           ! �����ϱ߽�
      CALL MPI_Irecv(U(1,0),      1, HTYPE, MYLOWER, NITER+100,
     &               COMM,  REQ(8),IERR)           ! �����±߽�
      DO J=JST+1,JEND-1
      DO I=IST+1,IEND-1
         U0(I,J)=F(I,J)+DX*(U(I,J-1)+U(I,J+1))+DY*(U(I-1,J)+U(I+1,J))
      ENDDO
      ENDDO
      CALL MPI_Waitall(8,REQ,STATUS,IERR)     ! ����ʽ�ȴ���Ϣ���ݵĽ���
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
! �����뾫ȷ�������
      ERR=0.0
      DO J=JST,JEND
      DO I=IST,IEND
         U(I,J)=U0(I,J)
         ERR=MAX(ERR, ABS(U(I,J)-US(I,J))) ! ��$L^\infty$ģ��ʹ�����NP�޹�
      ENDDO
      ENDDO
      ERR0=ERR
      CALL MPI_Allreduce(ERR0,ERR,1,MPI_REAL,MPI_MAX,
     &                   COMM, IERR)
      IF (MYRANK.EQ.0 .AND. MOD(NITER,100).EQ.0) THEN
         PRINT *, 'NITER = ', NITER, ',    ERR = ', ERR
      ENDIF
      IF (ERR.GT.1.E-3)  THEN     ! �������ж�
         GOTO 100                 ! û������, �����´ε���
      ENDIF
      T1 = MPI_Wtime()
      IF (MYRANK.EQ.0) THEN
         PRINT *, ' !!! Successfully converged after ', 
     &            NITER, ' iterations'
         PRINT *, ' !!! error = ', ERR, '   wtime = ', T1 - T0
      ENDIF
! ������ƽ�
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
! ����ֲ���������������
      CALL MPI_Type_create_subarray(2, GSIZE, LSIZE, START,
     &          MPI_ORDER_FORTRAN, MPI_REAL, FILETYPE, IERR)
      CALL MPI_Type_commit(FILETYPE, IERR)
! �򿪶������ļ�
      CALL MPI_File_open(COMM,'result.dat',
     &          MPI_MODE_CREATE + MPI_MODE_WRONLY,
     &          MPI_INFO_NULL, FH, IERR)
      OFFSET=0         ! ע��ʹ����ȷ�ı������� (INTEGER*4 �� INTEGER*8)
                       ! (�ο��ļ� mpif.h �� MPI_OFFSET_KIND �Ķ���)
      CALL MPI_File_set_view(FH, OFFSET, MPI_REAL, FILETYPE,
     &          'native', MPI_INFO_NULL, IERR)
! ������������, �������������ڴ��еķֲ�
      GSIZE(1)=IML+2
      GSIZE(2)=JML+2
      START(1)=1
      IF (MEPX.EQ.0) START(1)=0
      START(2)=1
      IF (MEPY.EQ.0) START(2)=0
      CALL MPI_Type_create_subarray(2, GSIZE, LSIZE, START,
     &          MPI_ORDER_FORTRAN, MPI_REAL, MEMTYPE, IERR)
      CALL MPI_Type_commit(MEMTYPE, IERR)
! ������ƽ� (������߽���)
      CALL MPI_File_write_all(FH, U, 1, MEMTYPE, STATUS, IERR)
      CALL MPI_File_close(FH, IERR)
      CALL MPI_Finalize(IERR)
      END
