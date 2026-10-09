function maxwellian_240505, x, p
  if n_elements(p.dim) gt 1 then return, p[*, 0] / p[*, 1]^3 / sqrt(!dpi)^3 *exp(-(x - p[*, 2])^2/p[*, 1]^2) $
  else return, p[0] / p[1]^3 / sqrt(!dpi)^3*exp(-(x - p[2])^2/p[1]^2)
end

pro ribbon_sounding_PointByPoint

  ;  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  ;  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;
  ;  lon_hp = data.field1
  ;  lat_hp = data.field2
  ;  ts = data.field3
  ;  hs = data.field4

  !EXCEPT = 0
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

  lon_mat = dblarr(180, 90)
  lat_mat = dblarr(180, 90)
  hp_mat = dblarr(180, 90)
  ts_mat = dblarr(180, 90)
  kk = 0
  for ii = 0, 179 do begin
    for jj = 0, 89 do begin
      lon_mat[ii, jj] = lon_hp[kk]
      lat_mat[ii, jj] = lat_hp[kk]
      hp_mat[ii, jj] = hp_dist[kk]
      ts_mat[ii, jj] = ts[kk]
      kk += 1
    endfor
  endfor




  nh = 0.2d

  for nnn = 0, 2 do begin
    if nnn eq 0 then nh = 0.10d
    if nnn eq 1 then nh = 0.15d
    if nnn eq 2 then nh = 0.20d

    ; ribbon data prep
    ver = 'svGP_v20240413'
    cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
    cd, cpath
    SEPNAME = 'L'
    MAPNAME = 'Theseus'


    fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\'+ $
      MAPNAME+'-'+SEPNAME+'_RC_Iteration\'+ver+'\Ribbon_Distance\'
    file_mkdir, fpath

    cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
    path_str = strsplit(cpath, '\', /extract)
    cd, cpath
    DPATH = strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-'+SEPNAME+'\'


    ; ************************** INPUT **************************
    year_min = 2009
    year_max = 2022
    time_ibex = [year_min:year_mAX]

    ; acquisition time
    frac_year = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
    FOR ram = 0, 1 DO BEGIN
      for yidx = year_min, year_max do begin
        IF ram THEN str = 'ARam' ELSE str = 'Ram'
        year = string(yidx, format = '(I4)')

        RESTORE, dpath +'SAV_'+ver+'\CountRate_Time\' +mapname+'-L_CNT_ACQ_'+year+'_'+str+'.sav'
        for esa = 2, 6 do $
          !null = execute('frac_year[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_FRAC_MAP')
      endfor
    endfor
    ; acquisition time



    rbn_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
    rbn_sig_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram

    restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
    FOR ram = 0, 1 DO BEGIN
      for yidx = year_min, year_max do begin
        IF ram THEN str = 'ARam' ELSE str = 'Ram'
        survp =  reform(survp_map[*, ram, *, *, *])

        year = string(yidx, format = '(I4)')
        RESTORE, dpath +'SAV_'+ver+'\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'
        for esa = 2, 6 do begin
          !null = execute('rbn_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
          !null = execute('rbn_sig_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_stddev_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
        endfor ; esa
      endfor ; year
    endfor ; ram
    ;  rbn_map_res = alog10(rbn_map_res)

    ; ribbon data prep

if nnn eq 0 then begin
    for esa = 2, 6 do begin
      rbn_map = mean(rbn_map_res[*, *, *, esa-2, 0], dim = 3)
      rbn_map[where(rbn_map eq 0, /null)] = !values.f_nan
      ec_map_single_plot, ESA, rbn_map, 1, 'RBN', cb_title = 'Flux [#/cm2-sr-s-keV]'
      write_png, fpath+'ESA'+string(esa, format = '(I1)')+'RBN_FLX_AVG.png',tvrd(/true)
    endfor ; esa
endif
    stop

    ; solar wind data prep
    e_step = [0.71,1.11,1.74,2.73,4.29]
    v_step = sqrt(2d / !const.mp * e_step * 1d3 * !const.e) ; m/s,  esa 1 - 6

    ymin = 1990
    ymax = 2022

    restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'

    ;  tidx = where(time ge ymin and time le ymax)
    ;  Time = time[tidx]
    ;  NSW = NSW[tidx, *]
    ;  VSW = VSW[tidx, *]

    SOLAR_P_Flux = replicate(!values.d_nan, time.length, sol_lat_ec.length, v_step.length) ; time x lat x energy
    Temperature_arr = replicate(!values.d_nan, time.length, sol_lat_ec.length) ; time x lat x energy

    for latidx = 0, sol_lat_ec.length-1 do begin
      Density = NSW[*, latidx] * 1d6; m-3

      Temperature = replicate(7.23, time.length) ; Fixed temperature MEAN(T_OMNI) ; constant T assumption
      ;    Temperature = interpol(SMOOTH(T, 60*24*30., /EDGE_TRUNCATE, /NAN), time_ace, time) ; Uniform T MEAN(T_OMNI)

      Temperature[where(VSW[*, latidx] lt 450, /null)] = -0.162d*VSW[where(VSW[*, latidx] lt 450, /null), latidx]^2 + 595d*VSW[where(VSW[*, latidx] lt 450, /null), latidx] -1.28e5
      Temperature[where(VSW[*, latidx] ge 450, /null)] = -0.521d*VSW[where(VSW[*, latidx] ge 450, /null), latidx]^2 + 1220d*VSW[where(VSW[*, latidx] ge 450, /null), latidx] -3.24e5
      Temperature = (Temperature * !CONST.K/!CONST.E)
      Temperature_arr[*, latidx] = Temperature

      theta1 = sqrt(2d * Temperature / !const.mp * !const.e)

      Velo = VSW[*, latidx] * 1d3; m/s

      p = [[Density], [theta1], [Velo]]

      res = []
      for ii = 0, v_step.length-1 do $
        res = [[res], [maxwellian_240505(v_step[ii], p)]]
      SOLAR_P_Flux[*, latidx, *] = res;psd2flux(res[*, 1:-1]*1d-12,transpose(rebin(e_step[1:-1], 5, time.length)) , psd_units = 3)
    endfor
    ; solar wind data prep

    ;Time Integration of Solar Wind Proton Flux

    a1 = 4.15
    a2 = 0.531
    a3 = 67.3
    sig = (a1-a2 * alog(e_step))^2 * (1 - exp(-a3/e_step))^4.5 * 1e-16

    tidx = where(time ge ymin and time le ymax)
    Time_tmp = time[tidx]
    NSW_tmp = NSW[tidx, *]
    VSW_tmp = VSW[tidx, *]


    Tcx = (nh * sig * v_step * 1d2)^(-1d) / 60 / 60 / 24 / 365.25d

    SOLAR_P_Flux_Integ = replicate(!values.d_nan, time_tmp.length, 19, 5)
    co = ['black', 'blue', 'green', 'orange', 'red']
    for ee = 0, Tcx.length-1 do begin
      for tt = 0, Time_tmp.length-1 do begin
        for ll = 0, 19-1 do begin
          Tcx_tmp = Tcx[ee]
          tidx = where(time gt Time_tmp[tt] - Tcx_tmp*3 and time le Time_tmp[tt])

          t_abs = abs(time[tidx]-Time_tmp[tt])
          ex = exp(-t_abs/Tcx_tmp)

          dt = abs(mean(t_abs[1:-1]-t_abs[0:-2]))
          ex_norm = ex/total(ex)
          SOLAR_P_Flux_Integ[tt, ll, ee] = total(SOLAR_P_Flux[tidx, ll, ee] * ex_norm)
        endfor
      endfor
      ;      p = plot(t_abs, ex_norm, xtitle = 'Time', ytitle = 'Norm. Ex', co = co[ee], /over, thick = 2)
    endfor

    Time_long = time
    time = time_tmp

    ;Time Integration of Solar Wind Proton Flux

    ;    for esa = 2, 6 do begin
    ;      dr = [1e-25, 1e-6]
    ;      ;    sp = spec_plot(SOLAR_P_Flux[*, *, esa-2], Time_long, sol_lat_ec, data_min = dr[0]*10d^((2.-esa)*2), data_max = dr[1]*10d^((2.-esa)*0.5), xtitle = 'Time', ytitle = 'Latitude', title = 'PSD, ESA'+strcompress(esa, /rem), xr = [1990, 2022], /data_log)
    ;      ;    cb = color_bar(sp, ytitle = 'PSD', /ylog)
    ;    endfor

    ; rbn x SENA chi-square

    ;  ribbon exist
    rridx = where(rbn_map_res le 0, /null, tmp)
    if tmp ne 0 then begin
      rbn_map_res[rridx] = !values.f_nan
      rbn_sig_map_res[rridx] = !values.f_nan
    endif
    rbn_flag = total(finite(rbn_map_res), 3)

    ;  ribbon exist

    mx = 15d

    time_shift = linspace(0d, mx, 100) ; time shift
    time_shift_min_chis = replicate(!values.d_nan, lon_arr.length, lat_arr.length, e_step.length, 2)
    chis_min = replicate(!values.d_nan, lon_arr.length, lat_arr.length, e_step.length, 2)

    time_shift_min_RMSD = replicate(!values.d_nan, lon_arr.length, lat_arr.length, e_step.length, 2)
    RMSD_min = replicate(!values.d_nan, lon_arr.length, lat_arr.length, e_step.length, 2)

    time_shift_max_rocc = replicate(!values.d_nan, lon_arr.length, lat_arr.length, e_step.length, 2)
    rocc_max = replicate(!values.d_nan, lon_arr.length, lat_arr.length, e_step.length, 2)

    Chis_mat = replicate(!values.d_nan, time_shift.length, lon_arr.length, lat_arr.length, e_step.length, 2)
    RMSD_mat = replicate(!values.d_nan, time_shift.length, lon_arr.length, lat_arr.length, e_step.length, 2)
    ROCC_mat = replicate(!values.d_nan, time_shift.length, lon_arr.length, lat_arr.length, e_step.length, 2)
    ROCC_sig_mat = replicate(!values.d_nan, time_shift.length, lon_arr.length, lat_arr.length, e_step.length, 2)

    ROCC_CRITERION = 0.5
    CHIS_CRITERION = 0.5
    RMSD_CRITERION = 0.3


    !P.BACKGROUND = 255
    !P.COLOR = 0
    tic
    for ram = 0, 0 do begin
      for latidx = 0, lat_arr.length-1 do begin
        lat_tmp = lat_arr[latidx]
        lat_index = interpol(findgen(sol_lat_ec.length), sol_lat_ec, lat_tmp)

        for lonidx = 0, lon_arr.length-1 do begin
          lon_tmp = lon_arr[latidx]
          for ee = 0, e_step.length-1 do begin
            if rbn_flag[lonidx, latidx, ee, ram] lt 14 then continue

            rbn_flux = reform(rbn_map_res[lonidx, latidx, *, ee, ram])
            rbn_sig = reform(rbn_sig_map_res[lonidx, latidx, *, ee, ram])

            rbn_frac_year = reform(frac_year[lonidx, latidx, *, ee, ram])
            if total(rbn_frac_year[1:-1] - rbn_frac_year[0:-2] lt 0) gt 0 then stop

            ;          sol_p_check = replicate(!values.d_nan, time_shift.length, rbn_frac_year.length)

            for ts = 0, time_shift.length-1 do begin
              time_index = interpol(findgen(time.length), time, rbn_frac_year-time_shift[ts])
              sol_p_flux_tmp = 10d^interpolate(alog10(SOLAR_P_Flux_Integ[*, *, ee]), time_index, replicate(lat_index, time_index.length))
              ;            sol_p_check[ts, *] = sol_p_flux_tmp
              Chis_mat[ts, lonidx, latidx, ee, ram] = total( (sol_p_flux_tmp-rbn_flux)^2/sol_p_flux_tmp^2 )
              ;              ROCC_mat[ts, lonidx, latidx, ee, ram] = (r_correlate(sol_p_flux_tmp, rbn_flux))[0]

              rbn_flux_scaled = (rbn_flux - min(rbn_flux))/max(rbn_flux - min(rbn_flux))  + 1
              sol_flux_scaled = (sol_p_flux_tmp - min(sol_p_flux_tmp))/max(sol_p_flux_tmp - min(sol_p_flux_tmp)) + 1

              Chis_mat[ts, lonidx, latidx, ee, ram] = total( (sol_flux_scaled-rbn_flux_scaled)^2/sol_flux_scaled^2 )
              RMSD_mat[ts, lonidx, latidx, ee, ram] = sqrt(total( (sol_flux_scaled-rbn_flux_scaled)^2 )/sol_flux_scaled.length )
              rocc_tmp = r_correlate(sol_flux_scaled, rbn_flux_scaled)
              ROCC_mat[ts, lonidx, latidx, ee, ram] = rocc_tmp[0]
              ROCC_sig_mat[ts, lonidx, latidx, ee, ram] = rocc_tmp[1]
            endfor ; time shift

            dist_min = hp_mat[lonidx, latidx]
            dist_max = 600d

            t_min = dist_min*!const.au / (v_step[ee]) / (60d*60d*24d*365.25d)
            t_max = dist_max*!const.au / (v_step[ee]) / (60d*60d*24d*365.25d)

            ;            tidx = where(time_shift gt (t_min*2 + Tcx[ee]) and time_shift lt (t_max*2 + Tcx[ee]), tmp)
            ;            if tmp lt 3 thenstop
            tidx = [0:time_shift.length-1]

            ;            chis_min[lonidx, latidx, ee, ram] = min(Chis_mat[tidx, lonidx, latidx, ee, ram], minidx)
            ;            time_shift_min_chis[lonidx, latidx, ee, ram] = time_shift[tidx[minidx]]
            ;
            ;            RMSD_min[lonidx, latidx, ee, ram] = min(RMSD_mat[tidx, lonidx, latidx, ee, ram], minidx2)
            ;            time_shift_min_RMSD[lonidx, latidx, ee, ram] = time_shift[tidx[minidx2]]
            ;
            ;            rocc_tmp = max(ROCC_mat[tidx, lonidx, latidx, ee, ram], maxidx)
            ;            ;            if ROCC_sig_mat[tidx[maxidx], lonidx, latidx, ee, ram] lt 0.1 then $
            ;            rocc_max[lonidx, latidx, ee, ram] = rocc_tmp
            ;            time_shift_max_rocc[lonidx, latidx, ee, ram] = time_shift[tidx[maxidx]]

            ; first peak
            tmp = smooth(Chis_mat[tidx, lonidx, latidx, ee, ram], 10, /edge_truncate)
            dtmp = tmp[1:-1]-tmp[0:-2]
            didx = where(sign(dtmp[1:-1]*dtmp[0:-2]) lt 0)
            local_peak = []
            for dd = 0, didx.length-1 do $
              if didx[dd] ne -1 then $
              if (dtmp[didx[dd]] lt 0) and (dtmp[didx[dd]+1] gt 0) then $
              local_peak = [local_peak, didx[dd]+1]
            if n_elements(local_peak) ne 0 then begin
              chis_min[lonidx, latidx, ee, ram] = Chis_mat[tidx[local_peak[0]], lonidx, latidx, ee, ram]
              time_shift_min_chis[lonidx, latidx, ee, ram] = time_shift[tidx[local_peak[0]]]
            endif

            tmp = smooth(RMSD_mat[tidx, lonidx, latidx, ee, ram], 10, /edge_truncate)
            dtmp = tmp[1:-1]-tmp[0:-2]
            didx = where(sign(dtmp[1:-1]*dtmp[0:-2]) lt 0)
            local_peak = []
            for dd = 0, didx.length-1 do $
              if didx[dd] ne -1 then $
              if (dtmp[didx[dd]] lt 0) and (dtmp[didx[dd]+1] gt 0) then $
              local_peak = [local_peak, didx[dd]+1]
            if n_elements(local_peak) ne 0 then begin
              RMSD_min[lonidx, latidx, ee, ram] = RMSD_mat[tidx[local_peak[0]], lonidx, latidx, ee, ram]
              time_shift_min_RMSD[lonidx, latidx, ee, ram] = time_shift[tidx[local_peak[0]]]
            endif

            tmp = smooth(ROCC_mat[tidx, lonidx, latidx, ee, ram], 10, /edge_truncate)
            dtmp = tmp[1:-1]-tmp[0:-2]
            didx = where(sign(dtmp[1:-1]*dtmp[0:-2]) lt 0)
            local_peak = []
            for dd = 0, didx.length-1 do $
              if didx[dd] ne -1 then $
              if (dtmp[didx[dd]] gt 0) and (dtmp[didx[dd]+1] lt 0) then $
              local_peak = [local_peak, didx[dd]+1]

            if n_elements(local_peak) ne 0 then begin
              rocc_tmp = ROCC_mat[tidx[local_peak[0]], lonidx, latidx, ee, ram]
              rocc_max[lonidx, latidx, ee, ram] = rocc_tmp
              time_shift_max_rocc[lonidx, latidx, ee, ram] = time_shift[tidx[local_peak[0]]]
            endif
            ; first peak

            esa = ee+2

            ;            if total(finite(ROCC_mat[*, lonidx, latidx, 1:2, ram])) eq 200 then if esa eq 5 then begin
            ;              p = plot(time_shift, ROCC_mat[*, lonidx, latidx, 1, ram], title = 'esa2')
            ;              p = plot(time_shift, ROCC_sig_mat[*, lonidx, latidx, 1, ram], co = 'blue', over = p)
            ;
            ;              p = plot(time_shift, ROCC_mat[*, lonidx, latidx, 2, ram], title = 'esa3')
            ;              p = plot(time_shift, ROCC_sig_mat[*, lonidx, latidx, 2, ram], co = 'blue', over = p)
            ;
            ;              p = plot(time_shift, ROCC_mat[*, lonidx, latidx, 3, ram], title = 'esa4')
            ;              p = plot(time_shift, ROCC_sig_mat[*, lonidx, latidx, 3, ram], co = 'blue', over = p)
            ;stop
            ;            endif
            ;            if lonidx eq 109 and latidx eq 20 then stop

            ;            ; best profile
            ;            ; best chi-square
            ;            time_index = interpol(findgen(time.length), time, rbn_frac_year-time_shift_min_chis[lonidx, latidx, ee, ram])
            ;            sol_p_flux_tmp = 10d^interpolate(alog10(SOLAR_P_Flux_Integ[*, *, ee]), time_index, replicate(lat_index, time_index.length))
            ;            rbn_flux_scaled = (rbn_flux - min(rbn_flux))/max(rbn_flux - min(rbn_flux))  + 1
            ;            sol_flux_scaled = (sol_p_flux_tmp - min(sol_p_flux_tmp))/max(sol_p_flux_tmp - min(sol_p_flux_tmp)) + 1
            ;
            ;            chi_tmp = total( (sol_flux_scaled-rbn_flux_scaled)^2/rbn_flux_scaled^2 )
            ;            if chi_tmp le CHIS_CRITERION then begin
            ;              plot, rbn_frac_year, rbn_flux_scaled, xr = [2009, 2022], yr = [0, 3], xtitle = 'Time', ytitle = 'Flux (scaled)', $
            ;                title = 'ESA'+string(esa, format = '(I1)')+', [Lon, Lat] = ['+string(lon_arr[lonidx], format = '(I3)')+', '+string(lat_arr[latidx], format = '(I3)')+']'+', Chi-Square = '+string(chi_tmp, format = '(f5.1)')
            ;              oplot, rbn_frac_year, sol_flux_scaled, co = '240'
            ;
            ;              fpath_tmp = fpath + 'Chi-Square\Nh'+string(nh, format = '(f4.2)')+'\ESA'+string(esa, format = '(I1)')+'\'
            ;              file_mkdir, fpath_tmp
            ;              write_png, fpath_tmp+'Lon'+string(lon_arr[lonidx], format = '(I3.3)')+'_Lat'+string(lat_arr[latidx], format = '(I3)')+'.png',tvrd(/true)
            ;            endif
            ;
            ;            ; best RMSD
            ;            time_index = interpol(findgen(time.length), time, rbn_frac_year-time_shift_min_RMSD[lonidx, latidx, ee, ram])
            ;            sol_p_flux_tmp = 10d^interpolate(alog10(SOLAR_P_Flux_Integ[*, *, ee]), time_index, replicate(lat_index, time_index.length))
            ;            rbn_flux_scaled = (rbn_flux - min(rbn_flux))/max(rbn_flux - min(rbn_flux))  + 1
            ;            sol_flux_scaled = (sol_p_flux_tmp - min(sol_p_flux_tmp))/max(sol_p_flux_tmp - min(sol_p_flux_tmp)) + 1
            ;
            ;            RMSD_tmp = sqrt(total( (sol_flux_scaled-rbn_flux_scaled)^2 )/sol_flux_scaled.length )
            ;            if RMSD_tmp le RMSD_CRITERION then begin
            ;              plot, rbn_frac_year, rbn_flux_scaled, xr = [2009, 2022], yr = [0, 3], xtitle = 'Time', ytitle = 'Flux (scaled)', $
            ;                title = 'ESA'+string(esa, format = '(I1)')+', [Lon, Lat] = ['+string(lon_arr[lonidx], format = '(I3)')+', '+string(lat_arr[latidx], format = '(I3)')+']'+', RMSD = '+string(RMSD_tmp, format = '(f5.1)')
            ;              oplot, rbn_frac_year, sol_flux_scaled, co = '240'
            ;
            ;              fpath_tmp = fpath + 'RMSD\Nh'+string(nh, format = '(f4.2)')+'\ESA'+string(esa, format = '(I1)')+'\'
            ;              file_mkdir, fpath_tmp
            ;              write_png, fpath_tmp+'Lon'+string(lon_arr[lonidx], format = '(I3.3)')+'_Lat'+string(lat_arr[latidx], format = '(I3)')+'.png',tvrd(/true)
            ;            endif
            ;
            ;            ; best ROCC
            ;            time_index = interpol(findgen(time.length), time, rbn_frac_year-time_shift_max_rocc[lonidx, latidx, ee, ram])
            ;            sol_p_flux_tmp = 10d^interpolate(alog10(SOLAR_P_Flux_Integ[*, *, ee]), time_index, replicate(lat_index, time_index.length))
            ;            rbn_flux_scaled = (rbn_flux - min(rbn_flux))/max(rbn_flux - min(rbn_flux))  + 1
            ;            sol_flux_scaled = (sol_p_flux_tmp - min(sol_p_flux_tmp))/max(sol_p_flux_tmp - min(sol_p_flux_tmp)) + 1
            ;
            ;            CC_tmp = (r_correlate(sol_flux_scaled, rbn_flux_scaled))[0]
            ;            if CC_tmp gt ROCC_CRITERION then begin
            ;              plot, rbn_frac_year, rbn_flux_scaled, xr = [2009, 2022], yr = [0, 3], xtitle = 'Time', ytitle = 'Flux (scaled)', $
            ;                title = 'ESA'+string(esa, format = '(I1)')+', [Lon, Lat] = ['+string(lon_arr[lonidx], format = '(I3)')+', '+string(lat_arr[latidx], format = '(I3)')+']'+', ROCC = '+string(CC_tmp, format = '(f6.3)')
            ;              oplot, rbn_frac_year, sol_flux_scaled, co = '240'
            ;
            ;              fpath_tmp = fpath + 'ROCC\Nh'+string(nh, format = '(f4.2)')+'\ESA'+string(esa, format = '(I1)')+'\'
            ;              file_mkdir, fpath_tmp
            ;              write_png, fpath_tmp+'Lon'+string(lon_arr[lonidx], format = '(I3.3)')+'_Lat'+string(lat_arr[latidx], format = '(I3)')+'.png',tvrd(/true)
            ;              ;              if (esa eq 3) and (lon_arr[lonidx] eq 1) and (lat_arr[latidx] eq 59) stop
            ;            endif
            ;            ; best profile

          endfor; energy
        endfor ; EC lon
      endfor ; EC lat
    endfor ; ram
    toc

    pos = make_plot_pos(0.1, 0.05, 0.80, 0.90, 5, /col, gap = 0.05)
    for esa = 2, 6 do begin
      for measure = 0, 2 do begin
        if measure eq 0 then begin
          ts_tmp = time_shift_max_rocc[*, *, esa-2, 0]
          rocc_tmp = rocc_max[*, *, esa-2, 0]
          fpath_tmp = fpath + 'ROCC\Nh'+string(nh, format = '(f4.2)')+'\'
        endif

        if measure eq 1 then begin
          ts_tmp = time_shift_min_chis[*, *, esa-2, 0]
          rocc_tmp = chis_min[*, *, esa-2, 0]
          fpath_tmp = fpath + 'Chi-Square\Nh'+string(nh, format = '(f4.2)')+'\'
        endif

        if measure eq 2 then begin
          ts_tmp = time_shift_min_RMSD[*, *, esa-2, 0]
          rocc_tmp = RMSD_min[*, *, esa-2, 0]
          fpath_tmp = fpath + 'RMSD\Nh'+string(nh, format = '(f4.2)')+'\'
        endif

        distance = (ts_tmp - Tcx[esa-2]) * (60d*60d*24d*365.25d) * v_step[esa-2] / 2

        ;        distance = (ts_tmp - Tcx[esa-2]) * (60*60*24*365.25d) * v_step[esa-2] / 2

        file_mkdir, fpath_tmp

        ec_map_single_plot, ESA, ts_tmp, 1, '', cb_title = 'Time delay [year]', data_range = [0, mx]
        write_png, fpath_tmp+'ESA'+string(esa, format = '(I1)')+'_Nh'+string(nh, format = '(f4.2)')+'_TimeDelay.png',tvrd(/true)

        ec_map_single_plot, ESA, distance/!const.au, 1, '', cb_title = 'Distance [AU]', data_range = [0, 700]
        write_png, fpath_tmp+'ESA'+string(esa, format = '(I1)')+'_Nh'+string(nh, format = '(f4.2)')+'_Distance.png',tvrd(/true)



        win = window(dim = [600, 1600])
        tx = text(0.5, 0.97, 'ESA'+string(esa, format = '(I1)')+'!CNh'+string(nh, format = '(f4.2)'), font_size = 20, align = 0.5, vertical_alignment = 0.5)

        sp = spec_plot(ts_tmp, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -1], current = win, xr = [360, 0], data_min = 0, data_max = mx, title = 'ESA'+string(esa, format = '(I1)')+', Ram')
        cb = color_bar(sp, ytitle = 'Time delay [year]')

        sp = spec_plot(distance/!const.au, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -2], current = win, xr = [360, 0], data_min = 0, data_max = 1000, title = 'ESA'+string(esa, format = '(I1)')+', Ram')
        cb = color_bar(sp, ytitle = 'Distance [AU]')



        if measure eq 0 then begin
          ridx = where(rocc_tmp lt ROCC_CRITERION, tmp)
          ec_map_single_plot, ESA, rocc_tmp, 1, '', cb_title = 'ROCC', data_range = [0, 1]
          sp = spec_plot(rocc_tmp, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -3], current = win, xr = [360, 0], data_min = 0, data_max = 1, title = 'ESA'+string(esa, format = '(I1)')+', Ram')
          cb = color_bar(sp, ytitle = 'ROCC')
        endif
        if measure eq 1 then begin
          ridx = where(rocc_tmp gt CHIS_CRITERION, tmp)
          ec_map_single_plot, ESA, rocc_tmp, 1, '', cb_title = 'Chi-square', data_range = [0, 1]
          sp = spec_plot(rocc_tmp, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -3], current = win, xr = [360, 0], data_min = 0, data_max = 1, title = 'ESA'+string(esa, format = '(I1)')+', Ram')
          cb = color_bar(sp, ytitle = 'Chi-Square')
        endif
        if measure eq 2 then begin
          ridx = where(rocc_tmp gt RMSD_CRITERION, tmp)
          ec_map_single_plot, ESA, rocc_tmp, 1, '', cb_title = 'RMSD', data_range = [0, 1]
          sp = spec_plot(rocc_tmp, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -3], current = win, xr = [360, 0], data_min = 0, data_max = 1, title = 'ESA'+string(esa, format = '(I1)')+', Ram')
          cb = color_bar(sp, ytitle = 'RMSD')
        endif

        write_png, fpath_tmp+'ESA'+string(esa, format = '(I1)')+'_Nh'+string(nh, format = '(f4.2)')+'_Measure.png',tvrd(/true)

        if tmp ne 0 then begin
          ts_tmp[ridx] = !values.d_nan
          sp = spec_plot(ts_tmp, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -4], current = win, xr = [360, 0], data_min = 0, data_max = mx, title = 'ESA'+string(esa, format = '(I1)')+', Ram!CCriteria')
          cb = color_bar(sp, ytitle = 'Time delay [year]')
          distance[ridx] = !values.d_nan
          sp = spec_plot(distance/!const.au, lon_arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', pos = pos[*, -5], current = win, xr = [360, 0], data_min = 0, data_max = 1000, title = 'ESA'+string(esa, format = '(I1)')+', Ram!CCriteria')
          cb = color_bar(sp, ytitle = 'Distance [AU]')
        endif

        win.refresh
        win.save, fpath_tmp+'ESA'+string(esa, format = '(I1)')+'_Nh'+string(nh, format = '(f4.2)')+'_Distance_Summary.png'
        win.close


        ec_map_single_plot, ESA, ts_tmp, 1, '', cb_title = 'Time delay [year]', data_range = [0, mx]
        write_png, fpath_tmp+'ESA'+string(esa, format = '(I1)')+'_Nh'+string(nh, format = '(f4.2)')+'_TimeDelay_MeasureCriteria.png',tvrd(/true)
        ec_map_single_plot, ESA, distance/!const.au, 1, '', cb_title = 'Distance [AU]', data_range = [0, 700]
        write_png, fpath_tmp+'ESA'+string(esa, format = '(I1)')+'_Nh'+string(nh, format = '(f4.2)')+'_Distance_MeasureCriteria.png',tvrd(/true)

      endfor ; measure
    endfor ; esa


  endfor
  ;  stop
  ;  for esa = 2, 6 do begin
  ;    sp = spec_plot(time_shift_min_chis[*, *, esa-2, 1], lon_arr, lat_arr, data_min = 0, data_max = mx, title = 'ESA'+string(esa)+', ARam')
  ;    cb = color_bar(sp, ytitle = 'Time delay [year]')
  ;  endfor
  ;  ; rbn x SENA chi-square
  ;  stop









end