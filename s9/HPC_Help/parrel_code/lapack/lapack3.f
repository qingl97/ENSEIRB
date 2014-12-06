      PROGRAM TESTBRD
* .. Scalar Arguments ..
      INTEGER ILO, IHI, INFO, LDA, LWORK, N
      PARAMETER ( N = 500, LDA = N, ILO = 1, IHI = N, LWORK = N*256 )
* .. Array Arguments ..
      DOUBLE PRECISION A( LDA, N ), TAU (N-1), WORK(LWORK)
* .. External Subroutines ..
      EXTERNAL DGEHRD

* .. Executable Statements ..
* Get the value of matrix A
      CALL INITMTRA(M, N, A, LDA)
* Reduce to upper Hessenberg form
      CALL DGEHRD(N, ILO, IHI, A, LDA, TAU, WORK, LWORK, INFO)
      STOP
      END

*********************************************************************
* 初始化矩阵的子程序 (同 QR 分解，略)
*********************************************************************\label{lapack3:end}
      SUBROUTINE INITMTRA(M, N, A, LDA)
* ..Scalar Arguments..
      INTEGER M, N, LDA
      DOUBLE PRECISION ZERO, THR, FOUR, FIVE
      PARAMETER( ZERO = 0.0D0, THR = 3.0D0, FOUR = 4.0D0, FIVE = 5.0D0 )
* ..Array Arguments..
      DOUBLE PRECISION A(LDA, *)
* ..Local Arguments..
      INTEGER I, J

      DO 20 J=1, N
      DO 10 I=1, M
         IF( I .EQ. J .AND. I .EQ. 1 )THEN
            A(I, J) = FOUR
         ELSE IF( I .EQ. J .AND. I .NE. 1 ) THEN
            A(I, J) = FIVE
         ELSE IF( I .EQ. J+1 ) THEN
            A(I, J) = THR
         ELSE
            A(I, J) = ZERO
         END IF
   10 CONTINUE
   20 CONTINUE
      RETURN
      END
