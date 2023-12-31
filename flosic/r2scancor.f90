!***********************************************************************
! Module description
!***********************************************************************
!
! JWF : this subroutine computes the correlation energy of SCAN
!  and some of its regularised variants.
!
!  Three Integer flags are required to select SCAN variant:
!   IALPHA  :  iso-orbital indicator
!               0: alpha        (scan)
!               1: alpha'       (rscan)
!               2: \bar{alpha}  (r++scan, r2scan, r4scan)
!
!   IINTERP :  interpolation function
!               0: scan
!               1: rscan, r++scan, r2scan, r4scan
!
!   IDELEC  :  gradient expansion correction
!               0: scan (scan, rscan, r++scan)
!               1: 2nd order (r2scan)
!               2: 2nd order (equivalent to 1, to match r4scan exchange input)
!
!
!  Hence, functionals are accessed by passing:
!   SCAN:       (0, 0, 0)
!   rSCAN:      (1, 1, 0)
!   r++SCAN:    (2, 1, 0)
!   r2SCAN:     (2, 1, 1)
!   r4SCAN:     (2, 1, 2)
!
! Author: James W. Furness
! eMail : jfurness@tulane.edu (james.w.furness.1@gmail.com)
! Date  : 24/06/2020
!
! This work is made available under the CC0 1.0 Universal (CC0 1.0)
! Public Domain Dedication.
! https://creativecommons.org/publicdomain/zero/1.0/
!
! The person who associated a work with this deed has dedicated the work
! to the public domain by waiving all of his or her rights to the work
! worldwide under copyright law, including all related and neighboring
! rights, to the extent allowed by law.
!
! You can copy, modify, distribute and perform the work, even for
! commercial purposes, all without asking permission. See Other Information
! below.
!
! Other Information:
!
! In no way are the patent or trademark rights of any person affected by CC0,
! nor are the rights that other persons may have in the work or in how the work
! is used, such as publicity or privacy rights.
!
! Unless expressly stated otherwise, the person who associated a work with this
! deed makes no warranties about the work, and disclaims liability for all uses
! of the work, to the fullest extent permitted by applicable law.
!
! When using or citing the work, you should not imply endorsement by the author
! or the affirmer.
!
! While we have made every effort to ensure the code's correctness, it is provided
! as is and no warranties or guarantees are given.
!***********************************************************************

subroutine r2scan_c_wrap_for_square_gradients(d0, d1, g00,   &
           g11, g01, t0, t1, eps_c, dedd0, dedd1,            &
           dedg00, dedg11, dedg01,                           &
           dedt0, dedt1, IALPHA, IINTERP, IDELEC)
    IMPLICIT NONE

