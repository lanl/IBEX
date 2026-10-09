pro bootstrap_intpl_pres


  restore, 'time_shift_new.sav'


  ;restore, 'ram_fract_Mar.sav'
  restore, 'Aram_fract_Sep.sav'


  mid_arr = ['A_']
  last_arr = ['B_ram']


  restarri = 0

  yi = 0
  m = 90
  l= 180
  
  nbootstrap = 100; 2000 ; no. of bootstrap smaples

  ty = 14
  Pres_ESA2_intpl=fltarr(ty, l, m, nbootstrap)
  Pres_ESA3_intpl=fltarr(ty, l, m, nbootstrap)
  Pres_ESA4_intpl=fltarr(ty, l, m, nbootstrap)
  Pres_ESA5_intpl=fltarr(ty, l, m, nbootstrap)
  Pres_ESA6_intpl=fltarr(ty, l, m, nbootstrap)
;  Pres_ESA2_stddev_intpl=fltarr(ty, l, m)
;  Pres_ESA3_stddev_intpl=fltarr(ty, l, m)
;  Pres_ESA4_stddev_intpl=fltarr(ty, l, m)
;  Pres_ESA5_stddev_intpl=fltarr(ty, l, m)
;  Pres_ESA6_stddev_intpl=fltarr(ty, l, m)
  Pres_ESA2_error=fltarr(ty, l, m)
  Pres_ESA3_error=fltarr(ty, l, m)
  Pres_ESA4_error=fltarr(ty, l, m)
  Pres_ESA5_error=fltarr(ty, l, m)
  Pres_ESA6_error=fltarr(ty, l, m)

  ;Ratio between ram and Aram -> only using this for Aram caluclation.
  ;for Ram no ratio needed
  ;esa2_ratio=1.17185
  ;esa3_ratio=1.16376
  ;esa4_ratio=1.07537
  ;esa5_ratio=0.956132
  ;esa6_ratio=0.978957

  ;New ratios from weighted averages
  esa2_ratio=1.1848530
  esa3_ratio=1.1709516
  esa4_ratio=1.0782830
  esa5_ratio=0.96419573
  esa6_ratio=0.94347966

 

  for a = 2009, 2022 do begin



    y = STRTRIM(a, 2)

    ;restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/antiram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'


    tot_flux = fltarr(90,180,6)
    tot_error = fltarr(90,180,6)
    ESA1_GDF_MAP=make_array(90,180, /float, value =0.0)
    ESA1_GDF_STDDEV_MAP=make_array(90,180, /float, value =0.0)
    
    tot_flux[*,*,0]=ESA1_GDF_MAP
    tot_flux[*,*,1]=transpose(ESA2_intpl[yi, *,*])/esa2_ratio
    tot_flux[*,*,2]=transpose(ESA3_intpl[yi, *,*])/esa3_ratio
    tot_flux[*,*,3]=transpose(ESA4_intpl[yi, *,*])/esa4_ratio
    tot_flux[*,*,4]=transpose(ESA5_intpl[yi, *,*])/esa5_ratio
    tot_flux[*,*,5]=transpose(ESA6_intpl[yi, *,*])/esa6_ratio
    
    tot_error[*,*,0]=ESA1_GDF_STDDEV_MAP
    tot_error[*,*,1]=transpose(ESA2_stddev_INTPL[yi, *,*])
    tot_error[*,*,2]=transpose(ESA3_stddev_INTPL[yi, *,*])
    tot_error[*,*,3]=transpose(ESA4_stddev_INTPL[yi, *,*])
    tot_error[*,*,4]=transpose(ESA5_stddev_INTPL[yi, *,*])
    tot_error[*,*,5]=transpose(ESA6_stddev_INTPL[yi, *,*])
    
