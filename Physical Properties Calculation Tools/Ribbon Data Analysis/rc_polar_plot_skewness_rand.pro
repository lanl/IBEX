pro RC_Polar_plot_SKEWNESS_rand, MAPNAME, SEPNAME, VER, cpath
  tol = 1d-15

  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $rc_e_lonlat
    [218.08, 38.44], $
    [214.68, 34.13]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  win = window(dim = [800, 800], /buffer)
  win.refresh, /disable

  YEAR_MIN = 2009
  if mapname eq 'ISOC' then BEGIN
    YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
    lon_num = 60
  endif
  if mapname eq 'Theseus' then BEGIN
    YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
    lon_num = 180
  endif
  year_arr = [YEAR_MIN:YEAR_MAX]
  year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]

  DPATH = dp+MAPNAME+'-'+SEPNAME+'\'
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'

  fname = mapname+'-'+sepname+'_RC_Iteration'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, FPATH

  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for yidx = YEAR_MIN, YEAR_MAX do begin
      year = string(yidx, format = '(I4)')
      restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'
      print, YEAR

      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)

        !NULL = EXECUTE('PEAK_FIT = ESA'+ESA_STR+'_PEAK_FIT')
        !NULL = EXECUTE('peak_pos = [[lon_arr], [ESA'+ESA_STR+'_PEAK_POS]]')

        !NULL = EXECUTE('peak_pos = [[lon_arr], [reform(ESA'+ESA_STR+'_MOM2_4[0, *])]]')
        !NULL = EXECUTE('peak_pos_stddev = [reform(ESA'+ESA_STR+'_MOM2_4_error[0, *])]')

