***********************************************************************
* This is a subroutine for FFT transform program                      *
* Made by Dr. Xue-bin Chi                                             *
* Date: Aug.18, 2005                                                  *
* Supercomputing Center                                               *
* Computer Network Information Center, CAS                            *
*                                                                     *
* Deal with the length N=2**m.                                        *
* x is an input array for FFT                                         *
* y is an output array for FFT                                        *
* ip is an output array for bit reverse order                         *
* w is an working space for saving exp(-2pijk/N)                      *
***********************************************************************
      subroutine fft1d( m, x, y, w, ip, f )
      integer m, ip(*), f
      complex*16 x(*), y(*), w(*)
      integer n, i, j, k, l, it, iw
      complex*16 s

      call bitreverse( m, ip )		!\label{fft1d:l20}
      n = 2**m
      do 10 i = 1, n
        y(i) = x(ip(i)+1)
 10   continue				!\label{fft1d:l24}

      if ( m .eq. 0 ) then
        return
      endif

      it = n / 2
      n = 1
      iw = 0
      
      call oneroots( m, w, f )		!\label{fft1d:l34}
      do 100 j=1, m
        l = 0
        do 90 k=1, it			!\label{fft1d:l37}
          do 80 i=1, n
            s = w(iw+i)*y(l+n+i)
            y(l+n+i) = y(l+i) - s
            y(l+i) = y(l+i) + s
 80       continue
          l = l + 2*n
 90     continue			!\label{fft1d:l44}
        iw = iw + n
        n = 2*n
        it = it / 2
100   continue

      if ( f .eq. -1 ) then		!\label{fft1d:l50}
        n = 2**m
        s = 1.0/n
        do 120 i=1, n
          y(i)=s*y(i)
120     continue
      endif				!\label{fft1d:l56}

      return
      end
