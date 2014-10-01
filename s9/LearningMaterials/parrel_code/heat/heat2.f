! ��ά�ȴ������̣�Peaceman-Rachford ��ʽ���ֿ���ˮ���㷨
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE  'mpif.h'
      PARAMETER(DW=2.D0, DH=3.D0) ! ������������� X��Y ����Ĵ�С
      PARAMETER(DT=.05D0)         ! ʱ�䲽��
      PARAMETER(IM=50, JM=100)    ! �� X��Y �����ȫ�������ģ
      PARAMETER(NPX=1, NPY=1)     ! �� X��Y ����Ľ��̸���
      PARAMETER(IML=IM/NPX, JML=JM/NPY)
	! �������� X��Y ����ľֲ������ģ, ��Ϊȫ�������ģ�� 1/(NPX*NPY)
      DIMENSION U (0:IML+1,0:JML+1) ! ��ǰʱ���Ľ��ƽ�
      DIMENSION U0(0:IML+1,0:JML+1) ! �м����
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
! ����������Խ����Է�����ı���
      PARAMETER(NBX=50, NBY=50)   ! �ֿ���ˮ�߷����� X��Y ����ֿ��С
      DOUBLE PRECISION LX(0:IML-1),DX(IML),UX(IML) ! �� X ����� LU �ֽ�ϵ��
      DOUBLE PRECISION LY(0:JML-1),DY(JML),UY(JML) ! �� Y ����� LU �ֽ�ϵ��
      INTEGER  LENS(2), DISPS(2), TYPES(2) ! ���ڶ��� VTYPE �ĸ�������
                      ! ע��ĳЩ 64 λ�����Ͽ�����Ҫ�� DISPS ������ INTEGER*8
      INTEGER  STATUS(MPI_STATUS_SIZE)
! Constants
      DATA ONE/1.D0/, TWO/2.D0/, ZERO/0.D0/, HALF/.5D0/
      DATA LENS/1,1/, TYPES/MPI_DOUBLE_PRECISION, MPI_UB/
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
! ��ʼ���� (ע��������Ҫ����ǵ㴦��ֵ)
      DO J=JST-1, JEND+1
         yy=(J+MEPY*JML)*HY
         DO I=IST-1, IEND+1
            xx=(I+MEPX*IML)*HX
            U(I,J)=solution(xx,yy,ZERO) ! ��ʼ��
         ENDDO
      ENDDO
! X �������ԽǾ���� LU �ֽ⣬�����������������Լ���Ҫ���ǲ���ϵ��
! (����ǰ�� MEPX*IML ���������Լ���ϵ��)
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
! Y �������ԽǾ���� LU �ֽ⣬�����������������Լ���Ҫ���ǲ���ϵ��
! (����ǰ�� MEPY*JML ���������Լ���ϵ��)
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
! �������Ͷ���
      HTYPE=MPI_DOUBLE_PRECISION
                 ! HTYPE ���ڷ����� X ����һ�����ϵ�һ������
      DISPS(1) = 0
      CALL MPI_Type_extent(MPI_DOUBLE_PRECISION, DISPS(2), IERR)
      DISPS(2) = DISPS(2) * (IML+2)
      CALL MPI_Type_struct(2, LENS, DISPS, TYPES, VTYPE, IERR)
      CALL MPI_Type_commit(VTYPE, IERR)
                 ! VTYPE ���ڷ����� Y ����һ�����ϵ�һ������
! ʱ���ƽ�
      NT=0
      T0 = MPI_Wtime()
100   CONTINUE   ! ��ѭ��
      NT=NT+1
      T=NT*DT
!---- X ������⣺���� (\ref{heat:eq10a})
      DO J=JST,JEND
      DO I=IST,IEND
         U0(I,J)=TWO*(U(I,J)-KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1)))) ! �Ҷ���
      ENDDO
      ENDDO
!     X ����߽�����
      IF (MEPX.EQ.0) THEN
!        �м��$\tilde{u}^{n+\frac12}$�ı߽�����ǰ�벿�� (������ U0)
         I=IST-1
         DO J=JST,JEND
            U0(I,J)=U(I,J)-KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1)))
         ENDDO
!        $u^{n+1}$�ı߽�����
         xx = ZERO
         DO J=JST-1,JEND+1
            yy=(J+MEPY*JML)*HY
            U(I,J)=solution(xx,yy,T)
         ENDDO
!        �м��$\tilde{u}^{n+\frac12}$�ı߽�������벿��
         DO J=JST,JEND
            U0(I,J)=HALF*(U0(I,J) +
     &                    U(I,J)+KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1))))
         ENDDO
      ENDIF
      IF (MEPX.EQ.NPX-1) THEN
!        �м��$\tilde{u}^{n+\frac12}$�ı߽�����ǰ�벿�� (���� U0 ��)
         I=IEND+1
         DO J=JST,JEND
            U0(I,J)=U(I,J)-KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1)))
         ENDDO
!        $u^{n+1}$�ı߽�����
         xx = DW
         DO J=JST-1,JEND+1
            yy=(J+MEPY*JML)*HY
            U(I,J)=solution(xx,yy,T)
         ENDDO
!        �м��$\tilde{u}^{n+\frac12}$�ı߽�������벿��
         DO J=JST,JEND
            U0(I,J)=HALF*(U0(I,J) +
     &                    U(I,J)+KY*(U(I,J)-HALF*(U(I,J-1)+U(I,J+1))))
         ENDDO
      ENDIF
!     ���������
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
!     ���������
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
!     �� X ���򽻻������ڸ����������ϵĽ��ƽ�
      CALL MPI_Sendrecv(U0(IEND,1), JEND-JST+1, VTYPE, MYRIGHT, 33,
     &                  U0(0,1),    JEND-JST+1, VTYPE, MYLEFT,  33,
     &                  MPI_COMM_WORLD, STATUS, IERR)
!---- Y ������⣺���� (\ref{heat:eq10b})
      DO J=JST,JEND
      DO I=IST,IEND
	 U(I,J)=TWO*(U0(I,J)-KX*(U0(I,J)-HALF*(U0(I-1,J)+U0(I+1,J)))) ! �Ҷ���
      ENDDO
      ENDDO
!     Y ����߽�����
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
!     ���������
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
!     ���������
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
!     �� Y ���򽻻������ڸ����������ϵĽ��ƽ�
      CALL MPI_Sendrecv(U(1,JEND),  IEND-IST+1, HTYPE, MYUPPER, 66,
     &                  U(1,0),     IEND-IST+1, HTYPE, MYLOWER, 66,
     &                  MPI_COMM_WORLD, STATUS, IERR)
! ע���� X �������������ϵĽ��ƽ�û�и��� (��һ��ʱ���ļ��㲻��Ҫ��)
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
