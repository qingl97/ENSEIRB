      PARAMETER(N=1024)
      REAL*8 A(N,N), B(N,N), C(N,N)
*
      DO J = 1, N
         DO I = 1, N
            A(I,J) = 1.D0
            B(I,J) = 1.D0
            C(I,J) = 0.D0
         ENDDO
      ENDDO
*\label{AxB.f:loop}
      DO J = 1, N
      DO K = 1, N
      DO I = 1, N
         C(I,J) = C(I,J) + A(I,K) * B(K,J)
      ENDDO
      ENDDO
      ENDDO
*\label{AxB.f:endloop}
      STOP
      END
