pro RC_SUMMARY_PLOT, MAPNAME, SEPNAME, VER, cpath
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

  fname = mapname+'-'+sepname+'_RC_Iteration'
  DPATH = dp+mapname+'-'+sepname+'\'

  YEAR_MIN = 2009
  if mapname eq 'ISOC' then BEGIN
    YEAR_MAX = 2021 ; ISOC = 2019, THESEUS = 2020
    lon_num = 60
  endif
  if mapname eq 'Theseus' then BEGIN
    YEAR_MAX = 2021 ; ISOC = 2019, THESEUS = 2020
    lon_num = 180
  endif
  year_arr = [YEAR_MIN:YEAR_MAX]
  year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]


  ;    if data_idx eq 0 then begin
  ;      mapname = 'ISOC'
  ;      DPATH = dp+'ISOC-D\'
  ;      fname = mapname+'-D_RC_Iteration'
  ;      ABEND = 0 ; ISOC = 0, THESEUS = 1
  ;      YEAR_MIN = 2009
  ;      YEAR_MAX = 2019 ; ISOC = 2019, THESEUS = 2020
  ;      year_arr = [2009.5:2019.5]
  ;      lon_num = 30
  ;    endif
  ;    if data_idx eq 2 then begin
  ;      mapname = 'Theseus'
  ;      DPATH = dp+'Theseus-L\'
  ;      fname = mapname+'-L_RC_Iteration'
  ;      ABEND = 1 ; ISOC = 0, THESEUS = 1
  ;      YEAR_MIN = 2009
  ;      YEAR_MAX = 2021 ; ISOC = 2019, THESEUS = 2020
  ;      year_arr = [YEAR_MIN:YEAR_MAX]
  ;      year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]
  ;      lon_num = 180
  ;    endif


  fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
  fit_par_ellip = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
  fit_par_sig_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
  fit_par_sig_ellip = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram


  moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

  moment_error_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_error_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_error_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_error_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit


  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored\'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, file_tmp


  ; data stacking
  for yidx = year_min, YEAR_MAX do begin
    FOR ram = 0, 1 DO BEGIN
      IF ram THEN str = 'ARam' ELSE str = 'Ram'

      year = string(yidx, format = '(I4)')
      restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'
      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        if rc_c_lonlat[esa-2, 3] gt 0 then $
          fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
        if rc_e_lonlat[esa-2, 3] gt 0 then $
          fit_par_ellip[*, (yidx-year_min), esa-2, ram] = reform(rc_e_lonlat[esa-2, *]); RLonLat x year x esa

        !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
        !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
        !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')

        !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
        !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
        !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')

      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking


  ; ============================ Ribbon Center Pos/Radius ============================
  FOR ram = 0, 1 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      ; RLonLatsig x year x esa x model x ab x ram

      ; 1111111111 Angular radius 1111111111
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:15, xtitle:'Year', ytitle:'Angular radius', xr:[2008, 2022], yr:[60, 90]}
      ;     Circle fit
      p = errorplot(year_arr_tmp, fit_par_circ[0, *, esa-2, ram], fit_par_circ[3, *, esa-2, ram], color = 'blue', _extra = extram, title = 'Angular radius, '+'ESA'+esa_str+', '+str)
      p = errorplot(year_arr_tmp, fit_par_ellip[0, *, esa-2, ram], fit_par_ellip[3, *, esa-2, ram], color = 'red', _extra = extram)

      win.refresh
      win.save, file_tmp+'RC_Radius_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      win.erase
      ; 1111111111 Angular radius 1111111111

      ; 2222222222 RC 2222222222
      ;     Circle fit
      z_tmp_byt = bytscl(year_arr_tmp, min = year_min, max = year_max+1)
      extram = {symbol:'CIRCLE', sym_thick:3, SYM_COLOR:'BLACK', magnitude:z_tmp_byt, rgb_table:33, sym_filled:1, xr:[200, 240], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])
      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram, title = 'RC poistion in EC, ESA'+esa_str+', '+str)
      cb = color_bar(p1, ytickformat = '(a1)', yticklen = 0, yminor = 0)

      extram = {symbol:'thin_diamond', sym_thick:3, SYM_COLOR:'BLACK', magnitude:z_tmp_byt, rgb_table:33, sym_filled:1, xr:[200, 240], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])
      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram)

      yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[year_min, (year_max+1 - year_min)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')
      win.refresh
      win.save, file_tmp+'RC_position_Circ_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      win.erase

      ; 2222222222 RC 2222222222
    endfor; esa




    for yidx = year_min, year_max do begin

      ; RLonLatsig x year x esa x model

      co = ['blue', 'green', 'yellow', 'orange', 'red']
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      ;     Circle fit
      year = string(yidx, format = '(I4)')
      extram = {symbol:'CIRCLE', sym_thick:3, sym_filled:1, xr:[200, 240], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      lon_tmp = reform(fit_par_circ[1, (yidx-year_min), *, ram]) & lat_tmp = reform(fit_par_circ[2, (yidx-year_min), *, ram])
      p1 = objarr(5)
      for esa = 2, 6 do $
        p1[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, title = 'RC poistion in EC,'+year, name = 'ESA'+strcompress(esa, /rem)+', Circ')
      p = plot(lon_tmp, lat_tmp, over = p1[0])
      sc = scatterplot(replicate(mean(lon_tmp, /nan), 2), replicate(mean(lat_tmp, /nan), 2), over = p1[0], SYM_COLOR = 'BLACK', sym_FILL_color = 'black', _extra = extram)

      extram = {symbol:'thin_diamond', sym_thick:3, sym_filled:1, xr:[200, 240], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$', over:p1[0]}
      lon_tmp = reform(fit_par_ellip[1, (yidx-year_min), *, ram]) & lat_tmp = reform(fit_par_ellip[2, (yidx-year_min), *, ram])
      p2 = objarr(5)
      for esa = 2, 6 do $
        p2[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, name = 'ESA'+strcompress(esa, /rem)+', Ellip')
      p = plot(lon_tmp, lat_tmp, over = p2[0])
      sc = scatterplot(replicate(mean(lon_tmp, /nan), 2), replicate(mean(lat_tmp, /nan), 2), over = p2[0], SYM_COLOR = 'BLACK', sym_FILL_color = 'black', _extra = extram)

      lgd = legend(position = [0.75, 0.8], target = [p1, p2], shadow = 0, linestyle = 6, sample_width = 0, color = 0)
      win.refresh
      win.save, file_tmp+'RC_position_Circ_Ellip_energy_year'+year+'_fit_'+str+'.png'
      win.erase
    endfor ; year
  endfor ; ram
  ;    ============================ Ribbon Center Pos/Radius ============================


  ; ============================ Longitudinal Distribution of Moments ============================
  win = window(dim = [900, 800], /buffer)
  win.refresh, /disable
  POS1 = [0.1, 0.08, 0.85, 0.7]
  POS2 = [0.1, 0.7, 0.85, 0.95]
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  FOR ram = 0, 1 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for momidx = 0, 3 do begin
      if momidx eq 0 then begin
        mrg = [65., 90]
        RGB_TABLE = 33
        mom_str = 'Mean'
      endif
      if momidx eq 1 then BEGIN
        mrg = [5, 20.]
        RGB_TABLE = 33
        mom_str = 'Stddev'
      endif
      if momidx eq 2 then BEGIN
        mrg = [-1, 1.]
        RGB_TABLE = 70
        mom_str = 'Skewness'
      ENDIF
      if momidx eq 3 then BEGIN
        mrg = [-1, 1.]
        RGB_TABLE = 70
        mom_str = 'Kurtosis'
      endif

      for esa = 2, 6 do begin
        ESA_STR = strcompress(esa, /rem)

        ytmp = reform(moment_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram

        lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

        ; Fixed RC Coordinate
        sz = size(ytmp)
        yy = ytmp
        yy[*] = !values.d_nan
        yyidx = ytmp
        yyidx[*] = 0

        hp_mat = ytmp
        hp_mat[*] = !values.d_nan

        ec_lat = ytmp
        ec_lat[*] = !values.d_nan

        for yidx = 0, sz[2]-1 do begin

          peak_pos = [[lon_arr], [peak_lat_res[*, yidx]]]

          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
          LONEC = TMP.LON & LATEC = TMP.LAT
          ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
          ec_lat[*, yidx] = LATEC
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          dlon = lon_arr[1]-lon_arr[0]
          for lidx = 0, lon_arr.length-1 do begin
            idx = where(TMP1.LON ge lon_arr[lidx]-dlon/2 and TMP1.LON le lon_arr[lidx]+dlon/2, tmp)
            if tmp eq 0 then continue
            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
            yyidx[lidx, yidx] = tmp
            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
          endfor
        endfor
        ; Fixed RC Coordinate

        ytmp = yy

        data_available = total(finite(ytmp), 2)
        data_mean = mean(ytmp, dim = 2, /nan)
        q = quartile(ytmp, dim = 2)
        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
        ec_lat_sign = sign(ec_lat_mean)

        idx = where(data_available lt 5, /null)
        data_mean[idx] = !values.d_nan
        q[*, idx] = !values.d_nan

        p_HP = plot([0, 0], [0, 0], POS = POS2, /nodata, title = mom_str+', ESA'+esa_str+', '+str, xtickformat = '(a1)', ytitle = 'HP Dist. [AU]', font_size = 15, xr = [360, 0], yr = [100, 400], current = win)
        p_hp = plot(lon_arr, hp_dist_mean, over = p_HP, co = 'green', thick = 2)
        esidx = where(ec_lat_sign eq 1)
        p_hp0 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 0, name = 'EC North')
        esidx = where(ec_lat_sign eq -1)
        p_hp1 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 1, name = 'EC South')
        lgd = legend(target = [p_hp0, p_hp1], pos = [pos2[2]-0.03, pos2[3]-0.04], shadow = 0, linestyle = 6, sample_width = 0.05)

        p = plot([0, 0], [0, 0], POS = POS1, /nodata, xtitle = 'Lon_RC', ytitle = mom_str, font_size = 15, xr = [360, 0], yr = mrg, current = win)

        sz = size(ytmp)
        co = rgb_vector(sz[2], ct = 33)
        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)

        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)

        ff = findgen(256)
        cba = transpose([[ff], [ff], [ff]])
        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2021 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')


        win.Refresh
        win.save, file_tmp+STRCOMPRESS(momidx+1, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
        win.erase

      endfor ; esa

    endfor ; mom
    ; ===================================================================== NUMERICAL MOMENTS =====================================================================

    ; ===================================================================== SEMI MOMENTS =====================================================================
    for momidx = 0, 3 do begin
      if momidx eq 0 then BEGIN
        mrg = [65, 90]
        RGB_TABLE = 33
        mom_str = 'Peak'
      endif
      if momidx eq 1 then BEGIN
        mrg = [10, 50.]
        RGB_TABLE = 33
        mom_str = 'FWHM'
      endif
      if momidx eq 2 then BEGIN
        mrg = [-1, 1.]
        RGB_TABLE = 70
        mom_str = 'PSKEW'
        moment24_stack[momidx, *, *, *, ram] =  moment24_stack[momidx, *, *, *, ram]/ moment_stack[1, *, *, *, ram]
      ENDIF
      if momidx eq 3 then BEGIN
        mrg = [2, 5]
        RGB_TABLE = 33
        mom_str = 'R80_20'
      endif

      for esa = 2, 6 do begin
        ESA_STR = strcompress(esa, /rem)

        ytmp = reform(moment24_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa

        lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

        ; Fixed RC Coordinate
        sz = size(ytmp)
        yy = ytmp
        yy[*] = !values.d_nan
        yyidx = ytmp
        yyidx[*] = 0

        hp_mat = ytmp
        hp_mat[*] = !values.d_nan

        ec_lat = ytmp
        ec_lat[*] = !values.d_nan

        for yidx = 0, sz[2]-1 do begin

          peak_pos = [[lon_arr], [peak_lat_res[*, yidx]]]

          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
          LONEC = TMP.LON & LATEC = TMP.LAT
          ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
          ec_lat[*, yidx] = LATEC
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          dlon = lon_arr[1]-lon_arr[0]
          for lidx = 0, lon_arr.length-1 do begin
            idx = where(TMP1.LON ge lon_arr[lidx]-dlon/2 and TMP1.LON le lon_arr[lidx]+dlon/2, tmp)
            if tmp eq 0 then continue
            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
            yyidx[lidx, yidx] = tmp
            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
          endfor
        endfor
        ; Fixed RC Coordinate

        ytmp = yy

        data_available = total(finite(ytmp), 2)
        data_mean = mean(ytmp, dim = 2, /nan)
        q = quartile(ytmp, dim = 2)
        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
        ec_lat_sign = sign(ec_lat_mean)

        idx = where(data_available lt 5, /null)
        data_mean[idx] = !values.d_nan
        q[*, idx] = !values.d_nan

        p_HP = plot([0, 0], [0, 0], POS = POS2, /nodata, title = mom_str+', ESA'+esa_str+', '+str, xtickformat = '(a1)', ytitle = 'HP Dist. [AU]', font_size = 15, xr = [360, 0], yr = [100, 400], current = win)
        p_hp = plot(lon_arr, hp_dist_mean, over = p_HP, co = 'green', thick = 2)
        esidx = where(ec_lat_sign eq 1)
        p_hp0 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 0, name = 'EC North')
        esidx = where(ec_lat_sign eq -1)
        p_hp1 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 1, name = 'EC South')
        lgd = legend(target = [p_hp0, p_hp1], pos = [pos2[2]-0.03, pos2[3]-0.04], shadow = 0, linestyle = 6, sample_width = 0.05)

        p = plot([0, 0], [0, 0], POS = POS1, /nodata, xtitle = 'Lon_RC', ytitle = mom_str, font_size = 15, xr = [360, 0], yr = mrg, current = win)

        sz = size(ytmp)
        co = rgb_vector(sz[2], ct = 33)
        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)

        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)
        ff = findgen(256)
        cba = transpose([[ff], [ff], [ff]])
        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2021 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')

        win.Refresh
        win.save, file_tmp+'\'+STRCOMPRESS(momidx+5, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
        win.erase
      endfor ; esa

    endfor ; mom
    ; ===================================================================== SEMI MOMENTS =====================================================================


    cbmax = [1200,500,180,120,45,10]
    ; ===================================================================== Ribbon Flux =====================================================================
    for fluxidx = 0, 1 do begin
      if fluxidx eq 0 then BEGIN
        RGB_TABLE = 33
        mom_str = 'FluxPeak'
      endif
      if fluxidx eq 1 then BEGIN
        RGB_TABLE = 33
        mom_str = 'FluxMean'
      endif

      for esa = 2, 6 do begin
        ESA_STR = strcompress(esa, /rem)
        mrg = [0, cbmax[esa-1]]

        ytmp = reform(flux_stack[fluxidx, *, *, esa-2, ram]); moment x lon x year x esa

        lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

        ; Fixed RC Coordinate
        sz = size(ytmp)
        yy = ytmp
        yy[*] = !values.d_nan
        yyidx = ytmp
        yyidx[*] = 0

        hp_mat = ytmp
        hp_mat[*] = !values.d_nan

        ec_lat = ytmp
        ec_lat[*] = !values.d_nan

        for yidx = 0, sz[2]-1 do begin

          peak_pos = [[lon_arr], [peak_lat_res[*, yidx]]]

          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
          LONEC = TMP.LON & LATEC = TMP.LAT
          ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
          ec_lat[*, yidx] = LATEC
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          dlon = lon_arr[1]-lon_arr[0]
          for lidx = 0, lon_arr.length-1 do begin
            idx = where(TMP1.LON ge lon_arr[lidx]-dlon/2 and TMP1.LON le lon_arr[lidx]+dlon/2, tmp)
            if tmp eq 0 then continue
            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
            yyidx[lidx, yidx] = tmp
            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
          endfor
        endfor
        ; Fixed RC Coordinate

        ytmp = yy

        data_available = total(finite(ytmp), 2)
        data_mean = mean(ytmp, dim = 2, /nan)
        q = quartile(ytmp, dim = 2)
        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
        ec_lat_sign = sign(ec_lat_mean)

        idx = where(data_available lt 5, /null)
        data_mean[idx] = !values.d_nan
        q[*, idx] = !values.d_nan

        p_HP = plot([0, 0], [0, 0], POS = POS2, /nodata, title = mom_str+', ESA'+esa_str+', '+str, xtickformat = '(a1)', ytitle = 'HP Dist. [AU]', font_size = 15, xr = [360, 0], yr = [100, 400], current = win)
        p_hp = plot(lon_arr, hp_dist_mean, over = p_HP, co = 'green', thick = 2)
        esidx = where(ec_lat_sign eq 1)
        p_hp0 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 0, name = 'EC North')
        esidx = where(ec_lat_sign eq -1)
        p_hp1 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 1, name = 'EC South')
        lgd = legend(target = [p_hp0, p_hp1], pos = [pos2[2]-0.03, pos2[3]-0.04], shadow = 0, linestyle = 6, sample_width = 0.05)

        p = plot([0, 0], [0, 0], POS = POS1, /nodata, xtitle = 'Lon_RC', ytitle = mom_str, font_size = 15, xr = [360, 0], yr = mrg, current = win)

        sz = size(ytmp)
        co = rgb_vector(sz[2], ct = 33)
        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)

        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)
        ff = findgen(256)
        cba = transpose([[ff], [ff], [ff]])
        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2021 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')

        win.Refresh
        win.save, file_tmp+'\'+STRCOMPRESS(fluxidx+9, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
        win.erase
      endfor ; esa

    endfor ; mom
  endfor ; ram
  ; ===================================================================== Ribbon Flux =====================================================================


  win.close
  ; ============================ Longitudinal Distribution of Moments ============================


end