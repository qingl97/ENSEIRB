      PROGRAM TESTEIG
* .. Scalar Arguments ..
      CHARACTER*1 JOBZ
      INTEGER INFO, LDZ, N, NN
      PARAMETER ( JOBZ = 'V', N = 500, LDZ = N+1, NN = 2*N-2 )
* .. Array Arguments ..
      DOUBLE PRECISION D( N ), E( N ), WORK( NN ), Z( LDZ, N )
* .. Parameters ..
      DOUBLE PRECISION ZERO, ONE
      PARAMETER ( ZERO = 0.0D0, ONE = 1.0D0 )
* .. Local Scalars ..
      LOGICAL WANTZ
      INTEGER IMAX, ISCALE
      DOUBLE PRECISION BIGNUM, EPS, RMAX, RMIN, SAFMIN,
     &                 SIGMA, SMLNUM, TNRM
* .. External Functions ..
      LOGICAL LSAME
      DOUBLE PRECISION DLAMCH, DLANST
      EXTERNAL LSAME, DLAMCH, DLANST
* .. External Subroutines ..
      EXTERNAL DSCAL, DSTEQR, DSTERF
* .. Intrinsic Functions ..
      INTRINSIC SQRT

* .. Executable Statements ..
      WANTZ = LSAME( JOBZ, 'V' )
* Quick return if possible
      IF( N.EQ.0 ) RETURN
      IF( N.EQ.1 ) THEN
         IF( WANTZ ) Z( 1, 1 ) = ONE
         RETURN
      END IF
* Get machine constants.
      SAFMIN = DLAMCH( 'Safe minimum' )
      EPS = DLAMCH( 'Precision' )
      SMLNUM = SAFMIN / EPS
      BIGNUM = ONE / SMLNUM
      RMIN = SQRT( SMLNUM )
      RMAX = SQRT( BIGNUM )
* Get the value of matrix A
      CALL INITMTRA( N, D, E )
* Scale matrix to allowable range, if necessary.
      ISCALE = 0
      TNRM = DLANST( 'M', N, D, E )
      IF( TNRM.GT.ZERO .AND. TNRM.LT.RMIN ) THEN
         ISCALE = 1
         SIGMA = RMIN / TNRM
      ELSE IF( TNRM.GT.RMAX ) THEN
         ISCALE = 1
         SIGMA = RMAX / TNRM
      END IF
      IF( ISCALE.EQ.1 ) THEN
         CALL DSCAL( N, SIGMA, D, 1 )
         CALL DSCAL( N-1, SIGMA, E( 1 ), 1 )
      END IF
* For eigenvalues only, call DSTERF. For eigenvalues and
* eigenvectors, call DSTEQR.
      IF( .NOT.WANTZ ) THEN
         CALL DSTERF( N, D, E, INFO )
      ELSE
         CALL DSTEQR( 'I', N, D, E, Z, LDZ, WORK, INFO )
      END IF
* If matrix was scaled, then rescale eigenvalues appropriately.
      IF( ISCALE.EQ.1 ) THEN
         IF( INFO.EQ.0 ) THEN
            IMAX = N
         ELSE
            IMAX = INFO - 1
         END IF
         CALL DSCAL( IMAX, ONE / SIGMA, D, 1 )
      END IF
      STOP
      END

*********************************************************************
* 初始化矩阵的子程序
*********************************************************************

      SUBROUTINE INITMTRA( N, D, E )
* ..Scalar Arguments..
      INTEGER N
* ..Array Arguments..
      DOUBLE PRECISION D( N ), E( N)
* ..Local Arguments..
      INTEGER I, ONE
      PARAMETER ( ONE = 1 )
* .. Intrinsic Functions ..
      INTRINSIC DBLE

      DO 10 I = ONE, N
         D(I) = DBLE(ONE)/(DBLE(ONE)+I)
   10 CONTINUE
      DO 20 I = ONE, N-1
         E(I) = DBLE(ONE)/(I+J)
   20 CONTINUE
      RETURN
      END
