function ips_interp, var, t1, l1, t2, l2

  idxr1 = interpol(findgen(t1.length), t1, t2)
  idx2 = interpol(findgen(l1.length), l1, l2)
  return, interpolate(var, idxr1, idx2)

end


pro ribbon_temporal_variation, ver, cpath

  ;  ver = '230705'
  ;  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  ;  cd, cpath

  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'
  tidx = where(time ge 2000 and time le 2023)
  time_ips = time[tidx]
  NSW_ips = NSW[tidx, *]
  VSW_ips = VSW[tidx, *]
  PDYN_ips = PDYN[tidx, *]
  ; sol_lat_ec

  ;  open solar wind boundary
  ;south

  VSW_s = VSW_ips[*, 0:8]
  lat = sol_lat_ec[0:8]
  lat_bound_s = replicate(!values.f_nan, time_ips.length)
  for ii = 0, time_ips.length-1 do begin
    VSW_s[ii, [where(VSW_s[ii, 1:-1]-VSW_s[ii, 0:-2] gt 0, /null)]] = !values.f_nan
    if total(VSW_s[ii, *] lt 500) eq 0 then continue
    if total(VSW_s[ii, *] gt 500) eq 0 then continue
    lat_bound_s[ii] = interpol(lat, VSW_s[ii, *], 500, /nan)
  endfor
  ;north
  VSW_n = VSW_ips[*, 10:18]
  lat = sol_lat_ec[10:18]
  lat_bound_n = replicate(!values.f_nan, time_ips.length)
  for ii = 0, time_ips.length-1 do begin
    VSW_n[ii, [where(VSW_n[ii, 1:-1]-VSW_n[ii, 0:-2] lt 0, /null)]] = !values.f_nan
    if total(VSW_n[ii, *] lt 500) eq 0 then continue
    if total(VSW_n[ii, *] gt 500) eq 0 then continue
    lat_bound_n[ii] = interpol(lat, VSW_n[ii, *], 500, /nan)
  endfor
  ;  open solar wind boundary

  ; omni ssn
  restore, 'D:\Data\omni\OMNI_1HR_1MIN_2000_2023.sav'
  T_TMP = JULDAY(1, 1, 1970, 0, 0, time_omni_1hr)

  jd2year, T_TMP, time_omni
  ; omni ssn


  tol = 1d-15

  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

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

  mapname = 'Theseus'
  sepname = 'L'
  DPATH = dp+'Theseus-L\'
  fname = mapname+'-'+sepname+'_RC_Iteration'
  YEAR_MIN = 2009
  YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  year_arr = [YEAR_MIN:YEAR_MAX]
  year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]
  lon_num = 180


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

  map_stack = replicate(!values.d_nan, lon_num, 90, year_arr.length, 5, 2); moment x lon x year x esa x ram
  map_sig_stack = replicate(!values.d_nan, lon_num, 90, year_arr.length, 5, 2); moment x lon x year x esa x ram

  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'_test\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored\'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, file_tmp

  ; data stacking
  for yidx = year_min, YEAR_MAX do begin
    FOR ram = 0, 1 DO BEGIN
      IF ram THEN str = 'ARam' ELSE str = 'Ram'

      year = string(yidx, format = '(I4)')
      restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav'

      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        if rc_c_lonlat[esa-2, 3] gt 0 then begin
          fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
          fit_par_sig_circ[*, (yidx-year_min), esa-2, ram] = reform([rc_c_PAR_SIG[esa-2, 0], rc_c_PAR_SIG[esa-2, 2], rc_c_PAR_SIG[esa-2, 1]]); RLonLat x year x esa
        endif

        if rc_e_lonlat[esa-2, 3] gt 0 then begin
          fit_par_ellip[*, (yidx-year_min), esa-2, ram] = [reform(rc_e_lonlat[esa-2, 0:2]), (1-(reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2), reform(rc_e_PAR[esa-2, 2]), reform(rc_e_lonlat[esa-2, 3])]; R,Lon,Lat,Ellip,Rot,sig x year x esa

          fit_par_sig_ellip[*, (yidx-year_min), esa-2, ram] = $
            [reform(sqrt(rc_E_PAR_SIG[esa-2, 0]^2+rc_E_PAR_SIG[esa-2, 1]^2)), $ ;R
            reform(rc_E_PAR_SIG[esa-2, 4]), $ ;Lon
            reform(rc_E_PAR_SIG[esa-2, 3]), $ ;Lat
            reform((reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2*sqrt(2/rc_e_PAR[esa-2, 0]^2*rc_E_PAR_SIG[esa-2, 0]^2 + 2/rc_e_PAR[esa-2, 1]^2*rc_E_PAR_SIG[esa-2, 1]^2)), $ ;Ellip
            reform(rc_E_PAR_SIG[esa-2, 2])] ; Rot
        endif

        ;        reform(rc_e_PAR[esa-2, 1]/rc_e_PAR[esa-2, 0] * sqrt((rc_E_PAR_SIG[esa-2, 0]/rc_e_PAR[esa-2, 0])^2+(rc_E_PAR_SIG[esa-2, 1]/rc_e_PAR[esa-2, 1])^2)) ; ellipticity

        !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
        !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
        !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')

        !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
        !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
        !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')

        !NULL = EXECUTE('map_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')
        !NULL = EXECUTE('map_sig_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_stddev_MAP')


      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking


  num_sec = 4
  lb_arr = linspace(0, 360, num_sec+1)
  lb_arr = lb_arr-10

  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    sector_flux_mean = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5, 2) ; year x sector x par/sig x esa x In&Out
    sector_flux_5deg = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5, 2) ; year x sector x par/sig x esa x In&Out

    sector_hpdist = replicate(!values.d_nan, year_arr.length, num_sec, 5) ; year x sector x esa
    sector_latec = replicate(!values.d_nan, year_arr.length, num_sec, 5) ; year x sector x esa


    for esa = 2, 6 do begin
      ESA_STR = strcompress(esa, /rem)





      lidx_tmp = where(lb_arr lt 0, /null, tmp)
      if tmp ne 0 then lb_arr[lidx_tmp] = lb_arr[lidx_tmp]+360


      co = rgb_vector(year_arr.length)
      co_lb = ['black', 'red', 'green', 'blue']

      for yidx = 0, year_arr.length-1 do begin

        year_str = string(year_arr[yidx], format = '(I4)')
        peak_pos = [[lon_arr], [peak_lat[*, yidx, esa-2, ram]]]

        lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])

        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

        ; Fixed RC Coordinate

        TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
        LONEC = TMP.LON & LATEC = TMP.LAT
        hp_dist_tmp = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)
        TMP1 = conv_coord_ec_rc(LONEC, LATEC, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))

        for lbidx = 0, lb_arr.length-2 do begin

          if lbidx eq 0 then $
            lon_idxr1 = where(TMP1.lon ge lb_arr[lbidx] or TMP1.lon lt lb_arr[lbidx+1]) else $
            lon_idxr1 = where(TMP1.lon ge lb_arr[lbidx] and TMP1.lon lt lb_arr[lbidx+1])

          ;  This standard deviation is valid if the number of map draws is the same for all year and/or all sectors

          lat_peak = reform(peak_lat[lon_idxr1, yidx, esa-2, ram])
          lidx = value_locate(lat_rc, lat_peak)

          aa =  map_stack[lon_idxr1, *, yidx, esa-2, ram]
          ss =  map_sig_stack[lon_idxr1, *, yidx, esa-2, ram]

          in_res = [] &  out_res = []
          in5_res = [] & out5_res = []

          in_sig_res = [] &  out_sig_res = []
          in5_sig_res = [] & out5_sig_res = []
          for ll = 0, lon_idxr1.length-1 do begin
            in_tmp = aa[ll, 0:lidx[ll]-1]
            out_tmp = aa[ll,lidx[ll]+1:lat_arr.length-1]
            in_tmp = in_tmp[where(in_tmp gt 0, /null)]
            out_tmp = out_tmp[where(out_tmp gt 0, /null)]

            in_sig_tmp = ss[ll, 0:lidx[ll]-1]
            out_sig_tmp = ss[ll,lidx[ll]+1:lat_arr.length-1]
            in_sig_tmp = in_sig_tmp[where(in_sig_tmp gt 0, /null)]
            out_sig_tmp = out_sig_tmp[where(out_sig_tmp gt 0, /null)]


            in_res = [in_res, in_tmp]
            out_res = [out_res, out_tmp]
            in_sig_res = [in_sig_res, in_sig_tmp]
            out_sig_res = [out_sig_res, out_sig_tmp]

            in5_res = [in5_res, aa[ll, lidx[ll]-5]] ; 10 degrees off the max
            out5_res = [out5_res, aa[ll, lidx[ll]+5]] ; 10 degrees off the max
            in5_sig_res = [in5_sig_res, SS[ll, lidx[ll]-5]] ; 10 degrees off the max
            out5_sig_res = [out5_sig_res, SS[ll, lidx[ll]+5]] ; 10 degrees off the max

          endfor

          sector_flux_mean[yidx, lbidx, 0, esa-2, *] = [mean(in_res), mean(out_res)];
          sector_flux_mean[yidx, lbidx, 1, esa-2, *] = [SQRT(mean(in_sig_res^2)), SQRT(mean(out_sig_res^2))];

          sector_flux_5deg[yidx, lbidx, 0, esa-2, *] = [mean(in5_res), mean(out5_res)];
          sector_flux_5deg[yidx, lbidx, 1, esa-2, *] = [SQRT(mean(in5_sig_res^2)), SQRT(mean(out5_sig_res^2))];

          sector_hpdist[yidx, lbidx, esa-2] = mean(hp_dist_tmp[lon_idxr1], /nan)
          sector_latec[yidx, lbidx, esa-2] = mean(LATEC[lon_idxr1], /nan)
        endfor

        ; Fixed RC Coordinate

      endfor ; year
    endfor ; esa


  endfor ; ram


  num_sec = 4
  lb_arr = linspace(0, 360, num_sec+1)
  lb_arr = lb_arr-10
  lidx_tmp = where(lb_arr lt 0, /null, tmp)
  if tmp ne 0 then lb_arr[lidx_tmp] = lb_arr[lidx_tmp]+360
  co = rgb_vector(lb_arr.length-1, ct = 33)
  co_lb = ['black', 'red', 'green', 'blue']
  sector_name = ['Nose', 'North', 'Tail', 'South']

