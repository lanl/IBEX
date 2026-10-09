pro RC_FIT_ELLIPSE_PLOT_rand_20250608
  MAPNAME = 'Theseus'
  SEPNAME = 'L'
  ver = 'svGP_v20240413'; 'svGP_v20250323_patialfit' ;'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'

  tol = 1d-15

  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  ;  RC_DAYEH_LONLAT = [[217.41, 44.36], $
  ;    [219.72, 41.50], $
  ;    [220.51, 39.96], $ ;rc_e_lonlat
  ;    [218.08, 38.44], $
  ;    [214.68, 34.13]]

  RC_DAYEH_LONLAT = [[227.28, 34.62], $
    [227.28, 34.62], $
    [227.28, 34.62], $
    [227.28, 34.62], $
    [227.28, 34.62]] ; ISMF from Zirnstein et al. 2016b & 2023 (https://iopscience.iop.org/article/10.3847/1538-4357/acc577)

  e_step = [0.71,1.11,1.74,2.73,4.29]


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
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\ELLIPSE_PLOT_fixedB_MeanLOC_20250612\'
  FPATH1 = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\RC_Summary_mom_dist_colored\'
  file_mkdir, FPATH1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, FPATH

  ct = 33
  co = rgb_vector(n_elements([YEAR_MIN:YEAR_MAX]), ct = ct)
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)

      ; grid draw
      p = plot([0, 0], [0, 0], /nodata, $
        axis_style = 4, xr = [-140, 140], yr = [-140, 140], current = win, $
        title = string(e_step[esa-2], format = '(f4.2)')+'keV', font_size = 20)
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
      tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'Nose', /data, font_size = 20)

      ns = conv_coord_ec_rc(255, 35, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1)
      tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V1', /data, font_size = 20)

      ns = conv_coord_ec_rc(289, -32, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1)
      tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V2', /data, font_size = 20)

      en = conv_coord_ec_rc(0, 90, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(en.lat, 2), replicate(en.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
      tx = text(cos(!dtor*en.lon)*en.lat, sin(!dtor*en.lon)*en.lat, 'EN', /data, font_size = 20)

      es = conv_coord_ec_rc(0, -90, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(es.lat, 2), replicate(es.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
      tx = text(cos(!dtor*es.lon)*es.lat, sin(!dtor*es.lon)*es.lat, 'ES', /data, font_size = 20)
      ; grid draw

      ;      NtoS = transpose(GreatCircle([es.lon, 90-es.lat], [en.lon, 90-en.lat], npath = 1000))
      ;      NtoS[*, -1] = 90-NtoS[*, -1]
      ;
      ;      res = map_2points(es.lon, 90-es.lat, en.lon, 90-en.lat)


      NtoS = transpose(GreatCircle([es.lon, 90-es.lat], [en.lon, 90-en.lat], npath = 1000, midpoint = [0, 90]))
      NtoS[*, -1] = 90-NtoS[*, -1]
      NtoS[where(NtoS[*, -1] gt 120), -1] = !values.f_nan




      for yidx = YEAR_MIN, YEAR_MAX do begin
        year = string(yidx, format = '(I4)')
        restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

        !NULL = EXECUTE('PEAK_FIT = ESA'+ESA_STR+'_PEAK_FIT')
        !NULL = EXECUTE('peak_pos = [[lon_arr], [ESA'+ESA_STR+'_PEAK_POS]]')

        !NULL = EXECUTE('peak_pos = [[lon_arr], [reform(ESA'+ESA_STR+'_MOM2_4[0, *])]]')
        !NULL = EXECUTE('peak_pos_stddev = [reform(ESA'+ESA_STR+'_MOM2_4_error[0, *])]')


        PP_TMP = peak_pos[*,1]

        idx = [80:130]
        tmp = max(PP_TMP[idx], minidx)

        lon_tail = lon_arr[idx[minidx]]
        lat_tail = tmp

        TMP = conv_coord_ec_rc(lon_tail, lat_tail, reform(RC_e_LONLAT[ESA-2, 1]), reform(RC_e_LONLAT[ESA-2, 2]), /REVERSE)
        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        Tail_pos_TMP = [TMP1.LON, TMP1.LAT]

        ;        MOMIDX = 0
        ;        if momidx le 3 then !NULL = EXECUTE('num_mom = ESA'+ESA_STR+'_num_mom') ; mom x lon
        ;        if momidx gt 3 then !NULL = EXECUTE('num_mom = ESA'+ESA_STR+'_MOM2_4') ; mom x lon
        ;        !NULL = EXECUTE('num_mom1 = ESA'+ESA_STR+'_num_mom') ; mom x lon
        ;
        ;        if momidx eq 0 then begin
        ;          mrg = [65., 90]
        ;          RGB_TABLE = 33
        ;          mom_str = 'Mean'
        ;          z_tmp = reform(num_mom[momidx, *])
        ;        endif
        ;
        ;        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
        ;        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        ;        PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
        ;        p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, symbol = '*', linestyle = 6, over = p, SYM_COLOR = CO)
        ;        x_tmp = PEAK_POS_TMP[*, 1]*cos(PEAK_POS_TMP[*, 0]*!dtor) & y_tmp = PEAK_POS_TMP[*, 1]*sin(PEAK_POS_TMP[*, 0]*!dtor)
        ;        fidx = where(finite(z_tmp) and finite(x_tmp) and finite(y_tmp))
        ;        x_tmp = x_tmp[fidx] & y_tmp = y_tmp[fidx] & z_tmp = z_tmp[fidx]
        ;        z_tmp_byt = bytscl(z_tmp, min = mrg[0], max = mrg[1])

        ; PEAK_FIT[*, 1] --> ELLIPSE FIT
        if TOTAL(PEAK_FIT[*, 1]) gt 0 then begin
          TMP = conv_coord_ec_rc(peak_pos[*, 0],PEAK_FIT[*, 1], reform(RC_e_LONLAT[ESA-2, 1]), reform(RC_e_LONLAT[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(TMP1.lat, TMP1.lon*!dtor, over = p, co = co[*, yidx-year_min])
          TMP1 = conv_coord_ec_rc(rc_e_lonlat[esa-2, 1], rc_e_lonlat[esa-2, 2], reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(TMP1.lat, 2), replicate(TMP1.lon, 2)*!dtor, over = p, sym_color = co[*, yidx-year_min], symbol = '*', sym_size = 2, linestyle = 6)


          major_tmp = [[replicate(rc_e_PAR[esa-2, 2]+180, fix(rc_e_PAR[esa-2, 0])+1), replicate(rc_e_PAR[esa-2, 2], fix(rc_e_PAR[esa-2, 0])+1)], [linspace(rc_e_PAR[esa-2, 0], 0, fix(rc_e_PAR[esa-2, 0])+1), linspace(0, rc_e_PAR[esa-2, 0], fix(rc_e_PAR[esa-2, 0])+1)]]
          TMP = conv_coord_ec_rc(major_tmp[*, 0], major_tmp[*, 1], reform(rc_e_lonlat[ESA-2, 1]), reform(rc_e_lonlat[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          major_tmp = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(major_tmp[*, 1], major_tmp[*, 0]*!dtor, thick = 2, over = p, color = co[*, yidx-year_min])

          dist_foci = sqrt(rc_e_PAR[esa-2, 0]^2-rc_e_PAR[esa-2, 1]^2)
          foci = [[rc_e_PAR[esa-2, 2]+180, rc_e_PAR[esa-2, 2]], [dist_foci, dist_foci]]
          TMP = conv_coord_ec_rc(foci[*, 0], foci[*, 1], reform(rc_e_lonlat[ESA-2, 1]), reform(rc_e_lonlat[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          major_tmp = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(major_tmp[*, 1], major_tmp[*, 0]*!dtor, over = p, sym_color = 'gray', symbol = '.', sym_size = 3, thick = 3, linestyle = 6)

          ;          tx = text(0.05, 0.89, 'Ellipse '+string(rc_e_lonlat[esa-2, 0], format = '(f5.1)')+' '+string(rc_e_lonlat[esa-2, 1], format = '(f5.1)')+' '+string(rc_e_lonlat[esa-2, 2], format = '(f5.1)') + string(rc_e_PAR[esa-2, 2], format = '(f5.1)'), font_size = 15)
        endif ; else tx = text(0.05, 0.89, 'Ellipse fit failed', font_size = 15)
        ;        ; error lines, 1sigma
        ;        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]-peak_pos_stddev/2, reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
        ;        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        ;        PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
        ;        p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, thick = 2, over = p, SYM_COLOR = 'magenta', color = 'magenta')
        ;
        ;        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]+peak_pos_stddev/2, reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
        ;        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        ;        PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
        ;        p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, thick = 2, over = p, SYM_COLOR = 'magenta', color = 'magenta')
        ;        ; error lines, 1sigma

        ;        ; tail pos
        ;        p = polarplot(replicate(Tail_pos_TMP[1], 2), replicate(Tail_pos_TMP[0], 2)*!dtor, symbol = 'tu', sym_thick = 1, sym_size = 1, over = p, SYM_COLOR = co[*, yidx-year_min])

        p = polarplot(NtoS[*, 1], NtoS[*, 0]*!dtor, over = p, COLOR = 'magenta', thick = 4, linestyle = 1, transparency = 50)


      endfor ; year
      CB_TMP1 = [YEAR_MIN:YEAR_MAX]
      CB_TMP2 = REBIN(CB_TMP1, CB_TMP1.length, 3)
      CB = SPEC_PLOT(CB_TMP2, CB_TMP1, FINDGEN(3), xtext_orientation = -20, font_size = 13, xbound = [[CB_TMP1-0.5], [CB_TMP1+0.5]], xr = [2008.5, 2022.5], yr = [0, 2], XTICKINTERVAL = 1, XMINOR = 0, xtitle = 'Year', YTICKLEN = 0, YTICKFORMAT = '(a1)', CURRENT = WIN, POS = [P.POSITION[0], P.POSITION[1]-0.04, P.POSITION[2], P.POSITION[1]-0.02], rgb_table = ct)

      win.refresh
      win.save, FPATH+'Fit_Plot_ESA'+esa_str+'.png', res = 150
      win.save, FPATH1+'Fit_Plot_ESA'+esa_str+'.png', res = 150
      win.erase
    end ; esa
  ENDFOR ; ram

  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)

      ; grid draw
      p = plot([0, 0], [0, 0], /nodata, $
        axis_style = 4, xr = [-140, 140], yr = [-140, 140], current = win, $
        title = string(e_step[esa-2], format = '(f4.2)')+'keV', font_size = 20)
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
      tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'Nose', /data, font_size = 20)

      ns = conv_coord_ec_rc(255, 35, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1)
      tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V1', /data, font_size = 20)

      ns = conv_coord_ec_rc(289, -32, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1)
      tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V2', /data, font_size = 20)

      en = conv_coord_ec_rc(0, 90, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(en.lat, 2), replicate(en.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
      tx = text(cos(!dtor*en.lon)*en.lat, sin(!dtor*en.lon)*en.lat, 'EN', /data, font_size = 20)

      es = conv_coord_ec_rc(0, -90, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
      p = polarplot(replicate(es.lat, 2), replicate(es.lon, 2)*!dtor, symbol = 'S', over = p, /sym_filled, sym_size = 1, sym_color = 'black')
      tx = text(cos(!dtor*es.lon)*es.lat, sin(!dtor*es.lon)*es.lat, 'ES', /data, font_size = 20)
      ; grid draw

      ;      NtoS = transpose(GreatCircle([es.lon, 90-es.lat], [en.lon, 90-en.lat], npath = 1000))
      ;      NtoS[*, -1] = 90-NtoS[*, -1]

      NtoS = transpose(GreatCircle([es.lon, 90-es.lat], [en.lon, 90-en.lat], npath = 1000, midpoint = [0, 90]))
      NtoS[*, -1] = 90-NtoS[*, -1]
      NtoS[where(NtoS[*, -1] gt 120), -1] = !values.f_nan


      for yidx = YEAR_MIN, YEAR_MAX do begin
        year = string(yidx, format = '(I4)')
        restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

        !NULL = EXECUTE('PEAK_FIT = ESA'+ESA_STR+'_PEAK_FIT')
        ;        !NULL = EXECUTE('peak_pos = [[lon_arr], [ESA'+ESA_STR+'_PEAK_POS]]')
        ;        !NULL = EXECUTE('peak_pos = [[lon_arr], [reform(ESA'+ESA_STR+'_MOM2_4[0, *])]]')
        ;        !NULL = EXECUTE('peak_pos_stddev = [reform(ESA'+ESA_STR+'_MOM2_4_error[0, *])]')

        !NULL = EXECUTE('peak_pos = [[lon_arr], [reform(ESA'+ESA_STR+'_NUM_MOM[0, *])]]')
        !NULL = EXECUTE('peak_pos_stddev = [reform(ESA'+ESA_STR+'_NUM_MOM_error[0, *])]')

        PP_TMP = peak_pos[*,1]

        idx = [80:130]
        tmp = max(PP_TMP[idx], minidx)

        lon_tail = lon_arr[idx[minidx]]
        lat_tail = tmp

        TMP = conv_coord_ec_rc(lon_tail, lat_tail, reform(RC_e_LONLAT[ESA-2, 1]), reform(RC_e_LONLAT[ESA-2, 2]), /REVERSE)
        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        Tail_pos_TMP = [TMP1.LON, TMP1.LAT]

        ;        MOMIDX = 0
        ;        if momidx le 3 then !NULL = EXECUTE('num_mom = ESA'+ESA_STR+'_num_mom') ; mom x lon
        ;        if momidx gt 3 then !NULL = EXECUTE('num_mom = ESA'+ESA_STR+'_MOM2_4') ; mom x lon
        ;        !NULL = EXECUTE('num_mom1 = ESA'+ESA_STR+'_num_mom') ; mom x lon
        ;
        ;        if momidx eq 0 then begin
        ;          mrg = [65., 90]
        ;          RGB_TABLE = 33
        ;          mom_str = 'Mean'
        ;          z_tmp = reform(num_mom[momidx, *])
        ;        endif
        ;
        ;        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
        ;        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        ;        PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
        ;        p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, symbol = '*', linestyle = 6, over = p, SYM_COLOR = CO)
        ;        x_tmp = PEAK_POS_TMP[*, 1]*cos(PEAK_POS_TMP[*, 0]*!dtor) & y_tmp = PEAK_POS_TMP[*, 1]*sin(PEAK_POS_TMP[*, 0]*!dtor)
        ;        fidx = where(finite(z_tmp) and finite(x_tmp) and finite(y_tmp))
        ;        x_tmp = x_tmp[fidx] & y_tmp = y_tmp[fidx] & z_tmp = z_tmp[fidx]
        ;        z_tmp_byt = bytscl(z_tmp, min = mrg[0], max = mrg[1])

        ; PEAK_FIT[*, 1] --> ELLIPSE FIT
        if TOTAL(PEAK_FIT[*, 1]) gt 0 then begin
          TMP = conv_coord_ec_rc(peak_pos[*, 0],peak_pos[*, 1], reform(RC_e_LONLAT[ESA-2, 1]), reform(RC_e_LONLAT[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(TMP1.lat, TMP1.lon*!dtor, over = p, co = co[*, yidx-year_min])
          TMP1 = conv_coord_ec_rc(rc_e_lonlat[esa-2, 1], rc_e_lonlat[esa-2, 2], reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          p = polarplot(replicate(TMP1.lat, 2), replicate(TMP1.lon, 2)*!dtor, over = p, sym_color = co[*, yidx-year_min], symbol = '*', sym_size = 2, linestyle = 6)

          major_tmp = [[replicate(rc_e_PAR[esa-2, 2]+180, fix(rc_e_PAR[esa-2, 0])+1), replicate(rc_e_PAR[esa-2, 2], fix(rc_e_PAR[esa-2, 0])+1)], [linspace(rc_e_PAR[esa-2, 0], 0, fix(rc_e_PAR[esa-2, 0])+1), linspace(0, rc_e_PAR[esa-2, 0], fix(rc_e_PAR[esa-2, 0])+1)]]
          TMP = conv_coord_ec_rc(major_tmp[*, 0], major_tmp[*, 1], reform(rc_e_lonlat[ESA-2, 1]), reform(rc_e_lonlat[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          major_tmp = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(major_tmp[*, 1], major_tmp[*, 0]*!dtor, thick = 2, over = p, color = co[*, yidx-year_min])


          dist_foci = sqrt(rc_e_PAR[esa-2, 0]^2-rc_e_PAR[esa-2, 1]^2)
          foci = [[rc_e_PAR[esa-2, 2]+180, rc_e_PAR[esa-2, 2]], [dist_foci, dist_foci]]
          TMP = conv_coord_ec_rc(foci[*, 0], foci[*, 1], reform(rc_e_lonlat[ESA-2, 1]), reform(rc_e_lonlat[ESA-2, 2]), /REVERSE)
          TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
          major_tmp = [[TMP1.LON], [TMP1.LAT]]
          p = polarplot(major_tmp[*, 1], major_tmp[*, 0]*!dtor, over = p, sym_color = 'gray', symbol = '.', sym_size = 3, thick = 3, linestyle = 6)
          ;          tx = text(0.05, 0.89, 'Ellipse '+string(rc_e_lonlat[esa-2, 0], format = '(f5.1)')+' '+string(rc_e_lonlat[esa-2, 1], format = '(f5.1)')+' '+string(rc_e_lonlat[esa-2, 2], format = '(f5.1)') + string(rc_e_PAR[esa-2, 2], format = '(f5.1)'), font_size = 15)
        endif ; else tx = text(0.05, 0.89, 'Ellipse fit failed', font_size = 15)
        ;        ; error lines, 1sigma
        ;        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]-peak_pos_stddev/2, reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
        ;        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        ;        PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
        ;        p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, thick = 2, over = p, SYM_COLOR = 'magenta', color = 'magenta')
        ;
        ;        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]+peak_pos_stddev/2, reform(RC_C_LONLAT[ESA-2, 1]), reform(RC_C_LONLAT[ESA-2, 2]), /REVERSE)
        ;        TMP1 = conv_coord_ec_rc(TMP.LON, TMP.LAT, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))
        ;        PEAK_POS_TMP = [[TMP1.LON], [TMP1.LAT]]
        ;        p = polarplot(PEAK_POS_TMP[*, 1], PEAK_POS_TMP[*, 0]*!dtor, thick = 2, over = p, SYM_COLOR = 'magenta', color = 'magenta')
        ;        ; error lines, 1sigma

        ;        ; tail pos
        ;        p = polarplot(replicate(Tail_pos_TMP[1], 2), replicate(Tail_pos_TMP[0], 2)*!dtor, symbol = 'tu', sym_thick = 1, sym_size = 1, over = p, SYM_COLOR = co[*, yidx-year_min])

        p = polarplot(NtoS[*, 1], NtoS[*, 0]*!dtor, over = p, COLOR = 'magenta', thick = 4, linestyle = 1, transparency = 50)


      endfor ; year
      CB_TMP1 = [YEAR_MIN:YEAR_MAX]
      CB_TMP2 = REBIN(CB_TMP1, CB_TMP1.length, 3)
      CB = SPEC_PLOT(CB_TMP2, CB_TMP1, FINDGEN(3), font_size = 13, xbound = [[CB_TMP1-0.5], [CB_TMP1+0.5]], xr = [2008.5, 2022.5], yr = [0, 2], XTICKINTERVAL = 1, XMINOR = 0, xtitle = 'Year', YTICKLEN = 0, YTICKFORMAT = '(a1)', CURRENT = WIN, POS = [P.POSITION[0], P.POSITION[1]-0.04, P.POSITION[2], P.POSITION[1]-0.02], rgb_table = ct)

      win.refresh
      win.save, FPATH+'Data_Plot_ESA'+esa_str+'.png', res = 150
      win.save, FPATH1+'Data_Plot_ESA'+esa_str+'.png', res = 150
      win.erase
    end ; esa
  ENDFOR ; ram
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  win.close
  print, fpath


  ;  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\Erics_Model\'
  ;  cd, cpath
  ;  Erics_Model_Peak_Center_MULTI_RUN


end