m4_define({m4_inner_most_dodepth}, 3)
m4_ifdef( {ni}, {}, {m4_define({ni},1)})
m4_ifdef( {nj}, {}, {m4_define({nj},1)})
m4_ifdef( {nk}, {}, {m4_define({nk},1)})

      PARAMETER(N=1024)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(N,N), B(N,N), C(N,N)
*
      DO J = 1, N
         DO I = 1, N
            A(I,J) = 1.D0
            B(I,J) = 1.D0
            C(I,J) = 0.D0
         ENDDO
      ENDDO
*
      m4_local(T, J, K)
      m4_do(J, 1, N, 1, nj, {
         m4_do(K, 1, N, 1, nk, {
            m4_expand(J, K, {T = B(K,J)})
            m4_do(I, 1, N, 1, ni, {
               m4_expand(J, I, {
                  C(I,J) = C(I,J) m4_expand(K, {&+ A(I,K)*T})
               })
            })
         })
      })
      m4_undefine({T})
*
      STOP
      END
