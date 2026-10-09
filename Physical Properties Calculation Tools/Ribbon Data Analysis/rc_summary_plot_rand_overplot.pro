pro RC_SUMMARY_PLOT_rand_overplot, VER, cpath
  tol = 1d-15

  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

  lon_hp = data.field2
  lat_hp = data.field3
  ts = data.field4
  hs = data.field5
  TRIANGULATE, lon_hp, lat_hp, tr_hp
  hp_dist = ts+hs


  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  win = window(dim = [800, 800], /buffer)
  win.refresh, /disable

  YEAR_MIN = 2009
  YEAR_MAX = 2021
  ;
  ;  if mapname eq 'ISOC' then BEGIN
  ;    YEAR_MAX = 2021 ; ISOC = 2019, THESEUS = 2020
  ;    lon_num = 60
  ;  endif
  ;  if mapname eq 'Theseus' then BEGIN
  ;    YEAR_MAX = 2021 ; ISOC = 2019, THESEUS = 2020
  ;    lon_num = 180
  ;  endif


  year_arr = [YEAR_MIN:YEAR_MAX]
  year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]


  fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2, 3); RLonLatsig x year x esa x ram
  fit_par_sig_circ = replicate(!values.d_nan, 3, year_arr.length, 5, 2, 3); RLonLat x year x esa x ram

  fit_par_ellip = replicate(!values.d_nan, 6, year_arr.length, 5, 2, 3); R,Lon,Lat,Ellip,Rot,sig x year x esa x ram
  fit_par_sig_ellip = replicate(!values.d_nan, 5, year_arr.length, 5, 2, 3); R,Lon,Lat,Ellip,Rot x year x esa x ram


  ;  moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2, 3); moment x lon x year x esa x ram
  ;  moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2, 3); moment x lon x year x esa x ram
  ;  flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2, 3); moment x lon x year x esa x ram
  ;  peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2, 3); lon x year x esa x ram, only for circle fit
  ;
  ;  moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2, 3); moment x lon x year x esa x ram
  ;  moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2, 3); moment x lon x year x esa x ram
  ;  flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2, 3); moment x lon x year x esa x ram
  ;  peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2, 3); lon x year x esa x ram, only for circle fit



  FPATH = strjoin(path_str[0:5], '\')+'\Figure\OverPlot\'+ver+'\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored\'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, file_tmp


  ; data stacking

  for midx = 0, 2 do begin
    if midx eq 0 then begin
      mapname = 'ISOC'
      sepname = 'L'
    endif
    if midx eq 1 then begin
      mapname = 'Theseus'
      sepname = 'L'
    endif
    if midx eq 2 then begin
      mapname = 'Theseus'
      sepname = 'D'
    endif

    for yidx = year_min, YEAR_MAX do begin
      FOR ram = 0, 1 DO BEGIN
        IF ram THEN str = 'ARam' ELSE str = 'Ram'

        DPATH = dp+mapname+'-'+sepname+'\'
        DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
        year = string(yidx, format = '(I4)')
        restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

        FOR ESA = 2, 6 DO BEGIN
          ESA_STR = strcompress(esa, /rem)
          if rc_c_lonlat[esa-2, 3] gt 0 then begin
            fit_par_circ[*, (yidx-year_min), esa-2, ram, midx] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
            fit_par_sig_circ[*, (yidx-year_min), esa-2, ram, midx] = reform([rc_c_PAR_SIG[esa-2, 0], rc_c_PAR_SIG[esa-2, 2], rc_c_PAR_SIG[esa-2, 1]]); RLonLat x year x esa
          endif

          if rc_e_lonlat[esa-2, 3] gt 0 then begin
            fit_par_ellip[*, (yidx-year_min), esa-2, ram, midx] = [reform(rc_e_lonlat[esa-2, 0:2]), reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]), reform(rc_e_PAR[esa-2, 2]), reform(rc_e_lonlat[esa-2, 3])]; R,Lon,Lat,Ellip,Rot,sig x year x esa

            fit_par_sig_ellip[*, (yidx-year_min), esa-2, ram, midx] = $
              [reform(sqrt(rc_E_PAR_SIG[esa-2, 0]^2+rc_E_PAR_SIG[esa-2, 1]^2)), $ ;R
              reform(rc_E_PAR_SIG[esa-2, 4]), $ ;Lon
              reform(rc_E_PAR_SIG[esa-2, 3]), $ ;Lat
              reform(rc_e_PAR[esa-2, 1]/rc_e_PAR[esa-2, 0] * sqrt((rc_E_PAR_SIG[esa-2, 0]/rc_e_PAR[esa-2, 0])^2+(rc_E_PAR_SIG[esa-2, 1]/rc_e_PAR[esa-2, 1])^2)), $ ;Ellip
              reform(rc_E_PAR_SIG[esa-2, 2])] ; Rot
          endif

          ;          !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
          ;          !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
          ;          !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
          ;          !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_PEAK_POS')
          ;
          ;          !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
          ;          !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
          ;          !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
          ;          !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram, midx] = ESA'+ESA_STR+'_PEAK_POS_error')


        endfor ; esa
      endfor ; year
    ENDFOR ; ram
  endfor ; map
  ; data stacking

  BV = GreatCircle([255.7, 5.1], [226.99, 34.82], npath = 1000) ; ISMF 227.28, 34.62 Zirnstein et al. 2016b 2023, nose direction 259, 5 Funsten et al. 2013

  ; ============================ Ribbon Center Pos/Radius ============================
  FOR ram = 0, 1 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for yidx = year_min, year_max do begin
      year = string(yidx, format = '(I4)')

      ; 2222222222 RC 2222222222
      ; RLonLatsig x year x esa x model
      co = ['blue', 'green', 'yellow', 'orange', 'red']
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      win1 = window(dim = [800, 600], /buffer)
      win1.refresh, /disable
      ;     Circle fit

      for midx = 0, 2 do begin
        if midx eq 0 then lineco = 'black'
        if midx eq 1 then lineco = 'red'
        if midx eq 2 then lineco = 'blue'

        extram = {symbol:'CIRCLE', sym_thick:1, sym_filled:1, xr:[240, 200], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
        lon_tmp = reform(fit_par_circ[1, (yidx-year_min), *, ram, midx]) & lat_tmp = reform(fit_par_circ[2, (yidx-year_min), *, ram, midx])
        lon_error_tmp = reform(fit_par_sig_circ[1, (yidx-year_min), *, ram, midx]) & lat_error_tmp = reform(fit_par_sig_circ[2, (yidx-year_min), *, ram, midx])

        p1 = objarr(5)
        for esa = 2, 6 do begin
          p1[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, title = 'RC position in EC,'+year, name = 'ESA'+strcompress(esa, /rem)+', Circ')
          pe = plot([lon_tmp[esa-2]-lon_error_tmp[esa-2]/2, lon_tmp[esa-2]+lon_error_tmp[esa-2]/2], [lat_tmp[esa-2], lat_tmp[esa-2]], over = p1[esa-2], COLOR = 'GRAY')
          pe = plot([lon_tmp[esa-2], lon_tmp[esa-2]], [lat_tmp[esa-2]-lat_error_tmp[esa-2]/2, lat_tmp[esa-2]+lat_error_tmp[esa-2]/2], over = p1[esa-2], COLOR = 'GRAY')
          ;        p1[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, title = 'RC position in EC,'+year, name = 'ESA'+strcompress(esa, /rem)+', Circ')
        endfor
        extram = {symbol:'CIRCLE', sym_thick:1, sym_filled:0, xr:[240, 200], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
        p = plot(lon_tmp, lat_tmp, over = p1[0], co = lineco)
        sc = scatterplot(replicate(mean(lon_tmp[0:3], /nan), 2), replicate(mean(lat_tmp[0:3], /nan), 2), over = p1[0], SYM_COLOR = lineco, _extra = extram)
        pbv = plot(BV[0, *], BV[1, *], over = p1[0], linestyle = 2, thick = 2)
        pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p1[0], symbol = '*', sym_size = 2)
        tx = text(226.99, 34.82, 'B', /data, font_size = 13, target = sc)
        tx = text(235, 30., 'B-V plane', /data, font_size = 13, orientation = 45., target = sc)

        extram = {symbol:'CIRCLE', sym_thick:1, sym_filled:0, xr:[240, 200], yr:[25, 55], current:win1, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
        sc = scatterplot(replicate(mean(lon_tmp[0:3], /nan), 2), replicate(mean(lat_tmp[0:3], /nan), 2), SYM_COLOR = lineco, _extra = extram, title = 'RC position in EC,'+year)
        pbv = plot(BV[0, *], BV[1, *], over = sc, linestyle = 2, thick = 2)
        pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = sc, symbol = '*', sym_size = 2)
        tx = text(226.99, 34.82, 'B', /data, font_size = 13, target = sc)
        tx = text(235, 30., 'B-V plane', /data, font_size = 13, orientation = 45., target = sc)

        extram = {symbol:'thin_diamond', sym_thick:1, sym_filled:1, xr:[240, 200], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$', over:p1[-1]}
        lon_tmp = reform(fit_par_ellip[1, (yidx-year_min), *, ram, midx]) & lat_tmp = reform(fit_par_ellip[2, (yidx-year_min), *, ram, midx])
        lon_error_tmp = reform(fit_par_sig_ellip[1, (yidx-year_min), *, ram, midx]) & lat_error_tmp = reform(fit_par_sig_ellip[2, (yidx-year_min), *, ram, midx])
        p2 = objarr(5)
        for esa = 2, 6 do begin
          p2[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, name = 'ESA'+strcompress(esa, /rem)+', Ellip')
          pe = plot([lon_tmp[esa-2]-lon_error_tmp[esa-2]/2, lon_tmp[esa-2]+lon_error_tmp[esa-2]/2], [lat_tmp[esa-2], lat_tmp[esa-2]], over = p2[esa-2], COLOR = 'GRAY')
          pe = plot([lon_tmp[esa-2], lon_tmp[esa-2]], [lat_tmp[esa-2]-lat_error_tmp[esa-2]/2, lat_tmp[esa-2]+lat_error_tmp[esa-2]/2], over = p2[esa-2], COLOR = 'GRAY')
          ;        p2[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, name = 'ESA'+strcompress(esa, /rem)+', Ellip')
        endfor
        extram = {symbol:'thin_diamond', sym_thick:1, sym_filled:0, xr:[240, 200], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$', over:p1[-1]}
        p = plot(lon_tmp, lat_tmp, over = p2[0], co = lineco)
        sc = scatterplot(replicate(mean(lon_tmp[0:3], /nan), 2), replicate(mean(lat_tmp[0:3], /nan), 2), over = p2[0], SYM_COLOR = lineco, _extra = extram)
        pbv = plot(BV[0, *], BV[1, *], over = p1[0], linestyle = 2, thick = 2)
        pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p1[0], symbol = '*', sym_size = 2)
        tx = text(226.99, 34.82, 'B', /data, font_size = 13, target = sc)
        tx = text(235, 30., 'B-V plane', /data, font_size = 13, orientation = 45., target = sc)
        lgd = legend(position = [0.75, 0.8], target = [p1, p2], shadow = 0, linestyle = 6, sample_width = 0, color = 0, transparency = 100)

        extram = {symbol:'thin_diamond', sym_thick:1, sym_filled:0, xr:[240, 200], yr:[25, 55], current:win1, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
        sc = scatterplot(replicate(mean(lon_tmp[0:3], /nan), 2), replicate(mean(lat_tmp[0:3], /nan), 2), SYM_COLOR = lineco, _extra = extram)
        pbv = plot(BV[0, *], BV[1, *], over = sc, linestyle = 2, thick = 2)
        pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = sc, symbol = '*', sym_size = 2)
        tx = text(226.99, 34.82, 'B', /data, font_size = 13, target = sc)
        tx = text(235, 30., 'B-V plane', /data, font_size = 13, orientation = 45., target = sc)

      endfor
      win.refresh
      win.save, file_tmp+'RC_position_Circ_Ellip_energy_year'+year+'_fit_'+str+'.png'
      win.erase

      win1.refresh
      win1.save, file_tmp+'RC_position_Circ_Ellip_energy_year'+year+'_fit_'+str+'_mean.png'
      win1.erase
      ; 2222222222 RC 2222222222


    endfor ; year

  endfor ; ram
  ;    ============================ Ribbon Center Pos/Radius ============================




end