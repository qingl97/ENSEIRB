      PROGRAM TEST
* .. Scalar Arguments ..
      INTEGER INFO, LDA, LDB, N, NRHS
      PARAMETER ( N = 500, NRHS = 20, LDA = N, LDB = N ) 
* .. Array Arguments ..
      INTEGER IPIV( N )
      DOUBLE PRECISION A( LDA, N ), B( LDB, NRHS )
* .. External Subroutines ..
      EXTERNAL DGETRF, DGETRS
* .. Intrinsic Functions ..
      INTRINSIC MAX

* .. Executable Statements ..
*     Get the value of matrix
*     Matrix values are $L=\min(i,j)$, $A_{ij}=\sum_{1\le k\le L}(i+j)$
      CALL INITMTRA(N, N, A, LDA)
* Compute the LU factorization of A.
      CALL DGETRF( N, N, A, LDA, IPIV, INFO )
      IF( INFO.EQ.0 ) THEN
*        Generate the right hand side of linear equations
*        Matrix values are $L=\min(i,j)$, $B_{ij}=\sum_{1\le k\le L}(1+j)/(i+k)$
         CALL INITMTRB(N, NRHS, B, LDB)
*        Solve the system A*X = B, overwriting B with X.
         CALL DGETRS( 'No transpose', N, NRHS, A, LDA, IPIV, B, LDB,
     &                INFO )
      END IF
      STOP
      END

*********************************************************************
* 初始化矩阵的子程序
*********************************************************************

      SUBROUTINE INITMTRA( M, N, A, LDA )
* ..Scalar Arguments..
      INTEGER M, N, LDA
* ..Array Arguments..
      DOUBLE PRECISION A(LDA,*)
* ..Intrinsic Funtions..
      INTRINSIC MIN
* ..Local Arguments..
      INTEGER I, J, K

      DO 30 J = 1, N
      DO 20 I = 1, M
         A(I,J) = 0.0
         DO 10 K = 1, MIN(I,J)
            A(I,J) = A(I,J) + I + J
   10    CONTINUE
   20 CONTINUE
   30 CONTINUE
      RETURN
      END

*********************************************************************

      SUBROUTINE INITMTRB( M, N, B, LDB )
* ..Scalar Arguments..
      INTEGER M, N, LDB
* ..Array Arguments..
      DOUBLE PRECISION B(LDB,*)
* ..Intrinsic Funtions..
      INTRINSIC MIN
* ..Local Arguments..
      INTEGER I, J, K

      DO 30 J = 1, N
      DO 20 I = 1, M
         B(I,J) = 0.0
         DO 10 K = 1, MIN(I,J)
            B(I,J) = B(I,J) + (1 + J) / (I + K)
   10    CONTINUE
   20 CONTINUE
   30 CONTINUE
      RETURN
      END
