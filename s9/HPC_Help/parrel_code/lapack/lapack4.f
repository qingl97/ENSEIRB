      PROGRAM TESTTRD
* .. Scalar Arguments ..
      CHARACTER*1 UPLO
      INTEGER INFO, LDA, LWORK, N
      PARAMETER ( UPLO = 'U', N = 500, LDA = N, LWORK = N*256 )
* .. Array Arguments ..
      DOUBLE PRECISION A(LDA, N), D(N), E(N-1), TAU(N-1), WORK(LWORK)
* .. External Subroutines ..
      EXTERNAL DSYTRD

* .. Executable Statements ..
* Get the value of matrix A
      CALL INITMTRA(M, N, A, LDA)
* Call DSYTRD to reduce symmetric matrix to tridiagonal form.
      CALL DSYTRD(UPOL, N, A, LDA, D, E, TAU, WORK, LWORK, INFO)
      STOP
      END

*********************************************************************
* 初始化矩阵的子程序 (同 QR 分解，略)
*********************************************************************\label{lapack4:end}
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
