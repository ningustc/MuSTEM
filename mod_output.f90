!--------------------------------------------------------------------------------
!
!  Copyright (C) 2017  L. J. Allen, H. G. Brown, A. J. D’Alfonso, S.D. Findlay, B. D. Forbes
!
!  This program is free software: you can redistribute it and/or modify
!  it under the terms of the GNU General Public License as published by
!  the Free Software Foundation, either version 3 of the License, or
!  (at your option) any later version.
!  
!  This program is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.
!   
!  You should have received a copy of the GNU General Public License
!  along with this program.  If not, see <http://www.gnu.org/licenses/>.
!                       
!--------------------------------------------------------------------------------

module output
    
    use m_precision, only: fp_kind
     implicit none

	interface crop
	    module procedure truncate_integer_2d,truncate_complex_2d,truncate_complex_1d,truncate_real_2d
	end interface

	interface array_from_txt_file
		module procedure array_from_txt_real_1d,array_from_txt_real
	end interface
		
    
      
    character(120) :: output_prefix

    contains

	integer*4 function nlines(fnam)
	character*(*),intent(in)::fnam
	integer*4::io
	nlines = 0 
	OPEN (50, file = fnam)
	DO
	  READ(50,*,iostat=io)
	  IF (io/=0) EXIT
	  nlines = nlines + 1
	END DO
	CLOSE (50)
	end

	function array_from_txt_real_1d(fnam,nopiy) result(array_from_txt)

	character*(*),intent(in)::fnam
	integer*4,intent(in)::nopiy

	real(fp_kind)::array_from_txt(nopiy)
	integer*4::i

	open(unit = 50,file = fnam,status='old',action='read')
	do i=1,nopiy
		read(50,*) array_from_txt(i)
	enddo

	close(50)
	end function


!	function array_from_txt_int_1d(fnam,nopiy) result(array_from_txt)
!
!	character*(*),intent(in)::fnam
!	integer*4,intent(in)::nopiy
!
!	integer*4::array_from_txt(nopiy),i
!
!	open(unit = 50,file = fnam,status='old',action='read')
!	do i=1,nopiy
!		read(50,*) array_from_txt(i)
!	enddo
!
!	close(50)
!	end function

	! function array_from_txt_int(fnam,nopiy,nopix) result(array_from_txt)

	! character*(*),intent(in)::fnam
	! integer*4,intent(in)::nopiy,nopix

	! integer*4::array_from_txt(nopiy,nopix),i,j

	! open(unit = 50,file = fnam,status='old',action='read')
	! do i=1,nopix
		! read(50,*) (array_from_txt(j,i),j=1,nopiy)
	! enddo

	! close(50)
	! end function

	function array_from_txt_real(fnam,nopiy,nopix) result(array_from_txt)

	character*(*),intent(in)::fnam
	integer*4,intent(in)::nopiy,nopix

	real(fp_kind)::array_from_txt(nopiy,nopix)
	integer*4::i,j

	open(unit = 50,file = fnam,status='old',action='read')
	do i=1,nopix
		read(50,*) (array_from_txt(j,i),j=1,nopiy)
	enddo

	close(50)
	end function


	function truncate_index(pin,pout)
        integer*4,intent(in)::pin,pout
        logical::ineven,outeven
        integer*4::truncate_index(2)
        
        ineven = mod(pin,2)==0
        outeven = mod(pout,2)==0
        
        truncate_index(1)= (pin-pout)/2+1
        if(ineven.and.outeven) truncate_index(1) = truncate_index(1)+1
        
        truncate_index(2) = truncate_index(1)+pout-1
        
        
    end function
	    function truncate_integer_2d(matrix,yout,xout)
        
        integer*4,intent(in)::yout,xout
        integer*4,intent(in)::matrix(yin,xin)
    
        integer*4::truncate_integer_2d(yout,xout)
        integer*4::yin,xin,y(2),x(2),sze(2)

        sze = shape(matrix)

        y = truncate_index(sze(1),yout)
        x = truncate_index(sze(2),xout)
        
        truncate_integer_2d = matrix(y(1):y(2),x(1):x(2))
           
    end function
    
    function truncate_complex_2d(matrix,yout,xout)
        
        integer*4,intent(in)::yout,xout
        complex*16,intent(in)::matrix(:,:)
    
        complex*16::truncate_complex_2d(yout,xout)
        integer*4::yin,xin,y(2),x(2),sze(2)

        sze = shape(matrix)

		y = truncate_index(sze(1),yout)
        x = truncate_index(sze(2),xout)
        
        truncate_complex_2d = matrix(y(1):y(2),x(1):x(2))
           
    end function

    function truncate_complex_1d(vector,xout)
        
        integer*4,intent(in)::xout
        complex*16,intent(in)::vector(:)
    
        complex*16::truncate_complex_1d(xout)
        integer*4::xin,x(2)
        
		xin = size(vector)
        x = truncate_index(xin,xout)
        
        truncate_complex_1d = vector(x(1):x(2))
           
    end function

	function truncate_real_2d(array_in,npiy,npix)
		real(fp_kind),intent(in)::array_in(:,:)
		integer*4,intent(in)::npiy,npix

		real(fp_kind)::truncate_real_2d(npiy,npix)

		integer*4::sze(2),y(2),x(2)

		sze = shape(array_in)

		y = truncate_index(sze(1),npiy)
        x = truncate_index(sze(2),npix)
        
        truncate_real_2d = array_in(y(1):y(2),x(1):x(2))

	end function
      
    subroutine setup_output_prefix
      
        use m_user_input, only: get_input
          
        implicit none
   