!   Wrapper function converting between square gradients and absolute gradients
!   expected by the subroutine.

    real(8), intent(in) :: d0, d1, g00, g11, g01, t0, t1
    real(8), intent(out) :: eps_c, dedd0, dedd1, dedg00, dedg11
    real(8), intent(out) :: dedg01, dedt0, dedt1
    integer, intent(in) :: IALPHA, IINTERP, IDELEC

    real(8) :: g0, g1, gt, dfdy, dedg0, dedg1

    g0 = sqrt(g00)
    g1 = sqrt(g11)
    gt = sqrt(g00 + g11 + 2.0d0*g01)

    !call vrSCANc(                                    &
    call vSCANc2(                                    &
   d0, d1, g0, g1, gt, t0, t1,                       &
   eps_c, dedd0, dedd1, dedg0, dedg1, dedt0, dedt1,  &
   IALPHA, IINTERP, IDELEC)

    dfdy = dedg0*g0/2.0d0/(g00 + g01)
    dedg00 = dfdy
    dedg11 = dfdy
    dedg01 = dfdy*2.0d0
end subroutine

!>>>> moved from previous r2scan interface -- comment of this interface is copied below.
! Interface follows the original SCAN interface
! Author: Jefferson E Bates
! eMail : jeb@temple.edu
! Date  : 23.06.2016
subroutine cscan_r0(ra, gaa, ta, f, IALPHA, IINTERP, IDELEC)
! SCAN correlation functional, 0th derivative
    implicit none
!    include 'fortrankinds.h'
!    integer, PARAMETER :: kdp = KIND(1.0d0)

    real(8), intent(in) :: ra, gaa, ta
    real(8), intent(out) :: f
    integer, intent(in) :: IALPHA, IINTERP, IDELEC

    real(8) :: fra, frb, fgaa, fgbb, fta, ftb

! JEB : abuse spin-polarized routine to compute spin-unpolarized result
    call cscan_u1(ra, ra, gaa, gaa, gaa, ta, ta, fra, frb, fgaa, &
                  fgbb, fgbb, fta, ftb, f, IALPHA, IINTERP, IDELEC)

end subroutine cscan_r0

subroutine cscan_r1(ra, gaa, ta, fra, fgaa, fgab, fta, f, &
    &               IALPHA, IINTERP, IDELEC)
! SCAN correlation functional, 1st derivatives
! Spin-restriced version (zeta = 0)
    implicit none
!    include 'fortrankinds.h'
!    integer, PARAMETER :: kdp = KIND(1.0d0)

    real(8), intent(in) :: ra, gaa, ta
    real(8), intent(out) :: f, fra, fgaa, fgab, fta
    integer, intent(in) :: IALPHA, IINTERP, IDELEC

    real(8) :: frb, fgbb, ftb

! JEB : use the spin-polarized routine with spin-unpolarized densities
    !f = 0.0d0
    !fra = 0.0d0
    !fgaa = 0.0d0
    !fgab = 0.0d0
    !fta = 0.0d0
    call cscan_u1(ra, ra, gaa, gaa, gaa, ta, ta, fra, frb, fgaa, &
                  fgab, fgbb, fta, ftb, f, IALPHA, IINTERP, IDELEC)

end subroutine cscan_r1

subroutine cscan_u0(ra, rb, gaa, gab, gbb, ta, tb, f, IALPHA, IINTERP, IDELEC)
! SCAN correlation functional, 0th derivative
    implicit none
!    include 'fortrankinds.h'
!    integer, PARAMETER :: kdp = KIND(1.0d0)

    real(8), intent(in) :: ra, rb, gaa, gab, gbb, ta, tb
    real(8), intent(out) :: f
    integer, intent(in) :: IALPHA, IINTERP, IDELEC

    real(8) :: d0, d1, g0, g1, gt, t0, t1
    real(8) :: ec, decdd0, decdd1, decdg0, decdg1, decdt0, decdt1

    d0 = ra
    d1 = rb
    g0 = sqrt(gaa)
    g1 = sqrt(gbb)
    gt = sqrt(gaa + gbb + 2.0d0*gab)
    t0 = ta
    t1 = tb

    call vSCANc2(d0, d1, g0, g1, gt, t0, t1, &
                 ec, decdd0, decdd1, decdg0, decdg1, decdt0, decdt1, &
                 IALPHA, IINTERP, IDELEC)

    f = ec
end subroutine cscan_u0

subroutine cscan_u1(ra, rb, gaa, gab, gbb, ta, tb, fra, frb, fgaa, &
                    fgab, fgbb, fta, ftb, f, IALPHA, IINTERP, IDELEC)
! SCAN correlation functional, 1st derivatives
    implicit none
!    include 'fortrankinds.h'
!    integer, PARAMETER :: kdp = KIND(1.0d0)

    real(8), intent(in) :: ra, rb, gaa, gab, gbb, ta, tb
    real(8), intent(out) :: f, fra, frb, fgaa, fgab, fgbb, fta, ftb
    integer, intent(in) :: IALPHA, IINTERP, IDELEC

    real(8) :: d0, d1, g0, g1, gt, t0, t1, dfdy
    real(8) :: ec, decdd0, decdd1, decdg0, decdg1, decdt0, decdt1
    d0 = ra
    d1 = rb
    g0 = sqrt(gaa)
    g1 = sqrt(gbb)
    gt = sqrt(gaa + gbb + 2.0d0*gab)
    t0 = ta
    t1 = tb

    call vSCANc2(d0, d1, g0, g1, gt, t0, t1, &
                 ec, decdd0, decdd1, decdg0, decdg1, decdt0, decdt1, &
                 IALPHA, IINTERP, IDELEC)

    !f = f + ec
    f = ec
    !fra = fra + decdd0
    fra = decdd0
    !frb = frb + decdd1
    frb = decdd1
    dfdy = decdg0*g0/2.0d0/(gaa + gab)
    !fgaa = fgaa + dfdy
    !fgbb = fgbb + dfdy
    !fgab = fgab + dfdy*2.0d0
    fgaa = dfdy
    fgbb = dfdy
    fgab = dfdy*2.0d0
    !fta = fta + decdt0
    !ftb = ftb + decdt1
    fta = decdt0
    ftb = decdt1

end subroutine cscan_u1
!<<<< end of interface subroutines

subroutine vSCANc2(d0, d1, g0, g1, gt, t0, t1, eps_c, &
                   dedd0, dedd1, dedg0, dedg1, dedt0, dedt1, &
                   IALPHA, IINTERP, IDELEC)
    IMPLICIT NONE

!       Inputs:
!           d0 : electron density for spin 0
!           d1 : electron density for spin 1
!           g0 : |grad d0|. Not this is not squared!
!           g1 : |grad d1|. Not this is not squared!
!           gt : |grad d|. Total density gradient. Note: not g0 + g1
!           t0 : Kinetic energy density spin 0
!           t1 : Kinetic energy density spin 1
!       Outputs:
!           eps_x : energy density
!           dedd0  : energy density derivative w.r.t. d0
!           dedd1  : energy density derivative w.r.t. d1
!           dedg0  : energy density derivative w.r.t. g0
!           dedg1  : energy density derivative w.r.t. g1
!           dedt0  : energy density derivative w.r.t. t0
!           dedt1  : energy density derivative w.r.t. t1
!       Parameters: (see top of file)
!           IALPHA  : selects alpha regularisation
!           IINTERP : selects interpolation function
!           IDELFX  : selects gradient expansion corrections

    real(8), intent(in) :: d0, d1, g0, g1, gt, t0, t1
    real(8), intent(out) :: eps_c, dedd0, dedg0, dedt0, dedd1
    real(8), intent(out) :: dedg1, dedt1
    integer, intent(in) :: IALPHA, IINTERP, IDELEC

    real(8) :: dt, tt, dthrd, rs, drsdd0, drsdd1
    real(8) :: zeta, dzetadd0, dzetadd1, ds_z, dds_zdd0, dds_zdd1
    real(8) :: s, dsdd0, dsdg0, dsdd1, dsdg1, gngn0, gngn1
    real(8) :: y0, y1, y, yc, dycdg0, dycdg1
    real(8) :: alpha, dadd0, dadg0, dadt0, dadd1, dadg1, dadt1, oma
    real(8) :: reg, dreg
    real(8) :: tueg, tueg_con, dtuegdd0, dtuegdd1
    real(8) :: tauw, dtauwdd0, dtauwdg0, dtauwdd1, dtauwdg1
    real(8) :: ief, diefda, diefdd0, diefdd1, diefdg0, diefdg1
    real(8) :: diefdt0, diefdt1
    real(8) :: ec0, dec0drs, dec0ds, dec0dz
    real(8) :: dec0dd0, dec0dd1, dec0dg0, dec0dg1
    real(8) :: ec1, dec1drs, dec1ds, dec1dz !dec1da is removed
    real(8) :: dec1dd0, dec1dd1, dec1dg0, dec1dg1

    real(8), parameter :: CFDC1 = 0.7d0
    real(8), parameter :: CFC1 = 0.640d0
    real(8), parameter :: CFC2 = 1.5d0

    real(8), parameter, dimension(7) :: IE_PARAMS_C = &
        (/ -0.64d0, -0.4352d0, -1.535685604549d0, 3.061560252175d0, &
            -1.915710236206d0, 0.516884468372d0, -0.051848879792d0/)

    real(8), parameter :: ETA = 1.0d-3
    real(8), parameter :: TAU_R = 1.0d-4
    real(8), parameter :: A_REG = 1.0d-3

    integer :: i

    real(8), parameter :: BETA_MB = 0.066725d0
    real(8), parameter :: GAMMA = 0.031090690869655d0
    real(8), parameter :: AFACTOR = 0.1d0
    real(8), parameter :: BFACTOR = 0.1778d0
    real(8), parameter :: PI = 3.1415926535897932384626433832795d0
    real(8), parameter :: PI2 = PI*PI

    dt = d0 + d1
    y0 = g0**2
    y1 = g1**2
    y = gt**2
    yc = (y - y0 - y1)/2.0d0
    tt = t0 + t1

    dycdg0 = yc/g0
    dycdg1 = yc/g1

    !        Zeta
    zeta = min(max((d0 - d1)/dt, -0.99999999999990d0), 0.99999999999990d0)
    dzetadd0 = 2.0d0*d1/dt**2
    dzetadd1 = -2.0d0*d0/dt**2

    !        Wigner-Seitz radius
    dthrd = dt**(1.0d0/3.0d0)
    rs = (0.75d0/PI)**(1.0d0/3.0d0)/dthrd
    drsdd0 = -(0.75d0/PI)**(1.0d0/3.0d0)/(3.0d0*dthrd*dt)
    drsdd1 = drsdd0

    !        Reduced density gradient
    s = gt/(2.0d0*(3.0d0*PI2)**(1.0d0/3.0d0)*dt**(4.0d0/3.0d0))
    dsdd0 = -4.0d0/3.0d0*s/dt
    dsdd1 = dsdd0
    gngn0 = 1.0d0/(2.0d0*gt)*(2.0d0*g0+2.0d0*yc/g0)
    gngn1 = 1.0d0/(2.0d0*gt)*(2.0d0*g1+2.0d0*yc/g1)
    dsdg0 = s/gt*gngn0
    dsdg1 = s/gt*gngn1

    !        ds_zeta
    ds_z = ((1.0d0 + zeta)**(5.0d0/3.0d0) + (1.0d0 - zeta)**(5.0d0/3.0d0))/2.0d0
    dds_zdd0 = 5.0d0/3.0d0* ((1.0d0 + zeta)**(2.0d0/3.0d0) &
              - (1.0d0 - zeta)**(2.0d0/3.0d0))*dzetadd0/2.0d0
    dds_zdd1 = 5.0d0/3.0d0* ((1.0d0 + zeta)**(2.0d0/3.0d0) &
              - (1.0d0 - zeta)**(2.0d0/3.0d0))*dzetadd1/2.0d0

    !       alpha
    tueg_con = 3.0d0/10.0d0*(3.0d0*PI2)**(2.0d0/3.0d0)

    if (IALPHA .eq. 1) then
        tueg = (tueg_con*dt**(5.0d0/3.0d0) + TAU_R)*ds_z
        dtuegdd0 = 5.0d0/3.0d0*tueg_con*dt**(2.0d0/3.0d0)*ds_z &
                  + tueg*dds_zdd0/ds_z
        dtuegdd1 = 5.0d0/3.0d0*tueg_con*dt**(2.0d0/3.0d0)*ds_z &
                  + tueg*dds_zdd1/ds_z
    else
        tueg = tueg_con*dt**(5.0d0/3.0d0)*ds_z
        dtuegdd0 = 5.0d0/3.0d0*tueg/dt + tueg*dds_zdd0/ds_z
        dtuegdd1 = 5.0d0/3.0d0*tueg/dt + tueg*dds_zdd1/ds_z
    end if

    !tauw = min(y/(8.0d0*dt), tt)
    tauw = y/(8.0d0*dt)
    dtauwdd0 = -tauw/dt
    dtauwdd1 = dtauwdd0
    dtauwdg0 = (g0 + dycdg0)/(4.0d0*dt)
    dtauwdg1 = (g1 + dycdg1)/(4.0d0*dt)

    if (IALPHA .eq. 0 .or. IALPHA .eq. 1) then
        ! Conventional alpha
        alpha = (tt - tauw)/tueg
        dadd0 = -(dtauwdd0 + alpha*dtuegdd0)/tueg
        dadd1 = -(dtauwdd1 + alpha*dtuegdd1)/tueg
        dadg0 = -dtauwdg0/tueg
        dadg1 = -dtauwdg1/tueg
        dadt0 = 1.0d0/tueg
        dadt1 = 1.0d0/tueg

    else if (IALPHA .eq. 2) then
        ! regularised alpha of r++scan, r2scan, r4scan
        alpha = (tt - tauw)/(tueg + ETA*tauw)
        dadd0 = -dtauwdd0/(tueg + ETA*tauw) &
              - (tt - tauw)*(dtuegdd0 + ETA*dtauwdd0)/(tueg + ETA*tauw)**2
        dadd1 = -dtauwdd1/(tueg + ETA*tauw) &
              - (tt - tauw)*(dtuegdd1 + ETA*dtauwdd1)/(tueg + ETA*tauw)**2
        dadg0 = -ETA*(tt - tauw)*dtauwdg0/(tueg + ETA*tauw)**2 &
              - dtauwdg0/(tueg + ETA*tauw)
        dadg1 = -ETA*(tt - tauw)*dtauwdg1/(tueg + ETA*tauw)**2 &
              - dtauwdg1/(tueg + ETA*tauw)
        dadt0 = 1.0d0/(tueg + ETA*tauw)
        dadt1 = dadt0
    else
        write(*,*) 'ERROR: Unknown IALPHA in SCAN'
        call stopit
    end if

    if (IALPHA .eq. 1) then
        ! alpha regularisation for rscan
        reg = alpha**3/(alpha**2 + A_REG)
        dreg = (alpha**4 + 3.0d0*alpha**2*A_REG)/(alpha**2 + A_REG)**2
        dadd0 = dadd0*dreg
        dadd1 = dadd1*dreg
        dadg0 = dadg0*dreg
        dadg1 = dadg1*dreg
        dadt0 = dadt0*dreg
        dadt1 = dadt1*dreg
        alpha = reg
    end if

    ief = 0.0d0
    diefda = 0.0d0
    oma = 1.0d0 - alpha

    if (IINTERP .eq. 0) then
        ! SCAN interpolation function
        if (alpha .lt. 1.0d0) then
            ief = exp(-CFC1*alpha/oma)
            diefda = -CFC1*ief/oma**2
        else if (alpha .ge. 1.0d0) then
            ief = -CFDC1*exp(CFC2/oma)
            diefda = CFC2*ief/oma**2
        endif

    else if (IINTERP .eq. 1) then
        ! rSCAN interpolation function
        if (alpha .lt. 1.0d-13) then
            ief = exp(-CFC1*alpha/oma)
            diefda = -CFC1*ief/oma**2
        else if (alpha .lt. 2.5d0) then
            ief = 1.0d0
            do i = 1, 7
                ief = ief + IE_PARAMS_C(i)*alpha**(i)
                diefda = diefda + i*IE_PARAMS_C(i)*alpha**(i - 1)
            end do
        else if (alpha .ge. 2.5d0) then
            ief = -CFDC1*exp(CFC2/oma)
            diefda = CFC2*ief/oma**2
        endif
    else
        write(*,*) 'ERROR: Unknown IINTERP in SCAN'
        call stopit
    end if

    diefdd0 = diefda*dadd0
    diefdd1 = diefda*dadd1
    diefdg0 = diefda*dadg0
    diefdg1 = diefda*dadg1
    diefdt0 = diefda*dadt0
    diefdt1 = diefda*dadt1

    !        Single Orbital Correlation
    ec0 = 0.0d0
    dec0drs = 0.0d0
    dec0ds = 0.0d0
    dec0dz = 0.0d0
    call scan_ec0(rs, s, zeta, ec0, dec0drs, dec0ds, dec0dz)
    dec0dd0 = dec0drs*drsdd0 + dec0dz*dzetadd0 + dec0ds*dsdd0
    dec0dd1 = dec0drs*drsdd1 + dec0dz*dzetadd1 + dec0ds*dsdd1
    dec0dg0 = dec0ds*dsdg0
    dec0dg1 = dec0ds*dsdg1

    !        Slowly Varying Correlation
    ec1 = 0.0d0
    dec1drs = 0.0d0
    dec1ds = 0.0d0
    dec1dz = 0.0d0
    call scan_ec1(rs, s, zeta, &
                  ec1, dec1drs, dec1dz, dec1ds, &
                  IE_PARAMS_C, ETA, IDELEC)
    dec1dd0 = dec1drs*drsdd0 + dec1dz*dzetadd0 + dec1ds*dsdd0
    dec1dd1 = dec1drs*drsdd1 + dec1dz*dzetadd1 + dec1ds*dsdd1
!    dec1dg0 = dec1ds*dsdg0 + dec1da*dadg0
!    dec1dg1 = dec1ds*dsdg1 + dec1da*dadg1
    dec1dg0 = dec1ds*dsdg0
    dec1dg1 = dec1ds*dsdg1

    !        Full correlation functional
    eps_c = (ec1 + ief*(ec0 - ec1)) !*dt  !Ec per particle (without dt)
    dedd0 = ec1 + (ec0 - ec1)*ief &
          + dt*(ief*(dec0dd0 - dec1dd0) + dec1dd0 + (ec0 - ec1)*diefdd0)
    dedd1 = ec1 + (ec0 - ec1)*ief &
          + dt*(ief*(dec0dd1 - dec1dd1) + dec1dd1 + (ec0 - ec1)*diefdd1)
    dedg0 = dt*(ief*(dec0dg0 - dec1dg0) + dec1dg0 + (ec0 - ec1)*diefdg0)
    dedg1 = dt*(ief*(dec0dg1 - dec1dg1) + dec1dg1 + (ec0 - ec1)*diefdg1)
    dedt0 = dt*(ec0 - ec1)*diefdt0
    dedt1 = dt*(ec0 - ec1)*diefdt1

end subroutine

subroutine scan_ec0(rs, s, zeta, ec0, dec0drs, dec0ds, dec0dz)
    IMPLICIT NONE

    real(8), intent(in) :: rs, s, zeta
    real(8), intent(out) :: ec0, dec0drs, dec0ds, dec0dz

    real(8) :: eclda, dldadrs, dldadrsrs
    real(8) :: dx_z, ddx_zdz, gc_z, dgc_zdz
    real(8) :: w0, dw0drs, ginf, dginfds
    real(8) :: h0, dh0drs, dh0ds

    real(8), parameter :: B1C = 0.0285764d0
    real(8), parameter :: CHI_LD = 0.12802585262625815d0

    call lda_0(rs, eclda, dldadrs, dldadrsrs, B1C)

    dx_z = ((1.0d0 + zeta)**(4.0d0/3.0d0) + (1.0d0 - zeta)**(4.0d0/3.0d0))/2.0d0
    ddx_zdz = -2.0d0*((1.0d0 - zeta)**(1.0d0/3.0d0) &
              - (1.0d0 + zeta)**(1.0d0/3.0d0))/3.0d0

    gc_z = (1.0d0 - 2.363d0*(dx_z - 1.0d0))*(1.0d0 - zeta**12)
    dgc_zdz = -(1.0d0 - 2.363d0*(dx_z - 1.0d0))*12.0d0*zeta**11
    dgc_zdz = dgc_zdz - 2.363d0*ddx_zdz*(1.0d0 - zeta**12)

    w0 = exp(-eclda/B1C) - 1.0d0
    dw0drs = -(w0 + 1.0d0)*dldadrs/B1C

    ginf = 1.0d0/(1.0d0 + 4.0d0*CHI_LD*s*s)**(1.0d0/4.0d0)
    dginfds = -2.0d0*CHI_LD*s/(1.0d0 + 4.0d0*CHI_LD*s*s)**(5.0d0/4.0d0)

    h0 = B1C*log(1.0d0 + w0*(1.0d0 - ginf))
    dh0drs = B1C*(1.0d0 - ginf)*dw0drs/(1.0d0 + (1.0d0 - ginf)*w0)
    dh0ds = -B1C*w0*dginfds/(1.0d0 + (1.0d0 - ginf)*w0)

    ec0 = (eclda + h0)*gc_z
    dec0drs = (dldadrs + dh0drs)*gc_z
    dec0dz = (h0 + eclda)*dgc_zdz
    dec0ds = dh0ds*gc_z

end subroutine

subroutine scan_ec1(rs, s, zeta, &
                    ec1, dec1drs, dec1dz, dec1ds, &
                    IE_PARAMS_C, ETA, IDELEC)
    IMPLICIT NONE

    real(8), intent(in) :: rs, s, zeta
    real(8), intent(out) :: ec1, dec1drs, dec1dz, dec1ds
    real(8), dimension(7), intent(in) :: IE_PARAMS_C
    real(8), intent(in) :: ETA
    integer, intent(in) :: IDELEC

    real(8) :: sqrt_rs, dx_z, ddx_zdz, gc_z, dgc_zdz
    real(8) :: phi, dphidz
    real(8) :: phi3, dphi3dz
    real(8) :: eclda0, declda0drs, declda0drsrs
    real(8) :: eclsda1, declsda1drs, declsda1dz
    real(8) :: declsda1drsrs, declsda1drsz
    real(8) :: t, dtdrs, dtdz, dtds
    real(8) :: w1, dw1drs, dw1dz, y, dydrs, dydz, dyds
    real(8) :: del_y, ddel_ydrs, ddel_ydz, ddel_yds
    real(8) :: g_y, dg_ydrs, dg_ydz, dg_yds
    real(8) :: h1, dh1drs, dh1dz, dh1ds

    real(8), parameter :: B1C = 0.0285764d0
    real(8), parameter :: PI = 3.1415926535897932384626433832795d0
    real(8), parameter :: GAMMA = 0.0310906908696d0
    real(8), parameter :: BETA_MB = 0.066724550603149220d0
    real(8), parameter :: AFACTOR = 0.1d0
    real(8), parameter :: BFACTOR = 0.1778d0
    real(8) :: AFIX_T

    AFIX_T = sqrt(PI/4.0d0)*(9.0d0*PI/4.0d0)**(1.0d0/6.0d0)

    dx_z = ((1.0d0 + zeta)**(4.0d0/3.0d0) + (1.0d0 - zeta)**(4.0d0/3.0d0))/2.0d0
    ddx_zdz = -2.0d0*((1.0d0 - zeta)**(1.0d0/3.0d0) &
             - (1.0d0 + zeta)**(1.0d0/3.0d0))/3.0d0

    gc_z = (1.0d0 - 2.3631d0*(dx_z - 1.0d0))*(1.0d0 - zeta**12)
    dgc_zdz = -(1.0d0 - 2.3631d0*(dx_z - 1.0d0))*12.0d0*zeta**11
    dgc_zdz = dgc_zdz - 2.3631d0*ddx_zdz*(1.0d0 - zeta**12)

    phi = (exp((2.0d0/3.0d0)*log(1.0d0 + zeta)) &
         + exp((2.0d0/3.0d0)*log(1.0d0 - zeta)))/2.0d0
    dphidz = (1.0d0/3.0d0)*((1.0d0 + zeta)**(-1.0d0/3.0d0) &
            - (1.0d0 - zeta)**(-1.0d0/3.0d0))

    phi3 = phi**3
    dphi3dz = 3.0d0*phi**2*dphidz

    call lda_0(rs, eclda0, declda0drs, declda0drsrs, B1C)
    call lsda_1(rs, zeta, eclsda1, &
                declsda1drs, declsda1dz, declsda1drsrs, declsda1drsz)

    sqrt_rs = sqrt(rs)

    t = AFIX_T*s/(sqrt_rs*phi)
    dtdrs = -AFIX_T*s/(2.0d0*phi*rs**(3.0/2.0))
    dtdz = -dphidz*AFIX_T*s/(sqrt_rs*phi**2)
    dtds = AFIX_T/(sqrt_rs*phi)

    w1 = exp(-eclsda1/(GAMMA*phi3)) - 1.0d0
    dw1drs = -(w1 + 1.0d0)*declsda1drs/(GAMMA*phi3)
    dw1dz = -(w1 + 1.0d0)/(GAMMA*phi3)*(declsda1dz - 3.0d0*eclsda1*dphidz/phi)

    call get_y(rs, t, dtdrs, dtdz, dtds, &
               w1, dw1drs, dw1dz, GAMMA, &
               y, dydrs, dydz, dyds)

    if (IDELEC .eq. 0) then
        del_y = 0.0d0
        ddel_ydrs = 0.0d0
        ddel_ydz = 0.0d0
        ddel_yds = 0.0d0

    else if (IDELEC .eq. 1 .or. IDELEC .eq. 2) then
        call get_del_y(rs, s, zeta,                                         &
             eclda0, declda0drs, declda0drsrs,                              &
             eclsda1, declsda1drs, declsda1dz, declsda1drsrs, declsda1drsz, &
             gc_z, dgc_zdz,                                                 &
             phi3, dphi3dz, w1, dw1drs, dw1dz, GAMMA,                       &
             del_y, ddel_ydrs, ddel_ydz, ddel_yds, IE_PARAMS_C, ETA)

    else
        write(*,*) 'ERROR: Unknown IDELEC in SCAN'
        call stopit
    end if

    g_y = 1.0d0/(1.0d0 + 4.0d0*(y - del_y))**(1.0/4.0)
    dg_ydrs = -(dydrs - ddel_ydrs) &
              /(1.0d0 + 4.0d0*(y - del_y))**(5.0d0/4.0d0)
    dg_ydz = -(dydz - ddel_ydz) &
              /(1.0d0 + 4.0d0*(y - del_y))**(5.0d0/4.0d0)
    dg_yds = -(dyds - ddel_yds) &
              /(1.0d0 + 4.0d0*(y - del_y))**(5.0d0/4.0d0)

    h1 = GAMMA*phi3*log(1.0d0 + w1*(1.0d0 - g_y))
    dh1drs = GAMMA*phi3*((1.0d0 - g_y)*dw1drs - w1*dg_ydrs) &
             /(1.0d0 + (1.0d0 - g_y)*w1)
    dh1dz = GAMMA*log(1.0d0 + (1.0d0 - g_y)*w1)*dphi3dz &
        + GAMMA*phi3*((1.0d0 - g_y)*dw1dz - w1*dg_ydz) &
             /(1.0d0 + (1.0d0 - g_y)*w1)
    dh1ds = -GAMMA*phi3*w1*dg_yds/(1.0d0 + (1.0d0 - g_y)*w1)

    ec1 = eclsda1 + h1
    dec1drs = declsda1drs + dh1drs
    dec1dz = declsda1dz + dh1dz
    dec1ds = dh1ds
end subroutine

subroutine get_y(rs, t, dtdrs, dtdz, dtds, &
                 w1, dw1drs, dw1dz, GAMMA, &
                 y, dydrs, dydz, dyds)
    implicit NONE

    real(8), intent(in) :: rs, t, dtdrs, dtdz, dtds
    real(8), intent(in) :: w1, dw1drs, dw1dz, GAMMA
    real(8), intent(out) :: y, dydrs, dydz, dyds
    real(8) :: beta, dbetadrs

    real(8), parameter :: BETA_MB = 0.066725d0
    real(8), parameter :: AFACTOR = 0.1d0
    real(8), parameter :: BFACTOR = 0.1778d0

    beta = BETA_MB*(1.0d0 + AFACTOR*rs)/(1.0d0 + BFACTOR*rs)
    dbetadrs = BETA_MB*(AFACTOR - BFACTOR)/(1.0d0 + BFACTOR*rs)**2

    y = beta/(GAMMA*w1)*t**2
    dydrs = t**2*dbetadrs/(GAMMA*w1) - beta*t**2*dw1drs/(GAMMA*w1**2) &
          + 2.0d0*beta*t*dtdrs/(GAMMA*w1)
    dydz = 2.0d0*beta*t*dtdz/(GAMMA*w1) - beta*t**2*dw1dz/(GAMMA*w1**2)
    dyds = 2.0d0*beta*t*dtds/(GAMMA*w1)
end subroutine

subroutine get_del_y(rs, s, zeta, lda0, dlda0drs, dlda0drsrs, &
         lsda1, dlsda1drs, dlsda1dz, dlsda1drsrs, dlsda1drsz, &
         gc, dgcdz,                                           &
         phi3, dphi3dz, w1, dw1drs, dw1dz, GAMMA,             &
         del_y, ddel_ydrs, ddel_ydz, ddel_yds, IE_PARAMS_C, ETA)
    IMPLICIT NONE

    real(8), intent(in) :: rs, s, zeta, lda0, dlda0drs, dlda0drsrs
    real(8), intent(in) :: lsda1, dlsda1drs, dlsda1dz, dlsda1drsrs
    real(8), intent(in) :: dlsda1drsz, gc, dgcdz
    real(8), intent(in) :: phi3, dphi3dz, w1, dw1drs, dw1dz, GAMMA
    real(8), intent(out) :: del_y, ddel_ydrs, ddel_ydz, ddel_yds
    real(8), dimension(7), intent(in) :: IE_PARAMS_C
    real(8), intent(in) :: ETA

    real(8) :: del_f2
    real(8) :: lsda0, dlsda0drs, dlsda0dz, dlsda0drsrs, dlsda0drsz
    real(8) :: K, dKdrs, dKdz
    real(8) :: t1, dt1drs, dt1dz, t2, dt2drs, dt2dz, t3
    real(8) :: dt3drs, dt3dz
    real(8) :: damp, ddampds
    real(8) :: p, ds_z, dds_zdz
    integer :: i

    real(8), parameter :: D_DAMP2 = 0.361d0

    p = s*s
    ds_z = ((1.0d0 + zeta)**(5.0d0/3.0d0) + (1.0d0 - zeta)**(5.0d0/3.0d0))/2.0d0
    dds_zdz = -5.0d0/6.0d0*((1.0d0 - zeta)**(2.0d0/3.0d0) &
            - (1.0d0 + zeta)**(2.0d0/3.0d0))

    lsda0 = lda0*gc
    dlsda0drs = dlda0drs*gc
    dlsda0dz = lda0*dgcdz
    dlsda0drsrs = dlda0drsrs*gc
    dlsda0drsz = dlda0drs*dgcdz

    del_f2 = 0.0d0
    do i = 1, 7
        del_f2 = del_f2 + i*IE_PARAMS_C(i)
    end do

    t1 = del_f2/(27.0d0*GAMMA*ds_z*phi3*w1)
    dt1drs = -t1*dw1drs/w1
    dt1dz = -del_f2*(w1*(phi3*dds_zdz + ds_z*dphi3dz) + ds_z*phi3*dw1dz) &
          /(27.0d0*GAMMA*(ds_z*phi3*w1)**2)

    t2 = 20.0d0*rs*(dlsda0drs - dlsda1drs)
    dt2drs = 20.0d0*(dlsda0drs - dlsda1drs + rs*(dlsda0drsrs - dlsda1drsrs))
    dt2dz = 20.0d0*rs*(dlsda0drsz - dlsda1drsz)

    t3 = 45.0d0*ETA*(lsda0 - lsda1)
    dt3drs = 45.0d0*ETA*(dlsda0drs - dlsda1drs)
    dt3dz = 45.0d0*ETA*(dlsda0dz - dlsda1dz)

    K = t1*(t2 - t3)
    dKdrs = dt1drs*(t2 - t3) + t1*(dt2drs - dt3drs)
    dKdz = dt1dz*(t2 - t3) + t1*(dt2dz - dt3dz)

    damp = exp(-p**2/D_DAMP2**4)
    ddampds = -4.0d0*damp*s**3/D_DAMP2**4

    del_y = K*p*damp
    ddel_ydrs = p*damp*dKdrs
    ddel_ydz = p*damp*dKdz
    ddel_yds = K*s*(2.0d0*damp + s*ddampds)
end subroutine get_del_y

subroutine lda_0(rs, elda_0, dldadrs, dldadrsrs, B1C)
    IMPLICIT NONE

    real(8), intent(in) :: rs
    real(8), intent(out) :: elda_0, dldadrs, dldadrsrs
    real(8), intent(in) :: B1C

    real(8) :: sqrtrs

    real(8), parameter :: B2C = 0.0889d0
    real(8), parameter :: B3C = 0.125541d0

    sqrtrs = sqrt(rs)
    elda_0 = -B1C/(1.0d0 + B2C*sqrtrs + B3C*rs)
    dldadrs = (B3C + B2C/(2.0d0*sqrtrs))*elda_0**2/B1C
    dldadrsrs = -B1C*(B2C + 3.0d0*B2C**2*sqrtrs + 9.0d0*B2C*B3C*rs &
              + 8.0d0*B3C**2*rs*sqrtrs)                            &
              /(4.0d0*rs*sqrtrs*(1.0d0 + B2C*sqrtrs + B3C*rs)**3)
end subroutine

subroutine lsda_1(rs, zeta, eclda1, declda1drs, declda1dz, &
                  declda1drsrs, declda1drsz)
    IMPLICIT NONE

    real(8), intent(in) :: rs, zeta
    real(8), intent(out) :: eclda1, declda1drs, declda1dz
    real(8), intent(out) :: declda1drsrs, declda1drsz
    real(8) :: z3, z4
    real(8) :: eu, deudrs, deudrsrs
    real(8) :: ep, depdrs, depdrsrs
    real(8) :: alfm, dalfmdrs, dalfmdrsrs
    real(8) :: F, dFdz

    real(8), parameter :: GAM = 0.51984209978974632953442121455650d0
    real(8), parameter :: FZZ = 8.0d0/(9.0d0*GAM)

    call gcor2scan(0.03109070d0, 0.213700d0, 7.59570d0, 3.58760d0, &
                   1.63820d0, 0.492940d0, rs, eu, deudrs, deudrsrs)
    call gcor2scan(0.015545350d0, 0.205480d0, 14.11890d0, 6.19770d0, &
                   3.36620d0, 0.625170d0, rs, ep, depdrs, depdrsrs)
    call gcor2scan(0.01688690d0, 0.111250d0, 10.3570d0, 3.62310d0, &
                   0.880260d0, 0.496710d0, rs, alfm, dalfmdrs, dalfmdrsrs)

    z3 = zeta**3
    z4 = zeta*z3

    F = ((1.0d0 + zeta)**(4.0d0/3.0d0) + (1.0d0 - zeta)**(4.0d0/3.0d0) - 2.0d0)/GAM
    dFdz = -4.0d0*((1.0d0 - zeta)**(1.0d0/3.0d0) &
         - (1.0d0 + zeta)**(1.0d0/3.0d0))/(3.0d0*GAM)

    eclda1 = EU*(1.0d0 - F*z4) + EP*F*z4 - ALFM*F*(1.0d0 - z4)/FZZ
    declda1drs = (1.0d0 - z4*F)*deudrs + z4*F*depdrs &
               - (1.0d0 - z4)*F*dalfmdrs/FZZ
    declda1dz = EU*(-4.0d0*z3*F - z4*dFdz) + z4*EP*dFdz + 4.0d0*z3*EP*F &
                   + 4.0d0*z3*alfm*F/FZZ - (1.0d0 - z4)*alfm*dFdz/FZZ

    ! Some second derivatives are required for r2scan/r4scan correlation.
    declda1drsrs = z4*F*depdrsrs + (1.0d0 - z4*F)*deudrsrs &
                 - (1.0d0 - z4)*F*dalfmdrsrs/FZZ
    declda1drsz = (4.0d0*z3*F*(dalfmdrs + FZZ*(depdrs - deudrs)) &
                + ((z4 - 1.0d0)*dalfmdrs + FZZ*z4*(depdrs - deudrs))*dFdz)/FZZ
end subroutine

subroutine gcor2scan(A, A1, B1, B2, B3, B4, rs, GG, GGRS, GGRSRS)
    IMPLICIT NONE

    real(8), intent(in) :: A, A1, B1, B2, B3, B4, rs
    real(8), intent(out) :: GG, GGRS, GGRSRS
    real(8) :: rtrs, Q0, Q1, Q2
    real(8) :: Q0RS, Q1RS, Q1RSRS, Q2RS, Q2RSRS

    rtrs = sqrt(rs)

    Q0 = -2.0d0*A*(1.0d0 + A1*rs)
    Q0RS = -2.0d0*A*A1

    Q1 = 2.0d0*A*rtrs*(B1 + rtrs*(B2 + rtrs*(B3 + B4*rtrs)))
    Q1RS = A*(2.0d0*B2 + B1/rtrs + 3.0d0*B3*rtrs + 4.0d0*B4*rs)
    Q1RSRS = A*(4.0d0*B4 - B1/(2.0d0*rs*rtrs) + 3.0d0*B3/(2.0d0*rtrs))

    Q2 = log(1.0d0 + 1.0d0/Q1)
    Q2RS = -Q1RS/((1.0d0 + 1.0d0/Q1)*Q1**2)
    Q2RSRS = ((1.0d0 + 2.0d0*Q1)*Q1RS**2 - Q1*(1.0d0 + Q1)*Q1RSRS)/(Q1**2*(1.0d0 + Q1)**2)

    GG = Q0*Q2
    GGRS = Q0*Q2RS + Q2*Q0RS
    GGRSRS = 2.0d0*Q0RS*Q2RS + Q0*Q2RSRS
end subroutine
