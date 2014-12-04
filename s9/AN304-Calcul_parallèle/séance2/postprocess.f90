program postprocess
!***   nno            : number of nodes
!***   nrtri          : number of elements
!***   nseg           : number of boundary elemenets
!***   itri(1..4,m)   : (1,m) subdomain index for element m (not used here)
!***                    (2..4,m) global number of vertex 1,2,3 for element m
!***   vois(1..3,m)   : element number of triangle opposite to vertex 1..3
!***                    in element m
!***   ifront(1..4,m) : (1..2,m) global node number of vertex (1..2) for
!***                             boundary element m
!***                    (3,m)    number of element to which boundary
!***                             element m belongs
!***                    (4,m)    boundary index for boundary element m
!***                             (not used here)
!***   coeg(1..2,n)   : x,y coordinates of node n
!***   
!***
!***   Convention : the outer boundary is described clockwise, inner
!***                boundaries are described counterclockwise
!***
!***   nno, nrtri and nseg are stored in commonblock.inc!***
!***   the preset values maxnod, maxele and maxseg in tables.inc 
!***   are checked
        implicit none        
	integer :: nno, nw, nrtri, nws, nseg
        integer :: i,j,tecfile, m, n
        integer :: partitionunit,tecunit,verif
        integer :: n1,n2,n3,d
        integer, dimension(:,:), allocatable    ::itri,ifront,vois
        integer, dimension(:),allocatable       :: domain
        real*8, dimension(:,:), allocatable     :: coeg
        open(1, file = 'mesh.data', status='old', form = 'formatted')
        read (1,'(1x,5(i7,1x))') nno, nw, nrtri, nws, nseg

        allocate(itri(4,nrtri))
        allocate(vois(3,nrtri))
        allocate(ifront(4,nseg))
        allocate(coeg(2,nno))

        do m = 1, nrtri
           read(1, '(1x,7(i7,1x))')  (itri(i,m), i = 2,4),&
     &                              (vois(i,m), i = 1,3), itri(1,m)
        enddo
        do m = 1, nseg
           read(1, '(1x,4(i7,1x))')   (ifront(i,m), i = 1,4)    
        enddo

        do m = 1, nno
           read(1, *)  (coeg(i,m), i = 1,2)
        enddo

        close(1)
        partitionunit = 10
        tecunit = 11
        open(partitionunit,file='dual.dpart',status='old') !for metis
        !open(partitionunit,file='dual.map',status='old') !for scotch 
        open(tecunit,file='decomp.plt',status='unknown')
        
        allocate(domain(nno))

        !read(partitionunit,*) verif !for scotch
        !if( verif .ne. nrtri )then
        !   write(*,*) 'Error'
        !   stop
        !endif
        do i=1,nrtri
           !for metis
           read(partitionunit,*) itri(1,i) !read the partition number of the element
           !for scotch
           !read(partitionunit,*) verif,itri(1,i) !read the partition number of the element
        enddo

        !Fast way to visualize the partition, not good for Boundaries between 2 partitions
        do i = 1, nrtri
           n1 = itri(2,i)
           n2 = itri(3,i)
           n3 = itri(4,i)
           d  = itri(1,i)
           domain(n1) = d !associate a domain to the node, for boundaries node the las one win
           domain(n2) = d
           domain(n3) = d
        enddo

        !store the solution in a tecplot format
        

        write(tecunit,*) 'TITLE      =  "2D FE Unstructured grid data" '
        write(tecunit,*) 'VARIABLES = "X", "Y", "Dom"'
        write(tecunit,*) 'ZONE T="P1", F=FEPOINT, N=',nno,' E=',nrtri,' ET=TRIANGLE'


        !write the nodes coordinates
        do i= 1,nno
           write(tecunit,'( 2(ES16.8),3x,I6 )') coeg(1,i),coeg(2,i),domain(i)
        enddo

        do i=1, nrtri
           write(tecunit,*) itri(2:4,i)
        enddo
        close(partitionunit)
        close(tecunit)

        deallocate(coeg,itri,domain,vois,ifront)
        stop
   end program postprocess

