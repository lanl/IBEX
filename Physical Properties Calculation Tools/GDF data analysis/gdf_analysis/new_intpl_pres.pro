pro new_intpl_pres


  ;restore, 'time_shift.sav'
  restore, 'time_shift_new.sav'
  ;restore, 'ESA_intpl_wNAN.sav'
  ;restore, 'RS_8Aug23ESA_intpl_wNAN.sav'
  ;restore, 'RS_8Aug23ESA_intpl_wNAN_fract.sav'
  ;restore, 'RS_8Aug23ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'p_RS_15Mar24ESA_intpl_wNAN_fract_new.sav'
  ;
  ;restore, 'p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'Aram_p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  
  ;restore, 'ram_fract_Mar.sav'
  restore, 'Aram_fract_Sep.sav'
  

  mid_arr = ['A_']
  last_arr = ['B_ram']

  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/asurv_map_04-05-2023/surv_map.sav
  ;sp = surv_struct.YEARLY_SURV_SC_RAM

  restarri = 0

    yi = 0
    m = 90
    l= 180
    ;ty = 13
    ty = 14
    Pres_ESA2_intpl=fltarr(ty, l, m)
    Pres_ESA3_intpl=fltarr(ty, l, m)
    Pres_ESA4_intpl=fltarr(ty, l, m)
    Pres_ESA5_intpl=fltarr(ty, l, m)
    Pres_ESA6_intpl=fltarr(ty, l, m)
    Pres_ESA2_stddev_intpl=fltarr(ty, l, m)
    Pres_ESA3_stddev_intpl=fltarr(ty, l, m)
    Pres_ESA4_stddev_intpl=fltarr(ty, l, m)
    Pres_ESA5_stddev_intpl=fltarr(ty, l, m)
    Pres_ESA6_stddev_intpl=fltarr(ty, l, m)
    
    ;Ratio between ram and Aram -> only using this for Aram caluclation. 
    ;for Ram no ratio needed
    ;esa2_ratio=1.17185
    ;esa3_ratio=1.16376
    ;esa4_ratio=1.07537
    ;esa5_ratio=0.956132
    ;esa6_ratio=0.978957
    
    ;New ratios from weighted averages
;    esa2_ratio=1.1848530
;    esa3_ratio=1.1709516
;    esa4_ratio=1.0782830
;    esa5_ratio=0.96419573
;    esa6_ratio=0.94347966

;last point removed ratios
    esa2_ratio=1.2006958
    esa3_ratio=1.1703193
    esa4_ratio=1.0965427
    esa5_ratio=0.97707021
    esa6_ratio=0.93653643
    

  ;for a = 2009, 2021 do begin
  for a = 2009, 2022 do begin
  ;for a = 2011, 2015 do begin


    y = STRTRIM(a, 2)


    ;restore, '/Users/nwalia/data/RS_8Aug23/cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/Data&RS_15Mar24/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/Data&RS_15Mar24/data_post/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    ;
    ;restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/antiram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    

    tot_flux = fltarr(90,180,6)
    tot_error = fltarr(90,180,6)
    ESA1_GDF_MAP=make_array(90,180, /float, value =0.0)
    ESA1_GDF_STDDEV_MAP=make_array(90,180, /float, value =0.0)
    tot_flux[*,*,0]=ESA1_GDF_MAP
    
;    tot_flux[*,*,1]=transpose(ESA2_intpl[yi, *,*])
;    tot_flux[*,*,2]=transpose(ESA3_intpl[yi, *,*])
;    tot_flux[*,*,3]=transpose(ESA4_intpl[yi, *,*])
;    tot_flux[*,*,4]=transpose(ESA5_intpl[yi, *,*])
;    tot_flux[*,*,5]=transpose(ESA6_intpl[yi, *,*])
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

    flux = tot_flux
    fluxerr=tot_error


    null=ibex_hi_calc_los_pressure_parallel(flux, fluxerr)

    Prs = null.pressure
    Prs_err = null.pressure_sigma


    Pres_ESA2_intpl[yi, *, *]=transpose(Prs[*,*,1]);transpose because pressure is m,l rather than l, m
    Pres_ESA3_intpl[yi, *, *]=transpose(Prs[*,*,2])
    Pres_ESA4_intpl[yi, *, *]=transpose(Prs[*,*,3])
    Pres_ESA5_intpl[yi, *, *]=transpose(Prs[*,*,4])
    Pres_ESA6_intpl[yi, *, *]=transpose(Prs[*,*,5])
    Pres_ESA2_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,1])
    Pres_ESA3_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,2])
    Pres_ESA4_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,3])
    Pres_ESA5_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,4])
    Pres_ESA6_stddev_intpl[yi, *, *]=transpose(Prs_err[*,*,5])
    

    print, yi
    yi += 1
  endfor
  ;save, filename='RS_8Aug23all_pres_intpl_wNan_fract.sav'
  ;save, filename='RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
  ;save, filename='p_RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
  ;save, filename='p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  
  
  ;save, filename='ram_pres_fract_Mar.sav'
  ;save, filename='Aram_pres_fract_Sep.sav'
  ;save, filename='Aram_pres_scal.sav'
  ;save, filename='Aram_pres_scal_new_wa.sav'
  save, filename='Aram_pres_scal_new_wa_rem_lp.sav' ;2015.75 point removed from esa ratios

  


  stop
end
