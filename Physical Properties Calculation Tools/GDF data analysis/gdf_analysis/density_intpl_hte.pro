pro density_intpl_hte


  ;restore, 'factor_time_shift_speed_new_et.sav'
  ;restore, 'pr_factor_time_shift_speed_new_et.sav'
  ;restore, 'pr_time_shift_speed_new_et.sav'
  ;restore, 'Dec2_equ4.sav'
  restore, 'Feb20_equ4_ag.sav'
  restore, 'helio_to_ecliptic.sav'

  yi = 0
  m = 90
  l= 180

  ty = 21
  lat_orig = [-90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90]

  time_array = []
  time_shift_array =[]
  speed_hte = fltarr(l, m)
  speeda = fltarr(ty, l, m)
  density_ts_ally_intpl=fltarr(ty, l, m)
  speed_ts_ally_p_t=intarr(ty, l,m)


  for a = 2002, 2022 do begin

    year = STRTRIM(a, 2)

    ;restore, '/Users/nwalia/data/Sokol_solar_wind/SAV_intpl/density'+year+'.sav'
    restore, '/Users/nwalia/data/Porowski_model_Nov_2023/SAV/density'+year+'.sav'

    speed_intpl = interpol(lat, lat_orig, lat_arr)
    speed = fltarr(l, m)

    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin
        speed[i,j] = speed_intpl[j]
      endfor
    endfor


    for q = 0, 90-1 do begin
      for p = 0, 180-1 do begin

        lonec = lon_ec[p,q]/2
        latec = (lat_ec[p,q]+90)/2
        if lonec eq 180 then lonec = 0
        if latec eq 90 then latec = 0
        ;if lonec eq 180 then lonec = 179
        ;if latec eq 90 then latec = 89
    ;print, latec, lonec
        speed_hte[lonec,latec]=speed[p,q]
    
    endfor
    endfor
    
      d1 = n_elements(speed_hte)
    speed_hte_1d = reform(speed_hte, d1)

    zero_loc = where(speed_hte_1d le 0)
    non_zero_loc = where(speed_hte_1d gt 0)

    speed_hte_1d[zero_loc] = interpol(speed_hte_1d[non_zero_loc], non_zero_loc, zero_loc)

    speed_hte_2d = reform(speed_hte_1d, 180, 90)
    
    
    speeda[yi, *, *]=speed_hte_2d[*,*]
    time_array = [time_array, a]

    yi += 1
  endfor


  for i = 0, l-1 do begin

    for j = 0, m-1 do begin


      density_ts_ally_intpl[*, i, j] = INTERPOL(speeda[*, i, j], time_array+speed_ts_ally[*,i,j], time_array)


    endfor
  endfor

  ;save, filename='factor_density_intpl_et.sav'
  ;save, filename='pr_factor_density_intpl_et.sav'
  ;save, filename='pr_density_intpl_et.sav'
  save, filename='hte_pr_factor_density_intpl_et_new.sav'

  stop
  
  end