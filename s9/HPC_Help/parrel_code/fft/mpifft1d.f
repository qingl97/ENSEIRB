***********************************************************************
* This is a subroutine for FFT transform program                      *
* Made by Dr. Xue-bin Chi                                             *
* Date: Sept. 12, 2005                                                *
* Supercomputing Center                                               *
* Computer Network Information Center, CAS                            *
*                                                                     *
* Deal with the length N=2**m.                                        *
* x is an input array for FFT                                         *
* y is an output array for FFT                                        *
* iwork is a working space at least having the length of              *
*        2**(q+q) + 2**q + 2**(m-2*q)                                 *
* work is an working space for saving exp(-2pijk/N) & as a temporary  *
* space for data transfer having at least 2**m+2**(m-q)-1             *
***********************************************************************
      subroutine mpifft1d( m, q, comm, iam, x, y, iwork, work, f )
      include 'mpif.h'

      integer m, q, comm, iam, iwork(*), f
      complex*16 x(*), y(*), work(*)
      integer n, p, ibr, imap, ipb, cmpl16, ierr, brdt, nsr,
     &        cnt, lng, str, mst, s, i, tw, stat(mpi_status_size),
     &        it, iw, l, j, k, n1, n2, siw, js, ks
      complex*16 w

      tw = 2**m
      p = 2**q
      s = 2**(m-q)
      call zcopy( s, x, 1, y, 1 )
      imap = 1
      ipb = imap + p*p
      ibr = ipb + p
      call mapping( q, iwork(imap), p )		!\label{mpifft1d:l33}
      call bitreverse( q, iwork(ipb) )
      call bitreverse( m-2*q, iwork(ibr) )
      call oneroots( m, work, f )

      lng = 1
      str = p
      cnt = 2**(m-2*q)
*data exchange among innerprocessor
      do 20 j=0, cnt-1				!\label{mpifft1d:l42}
        k = iwork(ibr+j)
        if ( k .gt. j ) then
          js = j*str
          ks = k*str
          do 10 i=1, p
            w = y(js+i)
            y(js+i) = y(ks+i)
            y(ks+i) = w
 10       continue
        endif
 20   continue					!\label{mpifft1d:l53}
      call mpi_type_contiguous( 2, mpi_double_precision, cmpl16, ierr )	!\label{mpifft1d:l54}
      call mpi_type_commit( cmpl16, ierr )
* bit reverse order data type
      call mpi_type_vector( cnt, lng, str, cmpl16, brdt, ierr )
      call mpi_type_commit( brdt, ierr )	!\label{mpifft1d:l58}
      ibr = 1 + iam*p
* data communication among processors
      do 50 i=1, p-1				!\label{mpifft1d:l61}
        nsr = iwork(ibr+i)
        mst = iwork(ipb+nsr)+1
        call zcopy( cnt, y(mst), str, work(tw), 1 )
        if ( iam .lt. nsr ) then
          call mpi_send(work(tw), cnt, cmpl16, nsr, 1, comm, ierr )
          call mpi_recv(y(mst), 1, brdt, nsr, 1, comm, stat, ierr )
        else
          call mpi_recv(y(mst), 1, brdt, nsr, 1, comm, stat, ierr )
          call mpi_send(work(tw), cnt, cmpl16, nsr, 1, comm, ierr )
        endif
 50   continue					!\label{mpifft1d:l72}

      it = s / 2
      n = 1
      iw = 0

      do 100 j=1, m-q				!\label{mpifft1d:l78}
        l = 0
        do 90 k=1, it
          do 80 i=1, n
            w = work(iw+i)*y(l+n+i)
            y(l+n+i) = y(l+i) - w
            y(l+i) = y(l+i) + w
 80       continue
          l = l + 2*n
 90     continue
        iw = iw + n
        n = 2*n
        it = it / 2
100   continue					!\label{mpifft1d:l91}

      n1 = 1
      do 110 j=1, q				!\label{mpifft1d:l94}
        n2 = n1*2
        k = mod( iam, n2 )
        if ( k .lt. n1 ) then
          nsr = iam + n1
          siw = k*s
          call mpi_recv( work(tw), s, cmpl16, nsr, 1, comm, stat, ierr )
          call mpi_send( y, s, cmpl16, nsr, 1, comm, ierr )
          do 103 i=1, s
            y(i) = y(i) + work(iw+siw+i)*work(tw+i-1)
103       continue
        else
          k = k - n1
          nsr = iam - n1
          siw = k*s
          call zcopy( s, y, 1, work(tw), 1 )
          call mpi_send( work(tw), s, cmpl16, nsr, 1, comm, ierr )
          call mpi_recv( y, s, cmpl16, nsr, 1, comm, stat, ierr )
          do 107 i=1, s
            y(i) = y(i) - work(iw+siw+i)*work(tw+i-1)
107       continue
        endif
        iw = iw + n
        n = 2*n
        n1 = n2
110   continue					!\label{mpifft1d:l119}

      call mpi_type_free( brdt, ierr )
      call mpi_type_free( cmpl16, ierr )

      if ( f .eq. -1 ) then
        n = tw
        w = 1.0/n
        do 120 i=1, s
          y(i)=w*y(i)
120     continue
      endif

      return
      end
