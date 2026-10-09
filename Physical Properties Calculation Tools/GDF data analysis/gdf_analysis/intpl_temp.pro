pro intpl_temp


  restore, 'time_shift_new.sav'
  ;restore, 'ESA_intpl_wNAN.sav'
  ;restore, 'RS_8Aug23ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  
  ;restore, 'Aram_p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  
  restore, '/Users/nwalia/IDLWorkspace/ram_fract_Mar.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_fract_Sep.sav'
  
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
  Temp_ESA2_intpl=fltarr(ty, l, m)
  Temp_ESA3_intpl=fltarr(ty, l, m)
  Temp_ESA4_intpl=fltarr(ty, l, m)
  Temp_ESA5_intpl=fltarr(ty, l, m)
  Temp_ESA6_intpl=fltarr(ty, l, m)
  Temp_ESA2_stddev_intpl=fltarr(ty, l, m)
  Temp_ESA3_stddev_intpl=fltarr(ty, l, m)
  Temp_ESA4_stddev_intpl=fltarr(ty, l, m)
  Temp_ESA5_stddev_intpl=fltarr(ty, l, m)
  Temp_ESA6_stddev_intpl=fltarr(ty, l, m)

  ;for a = 2009, 2021 do begin
  for a = 2009, 2022 do begin


    y = STRTRIM(a, 2)


    ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/LRS_Jun27/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/svgp_tot_and_gdf(Apr11_sep)/gdf_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    
    
    restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav' 
    ;restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/antiram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav' 

    tot_flux = fltarr(90,180,6)
    tot_error = fltarr(90,180,6)
    ESA1_GDF_MAP=make_array(90,180, /float, value =0.0)
    ESA1_GDF_STDDEV_MAP=make_array(90,180, /float, value =0.0)
    tot_flux[*,*,0]=ESA1_GDF_MAP
    ;tot_flux[*,*,1]=transpose(ESA2_intpl[yi, *,*])/sp[yi,*,*,1]
    ;tot_flux[*,*,2]=transpose(ESA3_intpl[yi, *,*])/sp[yi,*,*,2]
    ;tot_flux[*,*,3]=transpose(ESA4_intpl[yi, *,*])/sp[yi,*,*,3]
    ;tot_flux[*,*,4]=transpose(ESA5_intpl[yi, *,*])/sp[yi,*,*,4]
    ;tot_flux[*,*,5]=transpose(ESA6_intpl[yi, *,*])/sp[yi,*,*,5]
    tot_flux[*,*,1]=transpose(ESA2_intpl[yi, *,*])
    tot_flux[*,*,2]=transpose(ESA3_intpl[yi, *,*])
    tot_flux[*,*,3]=transpose(ESA4_intpl[yi, *,*])
    tot_flux[*,*,4]=transpose(ESA5_intpl[yi, *,*])
    tot_flux[*,*,5]=transpose(ESA6_intpl[yi, *,*])
    tot_error[*,*,0]=ESA1_GDF_STDDEV_MAP
    tot_error[*,*,1]=transpose(ESA2_GDF_STDDEV_MAP);remember total error is not accurate as it has not been interpolated
    tot_error[*,*,2]=transpose(ESA3_GDF_STDDEV_MAP)
    tot_error[*,*,3]=transpose(ESA4_GDF_STDDEV_MAP)
    tot_error[*,*,4]=transpose(ESA5_GDF_STDDEV_MAP)
    tot_error[*,*,5]=transpose(ESA6_GDF_STDDEV_MAP)

    flux = tot_flux
    fluxerr=tot_error


    null=ibex_hi_calc_temp_parallel(flux, fluxerr)

    Tmp = null.pressure
    Tmp_err = null.pressure_sigma


    Temp_ESA2_intpl[yi, *, *]=transpose(Tmp[*,*,1]);transpose because pressure is m,l rather than l, m
    Temp_ESA3_intpl[yi, *, *]=transpose(Tmp[*,*,2])
    Temp_ESA4_intpl[yi, *, *]=transpose(Tmp[*,*,3])
    Temp_ESA5_intpl[yi, *, *]=transpose(Tmp[*,*,4])
    Temp_ESA6_intpl[yi, *, *]=transpose(Tmp[*,*,5])
    Temp_ESA2_stddev_intpl[yi, *, *]=transpose(Tmp_err[*,*,1])
    Temp_ESA3_stddev_intpl[yi, *, *]=transpose(Tmp_err[*,*,2])
    Temp_ESA4_stddev_intpl[yi, *, *]=transpose(Tmp_err[*,*,3])
    Temp_ESA5_stddev_intpl[yi, *, *]=transpose(Tmp_err[*,*,4])
    Temp_ESA6_stddev_intpl[yi, *, *]=transpose(Tmp_err[*,*,5])

    print, yi
    yi += 1
  endfor
  ;save, filename='RS_8Aug23all_temp_intpl_wNan_fract_new.sav'
  ;save, filename='p_RS_7May24all_temp_intpl_wNan_fract_new.sav'
  ;save, filename='Aram_p_RS_7May24all_temp_intpl_wNan_fract_new.sav'
  
  save, filename='ram_temp_fract_Mar.sav'
  ;save, filename='Aram_temp_fract_Sep.sav'




  stop
end