10      write(6,*) 'Enter the prefix for all outputted filenames:'
        call get_input("Output filename", output_prefix)
        write(*,*)
      
        if (len_trim(output_prefix).eq.0) goto 10
        
        output_prefix = trim(adjustl(output_prefix))
      
    end subroutine


      
    subroutine binary_in(nopiy, nopix, array, filename)
        implicit none
      
        integer(4) :: nopiy, nopix
        real(fp_kind) :: array(nopiy,nopix)
        character(*) :: filename
      
        integer :: iostat
          
        open(unit=19, file=filename, form='binary', status='old', convert='big_endian', iostat=iostat)
          
        if (iostat.ne.0) then
            write(*,*) 'Error reading binary file "', trim(filename), '".'
            write(*,*) 'The program will now halt.'
            pause
            stop
            
        endif
        
        read(19, iostat=iostat) array
        
        if (iostat.ne.0) then
            write(*,*) 'Error reading binary file "', trim(filename), '".'
            write(*,*) 'The program will now halt.'
            pause
            stop
            
        endif
        
        close(19)
              
    end subroutine


    
    subroutine binary_out(nopiy, nopix, array, filename,write_to_screen)
    
        implicit none
      
        integer(4) :: nopiy, nopix
        real(fp_kind) :: array(nopiy,nopix)
        character(*) :: filename
		logical,intent(in),optional::write_to_screen
        
        character(512) :: fnam_out
        character(5) :: ydim,xdim
        integer::ierr
            
        write(ydim,'(i5)') nopiy
        write(xdim,'(i5)') nopix

        fnam_out = trim(adjustl(filename)) // '_' // trim(adjustl(xdim)) // 'x' // trim(adjustl(ydim)) // '.bin'
		
		if (present(write_to_screen)) then
			if (write_to_screen) write(*,*) trim(fnam_out)
		else
			write(*,*) trim(fnam_out)
		endif
      
        open(unit=18, file=fnam_out, form='binary', status='unknown', convert='big_endian', iostat=ierr)
        write(18) transpose(array)
        close(18)
      
        if (ierr.ne.0) then
            write(*,*) '      An error occurred while writing to binary file.'
        endif
      
    end subroutine

    
    
    subroutine binary_out_unwrap(nopiy, nopix, array, filename,write_to_screen,to_bandlimit)
        ! Unwrap and output a diffraction pattern
    
        implicit none
      
        integer(4) :: nopiy, nopix
        real(fp_kind) :: array(nopiy,nopix)
        character(*) :: filename
        real(fp_kind) :: array_unwrapped(nopiy,nopix)
		logical,optional,intent(in)::write_to_screen,to_bandlimit
      
	    integer::Npos_y, Npos_x, Nneg_y, Nneg_x
        integer::shifty, shiftx
		logical:: write_to_screen_,to_bandlimit_
	  
        Npos_y = int(floor(float(nopiy)/2))
        Npos_x = int(floor(float(nopix)/2))
      
        Nneg_y = nopix - Npos_y - 1
        Nneg_x = nopiy - Npos_x - 1
      
	    shifty = -Nneg_y
        shiftx = -Nneg_x
      
	    array_unwrapped = cshift(cshift(array, shifty, 1), shiftx, 2)
		
		if(present(write_to_screen)) then
			write_to_screen_ = write_to_screen
		else
			write_to_screen_ = .true.
		endif

		if(present(to_bandlimit)) then
			to_bandlimit_ = to_bandlimit
		else
			to_bandlimit_ = .true.
		endif

		if(to_bandlimit_) then
			call binary_out(nopiy*2/3, nopix*2/3, crop(array_unwrapped,nopiy*2/3, nopix*2/3), filename,write_to_screen_)
		else
			call binary_out(nopiy, nopix, array_unwrapped, filename,write_to_screen_)
		endif
      
    end subroutine



    subroutine printout_1d(image, nopix, filename)
    
        implicit none
      
        integer(4) :: nopix
        real(fp_kind) :: image(nopix)
        character(*) :: filename
      
        integer :: i
        
        write(*,*) trim(filename)
      
        open(unit = 19, file = filename, status = 'unknown')
        do i = 1, nopix
            write(19,*) image(i)
        enddo

        close(19)

    end subroutine

    
    
    subroutine printout_2d(image, nopiy, nopix, filename)
    
        implicit none
      
        integer(4) :: nopix, nopiy
        real(fp_kind) :: image(nopiy,nopix)
        character(*) :: filename
      
        integer(4) :: ny, nx, iostat
      
        write(*,*) trim(filename)
      
        open(unit=18, file=filename, status='unknown', iostat=iostat)
      
        if (iostat.ne.0) then
            write(*,*) 'Error reading binary file "', trim(filename), '".'
            write(*,*) 'The program will now halt.'
            pause
            stop
            
        endif
        
        do ny = 1,nopiy
            do nx = 1, nopix-1
                    write (18,142) image(ny,nx)
