      PARAMETER(N=4000, NB=80)
      REAL A(N,N), B(N,N)
*
      DO J = 1, N
         DO I = 1, N
            A(I,J) = 1.D0
            B(I,J) = 1.D0
         ENDDO
      ENDDO
*
      DO JJ = 1, N, NB
      DO II = 1, N, NB
         DO J = JJ, MIN(JJ+NB-1,N)
         DO I = II, MIN(II+NB-1,N)
            A(I,J) = A(I,J) + B(J,I)
         ENDDO
         ENDDO
      ENDDO
      ENDDO
*
      STOP
      END
