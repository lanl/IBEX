pro RC_SUMMARY_PLOT_rand, MAPNAME, SEPNAME, VER, cpath
  tol = 1d-15

  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

  lon_hp = data.field1
  lat_hp = data.field2
  ts = data.field3
  hs = data.field4
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
    if sepname eq 'L' then YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
    if sepname eq 'D' then YEAR_MAX = 2019 ; ISOC = 2019, THESEUS = 2020
    lon_num = 60
  endif
  if mapname eq 'Theseus' then BEGIN
    YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
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
  ;      YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  ;      year_arr = [YEAR_MIN:YEAR_MAX]
  ;      year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]
  ;      lon_num = 180
  ;    endif


  fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
  fit_par_sig_circ = replicate(!values.d_nan, 3, year_arr.length, 5, 2); RLonLat x year x esa x ram

  fit_par_ellip = replicate(!values.d_nan, 6, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot,sig x year x esa x ram
  fit_par_sig_ellip = replicate(!values.d_nan, 5, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot x year x esa x ram


  moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit



  moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit


  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored\'
  file_tmp1 = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\'+ver+'\RC_Summary_mom_dist_colored\'

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, file_tmp
  FILE_MKDIR, file_tmp1


  ; data stacking
  for yidx = year_min, YEAR_MAX do begin
    FOR ram = 0, 0 DO BEGIN
      IF ram THEN str = 'ARam' ELSE str = 'Ram'

      year = string(yidx, format = '(I4)')
      restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

      ff = where(rc_e_PAR[*, 2] gt 170, /null, tmp)
      if tmp ne 0 then rc_e_PAR[ff, 2] = rc_e_PAR[ff, 2]-180

      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        if rc_c_lonlat[esa-2, 3] gt 0 then begin
          fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
          fit_par_sig_circ[*, (yidx-year_min), esa-2, ram] = reform([rc_c_PAR_SIG[esa-2, 0], rc_c_PAR_SIG[esa-2, 2], rc_c_PAR_SIG[esa-2, 1]]); RLonLat x year x esa
        endif

        if rc_e_lonlat[esa-2, 3] gt 0 then begin
          b = reform(rc_e_PAR[esa-2, 1])
          a = reform(rc_e_PAR[esa-2, 0])
          db = reform(rc_E_PAR_SIG[esa-2, 1])
          da = reform(rc_E_PAR_SIG[esa-2, 0])

          r = b/a
          dr = sqrt((db/a)^2 + (b*da/a^2)^2)

          deccentricity = r/sqrt(1-r^2)*dr

          fit_par_ellip[*, (yidx-year_min), esa-2, ram] = [reform(rc_e_lonlat[esa-2, 0:2]), sqrt(1-(b/a)^2), reform(rc_e_PAR[esa-2, 2]), reform(rc_e_lonlat[esa-2, 3])]; R,Lon,Lat,Ellip,Rot,sig x year x esa

          fit_par_sig_ellip[*, (yidx-year_min), esa-2, ram] = $
            [reform(sqrt(rc_E_PAR_SIG[esa-2, 0]^2+rc_E_PAR_SIG[esa-2, 1]^2)), $ ;R
            reform(rc_E_PAR_SIG[esa-2, 4]), $ ;Lon
            reform(rc_E_PAR_SIG[esa-2, 3]), $ ;Lat
            reform(deccentricity), $
            ;            sqrt(reform((reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2*sqrt(2/rc_e_PAR[esa-2, 0]^2*rc_E_PAR_SIG[esa-2, 0]^2 + 2/rc_e_PAR[esa-2, 1]^2*rc_E_PAR_SIG[esa-2, 1]^2))), $ ;Ellip
            reform(rc_E_PAR_SIG[esa-2, 2])] ; Rot
        endif


        ;eccentricity error propagation for record
        ;sqrt(reform((reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2*sqrt(2/rc_e_PAR[esa-2, 0]^2*rc_E_PAR_SIG[esa-2, 0]^2 + 2/rc_e_PAR[esa-2, 1]^2*rc_E_PAR_SIG[esa-2, 1]^2))), $ ;Ellip

        ;        reform(rc_e_PAR[esa-2, 1]/rc_e_PAR[esa-2, 0] * sqrt((rc_E_PAR_SIG[esa-2, 0]/rc_e_PAR[esa-2, 0])^2+(rc_E_PAR_SIG[esa-2, 1]/rc_e_PAR[esa-2, 1])^2)) ; ellipticity

        !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
        !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
        !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')

        !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
        !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
        !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')



      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking

  RC_azi = lon_arr[0:lon_arr.length/2 - 1]
  ribbon_diameter = peak_lat[0:lon_arr.length/2 - 1, *, *]+peak_lat[lon_arr.length/2:lon_arr.length-1, *, *]


  Tail_POS = replicate(!values.d_nan, 2, year_arr.length, 5, 2); Lon&Lat x year x esa x ram, only for circle fit
  for yidx = 2009, 2022 do begin
    for ram = 0, 0 do begin
      for esa = 2, 6 do begin
        PP_TMP = peak_lat[*, (yidx-year_min), esa-2, ram]

        lon_tmp = reform(fit_par_ellip[1, yidx-2009, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, yidx-2009, esa-2, ram])

        idx = [80:130]
        tmp = max(PP_TMP[idx], minidx)

        lon_tail = lon_arr[idx[minidx]]
        lat_tail = tmp

        TMP = conv_coord_ec_rc(lon_tail, lat_tail, lon_tmp, lat_tmp, /REVERSE)
        LONEC = TMP.LON & LATEC = TMP.LAT
        Tail_pos[*, (yidx-year_min), esa-2, ram] = [lonec, latec]
      endfor
    endfor
  endfor


  BV = GreatCircle([255.6, 5.14], [226.99, 34.82], npath = 1000) ; ISMF 227.28, 34.62 Zirnstein et al. 2016b 2023, nose direction 259, 5 Funsten et al. 2013
  e_step = [0.71,1.11,1.74,2.73,4.29]
  ; ============================ Ribbon Center Pos/Radius ============================
  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      ; RLonLatsig x year x esa x model x ab x ram

      ; 1111111111 Angular radius 1111111111
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', xtickinterval:2, xminor:1, current:1, font_size:20, xtitle:'Year', ytitle:'Angular Radius [$\deg$]', xr:[year_min-1, year_max+1], yr:[65, 90]}
      ;     Circle fit
      ;      p = errorplot(year_arr_tmp, fit_par_circ[0, *, esa-2, ram], sqrt((fit_par_sig_circ[0, *, esa-2, ram])^2+fit_par_circ[3, *, esa-2, ram]^2), color = 'blue', _extra = extram, title = 'Angular radius, '+'ESA'+esa_str+', '+str)
      p = errorplot(year_arr_tmp, fit_par_ellip[0, *, esa-2, ram], sqrt((fit_par_sig_ellip[0, *, esa-2, ram])^2+fit_par_ellip[5, *, esa-2, ram]^2), color = 'black', _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')

      win.refresh
      win.save, file_tmp+'RC_Radius_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      win.save, file_tmp1+'RC_Radius_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      win.erase
      ; 1111111111 Angular radius 1111111111

      ; 2222222222 RC 2222222222
      ;     Circle fit
      z_tmp_byt = bytscl(year_arr_tmp, min = year_min, max = year_max+1)

      lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])
      lon_error_tmp = reform(fit_par_sig_ellip[1, *, esa-2, ram]) & lat_error_tmp = reform(fit_par_sig_ellip[2, *, esa-2, ram])

      ;      extram = {symbol:'*', sym_thick:0, SYM_COLOR:'BLACK', sym_filled:1, xr:[year_min-1, year_max+1], yr:[200, 240], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:20, xtitle:'Year', ytitle:'Lon$_{EC}$'}
      ;      p = errorplot(year_arr_tmp, lon_tmp, lon_error_tmp, color = 'black', _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      ;      win.refresh
      ;      win.save, file_tmp+'RC_position_Lon_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_position_Lon_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase

      ;      extram = {symbol:'*', sym_thick:0, SYM_COLOR:'BLACK', sym_filled:1, xr:[year_min-1, year_max+1], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:20, xtitle:'Year', ytitle:'Lat$_{EC}$'}
      ;      p = errorplot(year_arr_tmp, lat_tmp, lat_error_tmp, color = 'black', _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      ;      win.refresh
      ;      win.save, file_tmp+'RC_position_Lat_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_position_Lat_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase


      ;      extram = {symbol:'CIRCLE', sym_thick:1, SYM_COLOR:'BLACK', magnitude:z_tmp_byt, rgb_table:33, sym_filled:1, xr:[240, 200], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      ;      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram, title = 'RC position in EC, ESA'+esa_str+', '+str)
      ;      for ll = 0, lon_tmp.length-1 do begin
      ;        pe = plot([lon_tmp[ll]-lon_error_tmp[ll]/2, lon_tmp[ll]+lon_error_tmp[ll]/2], [lat_tmp[ll], lat_tmp[ll]], over = p1, COLOR = 'GRAY')
      ;        pe = plot([lon_tmp[ll], lon_tmp[ll]], [lat_tmp[ll]-lat_error_tmp[ll]/2, lat_tmp[ll]+lat_error_tmp[ll]/2], over = p1, COLOR = 'GRAY')
      ;      endfor
      ;      ;      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram, title = 'RC position in EC, ESA'+esa_str+', '+str)
      ;      pbv = plot(BV[0, *], BV[1, *], over = p1[0], linestyle = 2, thick = 2)
      ;      pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p1[0], symbol = '*', sym_size = 2)
      ;      tx = text(226.99, 34.82, 'B', /data, font_size = 14)
      ;      tx = text(235, 30., 'B-V plane', /data, font_size = 14, orientation = 45.)
      ;      cb = color_bar(p1, ytickformat = '(a1)', yticklen = 0, yminor = 0)

      extram = {symbol:'thin_diamond', sym_thick:0, sym_size:2, SYM_COLOR:'BLACK', magnitude:z_tmp_byt, rgb_table:33, sym_filled:1, xr:[230, 200], yr:[25, 50], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:20, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])
      lon_error_tmp = reform(fit_par_sig_ellip[1, *, esa-2, ram]) & lat_error_tmp = reform(fit_par_sig_ellip[2, *, esa-2, ram])
      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      co_tmp = rgb_vector(lon_tmp.length, ct = 33)
      for ll = 0, lon_tmp.length-1 do begin
        pe = plot([lon_tmp[ll]-lon_error_tmp[ll], lon_tmp[ll]+lon_error_tmp[ll]], [lat_tmp[ll], lat_tmp[ll]], over = p1, co = co_tmp[*, ll])
        pe = plot([lon_tmp[ll], lon_tmp[ll]], [lat_tmp[ll]-lat_error_tmp[ll], lat_tmp[ll]+lat_error_tmp[ll]], over = p1, co = co_tmp[*, ll])
      endfor
      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram)

      ;      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram)
      pbv = plot(BV[0, *], BV[1, *], over = p1[0], linestyle = 2, thick = 2)
      pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p1[0], symbol = '*', sym_size = 2)
      tx = text(227, 35, 'B', /data, font_size = 15)
      ;      tx = text(235, 30., 'B-V plane', /data, font_size = 14, orientation = 42.)
      tx = text(225, 34.5, 'B-V plane', /data, font_size = 15, orientation = 41.)


      ;      cb = color_bar(p1, ytickformat = '(a1)', yticklen = 0, yminor = 0)
      ;      yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[year_min, (year_max+1 - year_min)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')
      CB_TMP1 = [2009:2022]
      CB_TMP2 = transpose(REBIN(CB_TMP1, CB_TMP1.length, 3))
      CB = SPEC_PLOT(CB_TMP2, FINDGEN(3), CB_TMP1, title = 'Year', font_size = 14, ybound = [[CB_TMP1-0.5], [CB_TMP1+0.5]], yr = [2008.5, 2022.5], xr = [0, 2], YTICKINTERVAL = 1, YMINOR = 0, XTICKLEN = 0, XTICKFORMAT = '(a1)', YTICKFORMAT = '(a1)', CURRENT = win, POS = [P1.POSITION[2]+0.02, P1.POSITION[1], P1.POSITION[2]+0.04, P1.POSITION[3]], rgb_table = 33)
      ax = axis('Y', target = cb, location = 'right', tickfont_size = 14, tickinterval = 1)



      ;      print, esa, ram, total(lon_tmp/lon_error_tmp)/total(1/lon_error_tmp), total(lat_tmp/lat_error_tmp)/total(1/lat_error_tmp)
      ;      print, esa, ram, sqrt(mean(lon_error_tmp^2)), sqrt(mean(lat_error_tmp^2))


      win.refresh
      win.save, file_tmp+'RC_position_Circ_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      win.save, file_tmp1+'RC_position_Circ_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      win.erase
      ; 2222222222 RC 2222222222


      ; 2-1 2-1 2-1 tail position 2-1 2-1 2-1
      ;     Circle fit
      z_tmp_byt = bytscl(year_arr_tmp, min = year_min, max = year_max+1)


      extram = {symbol:'thin_diamond', sym_thick:0, sym_size:2, SYM_COLOR:'BLACK', magnitude:z_tmp_byt, rgb_table:33, sym_filled:1, xr:[150, 50], yr:[0, 50], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:20, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      lon_tmp = reform(Tail_pos[0, *, esa-2, ram]) & lat_tmp = reform(Tail_pos[1, *, esa-2, ram])

      p1 = scatterplot(lon_tmp, lat_tmp, _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')

      pbv = plot(BV[0, *], BV[1, *], over = p1[0], linestyle = 2, thick = 2)
      pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p1[0], symbol = '*', sym_size = 2)
      tx = text(227, 35, 'B', /data, font_size = 15)
      ;      tx = text(235, 30., 'B-V plane', /data, font_size = 14, orientation = 42.)
      tx = text(225, 34.5, 'B-V plane', /data, font_size = 15, orientation = 41.)

      ;      cb = color_bar(p1, ytickformat = '(a1)', yticklen = 0, yminor = 0)
      ;      yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[year_min, (year_max+1 - year_min)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')
      CB_TMP1 = [2009:2022]
      CB_TMP2 = transpose(REBIN(CB_TMP1, CB_TMP1.length, 3))
      CB = SPEC_PLOT(CB_TMP2, FINDGEN(3), CB_TMP1, title = '                  Year', font_size = 14, ybound = [[CB_TMP1-0.5], [CB_TMP1+0.5]], yr = [2008.5, 2022.5], xr = [0, 2], YTICKINTERVAL = 1, YMINOR = 0, XTICKLEN = 0, XTICKFORMAT = '(a1)', YTICKFORMAT = '(a1)', CURRENT = win, POS = [P1.POSITION[2]+0.02, P1.POSITION[1], P1.POSITION[2]+0.04, P1.POSITION[3]], rgb_table = 33)
      ax = axis('Y', target = cb, location = 'right', tickfont_size = 14, tickinterval = 1)




      win.refresh
      win.save, file_tmp+'Tail_position_Circ_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      win.save, file_tmp1+'Tail_position_Circ_Ellip_year_ESA'+esa_str+'_fit_'+str+'.png'
      win.erase
      ; 2-1 2-1 2-1 tail position 2-1 2-1 2-1

      ; 3333333333 Ellipticity 3333333333
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', xtickinterval:2, xminor:1, current:1, font_size:20, xtitle:'Year', ytitle:'Eccentricity $\epsilon$', xr:[year_min-1, year_max+1], yr:[0.1, 0.6]}
        ;     Circle fit
        p = errorplot(year_arr_tmp, fit_par_ellip[3, *, esa-2, ram], fit_par_sig_ellip[3, *, esa-2, ram], _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      win.refresh
      win.save, file_tmp+'RC_Eccentricity_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      win.save, file_tmp1+'RC_Eccentricity_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      win.erase
      ; 3333333333 Ellipticity 3333333333

      ;      ; 4444444444 Rotation Angle 4444444444
      ;      win = window(dim = [800, 600], /buffer)
      ;      win.refresh, /disable
      ;      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Year', ytitle:'Rotation Angle', xr:[year_min-1, year_max+1], yr:[-20, 160]}
      ;      ;     Circle fit
      ;
      ;      ;      if esa eq 5 then begin
      ;      ;        idx = where(fit_par_ellip[4, *, esa-2, ram] gt 150)
      ;      ;        fit_par_ellip[4, idx, esa-2, ram] = fit_par_ellip[4, idx, esa-2, ram]-180
      ;      ;      endif
      ;
      ;      par_angle = replicate(!values.f_nan, year_arr_tmp.length)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        ; Convert points to Cartesian coordinates
      ;        ;      meridional plane crossing RC
      ;        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat1 = 0d*!DTOR
      ;        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;        lon3 = 259d*!DTOR ; nose
      ;        lat3 = 5d*!DTOR ; nose
      ;        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;
      ;        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
      ;        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
      ;        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
      ;        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]
      ;
      ;        ; Compute normal vectors for the planes of the great circles
      ;        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
      ;        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle
      ;
      ;        ; Normalize the normal vectors
      ;        n1 = n1 / SQRT(TOTAL(n1^2))
      ;        n2 = n2 / SQRT(TOTAL(n2^2))
      ;
      ;        ; Compute the dot product of the normal vectors
      ;        dot_product = TOTAL(n1 * n2)
      ;
      ;        ; Compute the angle between the two planes
      ;        angle = ACOS(dot_product)  ; Angle in radians
      ;
      ;        ; Convert the angle to degrees
      ;        angle = angle * (180.0 / !PI)
      ;        par_angle[yy] = angle
      ;      endfor
      ;
      ;      par_angle = 180-par_angle
      ;      p = errorplot(year_arr_tmp, fit_par_ellip[4, *, esa-2], fit_par_sig_ellip[4, *, esa-2], _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      ;      ;    p = plot([year_min-1, 2023], [35, 35], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;    p = plot([year_min-1, 2023], [125, 125], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot(year_arr_tmp, par_angle, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot(year_arr_tmp, par_angle-90, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      tx = text(2008, par_angle[0]-90+1, 'perpendicular to NS', /data, font_size = 15)
      ;      tx = text(2008, par_angle[0]+1, 'parallel to NS', /data, font_size = 15)
      ;
      ;      ;      p = errorplot(year_arr_tmp, fit_par_ellip[4, *, esa-2, ram], fit_par_sig_ellip[4, *, esa-2, ram], _extra = extram, title = 'Rotation Angle, ESA'+esa_str+', '+str)
      ;      ;      p = plot([year_min-1, year_max+1], [35, 35], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      p = plot([year_min-1, year_max+1], [125, 125], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      tx = text(2008, 36, 'perpendicular to NS', /data, font_size = 12)
      ;      ;      tx = text(2008, 126, 'parallel to NS', /data, font_size = 12)
      ;      win.refresh
      ;      win.save, file_tmp+'RC_RotationAngle_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_RotationAngle_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase
      ;      ; 4444444444 Rotation Angle 4444444444


      ;      ; 5555555555 Rotation Angle 5555555555
      ;      win = window(dim = [800, 600], /buffer)
      ;      win.refresh, /disable
      ;      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', xtickinterval:2, xminor:1, current:1, font_size:20, xtitle:'Year', ytitle:'Rotation Angle $\rho$', xr:[year_min-1, year_max+1], yr:[-45, 195]}
      ;        ;     Circle fit
      ;
      ;        ;      if esa eq 5 then begin
      ;        ;        idx = where(fit_par_ellip[4, *, esa-2, ram] gt 150)
      ;        ;        fit_par_ellip[4, idx, esa-2, ram] = fit_par_ellip[4, idx, esa-2, ram]-180
      ;        ;      endif
      ;
      ;        par_angle = replicate(!values.f_nan, year_arr_tmp.length)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        ; Convert points to Cartesian coordinates
      ;        ;      meridional plane crossing RC
      ;        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat1 = 0d*!DTOR
      ;        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;        lon3 = 259d*!DTOR ; nose
      ;        lat3 = 5d*!DTOR ; nose
      ;        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;
      ;        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
      ;        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
      ;        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
      ;        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]
      ;
      ;        ; Compute normal vectors for the planes of the great circles
      ;        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
      ;        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle
      ;
      ;        ; Normalize the normal vectors
      ;        n1 = n1 / SQRT(TOTAL(n1^2))
      ;        n2 = n2 / SQRT(TOTAL(n2^2))
      ;
      ;        ; Compute the dot product of the normal vectors
      ;        dot_product = TOTAL(n1 * n2)
      ;
      ;        ; Compute the angle between the two planes
      ;        angle = ACOS(dot_product)  ; Angle in radians
      ;
      ;        ; Convert the angle to degrees
      ;        angle = angle * (180.0 / !PI)
      ;        par_angle[yy] = angle
      ;      endfor
      ;
      ;
      ;      angle_tmp = reform(fit_par_ellip[4, *, esa-2])+par_angle
      ;
      ;      aidx = where(angle_tmp lt 0 or angle_tmp gt 180, tmp)
      ;
      ;      if tmp ne 0 then begin
      ;        for aa = 0, aidx.length-1 do begin
      ;          while angle_tmp[aidx[aa]] lt 0 or angle_tmp[aidx[aa]] gt 180 do begin
      ;            if angle_tmp[aidx[aa]] lt 0 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] + 180
      ;            if angle_tmp[aidx[aa]] gt 180 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] - 180
      ;          endwhile
      ;        endfor
      ;      endif
      ;      ;    angle_tmp
      ;
      ;
      ;
      ;      p = errorplot(year_arr_tmp, angle_tmp, fit_par_sig_ellip[4, *, esa-2], _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      ;      p = plot(p.xr, replicate(90, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot(p.xr, replicate(0, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      tx = text(2008, 90+1, 'Perpendicular to NS', /data, font_size = 15)
      ;      tx = text(2008, 0+1, 'Parallel to NS', /data, font_size = 15)
      ;
      ;      ;      p = errorplot(year_arr_tmp, fit_par_ellip[4, *, esa-2, ram], fit_par_sig_ellip[4, *, esa-2, ram], _extra = extram, title = 'Rotation Angle, ESA'+esa_str+', '+str)
      ;      ;      p = plot([year_min-1, year_max+1], [35, 35], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      p = plot([year_min-1, year_max+1], [125, 125], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      tx = text(2008, 36, 'perpendicular to NS', /data, font_size = 12)
      ;      ;      tx = text(2008, 126, 'parallel to NS', /data, font_size = 12)
      ;      win.refresh
      ;      win.save, file_tmp+'RC_RotationAngle_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'_fromNS.png'
      ;      win.save, file_tmp1+'RC_RotationAngle_Circ_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'_fromNS.png'
      ;      win.erase
      ;      ; 5555555555 Rotation Angle 5555555555


      ;      ; 4444444444 Rotation Angle 4444444444
      ;      win = window(dim = [800, 600], /buffer)
      ;      win.refresh, /disable
      ;      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Year', ytitle:'Rotation Angle', xr:[year_min-1, year_max+1], yr:[-20, 160]}
      ;      res = linfit(year_arr_tmp, reform(fit_par_ellip[4, *, esa-2, 0]), measure_errors = reform(fit_par_sig_ellip[4, *, esa-2, 0]), yfit = yfit, sigma = sigma)
      ;      p = errorplot(year_arr_tmp, fit_par_ellip[4, *, esa-2, ram], fit_par_sig_ellip[4, *, esa-2, ram], _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      ;      p = plot(year_arr_tmp, yfit, over = p, co = 'gray', thick = 2)
      ;      tx = text(2015, 100, 'dROT/dt = '+string(res[1], format = '(f5.2)')+'$\deg$/year $\pm$'+string(sigma[1], format = '(f5.2)')+'$\deg$/year', /data, font_size = 15)
      ;
      ;        par_angle = replicate(!values.f_nan, year_arr_tmp.length)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        ; Convert points to Cartesian coordinates
      ;        ;      meridional plane crossing RC
      ;        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat1 = 0d*!DTOR
      ;        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;        lon3 = 259d*!DTOR ; nose
      ;        lat3 = 5d*!DTOR ; nose
      ;        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;
      ;        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
      ;        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
      ;        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
      ;        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]
      ;
      ;        ; Compute normal vectors for the planes of the great circles
      ;        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
      ;        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle
      ;
      ;        ; Normalize the normal vectors
      ;        n1 = n1 / SQRT(TOTAL(n1^2))
      ;        n2 = n2 / SQRT(TOTAL(n2^2))
      ;
      ;        ; Compute the dot product of the normal vectors
      ;        dot_product = TOTAL(n1 * n2)
      ;
      ;        ; Compute the angle between the two planes
      ;        angle = ACOS(dot_product)  ; Angle in radians
      ;
      ;        ; Convert the angle to degrees
      ;        angle = angle * (180.0 / !PI)
      ;        par_angle[yy] = angle
      ;      endfor
      ;      par_angle = 180-par_angle
      ;      p = errorplot(year_arr_tmp, fit_par_ellip[4, *, esa-2], fit_par_sig_ellip[4, *, esa-2], _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      ;      ;    p = plot([year_min-1, 2023], [35, 35], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;    p = plot([year_min-1, 2023], [125, 125], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot(year_arr_tmp, par_angle, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot(year_arr_tmp, par_angle-90, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      tx = text(2008, par_angle[0]-90+1, 'perpendicular to NS', /data, font_size = 15)
      ;      tx = text(2008, par_angle[0]+1, 'parallel to NS', /data, font_size = 15)
      ;
      ;      ;        p = plot([year_min-1, year_max+1], [35, 35], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      p = plot([year_min-1, year_max+1], [125, 125], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      tx = text(2008, 36, 'perpendicular to NS', /data, font_size = 12)
      ;      ;      tx = text(2008, 126, 'parallel to NS', /data, font_size = 12)
      ;      win.refresh
      ;      win.save, file_tmp+'RC_RotationAngle_Ellip_1sig_LINFIT_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_RotationAngle_Ellip_1sig_LINFIT_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase
      ;      ; 4444444444 Rotation Angle 4444444444


      ; 555555555 Rotation Angle 555555555
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Year', ytitle:'Rotation Angle $\rho$', xr:[year_min-1, year_max+1], yr:[-45, 195]}
        if esa eq 6 then extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Year', ytitle:'Rotation Angle $\rho$', xr:[year_min-1, year_max+1], yr:[10, 250]}


        par_angle = replicate(!values.f_nan, year_arr_tmp.length)
      for yy = 0, year_arr_tmp.length-1 do begin
        ; Convert points to Cartesian coordinates
        ;      meridional plane crossing RC
        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
        lat1 = 0d*!DTOR
        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR

        lon3 = 259d*!DTOR ; nose
        lat3 = 5d*!DTOR ; nose
        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR


        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]

        ; Compute normal vectors for the planes of the great circles
        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle

        ; Normalize the normal vectors
        n1 = n1 / SQRT(TOTAL(n1^2))
        n2 = n2 / SQRT(TOTAL(n2^2))

        ; Compute the dot product of the normal vectors
        dot_product = TOTAL(n1 * n2)

        ; Compute the angle between the two planes
        angle = ACOS(dot_product)  ; Angle in radians

        ; Convert the angle to degrees
        angle = angle * (180.0 / !PI)
        par_angle[yy] = angle
      endfor


      angle_tmp = reform(fit_par_ellip[4, *, esa-2, 0])+par_angle


      aidx = where(angle_tmp lt 0 or angle_tmp gt 180, tmp)

      if tmp ne 0 then begin
        for aa = 0, aidx.length-1 do begin
          while angle_tmp[aidx[aa]] lt 0 or angle_tmp[aidx[aa]] gt 180 do begin
            if angle_tmp[aidx[aa]] lt 0 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] + 180
            if angle_tmp[aidx[aa]] gt 180 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] - 180
          endwhile
        endfor
      endif

      if esa eq 6 then begin
        angle_tmp[4:10] = angle_tmp[4:10]+180
        angle_tmp[-1] = angle_tmp[-1]+180
      endif
      ;    angle_tmp



      res = linfit(year_arr_tmp, angle_tmp, measure_errors = reform(fit_par_sig_ellip[4, *, esa-2, 0]), yfit = yfit, sigma = sigma)
      p = errorplot(year_arr_tmp, angle_tmp, fit_par_sig_ellip[4, *, esa-2, ram], _extra = extram, title = string(e_step[esa-2], format = '(f4.2)')+'keV')
      p = plot(year_arr_tmp, yfit, over = p, co = 'sky blue', thick = 3)
      if esa ne 6 then $
        tx = text(2015, 10, 'd$\rho$/dt = '+string(res[1], format = '(f6.2)')+'$\deg$/yr $\pm$'+string(sigma[1], format = '(f5.2)')+'$\deg$/yr', /data, font_size = 15) $
      else $
        tx = text(2015, 50, 'd$\rho$/dt = '+string(res[1], format = '(f6.2)')+'$\deg$/yr $\pm$'+string(sigma[1], format = '(f5.2)')+'$\deg$/yr', /data, font_size = 15)



        p = plot(p.xr, replicate(0, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      tx = text(2008, 0+1, 'Parallel to NS', /data, font_size = 15)
      p = plot(p.xr, replicate(180, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      tx = text(2008, 180+1, 'Parallel to NS', /data, font_size = 15)

      p = plot(p.xr, replicate(90, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      tx = text(2008, 90+1, 'Perpendicular to NS', /data, font_size = 15)




      ;        p = plot([year_min-1, year_max+1], [35, 35], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot([year_min-1, year_max+1], [125, 125], linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      tx = text(2008, 36, 'perpendicular to NS', /data, font_size = 12)
      ;      tx = text(2008, 126, 'parallel to NS', /data, font_size = 12)
      win.refresh
      win.save, file_tmp+'RC_RotationAngle_Ellip_1sig_LINFIT_ESA'+esa_str+'_fit_'+str+'_fromNS.png'
      win.save, file_tmp1+'RC_RotationAngle_Ellip_1sig_LINFIT_ESA'+esa_str+'_fit_'+str+'_fromNS.png'
      win.erase
      ; 555555555 Rotation Angle 555555555
    endfor; esa


    for yidx = year_min, year_max do begin
      year = string(yidx, format = '(I4)')
      ; 1111111111 Angular radius 1111111111

      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy', xlog:1, ytitle:'Angular Radius', xr:[0.5, 5], yr:[65, 90]}
      ;     Circle fit
      ;      p = errorplot(e_step, fit_par_circ[0, (yidx-year_min), *, ram], sqrt((fit_par_sig_circ[0, (yidx-year_min), *, ram])^2+fit_par_circ[3, (yidx-year_min), *, ram]^2), color = 'blue', _extra = extram, title = 'Angular radius, '+year+', '+str)
      p = errorplot(e_step, fit_par_ellip[0, (yidx-year_min), *, ram], sqrt((fit_par_sig_ellip[0, (yidx-year_min), *, ram])^2+fit_par_ellip[5, (yidx-year_min), *, ram]^2), color = 'black', _extra = extram, title = year)
      win.refresh
      win.save, file_tmp+'RC_Radius_Circ_Ellip_1sig_year'+year+'_fit_'+str+'.png'
      win.save, file_tmp1+'RC_Radius_Circ_Ellip_1sig_year'+year+'_fit_'+str+'.png'
      win.close
      ; 1111111111 Angular radius 1111111111

      ; 2222222222 RC 2222222222
      ; RLonLatsig x year x esa x model
      co = ['blue', 'green', 'yellow', 'orange', 'red']
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      ;     Circle fit

      ;      extram = {symbol:'CIRCLE', sym_thick:1, sym_filled:1, xr:[240, 200], yr:[25, 55], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:15, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      ;      lon_tmp = reform(fit_par_circ[1, (yidx-year_min), *, ram]) & lat_tmp = reform(fit_par_circ[2, (yidx-year_min), *, ram])
      ;      lon_error_tmp = reform(fit_par_sig_circ[1, (yidx-year_min), *, ram]) & lat_error_tmp = reform(fit_par_sig_circ[2, (yidx-year_min), *, ram])
      ;
      ;      p1 = objarr(5)
      ;      for esa = 2, 6 do begin
      ;        p1[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, title = 'RC position in EC,'+year, name = 'ESA'+strcompress(esa, /rem)+', Circ')
      ;        pe = plot([lon_tmp[esa-2]-lon_error_tmp[esa-2]/2, lon_tmp[esa-2]+lon_error_tmp[esa-2]/2], [lat_tmp[esa-2], lat_tmp[esa-2]], over = p1[esa-2], COLOR = 'GRAY')
      ;        pe = plot([lon_tmp[esa-2], lon_tmp[esa-2]], [lat_tmp[esa-2]-lat_error_tmp[esa-2]/2, lat_tmp[esa-2]+lat_error_tmp[esa-2]/2], over = p1[esa-2], COLOR = 'GRAY')
      ;        ;        p1[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, title = 'RC position in EC,'+year, name = 'ESA'+strcompress(esa, /rem)+', Circ')
      ;      endfor
      ;      p = plot(lon_tmp, lat_tmp, over = p1[0])
      ;      sc = scatterplot(replicate(mean(lon_tmp, /nan), 2), replicate(mean(lat_tmp, /nan), 2), over = p1[0], SYM_COLOR = 'BLACK', sym_FILL_color = 'black', _extra = extram)
      ;      pbv = plot(BV[0, *], BV[1, *], over = p1[0], linestyle = 2, thick = 2)
      ;      pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p1[0], symbol = '*', sym_size = 2)
      ;      tx = text(226.99, 34.82, 'B', /data, font_size = 14)
      ;      tx = text(235, 30., 'B-V plane', /data, font_size = 14, orientation = 45.)

      extram = {symbol:'thin_diamond', sym_thick:0, sym_size:2, sym_filled:1, xr:[230, 200], yr:[27, 47], current:win, pos:[0.1, 0.1, 0.8, 0.9], font_size:20, xtitle:'Lon$_{EC}$', ytitle:'Lat$_{EC}$'}
      lon_tmp = reform(fit_par_ellip[1, (yidx-year_min), *, ram]) & lat_tmp = reform(fit_par_ellip[2, (yidx-year_min), *, ram])
      lon_error_tmp = reform(fit_par_sig_ellip[1, (yidx-year_min), *, ram]) & lat_error_tmp = reform(fit_par_sig_ellip[2, (yidx-year_min), *, ram])
      p2 = objarr(5)
      for esa = 2, 6 do begin
        p2[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = co[esa-2], sym_FILL_color = co[esa-2], _extra = extram, title = year, name = string(e_step[esa-2], format = '(f4.2)')+'keV')
        pe = plot([lon_tmp[esa-2]-lon_error_tmp[esa-2]/2, lon_tmp[esa-2]+lon_error_tmp[esa-2]/2], [lat_tmp[esa-2], lat_tmp[esa-2]], over = p2[esa-2], COLOR = co[esa-2])
        pe = plot([lon_tmp[esa-2], lon_tmp[esa-2]], [lat_tmp[esa-2]-lat_error_tmp[esa-2]/2, lat_tmp[esa-2]+lat_error_tmp[esa-2]/2], over = p2[esa-2], COLOR = co[esa-2])
        p2[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = co[esa-2], sym_FILL_color = co[esa-2], _extra = extram, title = year, name = string(e_step[esa-2], format = '(f4.2)')+'keV')
        ;        p2[esa-2] = scatterplot(replicate(lon_tmp[esa-2], 2), replicate(lat_tmp[esa-2], 2), SYM_COLOR = 'BLACK', sym_FILL_color = co[esa-2], _extra = extram, name = 'ESA'+strcompress(esa, /rem)+', Ellip')
      endfor
      p = plot(lon_tmp, lat_tmp, over = p2[0])
      sc = scatterplot(replicate(mean(lon_tmp, /nan), 2), replicate(mean(lat_tmp, /nan), 2), over = p2[0], SYM_COLOR = 'BLACK', sym_FILL_color = 'black', _extra = extram)
      pbv = plot(BV[0, *], BV[1, *], over = p, linestyle = 2, thick = 2)
      pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p, symbol = '*', sym_size = 2)
      tx = text(227, 35, 'B', /data, font_size = 15)
      tx = text(225, 34.5, 'B-V plane', /data, font_size = 15, orientation = 41.)

      lgd = legend(position = [0.30, 0.8], target = [p2], shadow = 0, linestyle = 6, sample_width = 0, color = 0, transparency = 100)
      win.refresh
      win.save, file_tmp+'RC_position_Circ_Ellip_energy_year'+year+'_fit_'+str+'.png'
      win.save, file_tmp1+'RC_position_Circ_Ellip_energy_year'+year+'_fit_'+str+'.png'
      win.close
      ; 2222222222 RC 2222222222

      ; 3333333333 Ellipticity 3333333333
      win = window(dim = [800, 600], /buffer)
      win.refresh, /disable
      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy', xlog:1, ytitle:'Eccentricity $\epsilon$', xr:[0.5, 5], yr:[0.1, 0.6]}
        p = errorplot(e_step, fit_par_ellip[3, (yidx-year_min), *, ram], fit_par_sig_ellip[3, (yidx-year_min), *, ram], _extra = extram, title = year)
      win.refresh
      win.save, file_tmp+'RC_Eccentricity_Circ_Ellip_1sig_year'+year+'_fit_'+str+'.png'
      win.save, file_tmp1+'RC_Eccentricity_Circ_Ellip_1sig_year'+year+'_fit_'+str+'.png'
      win.close
      ; 3333333333 Ellipticity 3333333333

      ;      ;      ; 4444444444 Rotation Angle 4444444444
      ;      ;      win = window(dim = [800, 600], /buffer)
      ;      ;      win.refresh, /disable
      ;      ;      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy', xlog:1, ytitle:'Rotation Angle', xr:[0.5, 5], yr:[-20, 160]}
      ;      ;      p = errorplot(e_step, fit_par_ellip[4, (yidx-year_min), *, ram], fit_par_sig_ellip[4, (yidx-year_min), *, ram], _extra = extram, title = year)
      ;      ;
      ;      ;
      ;      ;      yy = yidx-year_min
      ;      ;      par_angle_arr = replicate(!values.f_nan, 5)
      ;      ;      for esa = 2, 6 do begin
      ;      ;        ; Convert points to Cartesian coordinates
      ;      ;        ;      meridional plane crossing RC
      ;      ;        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;      ;        lat1 = 0d*!DTOR
      ;      ;        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;      ;        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;      ;
      ;      ;        lon3 = 259d*!DTOR ; nose
      ;      ;        lat3 = 5d*!DTOR ; nose
      ;      ;        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;      ;        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;      ;
      ;      ;
      ;      ;        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
      ;      ;        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
      ;      ;        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
      ;      ;        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]
      ;      ;
      ;      ;        ; Compute normal vectors for the planes of the great circles
      ;      ;        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
      ;      ;        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle
      ;      ;
      ;      ;        ; Normalize the normal vectors
      ;      ;        n1 = n1 / SQRT(TOTAL(n1^2))
      ;      ;        n2 = n2 / SQRT(TOTAL(n2^2))
      ;      ;
      ;      ;        ; Compute the dot product of the normal vectors
      ;      ;        dot_product = TOTAL(n1 * n2)
      ;      ;
      ;      ;        ; Compute the angle between the two planes
      ;      ;        angle = ACOS(dot_product)  ; Angle in radians
      ;      ;
      ;      ;        ; Convert the angle to degrees
      ;      ;        angle = angle * (180.0 / !PI)
      ;      ;        par_angle = angle
      ;      ;        par_angle = 180-par_angle
      ;      ;        par_angle_arr[esa-2] = par_angle
      ;      ;      endfor
      ;      ;      p = errorplot(e_step, fit_par_ellip[4, (yidx-year_min), *], fit_par_sig_ellip[4, (yidx-year_min), *], _extra = extram, title = ''+year+', '+str)
      ;      ;
      ;      ;      p = plot(e_step, par_angle_arr, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      p = plot(e_step, par_angle_arr-90, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      ;      tx = text(0.5, par_angle_arr[0]-90+1, 'perpendicular to NS', /data, font_size = 15)
      ;      ;      tx = text(0.5, par_angle_arr[0]+1, 'parallel to NS', /data, font_size = 15)
      ;      ;
      ;      ;
      ;      ;      win.refresh
      ;      ;      win.save, file_tmp+'RC_RotationAngle_Circ_Ellip_1sig_year'+year+'_fit_'+str+'.png'
      ;      ;      win.save, file_tmp1+'RC_RotationAngle_Circ_Ellip_1sig_year'+year+'_fit_'+str+'.png'
      ;      ;      win.close
      ;      ;      ; 4444444444 Rotation Angle 4444444444
      ;
      ;
      ;      ; 5555555555 Rotation Angle 5555555555
      ;      win = window(dim = [800, 600], /buffer)
      ;      win.refresh, /disable
      ;      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy', xlog:1, ytitle:'Rotation Angle $\rho$', xr:[0.5, 5], yr:[-45, 195]}
      ;
      ;
      ;        yy = yidx-year_min
      ;      par_angle_arr = replicate(!values.f_nan, 5)
      ;      for esa = 2, 6 do begin
      ;        ; Convert points to Cartesian coordinates
      ;        ;      meridional plane crossing RC
      ;        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat1 = 0d*!DTOR
      ;        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;        lon3 = 259d*!DTOR ; nose
      ;        lat3 = 5d*!DTOR ; nose
      ;        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
      ;        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR
      ;
      ;
      ;        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
      ;        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
      ;        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
      ;        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]
      ;
      ;        ; Compute normal vectors for the planes of the great circles
      ;        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
      ;        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle
      ;
      ;        ; Normalize the normal vectors
      ;        n1 = n1 / SQRT(TOTAL(n1^2))
      ;        n2 = n2 / SQRT(TOTAL(n2^2))
      ;
      ;        ; Compute the dot product of the normal vectors
      ;        dot_product = TOTAL(n1 * n2)
      ;
      ;        ; Compute the angle between the two planes
      ;        angle = ACOS(dot_product)  ; Angle in radians
      ;
      ;        ; Convert the angle to degrees
      ;        angle = angle * (180.0 / !PI)
      ;        par_angle = angle
      ;        par_angle = par_angle
      ;        par_angle_arr[esa-2] = par_angle
      ;      endfor
      ;
      ;
      ;      angle_tmp = reform(fit_par_ellip[4, (yidx-year_min), *])+par_angle_arr
      ;
      ;      aidx = where(angle_tmp lt 0 or angle_tmp gt 180, tmp)
      ;
      ;      if tmp ne 0 then begin
      ;        for aa = 0, aidx.length-1 do begin
      ;          while angle_tmp[aidx[aa]] lt 0 or angle_tmp[aidx[aa]] gt 180 do begin
      ;            if angle_tmp[aidx[aa]] lt 0 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] + 180
      ;            if angle_tmp[aidx[aa]] gt 180 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] - 180
      ;          endwhile
      ;        endfor
      ;      endif
      ;      ;    angle_tmp
      ;
      ;      p = errorplot(e_step, angle_tmp, fit_par_sig_ellip[4, (yidx-year_min), *], _extra = extram, title = year)
      ;
      ;      p = plot(p.xr, replicate(90, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      p = plot(p.xr, replicate(0, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      tx = text(0.5, 90+1, 'Perpendicular to NS', /data, font_size = 15)
      ;      tx = text(0.5, 0+1, 'Parallel to NS', /data, font_size = 15)
      ;
      ;
      ;      win.refresh
      ;      win.save, file_tmp+'RC_RotationAngle_Circ_Ellip_1sig_year'+year+'_fit_'+str+'_fromNS.png'
      ;      win.save, file_tmp1+'RC_RotationAngle_Circ_Ellip_1sig_year'+year+'_fit_'+str+'_fromNS.png'
      ;      win.close
      ;      ; 5555555555 Rotation Angle 5555555555




    endfor ; year

    ; mission average
    ;    111111111 Angular Radius 111111111
    win = window(dim = [800, 600], /buffer)
    win.refresh, /disable
    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy [keV]', xlog:1, ytitle:'Angular Radius', xr:[0.5, 5], yr:[65, 90]}
    val = reform(fit_par_ellip[0, *, *, ram])
    sig = reform(sqrt((fit_par_sig_ellip[0, *, *, ram])^2 + fit_par_ellip[5, *, *, ram]^2))
    sigp = sqrt(mean(sig^2, dim = 1, /nan)); sqrt(1d/total(1d/sig^2, 1, /nan))

    p = errorplot(e_step, mean(val, dim = 1), sigp, _extra = extram, title = 'Angular Radius Summary')
    ;    p = errorplot(e_step, mean(val, dim = 1), sqrt(mean(sig^2, dim = 1)), _extra = extram, title = 'Angular Radius, '+str)
    win.refresh
    win.save, file_tmp+'Summary_RC_Radius_'+str+'.png'
    win.save, file_tmp1+'Summary_RC_Radius_'+str+'.png'
    win.erase
    ;    111111111 Angular Radius 111111111


    ;    222222222 RC 222222222
    win = window(dim = [800, 600], /buffer)
    win.refresh, /disable
    extram = {symbol:'thin_diamond', sym_thick:0, sym_size:2, current:1, sym_filled:1, font_size:20, xtitle:'Lon$_{EC}$', xlog:0, ytitle:'Lat$_{EC}$', xr:[230, 200], yr:[25, 50], title:'RC Position Summary'}
    val_lon = mean(reform(fit_par_ellip[1, *, *, ram]), dim = 1) & val_lat = mean(reform(fit_par_ellip[2, *, *, ram]), dim = 1)
    val_lon_error = sqrt(mean(reform(fit_par_sig_ellip[1, *, *, ram])^2, dim = 1)) & val_lat_error = sqrt(mean(reform(fit_par_sig_ellip[2, *, *, ram])^2, dim = 1))
    ;    val_lon_error = sqrt(1d/total(1d/reform(fit_par_sig_ellip[1, *, *, ram])^2, 1, /nan)) & val_lat_error = sqrt(1d/total(1d/reform(fit_par_sig_ellip[2, *, *, ram])^2, 1, /nan))


    co = ['blue', 'green', 'yellow', 'orange', 'red']
    p2 = objarr(5)
    for esa = 2, 6 do begin
      p2[esa-2] = scatterplot(replicate(val_lon[esa-2], 2), replicate(val_lat[esa-2], 2), sym_FILL_color = co[esa-2], sym_color = co[esa-2], _extra = extram, name = string(e_step[esa-2], format = '(f4.2)')+'keV')
      pe = plot([val_lon[esa-2]-val_lon_error[esa-2], val_lon[esa-2]+val_lon_error[esa-2]], [val_lat[esa-2], val_lat[esa-2]], over = p2[esa-2], co = co[esa-2])
      pe = plot([val_lon[esa-2], val_lon[esa-2]], [val_lat[esa-2]-val_lat_error[esa-2], val_lat[esa-2]+val_lat_error[esa-2]], over = p2[esa-2], co = co[esa-2])
      p2[esa-2] = scatterplot(replicate(val_lon[esa-2], 2), replicate(val_lat[esa-2], 2), sym_FILL_color = co[esa-2], sym_color = co[esa-2], _extra = extram, name = string(e_step[esa-2], format = '(f4.2)')+'keV')
    endfor
    p = plot(val_lon, val_lat, over = p2[0])
    pbv = plot(BV[0, *], BV[1, *], over = p, linestyle = 2, thick = 2)
    pb = scatterplot(replicate(226.99, 2), replicate(34.82, 2), over = p, symbol = '*', sym_size = 2)
    tx = text(227, 35, 'B', /data, font_size = 15)
    tx = text(225, 34.5, 'B-V plane', /data, font_size = 15, orientation = 41.)
    lgd = legend(position = [0.30, 0.8], target = p2, shadow = 0, linestyle = 6, sample_width = 0, color = 0, transparency = 100, /auto_text_color)

    win.refresh
    win.save, file_tmp+'Summary_RC_Position_'+str+'.png'
    win.save, file_tmp1+'Summary_RC_Position_'+str+'.png'
    win.erase

    ;    222222222 RC 222222222

    ;    333333333 Ellipticity 333333333
    win = window(dim = [800, 600], /buffer)
    win.refresh, /disable
    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy [keV]', xlog:1, ytitle:'Eccentricity $\epsilon$', xr:[0.5, 5], yr:[0.1, 0.6]}
      val = reform(fit_par_ellip[3, *, *, ram])
    sig = reform(fit_par_sig_ellip[3, *, *, ram])
    sigp = sqrt(mean(sig^2, dim = 1, /nan)); sqrt(1d/total(1d/sig^2, 1, /nan))
    p = errorplot(e_step, mean(val, dim = 1), sigp, _extra = extram, title = 'Eccentricity Summary')
    win.refresh
    win.save, file_tmp+'Summary_Eccentricity_'+str+'.png'
    win.save, file_tmp1+'Summary_Eccentricity_'+str+'.png'
    win.erase
    ;    333333333 Ellipticity 333333333


    ;    ;    444444444 Rotation Angle 444444444
    ;    win = window(dim = [800, 600], /buffer)
    ;    win.refresh, /disable
    ;    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy', xlog:1, ytitle:'Rotation Angle', xr:[0.5, 5], yr:[-20, 160]}
    ;    val = reform(fit_par_ellip[4, *, *, ram])
    ;    sig = reform(fit_par_sig_ellip[4, *, *, ram])
    ;    sigp = sqrt(mean(sig^2, dim = 1, /nan)) ; sqrt(1d/total(1d/sig^2, 1, /nan))
    ;
    ;    p = errorplot(e_step, mean(val, dim = 1), sigp, _extra = extram, title = 'Rotation Angle Summary')
    ;
    ;    par_angle_arr = replicate(!values.f_nan, 5)
    ;    for esa = 2, 6 do begin
    ;      par_angle = replicate(!values.f_nan, year_arr_tmp.length)
    ;      for yy = 0, year_arr_tmp.length-1 do begin
    ;        ; Convert points to Cartesian coordinates
    ;        ;      meridional plane crossing RC
    ;        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
    ;        lat1 = 0d*!DTOR
    ;        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
    ;        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR
    ;
    ;        lon3 = 259d*!DTOR ; nose
    ;        lat3 = 5d*!DTOR ; nose
    ;        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
    ;        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR
    ;
    ;
    ;        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
    ;        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
    ;        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
    ;        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]
    ;
    ;        ; Compute normal vectors for the planes of the great circles
    ;        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
    ;        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle
    ;
    ;        ; Normalize the normal vectors
    ;        n1 = n1 / SQRT(TOTAL(n1^2))
    ;        n2 = n2 / SQRT(TOTAL(n2^2))
    ;
    ;        ; Compute the dot product of the normal vectors
    ;        dot_product = TOTAL(n1 * n2)
    ;
    ;        ; Compute the angle between the two planes
    ;        angle = ACOS(dot_product)  ; Angle in radians
    ;
    ;        ; Convert the angle to degrees
    ;        angle = angle * (180.0 / !PI)
    ;        par_angle[yy] = angle
    ;      endfor
    ;      par_angle = 180-par_angle
    ;      par_angle_arr[esa-2] = mean(par_angle)
    ;    endfor
    ;
    ;    p = plot(e_step, par_angle_arr, linestyle = 2, thick = 2, color = 'gray', over = p)
    ;    p = plot(e_step, par_angle_arr-90, linestyle = 2, thick = 2, color = 'gray', over = p)
    ;    tx = text(0.5, par_angle_arr[0]-90+1, 'perpendicular to NS', /data, font_size = 15)
    ;    tx = text(0.5, par_angle_arr[0]+1, 'parallel to NS', /data, font_size = 15)
    ;
    ;    win.refresh
    ;    win.save, file_tmp+'Summary_RotationAngle_'+str+'.png'
    ;    win.save, file_tmp1+'Summary_RotationAngle_'+str+'.png'
    ;    win.erase
    ;    ;    444444444 Rotation Angle 444444444

    ;    555555555 Rotation Angle 555555555
    win = window(dim = [800, 600], /buffer)
    win.refresh, /disable
    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:20, xtitle:'Energy [keV]', xlog:1, ytitle:'Rotation Angle $\rho$', xr:[0.5, 5], yr:[50, 260]}
      val = reform(fit_par_ellip[4, *, *, ram])
    sig = reform(fit_par_sig_ellip[4, *, *, ram])

    par_angle_arr = replicate(!values.f_nan, year_arr_tmp.length, 5)
    for esa = 2, 6 do begin
      for yy = 0, year_arr_tmp.length-1 do begin
        ; Convert points to Cartesian coordinates
        ;      meridional plane crossing RC
        lon1 = fit_par_ellip[1, yy, esa-2]*!DTOR
        lat1 = 0d*!DTOR
        lon2 = fit_par_ellip[1, yy, esa-2]*!DTOR
        lat2 = fit_par_ellip[2, yy, esa-2]*!DTOR

        lon3 = 259d*!DTOR ; nose
        lat3 = 5d*!DTOR ; nose
        lon4 = fit_par_ellip[1, yy, esa-2]*!DTOR
        lat4 = fit_par_ellip[2, yy, esa-2]*!DTOR


        a1 = [COS(lat1) * COS(lon1), COS(lat1) * SIN(lon1), SIN(lat1)]
        b1 = [COS(lat2) * COS(lon2), COS(lat2) * SIN(lon2), SIN(lat2)]
        a2 = [COS(lat3) * COS(lon3), COS(lat3) * SIN(lon3), SIN(lat3)]
        b2 = [COS(lat4) * COS(lon4), COS(lat4) * SIN(lon4), SIN(lat4)]

        ; Compute normal vectors for the planes of the great circles
        n1 = CROSSP(a1, b1)  ; Normal vector for the first great circle
        n2 = CROSSP(a2, b2)  ; Normal vector for the second great circle

        ; Normalize the normal vectors
        n1 = n1 / SQRT(TOTAL(n1^2))
        n2 = n2 / SQRT(TOTAL(n2^2))

        ; Compute the dot product of the normal vectors
        dot_product = TOTAL(n1 * n2)

        ; Compute the angle between the two planes
        angle = ACOS(dot_product)  ; Angle in radians

        ; Convert the angle to degrees
        angle = angle * (180.0 / !PI)
        par_angle = angle
        par_angle_arr[yy, esa-2] = par_angle
      endfor
    endfor


    angle_tmp = val+par_angle_arr

    aidx = where(angle_tmp lt 0 or angle_tmp gt 180, tmp)

    if tmp ne 0 then begin
      for aa = 0, aidx.length-1 do begin
        while angle_tmp[aidx[aa]] lt 0 or angle_tmp[aidx[aa]] gt 180 do begin
          if angle_tmp[aidx[aa]] lt 0 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] + 180
          if angle_tmp[aidx[aa]] gt 180 then angle_tmp[aidx[aa]] = angle_tmp[aidx[aa]] - 180
        endwhile
      endfor
    endif
    angle_tmp[4:10, -1] = angle_tmp[4:10, -1]+180
    angle_tmp[-1, -1] = angle_tmp[-1, -1]+180

    angle_tmp = mean(angle_tmp, dim = 1)

    ;    angle_tmp


    sigp = sqrt(mean(sig^2, dim = 1, /nan)); sqrt(1d/total(1d/sig^2, 1, /nan))
    p = errorplot(e_step, angle_tmp, sigp, _extra = extram, title = 'Rotation Angle Summary')

    p = plot(p.xr, replicate(90, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
    p = plot(p.xr, replicate(0, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
    p = plot(p.xr, replicate(180, 2), linestyle = 2, thick = 2, color = 'gray', over = p)
    tx = text(0.5, 90+1, 'Perpendicular to NS', /data, font_size = 15)
    tx = text(0.5, 0+1, 'Parallel to NS', /data, font_size = 15)
    tx = text(0.5, 180+1, 'Parallel to NS', /data, font_size = 15)

    win.refresh
    win.save, file_tmp+'Summary_RotationAngle_'+str+'_fromNS.png'
    win.save, file_tmp1+'Summary_RotationAngle_'+str+'_fromNS.png'
    win.erase
    ;    555555555 Rotation Angle 555555555
stop
    ; mission average


    ;    rotaion rate of the ellipse

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)

      ;
      ;
      ;      ; 6666666666 diameter 6666666666
      ;
      ;
      ;      ;    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:15, xtitle:'Year', ytitle:'Rotation Angle', xr:[year_min-1, 2023], yr:[-45, 195]}
      ;      extram = {current:1, font_size:15, xtitle:'Angle from NS', ytitle:'Diameter', xr:[0, 180], yr:[110, 180]}
      ;      co_arr = rgb_vector(14, ct = 33)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        alpha = RC_azi+par_angle[yy]; angle from NS
      ;        alpha = alpha mod 180
      ;        aidx = sort(alpha)
      ;        alpha = alpha[aidx]
      ;        ribbon_diameter_tmp = ribbon_diameter[aidx, yy, esa-2]
      ;        p = plot(alpha, ribbon_diameter_tmp, co = co_arr[*, yy], _extra = extram, title = 'ESA'+esa_str+', '+str)
      ;      endfor
      ;      p1 = plot([90, 90], p.yr, linestyle = 2, thick = 2, color = 'gray', over = p)
      ;      tx = text(90+1, 120, 'perpendicular to NS', /data, font_size = 12)
      ;      tx = text(0+1, 120, 'parallel to NS', /data, font_size = 12)
      ;      win.refresh
      ;      win.save, file_tmp+'RC_Diameter_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_Diameter_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase
      ;      ; 6666666666 diameter 6666666666
      ;
      ;
      ;      ; 7777777777 perp/par ratio 7777777777
      ;      ;    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:15, xtitle:'Year', ytitle:'Rotation Angle', xr:[year_min-1, 2023], yr:[-45, 195]}
      ;      extram = {current:1, font_size:15, xtitle:'Angle from NS', ytitle:'EW/NS', xr:[year_min-1, 2023], yr:[0.8, 1.2]}
      ;      ribbon_diameter_tmp = replicate(!values.f_nan, RC_azi.length, year_arr_tmp.length)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        alpha = RC_azi+par_angle[yy]; angle from NS
      ;        alpha = alpha mod 180
      ;        aidx = sort(alpha)
      ;        alpha = alpha[aidx]
      ;        ribbon_diameter_tmp[*, yy] = ribbon_diameter[aidx, yy, esa-2]
      ;      endfor
      ;
      ;      paridx = [0, 1, 2, 3, 4, RC_azi.length-1, RC_azi.length-2, RC_azi.length-3, RC_azi.length-4]
      ;      perpidx = [-4:4]+RC_azi.length/2
      ;
      ;      p = plot(year_arr_tmp, mean(ribbon_diameter_tmp[paridx, *], dim = 1, /nan)/mean(ribbon_diameter_tmp[perpidx, *], dim = 1, /nan), _extra = extram, title = 'EW/NS ratio, ESA'+esa_str+', '+str)
      ;
      ;      win.refresh
      ;      win.save, file_tmp+'RC_EW_NS_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_EW_NS_Ellip_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase
      ;      ; 7777777777 perp/par ratio 7777777777
      ;
      ;      ; 8888888888 FWHM north and south variation 8888888888
      ;      ;    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:15, xtitle:'Year', ytitle:'Rotation Angle', xr:[year_min-1, 2023], yr:[-45, 195]}
      ;      extram = {current:1, font_size:15, xtitle:'Angle from NS', ytitle:'FWMH', xr:[year_min-1, 2023], yr:[0, 40]}
      ;
      ;      var_tmp = replicate(!values.f_nan, lon_arr.length, year_arr_tmp.length)
      ;      sig_tmp = replicate(!values.f_nan, lon_arr.length, year_arr_tmp.length)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        alpha = lon_arr+par_angle[yy]; angle from NS
      ;        alpha = alpha mod 360
      ;        aidx = sort(alpha)
      ;        alpha = alpha[aidx]
      ;        var_tmp[*, yy] = REFORM(moment24_stack[1, AIDX, YY, esa-2, ram])
      ;        sig_tmp[*, yy] = REFORM(moment24_stack_error[1, AIDX, YY, esa-2, ram])
      ;      endfor
      ;
      ;      paridx = [0, 1, 2, 3, 4, lon_arr.length-1, lon_arr.length-2, lon_arr.length-3, lon_arr.length-4]
      ;      perpidx = [-4:4]+lon_arr.length/2
      ;
      ;      p = errorplot(year_arr_tmp, mean(var_tmp[PARIDX, *], dim = 1, /nan), sqrt(mean(sig_tmp[PARIDX, *]^2, dim = 1, /nan)), _extra = extram, title = 'FWHM NS, ESA'+esa_str+', '+str, CO = 'blue', errorbar_CO = 'blue')
      ;      p = errorplot(year_arr_tmp, mean(var_tmp[PERPIDX, *], dim = 1, /nan), sqrt(mean(sig_tmp[PERPIDX, *]^2, dim = 1, /nan)), OVER = P, CO = 'red', errorbar_CO = 'red')
      ;
      ;      tx = text(0.7, 0.8, 'South', font_size = 15, font_color = 'blue')
      ;      tx = text(0.7, 0.75, 'North', font_size = 15, font_color = 'red')
      ;
      ;      win.refresh
      ;      win.save, file_tmp+'RC_FWHM_NS_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_FWHM_NS_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase
      ;      ; 8888888888 FWHM north and south variation 8888888888
      ;
      ;
      ;      ; 9999999999 Skewness north and south variation 9999999999
      ;      ;    extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:15, xtitle:'Year', ytitle:'Rotation Angle', xr:[year_min-1, 2023], yr:[-45, 195]}
      ;      extram = {current:1, font_size:15, xtitle:'Angle from NS', ytitle:'FWMH', xr:[year_min-1, 2023], yr:[-0.2, 0.2]}
      ;
      ;      var_tmp = replicate(!values.f_nan, lon_arr.length, year_arr_tmp.length)
      ;      sig_tmp = replicate(!values.f_nan, lon_arr.length, year_arr_tmp.length)
      ;      for yy = 0, year_arr_tmp.length-1 do begin
      ;        alpha = lon_arr+par_angle[yy]; angle from NS
      ;        alpha = alpha mod 360
      ;        aidx = sort(alpha)
      ;        alpha = alpha[aidx]
      ;        var_tmp[*, yy] = REFORM(moment24_stack[2, AIDX, YY, esa-2, ram])
      ;        sig_tmp[*, yy] = REFORM(moment24_stack_error[2, AIDX, YY, esa-2, ram])
      ;      endfor
      ;
      ;      paridx = [0, 1, 2, 3, 4, lon_arr.length-1, lon_arr.length-2, lon_arr.length-3, lon_arr.length-4]
      ;      perpidx = [-4:4]+lon_arr.length/2
      ;
      ;      p = errorplot(year_arr_tmp, mean(var_tmp[PARIDX, *], dim = 1, /nan), sqrt(mean(sig_tmp[PARIDX, *]^2, dim = 1, /nan)), _extra = extram, title = 'Skewness NS, ESA'+esa_str+', '+str, CO = 'blue', errorbar_CO = 'blue')
      ;      p = errorplot(year_arr_tmp, mean(var_tmp[PERPIDX, *], dim = 1, /nan), sqrt(mean(sig_tmp[PERPIDX, *]^2, dim = 1, /nan)), OVER = P, CO = 'red', errorbar_CO = 'red')
      ;
      ;      tx = text(0.7, 0.8, 'South', font_size = 15, font_color = 'blue')
      ;      tx = text(0.7, 0.75, 'North', font_size = 15, font_color = 'red')
      ;
      ;      win.refresh
      ;      win.save, file_tmp+'RC_Skewness_NS_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.save, file_tmp1+'RC_Skewness_NS_1sig_ESA'+esa_str+'_fit_'+str+'.png'
      ;      win.erase
      ;      ; 9999999999 Skewness north and south variation 9999999999
      ;      ;

    endfor; esa


    ;    rotaion rate of the ellipse



  endfor ; ram
  ;    ============================ Ribbon Center Pos/Radius ============================


  ;  ; ============================ Longitudinal Distribution of Moments ============================
  ;  win = window(dim = [900, 800], /buffer)
  ;  win.refresh, /disable
  ;  POS1 = [0.1, 0.08, 0.85, 0.7]
  ;  POS2 = [0.1, 0.7, 0.85, 0.95]
  ;  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  ;  FOR ram = 0, 0 DO BEGIN
  ;    IF ram THEN str = 'ARam' ELSE str = 'Ram'
  ;
  ;    for momidx = 0, 3 do begin
  ;      if momidx eq 0 then begin
  ;        mrg = [65., 90]
  ;        RGB_TABLE = 33
  ;        mom_str = 'Mean'
  ;      endif
  ;      if momidx eq 1 then BEGIN
  ;        mrg = [5, 20.]
  ;        RGB_TABLE = 33
  ;        mom_str = 'Stddev'
  ;      endif
  ;      if momidx eq 2 then BEGIN
  ;        mrg = [-1, 1.]
  ;        RGB_TABLE = 70
  ;        mom_str = 'Skewness'
  ;      ENDIF
  ;      if momidx eq 3 then BEGIN
  ;        mrg = [-2, 2.]
  ;        RGB_TABLE = 70
  ;        mom_str = 'Kurtosis'
  ;      endif
  ;
  ;      for esa = 2, 6 do begin
  ;        ESA_STR = strcompress(esa, /rem)
  ;
  ;        ytmp = reform(moment_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
  ;        ytmp_error = reform(moment_stack_error[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
  ;
  ;        lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])
  ;
  ;        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])
  ;
  ;        ; Fixed RC Coordinate
  ;        sz = size(ytmp)
  ;        yy = ytmp
  ;        yy[*] = !values.d_nan
  ;
  ;        yy_error = ytmp_error
  ;        yy_error[*] = !values.d_nan
  ;
  ;        yyidx = ytmp
  ;        yyidx[*] = 0
  ;
  ;        hp_mat = ytmp
  ;        hp_mat[*] = !values.d_nan
  ;
  ;        ec_lat = ytmp
  ;        ec_lat[*] = !values.d_nan
  ;
  ;        for yidx = 0, sz[2]-1 do begin
  ;
  ;          peak_pos = [[lon_arr], [peak_lat_res[*, yidx]]]
  ;
  ;          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
  ;          LONEC = TMP.LON & LATEC = TMP.LAT
  ;          ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
  ;          ec_lat[*, yidx] = LATEC
  ;          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
  ;          dlon = lon_arr[1]-lon_arr[0]
  ;          for lidx = 0, lon_arr.length-1 do begin
  ;            idx = where(TMP1.LON ge lon_arr[lidx]-dlon/2 and TMP1.LON le lon_arr[lidx]+dlon/2, tmp)
  ;            if tmp eq 0 then continue
  ;            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
  ;            yy_error[lidx, yidx] = sqrt(mean(ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment
  ;            yyidx[lidx, yidx] = tmp
  ;            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
  ;          endfor
  ;
  ;        endfor
  ;        ; Fixed RC Coordinate
  ;
  ;        ytmp = yy
  ;        ytmp_error = yy_error
  ;
  ;        data_available = total(finite(ytmp), 2)
  ;        data_mean = mean(ytmp, dim = 2, /nan)
  ;
  ;        data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
  ;
  ;        data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))
  ;
  ;        q = quartile(ytmp, dim = 2)
  ;        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
  ;        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
  ;        ec_lat_sign = sign(ec_lat_mean)
  ;
  ;        idx = where(data_available lt 5, /null)
  ;        data_mean[idx] = !values.d_nan
  ;        data_mean_weighted[idx] = !values.d_nan
  ;        q[*, idx] = !values.d_nan
  ;
  ;        p_HP = plot([0, 0], [0, 0], POS = POS2, /nodata, title = mom_str+', ESA'+esa_str+', '+str, xtickformat = '(a1)', ytitle = 'HP Dist. [AU]', font_size = 15, xr = [360, 0], yr = [100, 400], current = win)
  ;        p_hp = plot(lon_arr, hp_dist_mean, over = p_HP, co = 'green', thick = 2)
  ;        esidx = where(ec_lat_sign eq 1)
  ;        p_hp0 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 0, name = 'EC North')
  ;        esidx = where(ec_lat_sign eq -1)
  ;        p_hp1 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 1, name = 'EC South')
  ;        lgd = legend(target = [p_hp0, p_hp1], pos = [pos2[2]-0.03, pos2[3]-0.04], shadow = 0, linestyle = 6, sample_width = 0.05, transparency = 100)
  ;
  ;        p = plot([0, 0], [0, 0], POS = POS1, /nodata, xtitle = 'Lon_RC', ytitle = mom_str, font_size = 15, xr = [360, 0], yr = mrg, current = win)
  ;
  ;        sz = size(ytmp)
  ;        co = rgb_vector(sz[2], ct = 33)
  ;        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
  ;        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)
  ;        ;        p = plot(lon_arr, data_mean_weighted, over = p, co = 'magenta', thick = 3)
  ;
  ;        p = plot(lon_arr, data_mean+data_error/2, over = p, co = 'black', thick = 3)
  ;        p = plot(lon_arr, data_mean-data_error/2, over = p, co = 'black', thick = 3)
  ;
  ;        ;        p = plot(lon_arr, data_mean_weighted+data_error/2, over = p, co = 'black', thick = 3)
  ;        ;        p = plot(lon_arr, data_mean_weighted-data_error/2, over = p, co = 'black', thick = 3)
  ;
  ;
  ;        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
  ;        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)
  ;
  ;        ff = findgen(256)
  ;        cba = transpose([[ff], [ff], [ff]])
  ;        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
  ;        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2022 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')
  ;
  ;
  ;        win.Refresh
  ;        win.save, file_tmp+STRCOMPRESS(momidx+1, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
  ;        win.erase
  ;
  ;      endfor ; esa
  ;
  ;    endfor ; mom
  ;    ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  ;
  ;    ; ===================================================================== SEMI MOMENTS =====================================================================
  ;    for momidx = 0, 3 do begin
  ;      if momidx eq 0 then BEGIN
  ;        mrg = [65, 90]
  ;        RGB_TABLE = 33
  ;        mom_str = 'Peak'
  ;      endif
  ;      if momidx eq 1 then BEGIN
  ;        mrg = [10, 50.]
  ;        RGB_TABLE = 33
  ;        mom_str = 'FWHM'
  ;      endif
  ;      if momidx eq 2 then BEGIN
  ;        mrg = [-0.4, 0.4]
  ;        ;        mrg = [-1d, 1]
  ;        RGB_TABLE = 70
  ;        mom_str = 'Bowley Skewness'
  ;        ;        mom_str = 'PSKEW'
  ;        ;        moment24_stack[momidx, *, *, *, ram] =  moment24_stack[momidx, *, *, *, ram]/ moment_stack[1, *, *, *, ram]
  ;      ENDIF
  ;      if momidx eq 3 then BEGIN
  ;        mrg = [-0.7, 0.7]
  ;        ;        mrg = [2d, 10]
  ;        RGB_TABLE = 33
  ;        mom_str = 'Moors Kurtosis'
  ;        ;        mom_str = 'R80_20'
  ;      endif
  ;
  ;      for esa = 2, 6 do begin
  ;        ESA_STR = strcompress(esa, /rem)
  ;
  ;        ytmp = reform(moment24_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa
  ;        ytmp_error = reform(moment24_stack_error[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
  ;
  ;        lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])
  ;
  ;        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])
  ;
  ;        ; Fixed RC Coordinate
  ;        sz = size(ytmp)
  ;        yy = ytmp
  ;        yy[*] = !values.d_nan
  ;
  ;        yy_error = ytmp_error
  ;        yy_error[*] = !values.d_nan
  ;
  ;        yyidx = ytmp
  ;        yyidx[*] = 0
  ;
  ;        hp_mat = ytmp
  ;        hp_mat[*] = !values.d_nan
  ;
  ;        ec_lat = ytmp
  ;        ec_lat[*] = !values.d_nan
  ;
  ;        for yidx = 0, sz[2]-1 do begin
  ;
  ;          peak_pos = [[lon_arr], [peak_lat_res[*, yidx]]]
  ;
  ;          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
  ;          LONEC = TMP.LON & LATEC = TMP.LAT
  ;          ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
  ;          ec_lat[*, yidx] = LATEC
  ;          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
  ;          dlon = lon_arr[1]-lon_arr[0]
  ;          for lidx = 0, lon_arr.length-1 do begin
  ;            idx = where(TMP1.LON ge lon_arr[lidx]-dlon/2 and TMP1.LON le lon_arr[lidx]+dlon/2, tmp)
  ;            if tmp eq 0 then continue
  ;            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
  ;            yy_error[lidx, yidx] = sqrt(mean(ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment
  ;            yyidx[lidx, yidx] = tmp
  ;            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
  ;          endfor
  ;        endfor
  ;        ; Fixed RC Coordinate
  ;
  ;        ytmp = yy
  ;        ytmp_error = yy_error
  ;
  ;        data_available = total(finite(ytmp), 2)
  ;        data_mean = mean(ytmp, dim = 2, /nan)
  ;
  ;        data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
  ;
  ;        data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))
  ;
  ;
  ;        q = quartile(ytmp, dim = 2)
  ;        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
  ;        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
  ;        ec_lat_sign = sign(ec_lat_mean)
  ;
  ;        idx = where(data_available lt 5, /null)
  ;        data_mean[idx] = !values.d_nan
  ;        data_mean_weighted[idx] = !values.d_nan
  ;        q[*, idx] = !values.d_nan
  ;
  ;        p_HP = plot([0, 0], [0, 0], POS = POS2, /nodata, title = mom_str+', ESA'+esa_str+', '+str, xtickformat = '(a1)', ytitle = 'HP Dist. [AU]', font_size = 15, xr = [360, 0], yr = [100, 400], current = win)
  ;        p_hp = plot(lon_arr, hp_dist_mean, over = p_HP, co = 'green', thick = 2)
  ;        esidx = where(ec_lat_sign eq 1)
  ;        p_hp0 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 0, name = 'EC North')
  ;        esidx = where(ec_lat_sign eq -1)
  ;        p_hp1 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 1, name = 'EC South')
  ;        lgd = legend(target = [p_hp0, p_hp1], pos = [pos2[2]-0.03, pos2[3]-0.04], shadow = 0, linestyle = 6, sample_width = 0.05, transparency = 100)
  ;
  ;        p = plot([0, 0], [0, 0], POS = POS1, /nodata, xtitle = 'Lon_RC', ytitle = mom_str, font_size = 15, xr = [360, 0], yr = mrg, current = win)
  ;
  ;        sz = size(ytmp)
  ;        co = rgb_vector(sz[2], ct = 33)
  ;        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
  ;        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)
  ;        ;        p = plot(lon_arr, data_mean_weighted, over = p, co = 'magenta', thick = 3)
  ;
  ;        p = plot(lon_arr, data_mean+data_error/2, over = p, co = 'black', thick = 3)
  ;        p = plot(lon_arr, data_mean-data_error/2, over = p, co = 'black', thick = 3)
  ;
  ;        ;        p = plot(lon_arr, data_mean_weighted+data_error/2, over = p, co = 'black', thick = 3)
  ;        ;        p = plot(lon_arr, data_mean_weighted-data_error/2, over = p, co = 'black', thick = 3)
  ;
  ;        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
  ;        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)
  ;        ff = findgen(256)
  ;        cba = transpose([[ff], [ff], [ff]])
  ;        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
  ;        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2022 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')
  ;
  ;        win.Refresh
  ;        win.save, file_tmp+'\'+STRCOMPRESS(momidx+5, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
  ;        win.erase
  ;      endfor ; esa
  ;
  ;    endfor ; mom
  ;    ; ===================================================================== SEMI MOMENTS =====================================================================
  ;
  ;
  ;    cbmax = [1200,500,180,120,45,10]
  ;    ; ===================================================================== Ribbon Flux =====================================================================
  ;    for fluxidx = 0, 1 do begin
  ;      if fluxidx eq 0 then BEGIN
  ;        RGB_TABLE = 33
  ;        mom_str = 'FluxPeak'
  ;      endif
  ;      if fluxidx eq 1 then BEGIN
  ;        RGB_TABLE = 33
  ;        mom_str = 'FluxMean'
  ;      endif
  ;
  ;      for esa = 2, 6 do begin
  ;        ESA_STR = strcompress(esa, /rem)
  ;        mrg = [0, cbmax[esa-1]]
  ;
  ;        ytmp = reform(flux_stack[fluxidx, *, *, esa-2, ram]); moment x lon x year x esa
  ;        ytmp_error = reform(flux_stack_error[fluxidx, *, *, esa-2, ram]); moment x lon x year x esa
  ;
  ;        lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])
  ;
  ;        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])
  ;
  ;        ; Fixed RC Coordinate
  ;        sz = size(ytmp)
  ;        yy = ytmp
  ;        yy[*] = !values.d_nan
  ;
  ;        yy_error = ytmp_error
  ;        yy_error[*] = !values.d_nan
  ;
  ;        yyidx = ytmp
  ;        yyidx[*] = 0
  ;
  ;        hp_mat = ytmp
  ;        hp_mat[*] = !values.d_nan
  ;
  ;        ec_lat = ytmp
  ;        ec_lat[*] = !values.d_nan
  ;
  ;        for yidx = 0, sz[2]-1 do begin
  ;
  ;          peak_pos = [[lon_arr], [peak_lat_res[*, yidx]]]
  ;
  ;          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
  ;          LONEC = TMP.LON & LATEC = TMP.LAT
  ;          ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
  ;          ec_lat[*, yidx] = LATEC
  ;          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
  ;          dlon = lon_arr[1]-lon_arr[0]
  ;          for lidx = 0, lon_arr.length-1 do begin
  ;            idx = where(TMP1.LON ge lon_arr[lidx]-dlon/2 and TMP1.LON le lon_arr[lidx]+dlon/2, tmp)
  ;            if tmp eq 0 then continue
  ;            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
  ;            yy_error[lidx, yidx] = sqrt(mean(ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment
  ;            yyidx[lidx, yidx] = tmp
  ;            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
  ;          endfor
  ;        endfor
  ;        ; Fixed RC Coordinate
  ;
  ;        ytmp = yy
  ;        ytmp_error = yy_error
  ;
  ;        data_available = total(finite(ytmp), 2)
  ;        data_mean = mean(ytmp, dim = 2, /nan)
  ;
  ;        data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
  ;
  ;        data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))
  ;
  ;
  ;        q = quartile(ytmp, dim = 2)
  ;        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
  ;        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
  ;        ec_lat_sign = sign(ec_lat_mean)
  ;
  ;        idx = where(data_available lt 5, /null)
  ;        data_mean[idx] = !values.d_nan
  ;        data_mean_weighted[idx] = !values.d_nan
  ;        q[*, idx] = !values.d_nan
  ;
  ;        p_HP = plot([0, 0], [0, 0], POS = POS2, /nodata, title = mom_str+', ESA'+esa_str+', '+str, xtickformat = '(a1)', ytitle = 'HP Dist. [AU]', font_size = 15, xr = [360, 0], yr = [100, 400], current = win)
  ;        p_hp = plot(lon_arr, hp_dist_mean, over = p_HP, co = 'green', thick = 2)
  ;        esidx = where(ec_lat_sign eq 1)
  ;        p_hp0 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 0, name = 'EC North')
  ;        esidx = where(ec_lat_sign eq -1)
  ;        p_hp1 = plot(lon_arr[esidx], replicate(390, esidx.length), over = p_hp, thick = 5, linestyle = 1, name = 'EC South')
  ;        lgd = legend(target = [p_hp0, p_hp1], pos = [pos2[2]-0.03, pos2[3]-0.04], shadow = 0, linestyle = 6, sample_width = 0.05, transparency = 100)
  ;
  ;        p = plot([0, 0], [0, 0], POS = POS1, /nodata, xtitle = 'Lon_RC', ytitle = mom_str, font_size = 15, xr = [360, 0], yr = mrg, current = win)
  ;
  ;        sz = size(ytmp)
  ;        co = rgb_vector(sz[2], ct = 33)
  ;        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
  ;        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)
  ;        ;        p = plot(lon_arr, data_mean_weighted, over = p, co = 'magenta', thick = 3)
  ;
  ;        p = plot(lon_arr, data_mean+data_error/2, over = p, co = 'black', thick = 3)
  ;        p = plot(lon_arr, data_mean-data_error/2, over = p, co = 'black', thick = 3)
  ;
  ;
  ;        ;        p = plot(lon_arr, data_mean_weighted+data_error/2, over = p, co = 'black', thick = 3)
  ;        ;        p = plot(lon_arr, data_mean_weighted-data_error/2, over = p, co = 'black', thick = 3)
  ;
  ;
  ;
  ;        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
  ;        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)
  ;        ff = findgen(256)
  ;        cba = transpose([[ff], [ff], [ff]])
  ;        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
  ;        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2022 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')
  ;
  ;        win.Refresh
  ;        win.save, file_tmp+'\'+STRCOMPRESS(fluxidx+9, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
  ;        win.erase
  ;      endfor ; esa
  ;
  ;    endfor ; mom
  ;  endfor ; ram
  ;  ; ===================================================================== Ribbon Flux =====================================================================

  win.close
  ; ============================ Longitudinal Distribution of Moments ============================


end