stop
  cbmax = [1200,400,180,70,25,6]
  ; ============================ Longitudinal Distribution of Moments ============================
  win = window(dim = [900, 800], /buffer)
  win.refresh, /disable
  POS1 = [0.1, 0.1, 0.85, 0.525]
  POS2 = [0.1, 0.525, 0.85, 0.95]
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for momidx = 0, 4 do begin

      for esa = 2, 6 do begin
        if momidx eq 0 then begin
          mrg = [65., 90]
          RGB_TABLE = 33
          mom_str = 'Mean'
        endif
        if momidx eq 1 then BEGIN
          if esa ge 4 then mrg = [10, 50.] else mrg = [10, 35.]
          RGB_TABLE = 33
          mom_str = 'FWHM'
        endif
        if momidx eq 2 then BEGIN
          mrg = [-0.4, 0.4]
          RGB_TABLE = 70
          mom_str = 'Bowley Skewness'
        ENDIF
        if momidx eq 3 then BEGIN
          mrg = [-0.7, 0.7]
          RGB_TABLE = 33
          mom_str = 'Moors Kurtosis'
        endif
        if momidx eq 4 then BEGIN
          mrg = [0, cbmax[esa-1]]
          RGB_TABLE = 33
          mom_str = 'FluxPeak'
        endif

        ESA_STR = strcompress(esa, /rem)

        if momidx eq 0 then begin
          ytmp = reform(moment_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
          ytmp_error = reform(moment_stack_error[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
        endif

        if momidx ge 1 and momidx le 3 then begin
          ytmp = reform(moment24_stack[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
          ytmp_error = reform(moment24_stack_error[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
        endif

        if momidx eq 4 then begin
          ytmp = reform(flux_stack[0, *, *, esa-2, ram]); moment x lon x year x esa
          ytmp_error = reform(flux_stack_error[0, *, *, esa-2, ram]); moment x lon x year x esa
        endif


        lon_tmp = reform(fit_par_ellip[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_ellip[2, *, esa-2, ram])

        peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

        ; Fixed RC Coordinate
        sz = size(ytmp)
        yy = ytmp
        yy[*] = !values.d_nan

        yy_error = ytmp_error
        yy_error[*] = !values.d_nan

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
        data_mean_weighted[idx] = !values.d_nan
        q[*, idx] = !values.d_nan


        data_mean_total = mean(ytmp, /nan)
        data_mean_weighted_total = total(ytmp/ytmp_error, /nan)/total(1/ytmp_error, /nan)
        data_error_total = sqrt(mean(ytmp_error^2, /nan))

        fac = 1
        if momidx eq 0 then fac = 2
        if momidx eq 4 then fac = 4

        if momidx eq 2 or momidx eq 3 then begin
          data_mean_weighted_total = 0
          data_mean_total = 0
        endif

        sp = spec_plot(transpose(ytmp), year_arr, lon_arr, data_min = data_mean_total-data_error_total*fac, data_max = data_mean_total+data_error_total*fac $
          , rgb_table = 70, xtitle = 'Year', ytitle = 'Lon_RC', font_size = 15, xr = [year_arr[0]-1, year_arr[-1]+1], yr = [0, 360], pos = pos1, current = win, /rgb_reverse)
        cb = color_bar(sp, ytitle = mom_str)

        for lbidx = 0, lb_arr.length-2 do begin
          if lbidx gt 0 then begin
            lb_y = [lb_arr[lbidx], lb_arr[lbidx+1]]
            p = plot(replicate(year_arr[0]-0.2, 2), lb_y, over = sp, thick = 6, co = co_lb[lbidx])
            p = plot(replicate(year_arr[-1]+0.2, 2), lb_y, over = sp, thick = 6, co = co_lb[lbidx])
            tx = text(year_arr[0]-0.5, mean(lb_y), sector_name[lbidx], /data, color = co_lb[lbidx], align = 0.5, vertical_alignment = 0.5, orientation = 90, font_size = 15)
            tx = text(year_arr[-1]+0.5, mean(lb_y), sector_name[lbidx], /data, color = co_lb[lbidx], align = 0.5, vertical_alignment = 0.5, orientation = 270, font_size = 15)
          endif

          if lbidx eq 0 then begin
            lb_y = [lb_arr[lbidx], lb_arr[lbidx+1]]
            p = plot(replicate(year_arr[0]-0.2, 2), [lb_arr[lbidx], 360], over = sp, thick = 6, co = co_lb[lbidx])
            p = plot(replicate(year_arr[0]-0.2, 2), [0, lb_arr[lbidx+1]], over = sp, thick = 6, co = co_lb[lbidx])
            p = plot(replicate(year_arr[-1]+0.2, 2), [lb_arr[lbidx], 360], over = sp, thick = 6, co = co_lb[lbidx])
            p = plot(replicate(year_arr[-1]+0.2, 2), [0, lb_arr[lbidx+1]], over = sp, thick = 6, co = co_lb[lbidx])
            tx = text(year_arr[0]-0.5, mean([lb_y[0]-360, lb_y[1]]), sector_name[lbidx], /data, color = co_lb[lbidx], align = 0.5, vertical_alignment = 0.5, orientation = 90, font_size = 15)
            tx = text(year_arr[-1]+0.5, mean([lb_y[0]-360, lb_y[1]]), sector_name[lbidx], /data, color = co_lb[lbidx], align = 0.5, vertical_alignment = 0.5, orientation = 270, font_size = 15)
          endif
        endfor



        ; sector
        y_sector_tmp = replicate(!values.d_nan, year_arr.length, lb_arr.length-1)
        yerror_sector_tmp = replicate(!values.d_nan, year_arr.length, lb_arr.length-1)

        for lbidx = 0, lb_arr.length-2 do begin
          if lbidx eq 0 then $
            lon_idxr1 = where(lon_arr ge lb_arr[lbidx] or lon_arr lt lb_arr[lbidx+1]) else $
            lon_idxr1 = where(lon_arr ge lb_arr[lbidx] and lon_arr lt lb_arr[lbidx+1])
          y_sector_tmp[*, lbidx] = mean(ytmp[lon_idxr1, *], dim = 1, /nan); total(ytmp[lon_idxr1, *]/ytmp_error[lon_idxr1, *], 1, /nan)/total(1/ytmp_error[lon_idxr1, *], 1, /nan)
          yerror_sector_tmp[*, lbidx] = sqrt(mean(ytmp_error[lon_idxr1, *]^2, dim = 1, /nan))
        endfor


        p = plot([0, 0], [0, 0], /nodata, current = win, pos = pos2, ytitle = mom_str, xtickformat = '(a1)', font_size = 15, xr = [year_arr[0]-1, year_arr[-1]+1], yr = mrg)
        pe = objarr(lb_arr.length-1)
        for lbidx = 0, lb_arr.length-2 do pe[lbidx] = errorplot(year_arr+(lbidx-1.)*0.05, y_sector_tmp[*, lbidx], yerror_sector_tmp[*, lbidx], symbol = '.', sym_thick = 6, over = p, co = co_lb[lbidx], errorbar_color = co_lb[lbidx], name = sector_name[lbidx])
        p1 = plot(p.xrange, replicate(data_mean_total, 2), over = p, co = 'gray', linestyle = 2)
        lgd = legend(target = pe, position = [0.99, 0.85], font_size = 20, sample_width = 0, /auto_text_color, shadow = 0, linestyle = 6, transparency = 100)
        tx = text(0.475, 0.98, 'ESA'+ESA_STR, font_size = 20, align = 0.5, vertical_alignment = 0.5)
        ;        sz = size(ytmp)
        ;        co = rgb_vector(sz[2], ct = 33)
        ;        for yy = 0, sz[2]-1 do p = plot(lon_arr, ytmp[*, yy], over = p, co = co[*, yy])
        ;        p = plot(lon_arr, data_mean, over = p, co = 'red', thick = 3)
        ;        p = plot(lon_arr, data_mean_weighted, over = p, co = 'magenta', thick = 3)
        ;
        ;        p = plot(lon_arr, data_mean_weighted+data_error/2, over = p, co = 'black', thick = 3)
        ;        p = plot(lon_arr, data_mean_weighted-data_error/2, over = p, co = 'black', thick = 3)
        ;
        ;
        ;        p = plot(lon_arr, q[0, *], over = p, co = 'blue', thick = 3)
        ;        p = plot(lon_arr, q[1, *], over = p, co = 'blue', thick = 3)
        ;
        ;        ff = findgen(256)
        ;        cba = transpose([[ff], [ff], [ff]])
        ;        cb = spec_plot(cba, findgen(3), ff, rgb_table = 13, pos = [pos1[2]+0.02, pos1[1], pos1[2]+0.05, pos1[3]], current = win, ytickformat = '(a1)', yticklen = 0, yminor = 0, xtickformat = '(a1)', xticklen = 0, xminor = 0)
        ;        yaxis = AXIS('Y', target = cb, LOCATION='right', TITLE='Year', COORD_TRANSFORM=[2009, (2022 - 2009)/255.], tickinterval = 2, minor = 1, tickformat = '(I4)')


        win.Refresh
        win.save, file_tmp+'Time_Variation_'+STRCOMPRESS(momidx+1, /REM)+'_'+mom_str+'_ESA'+esa_str+'_'+str+'_Summary.png', res = 150
        win.erase

      endfor ; esa

    endfor ; mom
  endfor ; ram
  win.close
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================





end