;        !NULL = EXECUTE('peak_pos = [[lon_arr], [reform(ESA'+ESA_STR+'_num_MOM[0, *])]]')
;        !NULL = EXECUTE('peak_pos_stddev = [reform(ESA'+ESA_STR+'_num_MOM_error[0, *])]')


        PP_TMP = peak_pos[*,1]

        idx = [80:130]
        tmp = max(PP_TMP[idx], minidx)

        lon_tail = lon_arr[idx[minidx]]
        lat_tail = tmp

        TMP = conv_coord_ec_rc(lon_tail, lat_tail, reform(RC_e_LONLAT[ESA-2, 1]), reform(RC_e_LONLAT[ESA-2, 2]), /REVERSE)
        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        Tail_pos_TMP = [TMP1.LON, TMP1.LAT]


        for momidx = 0, 7 do begin
          if momidx le 3 then !NULL = EXECUTE('num_mom = ESA'+ESA_STR+'_num_mom') ; mom x lon
          if momidx gt 3 then !NULL = EXECUTE('num_mom = ESA'+ESA_STR+'_MOM2_4') ; mom x lon
          !NULL = EXECUTE('num_mom1 = ESA'+ESA_STR+'_num_mom') ; mom x lon

          if momidx eq 0 then begin
            mrg = [65., 90]
            RGB_TABLE = 33
            mom_str = 'Mean'
            z_tmp = reform(num_mom[momidx, *])
          endif
          if momidx eq 1 then BEGIN
            mrg = [3, 20.]
            RGB_TABLE = 33
            mom_str = 'Stddev'
            z_tmp = reform(num_mom[momidx, *])
          endif
          if momidx eq 2 then BEGIN
            mrg = [-1, 1.]
            RGB_TABLE = 70
            mom_str = 'Skewness'
            z_tmp = reform(num_mom[momidx, *])
          ENDIF
          if momidx eq 3 then BEGIN
            mrg = [-1, 1.]
            RGB_TABLE = 70
            mom_str = 'Kurtosis'
            z_tmp = reform(num_mom[momidx, *])
          endif
          if momidx eq 4 then BEGIN
            mrg = [65, 90]
            RGB_TABLE = 33
            mom_str = 'Peak'
            z_tmp = reform(num_mom[momidx-4, *])
          endif
          if momidx eq 5 then BEGIN
            mrg = [10, 50.]
            RGB_TABLE = 33
            mom_str = 'FWHM'
            z_tmp = reform(num_mom[momidx-4, *])
          endif
          if momidx eq 6 then BEGIN
            mrg = [-3, 3.]
            RGB_TABLE = 70
            mom_str = 'PSKEW'
            z_tmp =  num_mom[momidx-4, *]/num_mom1[1, *]
          ENDIF
          if momidx eq 7 then BEGIN
            mrg = [2, 5]
            RGB_TABLE = 33
            mom_str = 'R80_20'
            z_tmp = reform(num_mom[momidx-4, *])
          endif

          ; grid draw
          p = plot([0, 0], [0, 0], /nodata, axis_style = 4, xr = [-140, 140], yr = [-140, 140], current = win, title = year+'!CESA'+esa_str+', '+mom_str)
          Rad = ([30, 60, 90, 120])##replicate(1d, 361)
          Pi = (findgen(361)*!dtor)#replicate(1d, 4)
          !null = polarplot(Rad, Pi, $
            overplot = p, $
            linestyle = 2)
          for pidx = 0, 11 do begin
            !null = polarplot([0, 120], [0, 30.*!dtor*pidx], over = p, linestyle = 2)
            txpos = [cos(30.*!dtor*pidx), sin(30.*!dtor*pidx)]*130d
            tx = text(txpos[0], txpos[1], string(30*pidx, format = '(I3)'), /data, align = 0.5, vertical_align = 0.5, font_size = 15)
          endfor

          ns = conv_coord_ec_rc(255.6, 5.14, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
          tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'Nose', /data, font_size = 15)

          ns = conv_coord_ec_rc(255, 35, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1)
          tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V1', /data, font_size = 15)

          ns = conv_coord_ec_rc(289, -32, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1)
          tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V2', /data, font_size = 15)

          en = conv_coord_ec_rc(0, 90, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(en.lat, 2), replicate(en.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
          tx = text(cos(!dtor*en.lon)*en.lat, sin(!dtor*en.lon)*en.lat, 'EN', /data, font_size = 15)

          en = conv_coord_ec_rc(0, -90, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(en.lat, 2), replicate(en.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
          tx = text(cos(!dtor*en.lon)*en.lat, sin(!dtor*en.lon)*en.lat, 'ES', /data, font_size = 15)
          ; grid draw

          CO = 'BLACK'

          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, symbol = '*', linestyle = 6, over = p, SYM_COLOR = CO)

          x_tmp = PEAK_POS_TMP[*, 1]*cos(PEAK_POS_TMP[*, 0]*!dtor) & y_tmp = PEAK_POS_TMP[*, 1]*sin(PEAK_POS_TMP[*, 0]*!dtor)

          fidx = where(finite(z_tmp) and finite(x_tmp) and finite(y_tmp))
          x_tmp = x_tmp[fidx] & y_tmp = y_tmp[fidx] & z_tmp = z_tmp[fidx]
          z_tmp_byt = bytscl(z_tmp, min = mrg[0], max = mrg[1])

          sc = scatterplot(x_tmp, y_tmp, magnitude = z_tmp_byt, rgb_table = RGB_TABLE, over = p, sym_thick = 2)
          cb = color_bar(sc, location = 'bottom', xtickformat = '(a1)', xticklen = 0)
          yaxis = AXIS('X', target = cb, LOCATION='bottom', COORD_TRANSFORM=[MRG[0], (MRG[1]-MRG[0])/255.], title = MOM_STR)
          tx = text(0.15, 0.95, ' R  Lon_EC Lat_EC', font_size = 15)

          if TOTAL(PEAK_FIT[*, 0]) gt 0 then begin
            TMP = conv_coord_ec_rc(peak_pos[*, 0], PEAK_FIT[*, 0], reform(RC_c_LONLAT[ESA-2, 1]), reform(RC_c_LONLAT[ESA-2, 2]), /REVERSE)
            TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
            p = polarplot(TMP1.lat, TMP1.lon*!dtor, over = p, co = 'blue')
            TMP1 = conv_coord_ec_rc(rc_c_lonlat[esa-2, 1], rc_c_lonlat[esa-2, 2], reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))

            p = polarplot(replicate(TMP1.lat, 2), replicate(TMP1.lon, 2)*!dtor, over = p, co = 'blue', symbol = '+', sym_size = 3);, sym_thick = 3)

            tx = text(0.052, 0.92, 'Circle  '+string(rc_c_lonlat[esa-2, 0], format = '(f5.1)')+' '+string(rc_c_lonlat[esa-2, 1], format = '(f5.1)')+' '+string(rc_c_lonlat[esa-2, 2], format = '(f5.1)'), font_size = 15)
          endif else tx = text(0.05, 0.92, 'Circle fit failed', font_size = 15)

          if TOTAL(PEAK_FIT[*, 1]) gt 0 then begin
            TMP = conv_coord_ec_rc(peak_pos[*, 0],PEAK_FIT[*, 1], reform(RC_e_LONLAT[ESA-2, 1]), reform(RC_e_LONLAT[ESA-2, 2]), /REVERSE)
            TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
            p = polarplot(TMP1.lat, TMP1.lon*!dtor, over = p, co = 'red')
            TMP1 = conv_coord_ec_rc(rc_e_lonlat[esa-2, 1], rc_e_lonlat[esa-2, 2], reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
            p = polarplot(replicate(TMP1.lat, 2), replicate(TMP1.lon, 2)*!dtor, over = p, co = 'red', symbol = 'X', sym_size = 3)


            major_tmp = [[replicate(rc_e_PAR[esa-2, 2]+180, 31), replicate(rc_e_PAR[esa-2, 2], 31)], [linspace(30, 0, 31), linspace(0, 30, 31)]]
            TMP = conv_coord_ec_rc(major_tmp[*, 0], major_tmp[*, 1], reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
            TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
            major_tmp = [[TMP1.LON], [TMP1.LAT]]

            p = polarplot(major_tmp[*, 1], major_tmp[*, 0]*!dtor, thick = 2, over = p, color = 'red')

            ;            p = polarplot(replicate(TMP1.lat, 2), replicate(TMP1.lon, 2)*!dtor, over = p, co = 'red', symbol = 'X', sym_size = 3)
            ;            string(rc_e_PAR[esa-2, 2], format = '(f5.1)')

            tx = text(0.05, 0.89, 'Ellipse '+string(rc_e_lonlat[esa-2, 0], format = '(f5.1)')+' '+string(rc_e_lonlat[esa-2, 1], format = '(f5.1)')+' '+string(rc_e_lonlat[esa-2, 2], format = '(f5.1)') + string(rc_e_PAR[esa-2, 2], format = '(f5.1)'), font_size = 15)
          endif  else tx = text(0.05, 0.89, 'Ellipse fit failed', font_size = 15)

          ; error lines, 1sigma
          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]-peak_pos_stddev/2, reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, thick = 2, over = p, SYM_COLOR = 'magenta', color = 'magenta')

          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]+peak_pos_stddev/2, reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, thick = 2, over = p, SYM_COLOR = 'magenta', color = 'magenta')

          ; error lines, 1sigma


          ; tail pos
          p = polarplot(replicate(Tail_pos_TMP[1], 2), replicate(Tail_pos_TMP[0], 2)*!dtor, symbol = 'tu', sym_thick = 2, sym_size = 2, over = p, SYM_COLOR = 'brown')


          win.refresh
          fpath_tmp = FPATH+'Ribbon_Fit_NUM_mom_dist\'+str+'\'+mom_str+'\'
          file_mkdir, fpath_tmp
          win.save, fpath_tmp+'ESA'+esa_str+'_'+year+'_'+mom_str+'.png', res = 150
          win.erase

        endfor ; moment
      end ; esa
    endfor ; year
  ENDFOR ; ram
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  win.close

end