pro RC_SUMMARY_average_plot, MAPNAME, SEPNAME, VER, cpath
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
  endif
  if mapname eq 'Theseus' then BEGIN
    YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
    lon_num = 180
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

  moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit


  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored_OldCT_241015\'
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

        !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
        !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
        !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')


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
  sector_name = ['Nose', 'North', 'S-T', 'South']


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

            ;            yy[lidx, yidx] = mean(ytmp[idx, yidx], /nan) ; lon x year x ab x ram x esa x model x moment
            ;            yy_error[lidx, yidx] =  sqrt(mean(ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment

            yy[lidx, yidx] = total(ytmp[idx, yidx]/ytmp_error[idx, yidx]^2, /nan)/total(1d/ytmp_error[idx, yidx]^2, /nan) ; lon x year x ab x ram x esa x model x moment
            yy_error[lidx, yidx] =  sqrt(1d/total(1d/ytmp_error[idx, yidx]^2, /nan)) ; lon x year x ab x ram x esa x model x moment

            yyidx[lidx, yidx] = tmp
            hp_mat[lidx, yidx] = mean(ts_mat[idx], /nan) ; lon x year x ab x ram x esa x model x moment
          endfor
        endfor
        ; Fixed RC Coordinate

        ytmp = yy
        ytmp_error = yy_error

        data_available = total(finite(ytmp), 2)
        ;        data_mean = mean(ytmp, dim = 2, /nan)
        ;        data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))

        data_mean = total(ytmp/ytmp_error^2, /nan)/total(1/ytmp_error^2, /nan) ;mean(ytmp, dim = 2, /nan)
        data_error = sqrt(1d/total(1d/ytmp_error^2, /nan))

        ;        data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
        ;        data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))
        ;        mean_mat = transpose(rebin(data_mean, data_mean.length, year_arr.length))
        ;        wstd = sqrt(total((ytmp-mean_mat)^2d/ytmp_error^2, 2, /nan)/total(1/ytmp_error^2, 2, /nan))
        ;        q = transpose([[data_mean-wstd], [data_mean+wstd]]); quartile(ytmp, dim = 2)

        ;        q = quartile(ytmp, dim = 2)
        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
        ec_lat_sign = sign(ec_lat_mean)

        ;        idx = where(data_available lt 5, /null)
        ;        data_mean[idx] = !values.d_nan
        ;        q[*, idx] = !values.d_nan


        average_mom[esa-2, momidx, ram] = data_mean
        stddev_mom[esa-2, momidx, ram] = data_error


        for sec_idx = 0, num_sec - 1 do begin
          if sec_idx eq 0 then $
            lonidx = where(lon_arr ge lb_arr[sec_idx]+360 or lon_arr lt lb_arr[sec_idx+1]) $
          else $
            lonidx = where(lon_arr ge lb_arr[sec_idx] and lon_arr lt lb_arr[sec_idx+1])
          ;          average4_mom[esa-2, momidx, ram, sec_idx] = mean(data_mean[lonidx], /nan)
          ;          stddev4_mom[esa-2, momidx, ram, sec_idx] = sqrt(mean(ytmp_error[lonidx]^2, /nan))
          average4_mom[esa-2, momidx, ram, sec_idx] = total(ytmp[lonidx, *]/ytmp_error[lonidx, *]^2, /nan)/total(1/ytmp_error[lonidx, *]^2, /nan)
          stddev4_mom[esa-2, momidx, ram, sec_idx] = sqrt(1d/total(1d/ytmp_error[lonidx, *]^2, /nan)) ;sqrt(mean(ytmp_error[lonidx, *]^2, dim = 2, /nan))
        endfor

        ;        average_mom_year[esa-2, momidx, ram, *] = mean(ytmp, /nan, dim = 1)
        ;        stddev_mom_year[esa-2, momidx, ram, *] = sqrt(mean(ytmp_error^2, dim = 1, /nan))

        average_mom_year[esa-2, momidx, ram, *] = total(ytmp/ytmp_error^2, 1, /nan)/total(1/ytmp_error^2, 1, /nan)
        stddev_mom_year[esa-2, momidx, ram, *] = sqrt(1d/total(1d/ytmp_error^2, 1, /nan))

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
        ;        data_mean = mean(ytmp, dim = 2, /nan)
        data_mean = total(ytmp/ytmp_error^2, /nan)/total(1/ytmp_error^2, /nan) ;mean(ytmp, dim = 2, /nan)
        data_error = sqrt(1d/total(1d/ytmp_error^2, /nan))


        ;        data_mean_weighted = total(ytmp/ytmp_error, 2, /nan)/total(1/ytmp_error, 2, /nan)
        ;        data_error = sqrt(mean(ytmp_error^2, dim = 2, /nan))
        ;        mean_mat = transpose(rebin(data_mean, data_mean.length, year_arr.length))
        ;        wstd = sqrt(total((ytmp-mean_mat)^2d/ytmp_error^2, 2, /nan)/total(1/ytmp_error^2, 2, /nan))
        ;        q = transpose([[data_mean-wstd], [data_mean+wstd]]); quartile(ytmp, dim = 2)

        ;        q = quartile(ytmp, dim = 2)
        hp_dist_mean = mean(hp_mat, dim = 2, /nan)
        ec_lat_mean = mean(ec_lat, dim = 2, /nan)
        ec_lat_sign = sign(ec_lat_mean)

        ;        idx = where(data_available lt 5, /null)
        ;        data_mean[idx] = !values.d_nan
        ;        q[*, idx] = !values.d_nan

        average_mom2_4[esa-2, momidx, ram] = data_mean;mean(data_mean, /nan)
        stddev_mom2_4[esa-2, momidx, ram] = data_error;sqrt(mean(ytmp_error^2, /nan))

        for sec_idx = 0, num_sec - 1 do begin
          if sec_idx eq 0 then $
            lonidx = where(lon_arr ge lb_arr[sec_idx]+360 or lon_arr lt lb_arr[sec_idx+1]) $
          else $
            lonidx = where(lon_arr ge lb_arr[sec_idx] and lon_arr lt lb_arr[sec_idx+1])
          ;          average4_mom2_4[esa-2, momidx, ram, sec_idx] = mean(data_mean[lonidx], /nan)
          ;          stddev4_mom2_4[esa-2, momidx, ram, sec_idx] = sqrt(mean(ytmp_error[lonidx]^2, /nan))

          average4_mom2_4[esa-2, momidx, ram, sec_idx] = total(ytmp[lonidx, *]/ytmp_error[lonidx, *]^2, /nan)/total(1/ytmp_error[lonidx, *]^2, /nan)
          stddev4_mom2_4[esa-2, momidx, ram, sec_idx] = sqrt(1d/total(1d/ytmp_error[lonidx, *]^2, /nan)); sqrt(mean(ytmp_error[lonidx, *]^2, dim = 2, /nan))
        endfor



        ;        if momidx eq 1 then begin
        ;          ;          sp = spec_plot(transpose(ytmp), year_arr, lon_arr, rgb_table = 70, data_min = mean(ytmp, /nan)-stddev(ytmp, /nan), data_max = mean(ytmp, /nan)+stddev(ytmp, /nan), xtitle = 'year', ytitle = '$\lambda$', title = 'ESA'+ESA_STR, rgb_reverse = 1)
        ;          ;          cb = color_bar(sp)
        ;
        ;          p = plot(lon_arr, ytmp[*, 0], xr = [0, 360], yr = [0, 60], xtitle = '$\lambda$', ytitle = 'FWHM', title = 'ESA'+ESA_STR)
        ;          for yy = 1, 13 do begin
        ;            p = plot(lon_arr, ytmp[*, yy], xr = [0, 360], over = p)
        ;          endfor
        ;          p = plot(lon_arr, mean(ytmp, dim = 2, /nan), xr = [0, 360], over = p, thick = 3)
        ;          p = plot(lon_arr, replicate(mean(ytmp, /nan), lon_arr.length), xr = [0, 360], over = p, thick = 3, co = 'blue')
        ;          p.save, file_tmp+'TEST_FWHM_ESA'+ESA_STR+'.png'
        ;          p.close
        ;
        ;        endif

        ;        average_mom2_4_year[esa-2, momidx, ram, *] = mean(ytmp, /nan, dim = 1)
        ;        stddev_mom2_4_year[esa-2, momidx, ram, *] = sqrt(mean(ytmp_error^2, dim = 1, /nan))

        average_mom2_4_year[esa-2, momidx, ram, *] = total(ytmp/ytmp_error^2, 1, /nan)/total(1/ytmp_error^2, 1, /nan)
        stddev_mom2_4_year[esa-2, momidx, ram, *] = sqrt(1d/total(1d/ytmp_error^2, 1, /nan))

      endfor ; esa

    endfor ; mom

    ; ===================================================================== SEMI MOMENTS =====================================================================
  endfor ; ram

  e_step = [0.71,1.11,1.74,2.73,4.29]
  e_color = ['blue','green','yellow','orange','red']

  sector_color = ['black', 'red', 'green', 'blue']

  for ram = 0, 1 do begin
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for momidx = 0, 3 do begin
      if momidx eq 0 then begin
        mrg = [70., 85]
        RGB_TABLE = 33
        mom_str = 'Angular Radius'
        mom_unit = '[$\deg$]'
      endif
      if momidx eq 1 then BEGIN
        mrg = [5, 30.]
        RGB_TABLE = 33
        mom_str = 'Stddev'
        mom_unit = '[$\deg$]'
      endif
      if momidx eq 2 then BEGIN
        mrg = [-1, 1.]
        RGB_TABLE = 70
        mom_str = 'Skewness'
        mom_unit = ''
      ENDIF
      if momidx eq 3 then BEGIN
        mrg = [-2, 2.]
        RGB_TABLE = 70
        mom_str = 'Kurtosis'
        mom_unit = ''
      endif

      extram = {symbol:'.', sym_FILL_color:'gray', errorbar_color:'gray', current:1, font_size:25, xtitle:'Energy [keV]', xlog:1, ytitle:mom_str+' '+mom_unit, xr:[0.5, 5], yr:mrg}
      p1 = errorplot(e_step, average_mom[*, momidx, ram], stddev_mom[*, momidx, ram], thick = 1, errorbar_thick = 3, _extra = extram, title = mom_str+', '+str, name = 'Total')

      p2 = objarr(sector_name.length)
      for sidx = 0, sector_name.length-1 do $
        p2[sidx] = errorplot(e_step, average4_mom[*, momidx, ram, sidx], stddev4_mom[*, momidx, ram, sidx], name = sector_name[sidx], linestyle = 2, over = p1, co = sector_color[sidx], errorbar_color = sector_color[sidx], thick = 1, errorbar_thick = 3)

      lgd = legend(target = [p1,p2], position = [0.55, 0.85], font_size = 15, sample_width = 0.07, /auto_text_color, shadow = 0, linestyle = 6, transparency = 100)

      win.refresh
      win.save, file_tmp+'LonAveraged_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_fit_'+str+'.png'
      win.erase

      for eidx = 0, e_step.length-1 do begin
        extram = {symbol:'.', errorBar_color:e_color[eidx], color:e_color[eidx], current:1, font_size:25, xtitle:'Year', ytitle:mom_str+' '+mom_unit, xr:[2008.5, 2022.5], xminor:0, yr:mrg}
        p = errorplot(year_arr, average_mom_year[eidx, momidx, ram, *], stddev_mom_year[eidx, momidx, ram, *], _extra = extram, title = mom_str+', '+str)
      endfor
      win.refresh
      win.save, file_tmp+'LonAveraged_yearly_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_fit_'+str+'.png'
      win.erase


    endfor ;  mom

    for momidx = 0, 3 do begin
      if momidx eq 0 then BEGIN
        mrg = [70, 85]
        RGB_TABLE = 33
        mom_str = 'Peak'
        mom_unit = '[$\deg$]'
      endif
      if momidx eq 1 then BEGIN
        mrg = [10, 45.]
        RGB_TABLE = 33
        mom_str = 'FWHM'
        mom_unit = '[$\deg$]'
      endif
      if momidx eq 2 then BEGIN
        mrg = [-0.15, 0.15]
        ;        mrg = [-1d, 1]
        RGB_TABLE = 70
        mom_str = 'Skewness'
        mom_unit = ''
        ;        mom_str = 'PSKEW'
        ;        moment24_stack[momidx, *, *, *, ram] =  moment24_stack[momidx, *, *, *, ram]/ moment_stack[1, *, *, *, ram]
      ENDIF
      if momidx eq 3 then BEGIN
        mrg = [-0.3, 0.3]
        ;        mrg = [2d, 10]
        RGB_TABLE = 33
        mom_str = 'Kurtosis'
        mom_unit = ''
        ;        mom_str = 'R80_20'
      endif

      extram = {symbol:'.', sym_FILL_color:'gray', errorbar_color:'gray', current:1, font_size:25, xtitle:'Energy [keV]', xlog:1, ytitle:mom_str+' '+mom_unit, xr:[0.5, 5], yr:mrg}
      p1 = errorplot(e_step, average_mom2_4[*, momidx, ram], stddev_mom2_4[*, momidx, ram], thick = 2, errorbar_thick = 3, _extra = extram, title = mom_str+', '+str, name = 'Total')


      p2 = objarr(sector_name.length)
      for sidx = 0, sector_name.length-1 do $
        p2[sidx] = errorplot(e_step, average4_mom2_4[*, momidx, ram, sidx], stddev4_mom2_4[*, momidx, ram, sidx], name = sector_name[sidx], linestyle = 2, over = p1, co = sector_color[sidx], errorbar_color = sector_color[sidx], thick = 1, errorbar_thick = 3)

      extram = {symbol:'.', sym_FILL_color:'gray', errorbar_color:'gray', current:1, font_size:25, xtitle:'Energy [keV]', xlog:1, ytitle:mom_str+' '+mom_unit, xr:[0.5, 5], yr:mrg}
      p1 = errorplot(e_step, average_mom2_4[*, momidx, ram], stddev_mom2_4[*, momidx, ram], thick = 2, errorbar_thick = 3, _extra = extram, title = mom_str+', '+str, name = 'Total')


      lgd = legend(target = [p1,p2], position = [0.55, 0.85], font_size = 15, sample_width = 0.07, /auto_text_color, shadow = 0, linestyle = 6, transparency = 100)

      win.refresh
      win.save, file_tmp+'LonAveraged_'+STRCOMPRESS(momidx+5, /REM)+mom_str+'_fit_'+str+'.png'
      win.erase

      for eidx = 0, e_step.length-1 do begin
        extram = {symbol:'.', errorBar_color:e_color[eidx], color:e_color[eidx], current:1, font_size:25, xtitle:'Year', ytitle:mom_str+' '+mom_unit, xr:[2008.5, 2022.5], xminor:0, yr:mrg}
        p = errorplot(year_arr, average_mom2_4_year[eidx, momidx, ram, *], stddev_mom2_4_year[eidx, momidx, ram, *], _extra = extram, title = mom_str+', '+str)
      endfor
      win.refresh
      win.save, file_tmp+'LonAveraged_yearly_'+STRCOMPRESS(momidx+5, /REM)+mom_str+'_fit_'+str+'.png'
      win.erase
    endfor ;  mom

  endfor ; ram
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