;    flux_bootstrap = fltarr(90,180,6,nbootstrap)
;    for latidx = 0, 90-1 do begin
;      for lonidx = 0, 180-1 do begin
;        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
;        flux_bootstrap[latidx, lonidx, *, *] = x_samples * tot_error[latidx, lonidx,*] + tot_flux[latidx, lonidx,*]
;      endfor
;    endfor
    
    flux_bootstrap = fltarr(90,180,6,nbootstrap)
    
    for latidx = 0, 90-1 do begin
      for lonidx = 0, 180-1 do begin
        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
        flux_bootstrap[latidx, lonidx, 0, *] = x_samples * tot_error[latidx, lonidx,0] + tot_flux[latidx, lonidx,0]
      endfor
    endfor
    
    for latidx = 0, 90-1 do begin
      for lonidx = 0, 180-1 do begin
        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
        flux_bootstrap[latidx, lonidx, 1, *] = x_samples * tot_error[latidx, lonidx,1] + tot_flux[latidx, lonidx,1]
      endfor
    endfor
    
    for latidx = 0, 90-1 do begin
      for lonidx = 0, 180-1 do begin
        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
        flux_bootstrap[latidx, lonidx, 2, *] = x_samples * tot_error[latidx, lonidx,2] + tot_flux[latidx, lonidx,2]
      endfor
    endfor
    
    for latidx = 0, 90-1 do begin
      for lonidx = 0, 180-1 do begin
        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
        flux_bootstrap[latidx, lonidx, 3, *] = x_samples * tot_error[latidx, lonidx,3] + tot_flux[latidx, lonidx,3]
      endfor
    endfor
    
    for latidx = 0, 90-1 do begin
      for lonidx = 0, 180-1 do begin
        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
        flux_bootstrap[latidx, lonidx, 4, *] = x_samples * tot_error[latidx, lonidx,4] + tot_flux[latidx, lonidx,4]
      endfor
    endfor
    
    for latidx = 0, 90-1 do begin
      for lonidx = 0, 180-1 do begin
        x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
        flux_bootstrap[latidx, lonidx, 5, *] = x_samples * tot_error[latidx, lonidx,5] + tot_flux[latidx, lonidx,5]
      endfor
    endfor
    
    for n = 0,nbootstrap-1 do begin
      print, 'n', n
      flux = flux_bootstrap[*,*,*,n]
      fluxerr=tot_error

      null=ibex_hi_calc_los_pressure_parallel(flux, fluxerr)

      Prs = null.pressure
      Prs_err = null.pressure_sigma

      Pres_ESA2_intpl[yi, *, *, n]=transpose(Prs[*,*,1]);transpose because pressure is m,l rather than l, m
      Pres_ESA3_intpl[yi, *, *, n]=transpose(Prs[*,*,2])
      Pres_ESA4_intpl[yi, *, *, n]=transpose(Prs[*,*,3])
      Pres_ESA5_intpl[yi, *, *, n]=transpose(Prs[*,*,4])
      Pres_ESA6_intpl[yi, *, *, n]=transpose(Prs[*,*,5])
    ;Pres_ESA2_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,1])
    ;Pres_ESA3_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,2])
    ;;Pres_ESA4_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,3])
    ;Pres_ESA5_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,4])
    ;Pres_ESA6_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,5])

    endfor
    
    print,'yi',  yi
    yi += 1
  endfor
  
for m = 0, 90-1 do begin
      for l = 0, 180-1 do begin
      Pres_ESA2_error[yi, l, m]  = stdddev(Pres_ESA2_intpl[yi, l, m, *])
      Pres_ESA3_error[yi, l, m]  = stdddev(Pres_ESA3_intpl[yi, l, m, *])
      Pres_ESA4_error[yi, l, m]  = stdddev(Pres_ESA4_intpl[yi, l, m, *])
      Pres_ESA5_error[yi, l, m]  = stdddev(Pres_ESA5_intpl[yi, l, m, *])
      Pres_ESA6_error[yi, l, m]  = stdddev(Pres_ESA6_intpl[yi, l, m, *])
      endfor
    endfor
      
      ;stop
      
  ;save, filename='ram_pres_fract_Mar.sav'
  ;save, filename='Aram_pres_fract_Sep.sav'
 
  save, filename='Aram_pres_scal_bootstrap.sav'




  stop
end