142               format(1x,e20.12,$)
            enddo
            write (18,144) image(ny,nopix)
144         format(1x,e20.12)
        enddo

        close(18)
        
    end subroutine

    
      
    subroutine tile_output(in_image, nopiy, nopix, ifacty, ifactx, out_image)
    
        implicit none
          
        integer(4) :: nopiy,nopix
        real(fp_kind) :: in_image(nopiy,nopix)
        integer(4) :: ifacty, ifactx
        real(fp_kind) :: out_image(nopiy*ifacty,nopix*ifactx)
        
        integer(4) :: i, j
        
        do i = 1, ifacty
        do j = 1, ifactx
            out_image((i-1)*nopiy + 1 : (i-1)*nopiy + nopiy, (j-1)*nopix + 1 : (j-1)*nopix + nopix)  = in_image(1:nopiy,1:nopix)
		enddo
        enddo
          
    end subroutine


             
    subroutine interpolate_real2D(a, b)
    
        use CUFFT_wrapper
        
        implicit none
        
        real(fp_kind)::a(:,:), b(:,:)
        
        complex(fp_kind),allocatable::a1(:,:), a2(:,:), b1(:,:), b2(:,:)
        
        integer::nopiy_a, nopix_a, nopiy_b, nopix_b

	    integer::Npos_y, Npos_x, Nneg_y, Nneg_x
        integer::shifty, shiftx
	  
        nopiy_a = size(a, 1)
        nopix_a = size(a, 2)
        nopiy_b = size(b, 1)
        nopix_b = size(b, 2)
        
        allocate(a1(nopiy_a,nopix_a))
        allocate(a2(nopiy_a,nopix_a))
        
        allocate(b1(nopiy_b,nopix_b))
        allocate(b2(nopiy_b,nopix_b))
        
        a1 = a
        
        call fft2(nopiy_a, nopix_a, a1, nopiy_a, a2, nopix_a)
        a2 = a2 * sqrt(float(nopiy_a*nopix_a))
        
        Npos_y = int(floor(float(nopiy_a)/2))
        Npos_x = int(floor(float(nopix_a)/2))
      
        Nneg_y = nopiy_a - Npos_y - 1
        Nneg_x = nopix_a - Npos_x - 1
      
	    shifty = -Nneg_y
        shiftx = -Nneg_x
      
        a1 = cshift(a2, shifty, 1)
	    a2 = cshift(a1, shiftx, 2)

        b1 = 0.0_fp_kind
        b1(1:nopiy_a,1:nopix_a) = a2                

        b2 = cshift(cshift(b1, -shifty, 1), -shiftx, 2)
        
        call ifft2(nopiy_b, nopix_b, b2, nopiy_b, b1, nopix_b)
        b1 = b1 / sqrt(float(nopiy_b*nopix_b))
                
        b = real(b1) * float(product(shape(b))) / float(product(shape(a)))
        
	end subroutine


    
    
      !----------------------------------------------------------------------
      !   subroutine constructs a filename appending the integer to the input
      !   no extension is added
      !----------------------------------------------------------------------
      subroutine make_fnam_out_noext(output_prefix,fnam_out,num)
      
      implicit none
      
      integer(4)   i,itmp,itmp1,num
      character(*) output_prefix,fnam_out
      character*80 fnam_temp,fnam_temp1
      character*80 fnam_temp2,fnam_temp3

      fnam_temp=adjustl(output_prefix)
      write (fnam_temp1,123) num
