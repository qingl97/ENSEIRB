      PARAMETER(N=4000, NB=32)
      REAL A(N,N), B(N,N)
*
      DO J = 1, N
         DO I = 1, N
            A(I,J) = 1.D0
            B(I,J) = 1.D0
         ENDDO
      ENDDO
*
      DO J = 1, N
      DO I = 1, N
         A(I,J) = A(I,J) + B(J,I)
      ENDDO
      ENDDO
*
      STOP
      END
