pro ESA_flux_intpl


  ;restore, 'time_shift.sav'
  restore, 'time_shift_new.sav'

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
  ESA2=fltarr(ty, l, m)
  ESA3=fltarr(ty, l, m)
  ESA4=fltarr(ty, l, m)
  ESA5=fltarr(ty, l, m)
  ESA6=fltarr(ty, l, m)
  ESA2_stddev=fltarr(ty, l, m)
  ESA3_stddev=fltarr(ty, l, m)
  ESA4_stddev=fltarr(ty, l, m)
  ESA5_stddev=fltarr(ty, l, m)
  ESA6_stddev=fltarr(ty, l, m)
  fractime_array=fltarr(ty, l, m)
  time_array = []
  time_shift_array =[]
  ESA2_intpl=fltarr(ty, l, m)
  ESA3_intpl=fltarr(ty, l, m)
  ESA4_intpl=fltarr(ty, l, m)
  ESA5_intpl=fltarr(ty, l, m)
  ESA6_intpl=fltarr(ty, l, m)
  ESA2_stddev_intpl=fltarr(ty, l, m)
  ESA3_stddev_intpl=fltarr(ty, l, m)
  ESA4_stddev_intpl=fltarr(ty, l, m)
  ESA5_stddev_intpl=fltarr(ty, l, m)
  ESA6_stddev_intpl=fltarr(ty, l, m)
  ESA2_p_t=intarr(l,m)
  ESA3_p_t=intarr(l,m)
  ESA4_p_t=intarr(l,m)
  ESA5_p_t=intarr(l,m)
  ESA6_p_t=intarr(l,m)



  ;for a = 2009, 2021 do begin
  for a = 2009, 2022 do begin


    y = STRTRIM(a, 2)


    
    restore, '/Users/nwalia/data/RS_8Aug23/cg_fractional_time/SAV/Theseus-L_RBN_SEP_cdate_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/svgp_tot_and_gdf/Theseus_skymaps/cg/antiram/data/SAV/Theseus-L_RBN_SEP_cdate_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav' 
    
    restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav' 
    ;restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/antiram/data/SAV/Theseus-L_RBN_SEP_'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav' 
    
    
    ESA2[yi, *, *]=ESA2_GDF_MAP[*,*];+ESA2_RBN_MAP[*,*]
    ESA3[yi, *, *]=ESA3_GDF_MAP[*,*];+ESA3_RBN_MAP[*,*]
    ESA4[yi, *, *]=ESA4_GDF_MAP[*,*];+ESA4_RBN_MAP[*,*]
    ESA5[yi, *, *]=ESA5_GDF_MAP[*,*];+ESA5_RBN_MAP[*,*]
    ESA6[yi, *, *]=ESA6_GDF_MAP[*,*];+ESA6_RBN_MAP[*,*]
    
    ESA2_stddev[yi, *, *]=ESA2_gdf_stddev_MAP[*,*]
    ESA3_stddev[yi, *, *]=ESA3_gdf_stddev_MAP[*,*]
    ESA4_stddev[yi, *, *]=ESA4_gdf_stddev_MAP[*,*]
    ESA5_stddev[yi, *, *]=ESA5_gdf_stddev_MAP[*,*]
    ESA6_stddev[yi, *, *]=ESA6_gdf_stddev_MAP[*,*]
    
    fractime_array[yi, *, *] = ESA2_CDATE_MAP[*,*]
    ;time_array = [time_array, a]
    
    ;stop
    time_array = [time_array, a+0.25]
    ;time_array = [time_array, a+0.75]

    print, yi
    yi += 1
  endfor


  for i = 0, l-1 do begin

    for j = 0, m-1 do begin
      
      
      ESA2_intpl[*, i, j] = INTERPOL(ESA2[*, i, j], fractime_array[*, i, j]-ESA2_t_y[i,j], time_array)
      
      idx = where(time_array gt max(fractime_array[*, i, j]-ESA2_t_y[i,j]), tmp)
      if tmp ne 0 then ESA2_intpl[idx, i, j] = !values.F_NAN
      
      ESA3_intpl[*, i, j] = INTERPOL(ESA3[*, i, j], fractime_array[*, i, j]-ESA3_t_y[i,j], time_array)
      
      idx = where(time_array gt max(fractime_array[*, i, j]-ESA3_t_y[i,j]), tmp)
      if tmp ne 0 then ESA3_intpl[idx, i, j] = !values.F_NAN
      
      ESA4_intpl[*, i, j] = INTERPOL(ESA4[*, i, j], fractime_array[*, i, j]-ESA4_t_y[i,j], time_array)
      
      idx = where(time_array gt max(fractime_array[*, i, j]-ESA4_t_y[i,j]), tmp)
      if tmp ne 0 then ESA4_intpl[idx, i, j] = !values.F_NAN
      
      ESA5_intpl[*, i, j] = INTERPOL(ESA5[*, i, j], fractime_array[*, i, j]-ESA5_t_y[i,j], time_array)
      
      idx = where(time_array gt max(fractime_array[*, i, j]-ESA5_t_y[i,j]), tmp)
      if tmp ne 0 then ESA5_intpl[idx, i, j] = !values.F_NAN
      
      ESA6_intpl[*, i, j] = INTERPOL(ESA6[*, i, j], fractime_array[*, i, j]-ESA6_t_y[i,j], time_array)
      
      idx = where(time_array gt max(fractime_array[*, i, j]-ESA6_t_y[i,j]), tmp)
      if tmp ne 0 then ESA6_intpl[idx, i, j] = !values.F_NAN
      
      ;stddev
      
      ESA2_stddev_intpl[*, i, j] = INTERPOL(ESA2_stddev[*, i, j], fractime_array[*, i, j]-ESA2_t_y[i,j], time_array)

      idx = where(time_array gt max(fractime_array[*, i, j]-ESA2_t_y[i,j]), tmp)
      if tmp ne 0 then ESA2_stddev_intpl[idx, i, j] = !values.F_NAN

      ESA3_stddev_intpl[*, i, j] = INTERPOL(ESA3_stddev[*, i, j], fractime_array[*, i, j]-ESA3_t_y[i,j], time_array)

      idx = where(time_array gt max(fractime_array[*, i, j]-ESA3_t_y[i,j]), tmp)
      if tmp ne 0 then ESA3_stddev_intpl[idx, i, j] = !values.F_NAN

      ESA4_stddev_intpl[*, i, j] = INTERPOL(ESA4_stddev[*, i, j], fractime_array[*, i, j]-ESA4_t_y[i,j], time_array)

      idx = where(time_array gt max(fractime_array[*, i, j]-ESA4_t_y[i,j]), tmp)
      if tmp ne 0 then ESA4_stddev_intpl[idx, i, j] = !values.F_NAN

      ESA5_stddev_intpl[*, i, j] = INTERPOL(ESA5_stddev[*, i, j], fractime_array[*, i, j]-ESA5_t_y[i,j], time_array)

      idx = where(time_array gt max(fractime_array[*, i, j]-ESA5_t_y[i,j]), tmp)
      if tmp ne 0 then ESA5_stddev_intpl[idx, i, j] = !values.F_NAN

      ESA6_stddev_intpl[*, i, j] = INTERPOL(ESA6_stddev[*, i, j], fractime_array[*, i, j]-ESA6_t_y[i,j], time_array)

      idx = where(time_array gt max(fractime_array[*, i, j]-ESA6_t_y[i,j]), tmp)
      if tmp ne 0 then ESA6_stddev_intpl[idx, i, j] = !values.F_NAN

    endfor
  endfor
  

  
  ;save, filename='RS_8Aug23ESA_intpl_wNAN_fract.sav'
  ;save, filename='RS_8Aug23ESA_intpl_wNAN_fract_new.sav'
  ;save, filename='RS_15Mar24ESA_intpl_wNAN_fract_new.sav'
  ;save, filename='p_RS_15Mar24ESA_intpl_wNAN_fract_new.sav'
  ;save, filename='p_RS_22Apr24ESA_intpl_wNAN_fract_new.sav'
  
  
  ;save, filename='p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  ;save, filename='Aram_p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  
  
  save, filename='ram_fract_Mar.sav'
  ;save, filename='Aram_fract_Sep.sav'
  
 
 
 
 
 
 
 
 
 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ;for i = 0, l-1 do begin
 ;for j = 0, m-1 do begin
 ;ESA2_p_t[i,j] = long(2022-ESA2_t_y[i,j]-2009)
 ;ESA3_p_t[i,j] = long(2022-ESA3_t_y[i,j]-2009)
 ;ESA4_p_t[i,j] = long(2022-ESA4_t_y[i,j]-2009)
 ;ESA5_p_t[i,j] = long(2022-ESA5_t_y[i,j]-2009)
 ;ESA6_p_t[i,j] = long(2022-ESA6_t_y[i,j]-2009)
 ;endfor
 ;endfor  
 
 ;for i = 0, l-1 do begin
   ;for j = 0, m-1 do begin
    
    ;for t = ESA2_p_t[i,j]+1,ty-1 do begin
    ;  ESA2_intpl[t, i, j] = !VALUES.F_NAN
    ;endfor
    ;endfor
   ;endfor
   
   
   ;for i = 0, l-1 do begin
   ;  for j = 0, m-1 do begin
   ;    for t = ESA3_p_t[i,j]+1,ty-1 do begin
    ;     ESA3_intpl[t, i, j] = !VALUES.F_NAN
   ;    endfor
    ; endfor
  ; endfor
   
  ; for i = 0, l-1 do begin
   ;  for j = 0, m-1 do begin
   ;    for t = ESA4_p_t[i,j]+1,ty-1 do begin
   ;      ESA4_intpl[t, i, j] = !VALUES.F_NAN
    ;   endfor
   ;  endfor
   ;endfor
 
   ;for i = 0, l-1 do begin
    ; for j = 0, m-1 do begin
     ;  for t = ESA5_p_t[i,j]+1,ty-1 do begin
     ;    ESA5_intpl[t, i, j] = !VALUES.F_NAN
     ;  endfor
    ; endfor
  ; endfor
   
   ;for i = 0, l-1 do begin
    ; for j = 0, m-1 do begin
    ;   for t = ESA6_p_t[i,j]+1,ty-1 do begin
     ;    ESA6_intpl[t, i, j] = !VALUES.F_NAN
     ;  endfor
    ; endfor
  ; endfor
 
  ;save, filename='RS_8Aug23ESA_intpl_wNAN.sav'
  ;stop
end
  
  
  