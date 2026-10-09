function ips_interp, var, t1, l1, t2, l2

  idxr1 = interpol(findgen(t1.length), t1, t2)
  idx2 = interpol(findgen(l1.length), l1, l2)
  return, interpolate(var, idxr1, idx2)

end


pro ENA_flux_response_Comp_IPS_inout_sep, ver, cpath

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


  pos0 = [0.1, 0.8, 0.9, 0.95]
  pos1 = [0.1, 0.65, 0.9, 0.8]
  pos2 = [0.1, 0.1, 0.9, 0.60]

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
  fit_par_ellip = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram

  peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
  map_stack = replicate(!values.d_nan, lon_num, 90, year_arr.length, 5, 2); moment x lon x year x esa x ram
  map_sig_stack = replicate(!values.d_nan, lon_num, 90, year_arr.length, 5, 2); moment x lon x year x esa x ram

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
      restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav'

      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        if rc_c_lonlat[esa-2, 3] gt 0 then $
          fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
        if rc_e_lonlat[esa-2, 3] gt 0 then $
          fit_par_ellip[*, (yidx-year_min), esa-2, ram] = reform(rc_e_lonlat[esa-2, *]); RLonLat x year x esa

        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')
        !NULL = EXECUTE('map_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')
        ;        !NULL = EXECUTE('map_sig_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')
        !NULL = EXECUTE('map_sig_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_stddev_MAP')
      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking

  num_sec = 4

  FOR ram = 0, 0 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    sector_flux_mean = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5, 2) ; year x sector x par/sig x esa x In&Out
    sector_flux_5deg = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5, 2) ; year x sector x par/sig x esa x In&Out

    sector_hpdist = replicate(!values.d_nan, year_arr.length, num_sec, 5) ; year x sector x esa
    sector_latec = replicate(!values.d_nan, year_arr.length, num_sec, 5) ; year x sector x esa


    for esa = 2, 6 do begin
      ESA_STR = strcompress(esa, /rem)



      lb_arr = linspace(0, 360, num_sec+1)
      lb_arr = lb_arr-10

      lidx_tmp = where(lb_arr lt 0, /null, tmp)
      if tmp ne 0 then lb_arr[lidx_tmp] = lb_arr[lidx_tmp]+360


      co = rgb_vector(year_arr.length)
      co_lb = ['black', 'red', 'green', 'blue']

      for yidx = 0, year_arr.length-1 do begin

        year_str = string(year_arr[yidx], format = '(I4)')
        peak_pos = [[lon_arr], [peak_lat[*, yidx, esa-2, ram]]]

        lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

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

          ;  This standar deviation is valid if the number of map draws is the same for all year and/or all sectors

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

    xr1 = [2005, 2023]

    best_delay = replicate(!values.d_nan, lb_arr.length-1, 5)
    best_delay_cc = replicate(!values.d_nan, lb_arr.length-1, 5)

    best_delay_5deg = replicate(!values.d_nan, lb_arr.length-1, 5)
    best_delay_5deg_cc = replicate(!values.d_nan, lb_arr.length-1, 5)


    for esa = 2, 6 do begin
      ESA_STR = strcompress(esa, /rem)


      e_step = [0.45,0.71,1.11,1.74,2.73,4.29d]
      nose_lat = 5.14

      D_Dist = mean(sector_hpdist[*, *, esa-2], dim = 1, /nan)*!const.AU
      V = sqrt(2*e_step[esa-1]*1e3*!const.e/!const.MP)
      DT = 2*D_Dist/V/60/60/24/365.25

      sector_name = ['Nose', 'North', 'Tail', 'South']

      pdyn_interp = replicate(!values.f_nan, year_arr.length, lb_arr.length-1)
      for lbidx = 0, lb_arr.length-2 do pdyn_interp[*, lbidx] = ips_interp(pdyn_ips, time_ips, sol_lat_ec, year_arr, sector_latec[*, lbidx, esa-2])

      Vsw_interp = replicate(!values.f_nan, year_arr.length, lb_arr.length-1)
      for lbidx = 0, lb_arr.length-2 do Vsw_interp[*, lbidx] = ips_interp(VSW_ips, time_ips, sol_lat_ec, year_arr, sector_latec[*, lbidx, esa-2])

      Nsw_interp = replicate(!values.f_nan, year_arr.length, lb_arr.length-1)
      for lbidx = 0, lb_arr.length-2 do Nsw_interp[*, lbidx] = ips_interp(NSW_ips, time_ips, sol_lat_ec, year_arr, sector_latec[*, lbidx, esa-2])

      win = window(dim = [800, 1000], /buffer)
      win.refresh, /disable

      win1 = window(dim = [800, 600], /buffer)
      win1.refresh, /disable

      ; Ribbon characteristics change over time

      sector_flux = sector_flux_mean

      p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
      p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

      p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
      p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

      p = objarr(lb_arr.length-1)
      p[0] = errorplot(year_arr, sector_flux[*, 0, 0, esa-2, 0]/mean(sector_flux[*, 0, 0, esa-2, 0]), sector_flux[*, 0, 1, esa-2, 0]/mean(sector_flux[*, 0, 0, esa-2, 0])/2, $
        xr = xr1, yr = [0, 2], pos = pos2, $
        co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Flux', xtitle = 'Year', ytitle = 'Norm. Flux', $
        name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
        font_size = 15, current = win)
      pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

      for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_flux[*, lbidx, 0, esa-2, 0]/mean(sector_flux[*, lbidx, 0, esa-2, 0]), sector_flux[*, lbidx, 1, esa-2, 0]/mean(sector_flux[*, lbidx, 0, esa-2, 0])/2, $
        co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

      for lbidx = 0, lb_arr.length-2 do pp = errorplot(year_arr, sector_flux[*, lbidx, 0, esa-2, 1]/mean(sector_flux[*, lbidx, 0, esa-2, 1]), sector_flux[*, lbidx, 1, esa-2, 1]/mean(sector_flux[*, lbidx, 0, esa-2, 1])/2, $
        co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs', linestyle = 2)

      lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
      win.refresh
      win.save, file_tmp+'SectorFlux_InOut_E'+esa_str+'_'+str+'.png', res = 150
      win.erase


      delay_time = linspace(-2.5, 2.5, 101, /double)
      sector_flux_CC = replicate(!values.d_nan, delay_time.length, lb_arr.length-1)
      for lbidx = 0, lb_arr.length-2 do begin
        for didx = 0, delay_time.length-1 do begin
          sector_flux_out_tmp = sector_flux[*, lbidx, 0, esa-2, 1]
          sector_flux_in_tmp = interpol(sector_flux[*, lbidx, 0, esa-2, 0], year_arr, year_arr+delay_time[didx])

          youtside = where(year_arr+delay_time[didx] lt 2009 or year_arr+delay_time[didx] gt 2022, tmp)
          if tmp ne 0 then sector_flux_in_tmp[youtside] = !values.d_nan
          if tmp ne 0 then sector_flux_out_tmp[youtside] = !values.d_nan

          sector_flux_CC[didx, lbidx] = (r_correlate(sector_flux_in_tmp, sector_flux_out_tmp))[0]
        endfor
        cc_tmp = max(sector_flux_CC[*, lbidx], mxidx)
        best_delay[lbidx, esa-2] = delay_time[mxidx]
        best_delay_cc[lbidx, esa-2] = cc_tmp
      endfor

      p = objarr(lb_arr.length-1)

      p1 = plot([0, 0], [0, 1.2], co = 'gray', linestyle = 2, font_size = 15, current = win1, $
        xr = [delay_time[0], delay_time[-1]], yr = [0, 1.2], pos = [0.1, 0.1, 0.95, 0.9], $
        title = 'ESA'+esa_str+', '+str+', In-Out Time Shift', xtitle = 'Tout - Tin [Year]', ytitle = 'ROCC', xminor = 0)

      for lbidx = 0, lb_arr.length-2 do begin
        p[lbidx] = plot(delay_time, sector_flux_CC[*, lbidx], $
          co = co_lb[lbidx], over = p1, name = sector_name[lbidx]+', $\Delta$T'+string(best_delay[lbidx, esa-2], format = '(f5.2)'))
          pp = scatterplot(best_delay[lbidx, esa-2], best_delay_cc[lbidx, esa-2], over = p[0], sym_color = co_lb[lbidx], SYMBOL = '*')
      endfor

      lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
      win1.refresh
      win1.save, file_tmp+'SectorFlux_InOut_TimeLagCC_E'+esa_str+'_'+str+'.png', res = 150
      win1.erase


      ; Ribbon characteristics change over time

      sector_flux = sector_flux_5deg

      p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
      p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

      p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
      p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

      p = objarr(lb_arr.length-1)
      p[0] = errorplot(year_arr, sector_flux[*, 0, 0, esa-2, 0]/mean(sector_flux[*, 0, 0, esa-2, 0]), sector_flux[*, 0, 1, esa-2, 0]/mean(sector_flux[*, 0, 0, esa-2, 0])/2, $
        xr = xr1, yr = [0, 2], pos = pos2, $
        co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Flux', xtitle = 'Year', ytitle = 'Norm. Flux', $
        name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
        font_size = 15, current = win)
      pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

      for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_flux[*, lbidx, 0, esa-2, 0]/mean(sector_flux[*, lbidx, 0, esa-2, 0]), sector_flux[*, lbidx, 1, esa-2, 0]/mean(sector_flux[*, lbidx, 0, esa-2, 0])/2, $
        co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

      for lbidx = 0, lb_arr.length-2 do pp = errorplot(year_arr, sector_flux[*, lbidx, 0, esa-2, 1]/mean(sector_flux[*, lbidx, 0, esa-2, 1]), sector_flux[*, lbidx, 1, esa-2, 1]/mean(sector_flux[*, lbidx, 0, esa-2, 1])/2, $
        co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs', linestyle = 2)


      lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
      win.refresh
      win.save, file_tmp+'SectorFlux_InOut_10DegOff_E'+esa_str+'_'+str+'.png', res = 150
      win.erase


      sector_flux_CC = replicate(!values.d_nan, delay_time.length, lb_arr.length-1)
      for lbidx = 0, lb_arr.length-2 do begin
        for didx = 0, delay_time.length-1 do begin
          sector_flux_out_tmp = sector_flux[*, lbidx, 0, esa-2, 1]
          sector_flux_in_tmp = interpol(sector_flux[*, lbidx, 0, esa-2, 0], year_arr, year_arr+delay_time[didx])

          youtside = where(year_arr+delay_time[didx] lt 2009 or year_arr+delay_time[didx] gt 2022, tmp)
          if tmp ne 0 then sector_flux_in_tmp[youtside] = !values.d_nan
          if tmp ne 0 then sector_flux_out_tmp[youtside] = !values.d_nan

          sector_flux_CC[didx, lbidx] = (r_correlate(sector_flux_in_tmp, sector_flux_out_tmp))[0]
        endfor
        cc_tmp = max(sector_flux_CC[*, lbidx], mxidx)
        best_delay_5deg[lbidx, esa-2] = delay_time[mxidx]
        best_delay_5deg_cc[lbidx, esa-2] = cc_tmp
      endfor

      p = objarr(lb_arr.length-1)
      p1 = plot([0, 0], [0, 1.2], co = 'gray', linestyle = 2, font_size = 15, current = win1, $
        xr = [delay_time[0], delay_time[-1]], yr = [0, 1.2], pos = [0.1, 0.1, 0.95, 0.9], $
        title = 'ESA'+esa_str+', '+str+', In-Out Time Shift', xtitle = 'Tout - Tin [Year]', ytitle = 'ROCC', xminor = 0)

      for lbidx = 0, lb_arr.length-2 do begin
        p[lbidx] = plot(delay_time, sector_flux_CC[*, lbidx], $
          co = co_lb[lbidx], over = p1, name = sector_name[lbidx]+', $\Delta$T'+string(best_delay_5deg[lbidx, esa-2], format = '(f5.2)'))
          pp = scatterplot(best_delay_5deg[lbidx, esa-2], best_delay_5deg_cc[lbidx, esa-2], over = p1, sym_color = co_lb[lbidx], SYMBOL = '*')
      endfor

      lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
      win1.refresh
      win1.save, file_tmp+'SectorFlux_InOut_10DegOff_TimeLagCC_E'+esa_str+'_'+str+'.png', res = 150
      win1.erase

    endfor ; energy


    p = objarr(lb_arr.length-1)
    p1 = plot([0.5, 5], [0, 0], co = 'gray', linestyle = 2, font_size = 15, current = win1, $
      xr = [0.5, 5], yr = [delay_time[0], delay_time[-1]], pos = [0.1, 0.1, 0.95, 0.9], $
      title = 'In-Out Time Shift', xtitle = 'Energy [keV]', ytitle = 'Tout - Tin [Year]', xminor = 0, /xlog)
    p2 = plot([0.5, 5], [1, 1], co = 'gray', linestyle = 2, over = p1)
    p2 = plot([0.5, 5], -[1, 1], co = 'gray', linestyle = 2, over = p1)
    for lbidx = 0, lb_arr.length-2 do begin
      p[lbidx] = plot(e_step[1:-1], best_delay[lbidx, *], $
        color = co_lb[lbidx], over = p1, name = sector_name[lbidx], SYMBOL = '*')
    endfor

    lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)

    win1.refresh
    win1.save, file_tmp+'SectorFlux_InOut_TimeLagCC_Summary.png', res = 150
    win1.erase

    p = objarr(lb_arr.length-1)
    p1 = plot([0.5, 5], [0, 0], co = 'gray', linestyle = 2, font_size = 15, current = win1, $
      xr = [0.5, 5], yr = [delay_time[0], delay_time[-1]], pos = [0.1, 0.1, 0.95, 0.9], $
      title = 'In-Out Time Shift', xtitle = 'Energy [keV]', ytitle = 'Tout - Tin [Year]', xminor = 0, /xlog, XTICKVALUES = [0.7, 1, 2, 3, 4])
    p2 = plot([0.5, 5], [1, 1], co = 'gray', linestyle = 2, over = p1)
    p2 = plot([0.5, 5], -[1, 1], co = 'gray', linestyle = 2, over = p1)
    for lbidx = 0, lb_arr.length-2 do begin
      p[lbidx] = plot(e_step[1:-1], best_delay_5deg[lbidx, *], $
        color = co_lb[lbidx], over = p1, name = sector_name[lbidx], SYMBOL = '*', linestyle = 0)
    endfor

    lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)

    win1.refresh
    win1.save, file_tmp+'SectorFlux_InOut_10DegOff_TimeLagCC_Summary.png', res = 150
    win1.erase



  endfor ; ram


  D_Dist = 100*!const.AU
  E = [0.45,0.71,1.11,1.74,2.73,4.29]
  V = sqrt(2*E*1e3*!const.e/!const.MP)
  DT = 2*D_Dist/V/60/60/24/365.25


end