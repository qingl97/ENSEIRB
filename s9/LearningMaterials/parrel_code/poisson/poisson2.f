! Poisson �������Ľ���: �ص����ּ�����ͨ�š�����: Ī��Ң
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
! ����Ȼ�� (���� X ����, ���� Y ����) ȷ�������������� 4 �����ڽ��̵Ľ��̺�
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
!                      ��Ӧ��ά NPYxNPX Cartesian ����������Ϊ (MEPY,MEPX).
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
     &               MPI_COMM_WORLD,REQ(1),IERR)            ! ������߽�
      CALL MPI_Isend(U(IEND,1),   1, VTYPE, MYRIGHT, NITER+100,
     &               MPI_COMM_WORLD,REQ(2),IERR)            ! �����ұ߽�
      CALL MPI_Isend(U(1,1),      1, HTYPE, MYLOWER, NITER+100,
     &               MPI_COMM_WORLD,REQ(3),IERR)            ! �����±߽�
      CALL MPI_Isend(U(1,JEND),   1, HTYPE, MYUPPER, NITER+100,
     &               MPI_COMM_WORLD,REQ(4),IERR)            ! �����ϱ߽�
      CALL MPI_Irecv(U(IEND+1,1), 1, VTYPE, MYRIGHT, NITER+100,
     &               MPI_COMM_WORLD, REQ(5),IERR)           ! �����ұ߽�
      CALL MPI_Irecv(U(0,1),      1, VTYPE, MYLEFT,  NITER+100,
     &               MPI_COMM_WORLD, REQ(6),IERR)           ! ������߽�
      CALL MPI_Irecv(U(1,JEND+1), 1, HTYPE, MYUPPER, NITER+100,
     &               MPI_COMM_WORLD, REQ(7),IERR)           ! �����ϱ߽�
      CALL MPI_Irecv(U(1,0),      1, HTYPE, MYLOWER, NITER+100,
     &               MPI_COMM_WORLD, REQ(8),IERR)           ! �����±߽�
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
     &                   MPI_COMM_WORLD,IERR)
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
! ������ƽ� (��)
      CALL MPI_Finalize(IERR)
      END
