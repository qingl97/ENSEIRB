      PARAMETER(N=2048)
      REAL*8 A(N,N)
      DO K = 1, 100
         DO I = 1, N
         DO J = 1, N
            A(I,J) = 1.D0
         ENDDO
         ENDDO
      ENDDO
      STOP
      END