123   format(i4)

      fnam_temp2=adjustl(fnam_temp1) 
      itmp=len_trim(fnam_temp2)
      fnam_temp3=trim(fnam_temp2)
      do i = 1,5
            itmp1=itmp+i
            if(itmp1.lt.6)then
                  fnam_temp3='0'//trim(fnam_temp3)
            endif
      enddo
      
      !fnam_out=trim(fnam_temp)//trim(fnam_temp3)//'_'
      fnam_out=trim(fnam_temp)//trim(fnam_temp3)
      
      return
      end subroutine

      subroutine add_zero_padded_int(output_prefix, fnam_out, num, width)
        implicit none
        
        character(*) :: output_prefix, fnam_out
        integer :: num, width
        
        character(10) :: fmt
        
10      format('(i', i1, '.', i1, ')')   

        if (num.ge.0) then
            write(fmt, 10) width, width
        else
            write(fmt, 10) width, width-1
        endif
        
        write(fnam_out, fmt) num
        
        fnam_out = trim(output_prefix) // fnam_out
        
      end subroutine

      subroutine add_zero_padded_int_signed(output_prefix, fnam_out, num, width)
        implicit none
        
        character(*) :: output_prefix, fnam_out
        integer :: num, width
        
        character(10) :: fmt
        
10      format('(sp, i', i1, '.', i1, ')')        
        write(fmt, 10) width, width-1
        
        write(fnam_out, fmt) num
        
        fnam_out = trim(output_prefix) // fnam_out
        
      end subroutine

      
      
      !----------------------------------------------------------------------------
      !subroutine output stem image

    subroutine output_stem_image(stem_image,fnam_det)
        use global_variables
        use m_lens
        use m_probe_scan, only: nysample, nxsample, scan_quarter, unwrap_quarter_image
        
        implicit none

        integer(4) :: i_df
        real(fp_kind),dimension(:,:,:) :: stem_image
        real(fp_kind),allocatable :: tiled_image(:,:)
        real(fp_kind) :: interpolated_image(output_nopiy,output_nopix)
        character(*) :: fnam_det
        character(512) :: fnam_temp,fnam_out
        
        logical :: many_y, many_x, many_df
                
        if (scan_quarter) then
            
            do i_df = 1, n_df
                call unwrap_quarter_image(stem_image(:,:,i_df), nysample, nxsample, stem_image(:,:,i_df))
            enddo
                        
        endif
        
        many_y = nysample .gt. 1
        many_x = nxsample .gt. 1
        many_df = n_df .gt. 1
        
        if (many_y .and. many_x .and. many_df) then
            ! y, x, df
        
            do i_df = 1, n_df
            
                ! Output STEM image at original sampling
            
                fnam_temp = trim(adjustl(fnam_det)) // '_Defocus'
                call add_zero_padded_int_signed(fnam_temp, fnam_out, int(defoci(i_df)), 5)
                fnam_out = trim(fnam_out) // 'Ang'
            
                call binary_out(nysample, nxsample, stem_image(:,:,i_df), fnam_out)
                        
                ! Output STEM image with tiling and interpolation
                
                if(allocated(tiled_image)) deallocate(tiled_image)
                allocate(tiled_image(tiley*nysample,tilex*nxsample))
                
                call tile_output(stem_image(:,:,i_df), nysample, nxsample, tiley, tilex, tiled_image)

                call interpolate_real2D(tiled_image, interpolated_image)
                
                fnam_out = trim(fnam_out) // '_Interpolated'
                
                call binary_out(output_nopiy, output_nopix, interpolated_image, fnam_out)
                
            enddo
            
        elseif (many_y .and. many_x) then
            ! y vs. x
        
            ! Output STEM image at original sampling
        
            fnam_out = trim(fnam_det)
            call binary_out(nysample, nxsample, stem_image(:,:,1), fnam_out)
                        
            ! Output STEM image with tiling and interpolation
                
            if(allocated(tiled_image)) deallocate(tiled_image)
            allocate(tiled_image(tiley*nysample,tilex*nxsample))
                
            call tile_output(stem_image(:,:,1), nysample, nxsample, tiley, tilex, tiled_image)

            call interpolate_real2D(tiled_image, interpolated_image)
                
            fnam_out = trim(fnam_det) // '_Interpolated'
                
            call binary_out(output_nopiy, output_nopix, interpolated_image, fnam_out)
        
        elseif (many_y .and. many_df) then
            ! y vs. df
        
            fnam_temp = trim(adjustl(fnam_det)) // '_Linescan(y)_vs_Defocus'
            call binary_out(nysample, n_df, stem_image(:,1,:), fnam_temp)
        
        elseif (many_y) then
            ! y
        
            fnam_temp = trim(adjustl(fnam_det)) // '_Linescan(y).txt'
            call printout_1d(stem_image(:,1,1), nysample, fnam_temp)
        
        elseif (many_x .and. many_df) then
            ! x vs. df

            fnam_temp = trim(adjustl(fnam_det)) // '_Linescan(x)_vs_Defocus'
            call binary_out(n_df, nxsample, transpose(stem_image(1,:,:)), fnam_temp)
            ! Note: the transpose is so that defocus is passed through to 
            ! binary_out() as the fastest varying dimension; binary_out()
            ! then transposes again so that x will be outputted as the fastest varying
            ! dimension and thus will be displayed horizontally in ImageJ
       
        elseif (many_x) then
            ! x

            fnam_temp = trim(adjustl(fnam_det)) // '_Linescan(x).txt'
            call printout_2d(stem_image(1:1,:,1), 1, nxsample, fnam_temp)
            ! Note: use printout_2d() to force x horizontal
            
        elseif (many_df) then
            !df
        
            fnam_temp = trim(adjustl(fnam_det)) // '_DefocusSeries.txt'
            call printout_1d(stem_image(1,1,:), n_df, fnam_temp)
        
        else
            !Single value
        
            fnam_temp = trim(adjustl(fnam_det)) // '_Signal.txt'
            call printout_1d(stem_image(:,1,1), 1, fnam_temp)
            
        endif          

	end subroutine


    end module