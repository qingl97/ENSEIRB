! ��ά�ȴ������̣���ʽŷ����ʽ (����Ī��Ң�� poisson1.f)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE  'mpif.h'
      PARAMETER(DW=2.D0,DH=3.D0)  ! ������������� X��Y ����Ĵ�С
      PARAMETER(DT=.0008D0)	  ! ʱ�䲽����Ҫ�����㣺$\Delta t(1/h_x^2+1/h_y^2)<1/2$
      PARAMETER(IM=30, JM=60)     ! �� X��Y �����ȫ�������ģ
      PARAMETER(NPX=1, NPY=1)     ! �� X��Y ����Ľ��̸���
      PARAMETER(IML=IM/NPX, JML=JM/NPY)
	! �������� X��Y ����ľֲ������ģ, ��Ϊȫ�������ģ�� 1/(NPX*NPY)
      DIMENSION U (0:IML+1,0:JML+1) ! ��ǰʱ���Ľ��ƽ�
      DIMENSION U0(0:IML+1,0:JML+1) ! ǰһʱ���Ľ��ƽ�
      DOUBLE PRECISION KX, KY     ! $\Delta t/h_x^2$��$\Delta t/h_y^2$
      DOUBLE PRECISION T0, T1     ! ����ͳ������ʱ��
      INTEGER  NPROC              ! mpirun �����Ľ��̸���, ������� NPX*NPY
      INTEGER  MYRANK, MYLEFT, MYRIGHT, MYUPPER, MYLOWER
                                  ! ����������Ľ��̺�, 4 �����ڽ��̵Ľ��̺�
      INTEGER  MEPX,MEPY          ! ����������Ľ��̺��� X��Y ���������
      INTEGER  IST,IEND,JST,JEND
                      ! �������� X��Y ������ڲ����������ʼ����ֹ����
      INTEGER  HTYPE, VTYPE
                      ! MPI �û��Զ�����������, ��ʾ�������� X��Y ����
                      ! �����ڽ��̽��������ݵ�Ԫ
      INTEGER  REQ(8), STATUS(MPI_STATUS_SIZE,8)
! Constants
      DATA TWO/2.D0/, ZERO/0.D0/
! In-line functions
      solution(x,y,t) = EXP(-t-t)*SIN(x)*COS(y) ! �����⣺$e^{-2t}\sin x\cos y$
! �����ִ����俪ʼ
      CALL MPI_Init(IERR)
      CALL MPI_Comm_size(MPI_COMM_WORLD,NPROC,IERR)
      IF (NPROC.NE.NPX*NPY.OR.MOD(IM,NPX).NE.0.OR.MOD(JM,NPY).NE.0) THEN
         PRINT *, '+++ Incorrect parameters, abort +++'
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
! ����������ֵ, ȷ�������̸����������
      HX = DW/IM		! X �������񲽳�$h_x$
      KX = DT/(HX*HX)           ! $\Delta t/h_x^2$
      HY = DH/JM		! Y �������񲽳�$h_y$
      KY = DT/(HY*HY)		! $\Delta t/h_y^2$
! �������������ķ�Χ
      IST=1
      IEND=IML
      IF (MEPX.EQ.NPX-1) IEND=IEND-1   ! ���ұߵ����� X ������һ����
      JST=1
      JEND=JML
      IF (MEPY.EQ.NPY-1) JEND=JEND-1   ! ���ϱߵ����� Y ������һ����
! ��ʼ����
      DO J=JST-1, JEND+1
         yy=(J+MEPY*JML)*HY
         DO I=IST-1, IEND+1
            xx=(I+MEPX*IML)*HX
            U(I,J)=solution(xx,yy,ZERO) ! ��ʼ��
         ENDDO
      ENDDO
! �������Ͷ���
      CALL MPI_Type_contiguous(IEND-IST+1, MPI_DOUBLE_PRECISION,
     &                         HTYPE, IERR)
      CALL MPI_Type_commit(HTYPE, IERR)
                 ! �� X ��������� IEND-IST+1 �� MPI_DOUBLE_PRECISION ���ݵ�Ԫ,
                 ! �����ڱ�ʾ�ý��������ϡ��½��̽��������ݵ�Ԫ
      CALL MPI_Type_vector(JEND-JST+1, 1, IML+2, MPI_DOUBLE_PRECISION,
     &                     VTYPE, IERR)
      CALL MPI_Type_commit(VTYPE, IERR)
                 ! �� Y ��������� JEND-JST+1 �� MPI_DOUBLE_PRECISION ���ݵ�Ԫ,
                 ! �����ڱ�ʾ�ý����������ҽ��̽��������ݵ�Ԫ
! ʱ���ƽ�
      NT=0
      T0 = MPI_Wtime()
100   CONTINUE   ! ��ѭ��
      NT=NT+1
      T=NT*DT
! ���� U -> U0
      DO J=JST-1,JEND+1
      DO I=IST-1,IEND+1
         U0(I,J)=U(I,J)
      ENDDO
      ENDDO
! �߽�����
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
! ��ʽŷ����ʽ�ƽ�
      DO J=JST,JEND
      DO I=IST,IEND
         U(I,J)=U0(I,J)
     &              - KX * (TWO*U0(I,J) - U0(I-1,J) - U0(I+1,J))
     &              - KY * (TWO*U0(I,J) - U0(I,J-1) - U0(I,J+1))
      ENDDO
      ENDDO
! ���������ڸ����������ϵĽ��ƽ�
      CALL MPI_Isend(U(1,1),      1, VTYPE, MYLEFT,  NT+100,
     &               MPI_COMM_WORLD,REQ(1),IERR)            ! ������߽�
      CALL MPI_Isend(U(IEND,1),   1, VTYPE, MYRIGHT, NT+100,
     &               MPI_COMM_WORLD,REQ(2),IERR)            ! �����ұ߽�
      CALL MPI_Isend(U(1,1),      1, HTYPE, MYLOWER, NT+100,
     &               MPI_COMM_WORLD,REQ(3),IERR)            ! �����±߽�
      CALL MPI_Isend(U(1,JEND),   1, HTYPE, MYUPPER, NT+100,
     &               MPI_COMM_WORLD,REQ(4),IERR)            ! �����ϱ߽�
      CALL MPI_Irecv(U(IEND+1,1), 1, VTYPE, MYRIGHT, NT+100,
     &               MPI_COMM_WORLD, REQ(5),IERR)           ! �����ұ߽�
      CALL MPI_Irecv(U(0,1),      1, VTYPE, MYLEFT,  NT+100,
     &               MPI_COMM_WORLD, REQ(6),IERR)           ! ������߽�
      CALL MPI_Irecv(U(1,JEND+1), 1, HTYPE, MYUPPER, NT+100,
     &               MPI_COMM_WORLD, REQ(7),IERR)           ! �����ϱ߽�
      CALL MPI_Irecv(U(1,0),      1, HTYPE, MYLOWER, NT+100,
     &               MPI_COMM_WORLD, REQ(8),IERR)           ! �����±߽�
      CALL MPI_Waitall(8,REQ,STATUS,IERR)     ! ����ʽ�ȴ���Ϣ���ݵĽ���
      T1 = MPI_Wtime()
      IF (MYRANK.EQ.0) PRINT *, 'T=', T, '   wtime=', T1 - T0
      IF (T.LT.1.0) GOTO 100
! �����뾫ȷ�������
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
