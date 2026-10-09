pro Ribbon_width_Overplot_Theseus_ISOC_Official
  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  survp =  reform(survp_map[*, 0, *, *, *])


  for mapidx = 0,0 do begin
    if mapidx eq 0 then begin
      MAPNAME  = 'Theseus'
      VER = 'svGP_v20240413'
      cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
    endif

    if mapidx eq 1 then begin
      MAPNAME  = 'ISOC'
      ver = '20240325';'230809' ;
      cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\For_ISOC-L\'
    endif

    SEPNAME = 'L'

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
      if sepname eq 'L' then YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
      if sepname eq 'D' then YEAR_MAX = 2019 ; ISOC = 2019, THESEUS = 2020
      lon_num = 60
      lat_num = 30
    endif
    if mapname eq 'Theseus' then BEGIN
      YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
      lon_num = 180
      lat_num = 90
    endif
    year_arr = [YEAR_MIN:YEAR_MAX]
    year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]



    fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
    fit_par_sig_circ = replicate(!values.d_nan, 3, year_arr.length, 5, 2); RLonLat x year x esa x ram

    fit_par_ellip = replicate(!values.d_nan, 6, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot,sig x year x esa x ram
    fit_par_sig_ellip = replicate(!values.d_nan, 5, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot x year x esa x ram


    moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

    Ribbon_stack = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

    moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
    Ribbon_stack_error = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

    DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
    FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'
    file_tmp = FPATH + 'RC_Summary_mom_dist_colored\'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    FILE_MKDIR, file_tmp

    ; data stacking
    for yidx = year_min, YEAR_MAX do begin
      FOR ram = 0, 0 DO BEGIN
        IF ram THEN str = 'ARam' ELSE str = 'Ram'

        year = string(yidx, format = '(I4)')
        restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

        FOR ESA = 2, 6 DO BEGIN
          ESA_STR = strcompress(esa, /rem)
          if rc_c_lonlat[esa-2, 3] gt 0 then begin
            fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
            fit_par_sig_circ[*, (yidx-year_min), esa-2, ram] = reform([rc_c_PAR_SIG[esa-2, 0], rc_c_PAR_SIG[esa-2, 2], rc_c_PAR_SIG[esa-2, 1]]); RLonLat x year x esa
          endif

          if rc_e_lonlat[esa-2, 3] gt 0 then begin
            fit_par_ellip[*, (yidx-year_min), esa-2, ram] = [reform(rc_e_lonlat[esa-2, 0:2]), sqrt(1-(reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2), reform(rc_e_PAR[esa-2, 2]), reform(rc_e_lonlat[esa-2, 3])]; R,Lon,Lat,Ellip,Rot,sig x year x esa

            fit_par_sig_ellip[*, (yidx-year_min), esa-2, ram] = $
              [reform(sqrt(rc_E_PAR_SIG[esa-2, 0]^2+rc_E_PAR_SIG[esa-2, 1]^2)), $ ;R
              reform(rc_E_PAR_SIG[esa-2, 4]), $ ;Lon
              reform(rc_E_PAR_SIG[esa-2, 3]), $ ;Lat
              reform(rc_e_PAR[esa-2, 1]/rc_e_PAR[esa-2, 0] * sqrt((rc_E_PAR_SIG[esa-2, 0]/rc_e_PAR[esa-2, 0])^2+(rc_E_PAR_SIG[esa-2, 1]/rc_e_PAR[esa-2, 1])^2)), $ ;Ellip
              reform(rc_E_PAR_SIG[esa-2, 2])] ; Rot
          endif

          !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
          !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
          !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
          !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')
          !NULL = EXECUTE('Ribbon_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')

          !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
          !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
          !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
          !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')
          !NULL = EXECUTE('Ribbon_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_STDDEV_MAP')

        endfor ; esa
      endfor ; year
    ENDFOR ; ram
    ; data stacking

    BV = GreatCircle([255.6, 5.14], [226.99, 34.82], npath = 1000) ; ISMF 227.28, 34.62 Zirnstein et al. 2016b 2023, nose direction 259, 5 Funsten et al. 2013

    ; ============================ Longitudinal Distribution of Moments ============================
    win = window(dim = [900, 800], /buffer)
    win.refresh, /disable
    POS1 = [0.1, 0.08, 0.85, 0.7]
    POS2 = [0.1, 0.7, 0.85, 0.95]

    average_mom = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram
    average_mom2_4 = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram
    stddev_mom = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram
    stddev_mom2_4 = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram

    average_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram
    average_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram
    stddev_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram
    stddev_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram


    average4_mom = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram
    average4_mom2_4 = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram
    stddev4_mom = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram
    stddev4_mom2_4 = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram

    average4_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram
    average4_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram
    stddev4_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram
    stddev4_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram


    num_sec = 4
    lb_arr = linspace(0, 360, num_sec+1)
    lb_arr = lb_arr-10
    sector_name = ['Nose', 'North', 'Tail', 'South']


    ; ===================================================================== NUMERICAL MOMENTS =====================================================================
    FOR ram = 0, 1 DO BEGIN
      IF ram THEN str = 'ARam' ELSE str = 'Ram'

      for momidx = 0, 3 do begin


        for esa = 2, 6 do begin
          ESA_STR = strcompress(esa, /rem)

          ytmp = reform(moment_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
          ytmp_error = reform(moment_stack_error[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram

          lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

          peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

          ; Fixed RC Coordinate
          sz = size(ytmp)
          yy = ytmp
          yy[*] = !values.d_nan
          yyidx = ytmp
          yyidx[*] = 0

          yy_error = ytmp_error
          yy_error[*] = !values.d_nan

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
              ;            yy_error[lidx, yidx] =  sqrt(total(ytmp_error[idx, yidx]^2, /nan))/total(finite(ytmp_error[idx, yidx])) ; lon x year x ab x ram x esa x model x moment
              yy_error[lidx, yidx] =  sqrt(mean(ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment
              yyidx[lidx, yidx] = tmp
              hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
            endfor
          endfor
          ; Fixed RC Coordinate

          ytmp = yy
          ytmp_error = yy_error

          data_available = total(finite(ytmp), 2)
          data_mean = mean(ytmp, dim = 2, /nan)

          data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
          data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))

          q = quartile(ytmp, dim = 2)
          hp_dist_mean = mean(hp_mat, dim = 2, /nan)
          ec_lat_mean = mean(ec_lat, dim = 2, /nan)
          ec_lat_sign = sign(ec_lat_mean)

          idx = where(data_available lt 5, /null)
          data_mean[idx] = !values.d_nan
          q[*, idx] = !values.d_nan


          average_mom[esa-2, momidx, ram] = mean(data_mean, /nan)
          stddev_mom[esa-2, momidx, ram] = sqrt(mean(ytmp_error^2, /nan))


          for sec_idx = 0, num_sec - 1 do begin
            if sec_idx eq 0 then $
              lonidx = where(lon_arr ge lb_arr[sec_idx]+360 or lon_arr lt lb_arr[sec_idx+1]) $
            else $
              lonidx = where(lon_arr ge lb_arr[sec_idx] and lon_arr lt lb_arr[sec_idx+1])
            average4_mom[esa-2, momidx, ram, sec_idx] = mean(data_mean[lonidx], /nan)
            stddev4_mom[esa-2, momidx, ram, sec_idx] = sqrt(mean(ytmp_error[lonidx]^2, /nan))
          endfor




          average_mom_year[esa-2, momidx, ram, *] = mean(ytmp, /nan, dim = 1)
          stddev_mom_year[esa-2, momidx, ram, *] = sqrt(mean(ytmp_error^2, dim = 1, /nan))

        endfor ; esa

      endfor ; mom
      ; ===================================================================== NUMERICAL MOMENTS =====================================================================

      ; ===================================================================== SEMI MOMENTS =====================================================================
      for momidx = 0, 3 do begin


        for esa = 2, 6 do begin
          ESA_STR = strcompress(esa, /rem)

          ytmp = reform(moment24_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa
          ytmp_error = reform(moment24_stack_error[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram

          lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

          peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

          ; Fixed RC Coordinate
          sz = size(ytmp)
          yy = ytmp
          yy[*] = !values.d_nan
          yyidx = ytmp
          yyidx[*] = 0

          yy_error = ytmp_error
          yy_error[*] = !values.d_nan

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
              ;            yy_error[lidx, yidx] = sqrt(total(ytmp_error[idx, yidx]^2, /nan))/total(finite(ytmp_error[idx, yidx])) ; lon x year x ab x ram x esa x model x moment
              yy_error[lidx, yidx] = sqrt(mean(ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment
              yyidx[lidx, yidx] = tmp
              hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
            endfor
          endfor
          ; Fixed RC Coordinate

          ytmp = yy
          ytmp_error = yy_error

          data_available = total(finite(ytmp), 2)
          data_mean = mean(ytmp, dim = 2, /nan)

          data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
          data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))

          q = quartile(ytmp, dim = 2)
          hp_dist_mean = mean(hp_mat, dim = 2, /nan)
          ec_lat_mean = mean(ec_lat, dim = 2, /nan)
          ec_lat_sign = sign(ec_lat_mean)

          idx = where(data_available lt 5, /null)
          data_mean[idx] = !values.d_nan
          q[*, idx] = !values.d_nan

          average_mom2_4[esa-2, momidx, ram] = mean(data_mean, /nan)
          stddev_mom2_4[esa-2, momidx, ram] = sqrt(mean(ytmp_error^2, /nan))

          for sec_idx = 0, num_sec - 1 do begin
            if sec_idx eq 0 then $
              lonidx = where(lon_arr ge lb_arr[sec_idx]+360 or lon_arr lt lb_arr[sec_idx+1]) $
            else $
              lonidx = where(lon_arr ge lb_arr[sec_idx] and lon_arr lt lb_arr[sec_idx+1])
            average4_mom2_4[esa-2, momidx, ram, sec_idx] = mean(data_mean[lonidx], /nan)
            stddev4_mom2_4[esa-2, momidx, ram, sec_idx] = sqrt(mean(ytmp_error[lonidx]^2, /nan))
          endfor

          average_mom2_4_year[esa-2, momidx, ram, *] = mean(ytmp, /nan, dim = 1)
          ;        stddev_mom2_4_year[esa-2, momidx, ram, *] = (quartile(ytmp, dim = 1))[1, *]-(quartile(ytmp, dim = 1))[0, *]

          ;        average_mom2_4_year[esa-2, momidx, ram, *] = total(ytmp/ytmp_error, 1, /nan)/total(1/ytmp_error, 1, /nan)
          stddev_mom2_4_year[esa-2, momidx, ram, *] = sqrt(mean(ytmp_error^2, dim = 1, /nan))
          ;        stddev_mom2_4_year[esa-2, momidx, ram, *] = sqrt(total(ytmp_error^2, 1, /nan))/total(finite(ytmp_error), 1)
          ;if momidx eq 2 then stop
        endfor ; esa

      endfor ; mom
      ; ===================================================================== SEMI MOMENTS =====================================================================


      ; ================== sky map rotation =========================

      for yidx = year_min, YEAR_MAX do begin
        for esa = 2, 6 do begin
          ESA_STR = strcompress(esa, /rem)

          esa_map = reform(Ribbon_stack[*, *, yidx-year_min, esa-2, 0])
          esa_map_error = reform(Ribbon_stack_error[*, *, yidx-year_min, esa-2, 0])

          P0 = fit_par_circ[1, (yidx-year_min), esa-2, 0]
          T0 = fit_par_circ[2, (yidx-year_min), esa-2, 0]

          ; 111111111111111 esa map from rc to ec
          res = meshgrid(LON_ARR, lat_rc)
          lat_mat = res.remove()
          lon_mat = res.remove()
          conv = conv_coord_ec_rc(lON_mat, lat_mat-90, P0, T0, nose_POS = [255.6, 5.14])
          P1 = conv.LON
          T1 = conv.LAT
          ;      T1 = T1-90
          LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
          LAT_IDX = interpol(dindgen(lat_rc.length), lat_rc, T1)

          ESA_MAP = INTERPOLATE(esa_map, LON_IDX, LAT_IDX, /DOUBLE)
          esa_map_error = INTERPOLATE(esa_map_error, LON_IDX, LAT_IDX, /DOUBLE)

          ESA_MAP = ESA_MAP/reform(survp[yidx-year_min, *, *, esa-2])
          esa_map_error = sqrt(esa_map_error^2/reform(survp[yidx-year_min, *, *, esa-2]))


          res = meshgrid(LON_ARR, lat_arr)
          lat_mat = res.remove()
          lon_mat = res.remove()
          res = conv_coord_ec_rc(lON_mat, lat_mat+90, RC_DAYEH_LONLAT[0, esa-2], RC_DAYEH_LONLAT[1, esa-2], /reverse, nose_POS = [255.6, 5.14])
          P1 = RES.LON
          T1 = RES.LAT
          LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
          LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

          ESA_MAP_RC = INTERPOLATE(ESA_MAP, LON_IDX, LAT_IDX, /DOUBLE)
          esa_map_error_RC = INTERPOLATE(esa_map_error, LON_IDX, LAT_IDX, /DOUBLE)

          Ribbon_stack[*, *, yidx-year_min, esa-2, 0] = ESA_MAP_RC
          Ribbon_stack_error[*, *, yidx-year_min, esa-2, 0] = esa_map_error_RC

          ; 111111111111111 esa map from rc to ec
        endfor ; esa
      endfor ; year
      ; ================== sky map rotation =========================
    endfor ; ram

    if mapidx eq 0 then begin
      mom_mat_theseus = average_mom
      mom_mat_theseus_STDDEV = stddev_mom
      mom_mat_theseus_YEAR = average_mom_year
      mom_mat_theseus_YEAR_STDDEV = stddev_mom_year
      Ribbon_mat_theseus = Ribbon_stack
      Ribbon_mat_theseus_STDDEV = Ribbon_stack_error
      lon_theseus = lon_arr
      lat_theseus = lat_rc

      mom_mat_theseus[*, 1:3, *] = average_mom2_4[*, 1:3, *]
      mom_mat_theseus_STDDEV[*, 1:3, *] = stddev_mom2_4[*, 1:3, *]
      mom_mat_theseus_YEAR[*, 1:3, *, *] = average_mom2_4_year[*, 1:3, *, *]
      mom_mat_theseus_YEAR_STDDEV[*, 1:3, *, *] = stddev_mom2_4_year[*, 1:3, *, *]
    endif

    if mapidx eq 1 then begin
      mom_mat_ISOC = average_mom
      mom_mat_ISOC_STDDEV = stddev_mom
      mom_mat_ISOC_YEAR = average_mom_year
      mom_mat_ISOC_YEAR_STDDEV = stddev_mom_year
      Ribbon_mat_ISOC = Ribbon_stack
      Ribbon_mat_ISOC_STDDEV = Ribbon_stack_error
      lon_isoc = lon_arr
      lat_isoc = lat_rc

      mom_mat_ISOC[*, 1:3, *] = average_mom2_4[*, 1:3, *]
      mom_mat_ISOC_STDDEV[*, 1:3, *] = stddev_mom2_4[*, 1:3, *]
      mom_mat_ISOC_YEAR[*, 1:3, *, *] = average_mom2_4_year[*, 1:3, *, *]
      mom_mat_ISOC_YEAR_STDDEV[*, 1:3, *, *] = stddev_mom2_4_year[*, 1:3, *, *]
    endif
  end ; map


  e_step = [0.71,1.11,1.74,2.73,4.29]
  e_color = ['blue','green','yellow','orange','red']

  lon_isoc = [3:360-3:6]
  lat_isoc = [3:180-3:6]
  LON_ARR = lon_isoc
  Lat_ARR = [-90+3:90-3:6]

  Ribbon_mat_ISOC = replicate(!values.f_nan, 60, 30, 14, 5, 2)
  Ribbon_mat_ISOC_STDDEV = replicate(!values.f_nan, 60, 30, 14, 5, 2)
  for yidx = year_min, year_max do begin
    file = file_search('U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\ribbonmedian\SAV\IBEX-HI_CG_ram_'+string(yidx, format = '(I4)')+'.sav')
    restore, file

    for esa = 2, 6 do begin
      !null = execute('Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0] = ESA'+string(esa, format = '(I1)')+'_RIBBON_FLUX')
      !null = execute('Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0] = ESA'+string(esa, format = '(I1)')+'_RIBBON_VAR')

      Ribbon_mat_ISOC[where(Ribbon_mat_ISOC_STDDEV eq 0)] = !values.d_nan

      res = meshgrid(LON_ARR, lat_arr)
      lat_mat = res.remove()
      lon_mat = res.remove()
      res = conv_coord_ec_rc(lON_mat, lat_mat+90, RC_DAYEH_LONLAT[0, esa-2], RC_DAYEH_LONLAT[1, esa-2], /reverse, nose_POS = [255.6, 5.14])
      P1 = RES.LON
      T1 = RES.LAT
      LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
      LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

      Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0] = INTERPOLATE(Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0], LON_IDX, LAT_IDX, /DOUBLE)
      Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0] = INTERPOLATE(Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0], LON_IDX, LAT_IDX, /DOUBLE)
    endfor


  endfor
  Ribbon_mat_ISOC_STDDEV = sqrt(Ribbon_mat_ISOC_STDDEV)

  file_tmp = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\ISOC-L_RC_Iteration\ISOC_official\RC_Summary_mom_dist_colored\'

  azim_range = [0:360:30.]
  for yidx = year_min, YEAR_MAX do begin
    for esa = 2, 6 do begin
      ESA_STR = strcompress(esa, /rem)

      for az = 0, azim_range.length-2 do begin
        lidx_i = where(lon_isoc ge azim_range[az] and lon_isoc lt azim_range[az+1])
        lidx_t = where(lon_theseus ge azim_range[az] and lon_theseus lt azim_range[az+1])

        ribbon_i = mean(reform(Ribbon_mat_isoc[lidx_i, *, yidx-year_min, esa-2, 0]), dim = 1, /nan)
        ribbon_sig_i = sqrt(mean(reform(Ribbon_mat_isoc_STDDEV[lidx_i, *, yidx-year_min, esa-2, 0])^2, dim = 1, /nan))

        ribbon_t = mean(reform(Ribbon_mat_theseus[lidx_t, *, yidx-year_min, esa-2, 0]), dim = 1, /nan)
        ribbon_sig_t = sqrt(mean(reform(Ribbon_mat_theseus_STDDEV[lidx_t, *, yidx-year_min, esa-2, 0])^2, dim = 1, /nan))

        ; flux comparison
        p = errorplot(lat_theseus, ribbon_t, ribbon_sig_t/2, font_size = 15, xtitle = '$\phi$ [$\deg$]', ytitle = 'Flux', $
          title = 'Year'+string(yidx, format = '(I4)')+', ESA'+ESA_STR+'!C$\lambda$ = '+string(fix(azim_range[az]), format = '(I3)')+'$\deg$ - '+string(fix(azim_range[az+1]), format = '(I3)')+'$\deg$', current = win)
        p = errorplot(lat_isoc, ribbon_i, ribbon_sig_i/2, over = p, co = 'blue', errorbar_color = 'blue')
        ; flux comparison


        ; FWHM
        mx = max(ribbon_t, mxidx, /nan)
        LAT_LH = INTERPOL(lat_theseus[0:mxidx], ribbon_t[0:mxidx], mx*0.5, /nan)
        LAT_UH = INTERPOL(lat_theseus[mxidx:-1], ribbon_t[mxidx:-1], mx*0.5, /nan)
        FWHM_t = LAT_UH-LAT_LH

        mx = max(ribbon_i, mxidx, /nan)
        LAT_LH = INTERPOL(lat_isoc[0:mxidx], ribbon_i[0:mxidx], mx*0.5, /nan)
        LAT_UH = INTERPOL(lat_isoc[mxidx:-1], ribbon_i[mxidx:-1], mx*0.5, /nan)
        FWHM_i = LAT_UH-LAT_LH

        idx01 = [mxidx-round(FWHM_t*2/6):mxidx+round(FWHM_t*2/6)];where(ribbon_i gt mx*0.1)
        idx01 = idx01[where(idx01 ge 0 and idx01 le lat_isoc.length-1, /null)]
        if total(~finite(ribbon_i[idx01[0]:idx01[-1]])) gt 3 then FWHM_i = !values.f_nan

        tx = text(0.65, 0.8, 'Theseus'+string(FWHM_t, format = '(f6.2)')+'$\deg$', font_size = 15)
        tx = text(0.65, 0.75, 'ISOC     '+string(FWHM_i, format = '(f6.2)')+'$\deg$', font_size = 15, font_color = 'blue')
        ; FWHM


        f_path = file_tmp+'Ribbon_Flux_Theseus_ISOC\'
        file_mkdir, f_path
        win.refresh
        win.save, f_path+'ESA'+ESA_STR+'_Year'+string(yidx, format = '(I4)')+'_Azimuth'+string(fix(azim_range[az]), format = '(I3.3)')+'-'+string(fix(azim_range[az+1]), format = '(I3.3)')+'.png', res = 150
        win.erase

      endfor ; azimuth
    endfor ; esa
  endfor ; year




  stop


  for ram = 0, 1 do begin
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for momidx = 0, 3 do begin
      if momidx eq 0 then begin
        mrg = [65., 90]
        RGB_TABLE = 33
        mom_str = 'Angular Radius'
        mom_unit = '[$\deg$]'
      endif

      if momidx eq 1 then BEGIN
        mrg = [10, 50.]
        RGB_TABLE = 33
        mom_str = 'FWHM'
        mom_unit = '[$\deg$]'
      endif
      if momidx eq 2 then BEGIN
        mrg = [-0.2, 0.2]
        ;        mrg = [-1d, 1]
        RGB_TABLE = 70
        mom_str = 'Skewness'
        mom_unit = ''
      ENDIF
      if momidx eq 3 then BEGIN
        mrg = [-0.7, 0.7]
        ;        mrg = [2d, 10]
        RGB_TABLE = 33
        mom_str = 'Kurtosis'
        mom_unit = ''
      endif
      ;            if momidx eq 1 then BEGIN
      ;              mrg = [5, 30.]
      ;              RGB_TABLE = 33
      ;              mom_str = 'Stddev'
      ;              mom_unit = '[$\deg$]'
      ;            endif
      ;            if momidx eq 2 then BEGIN
      ;              mrg = [-1, 1.]
      ;              RGB_TABLE = 70
      ;              mom_str = 'Skewness Original'
      ;              mom_unit = ''
      ;            ENDIF
      ;            if momidx eq 3 then BEGIN
      ;              mrg = [-2, 2.]
      ;              RGB_TABLE = 70
      ;              mom_str = 'Kurtosis Original'
      ;              mom_unit = ''
      ;            endif

      extram = {symbol:'*', sym_FILL_color:'black', errorbar_color:'black', current:1, font_size:25, xtitle:'Energy [keV]', xlog:1, ytitle:mom_str+' '+mom_unit, xr:[0.5, 5], yr:mrg}
      p = errorplot(e_step, mom_mat_ISOC[*, momidx, ram], mom_mat_ISOC_stddev[*, momidx, ram]/2, _extra = extram, title = mom_str+', '+str, thick = 3, errorbar_thick = 3, name = 'ISOC')
      p1 = errorplot(e_step, mom_mat_theseus[*, momidx, ram], mom_mat_Theseus_stddev[*, momidx, ram]/2, over = p, co = 'gray', errorbar_color = 'gray', symbol = 'D', name = 'Theseus', thick = 2)
      lgd = legend(target = [p, p1], position = [0.40, 0.8], font_size = 15, sample_width = 0, /auto_text_color, shadow = 0, linestyle = 6, transparency = 100)
      win.refresh
      win.save, file_tmp+'LonAveraged_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_fit_'+str+'_Theseus_over.png'
      win.erase

      for eidx = 0, e_step.length-1 do begin
        extram = {symbol:'*', errorBar_color:e_color[eidx], color:e_color[eidx], current:1, font_size:25, xtitle:'Year', ytitle:mom_str+' '+mom_unit, xr:[2008.5, 2022.5], xminor:0, yr:mrg}
        p = errorplot(year_arr, mom_mat_ISOC_year[eidx, momidx, ram, *], mom_mat_ISOC_year_stddev[eidx, momidx, ram, *]/2, _extra = extram, title = mom_str+', '+str)
      endfor
      win.refresh
      win.save, file_tmp+'LonAveraged_yearly_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_fit_'+str+'_Theseus_over.png'
      win.erase


    endfor ;  mom


  endfor ; ram


  stop
  print, '========================================================='
  print, mapname + '-' + sepname
  print, 'Ram'

  print, 'Mean', average_mom[*, 0, 0]
  print, 'Mean', STDDEV_mom[*, 0, 0]

  print, 'FWHM', average_mom2_4[*, 1, 0]
  print, 'FWHM', STDDEV_mom2_4[*, 1, 0]

  print, 'Skewness', average_mom2_4[*, 2, 0]
  print, 'Skewness', STDDEV_mom2_4[*, 2, 0]

  print, 'Kurtosis', average_mom2_4[*, 3, 0]
  print, 'Kurtosis', STDDEV_mom2_4[*, 3, 0]

  print, '========================================================='


  print, '=========================== Four Sectors =============================='
  print, mapname + '-' + sepname
  print, 'Ram'

  for sec_idx = 0, num_sec -1 do begin
    print, '############ '+sector_name[sec_idx]+' ############'
    print, 'Mean', average4_mom[*, 0, 0, sec_idx]
    print, 'Mean', STDDEV4_mom[*, 0, 0, sec_idx]

    print, 'FWHM', average4_mom2_4[*, 1, 0, sec_idx]
    print, 'FWHM', STDDEV4_mom2_4[*, 1, 0, sec_idx]

    print, 'Skewness', average4_mom2_4[*, 2, 0, sec_idx]
    print, 'Skewness', STDDEV4_mom2_4[*, 2, 0, sec_idx]

    print, 'Kurtosis', average4_mom2_4[*, 3, 0, sec_idx]
    print, 'Kurtosis', STDDEV4_mom2_4[*, 3, 0, sec_idx]
    print, '############ '+sector_name[sec_idx]+' ############'
  endfor
  print, '=========================== Four Sectors =============================='





  win.close
  ; ============================ Longitudinal Distribution of Moments ============================


end