function maxwellian_240505, x, p
  if n_elements(p.dim) gt 1 then return, p[*, 0] / p[*, 1]^3 / sqrt(!dpi)^3 *exp(-(x - p[*, 2])^2/p[*, 1]^2) $
  else return, p[0] / p[1]^3 / sqrt(!dpi)^3*exp(-(x - p[2])^2/p[1]^2)
end

pro ribbon_sounding

  ; ribbon data prep
  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  cd, cpath
  SEPNAME = 'L'
  MAPNAME = 'Theseus'

  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  path_str = strsplit(cpath, '\', /extract)
  cd, cpath
  DPATH = strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-'+SEPNAME+'\'
  ; ************************** INPUT **************************
  year_min = 2009
  year_max = 2022
  time_ibex = [year_min:year_mAX]
  rbn_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  FOR ram = 0, 1 DO BEGIN
    for yidx = year_min, year_max do begin
      IF ram THEN str = 'ARam' ELSE str = 'Ram'
      survp =  reform(survp_map[*, ram, *, *, *])

      year = string(yidx, format = '(I4)')
      RESTORE, dpath +'SAV_'+ver+'\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'
      for esa = 2, 6 do $
        !null = execute('rbn_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
    endfor
  endfor
  rbn_map_res = alog10(rbn_map_res)

  rbn_properties_res = replicate(!values.f_nan, 4, 14, 5, 2) ; properties (RClon, RClat, opening angle, FWHM) x year x energy x ram
  FOR ram = 0, 0 DO BEGIN
    for yidx = year_min, year_max do begin
      IF ram THEN str = 'ARam' ELSE str = 'Ram'
      survp =  reform(survp_map[*, ram, *, *, *])

      year = string(yidx, format = '(I4)')
      RESTORE, dpath +'TheseusRibbonSep_RC_Peak_Moment_'+ver+'\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'

      rbn_map_tmp = replicate(!values.f_nan, 180, 90, 5)

      rbn_properties_res[2, yidx-year_min, *, ram] = RC_E_LONLAT[*, 0] ; opening angle
      rbn_properties_res[0:1, yidx-year_min, *, ram] = transpose(RC_E_LONLAT[*, 1:2]) ; opening angle

      for esa = 2, 6 do $
        !null = execute('rbn_properties_res[3, yidx-year_min, esa-2, ram] = mean(ESA'+strcompress(esa, /rem)+'_MOM2_4[1, *], /nan)')

    endfor
  endfor
  rbn_properties = mean(rbn_properties_res[*, *, *, 0], dim = 2, /nan)


  ; ribbon data prep


  ; solar wind data prep
  e_step = [0.71,1.11,1.74,2.73,4.29]
  v_step = sqrt(2d / !const.mp * e_step * 1d3 * !const.e) ;  esa 1 - 6

  ymin = 2000
  ymax = 2022

  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'

  ;  tidx = where(time ge ymin and time le ymax)
  ;  Time = time[tidx]
  ;  NSW = NSW[tidx, *]
  ;  VSW = VSW[tidx, *]

  SOLAR_P_Flux = replicate(!values.d_nan, time.length, sol_lat_ec.length, v_step.length) ; time x lat x energy

  for latidx = 0, sol_lat_ec.length-1 do begin
    Density = NSW[*, latidx] * 1d6; m-3

    Temperature = replicate(7.23, time.length) ; Fixed temperature MEAN(T_OMNI) ; constant T assumption
    ;    Temperature = interpol(SMOOTH(T, 60*24*30., /EDGE_TRUNCATE, /NAN), time_ace, time) ; Uniform T MEAN(T_OMNI)

    Temperature[where(VSW[*, latidx] lt 450, /null)] = -0.162d*VSW[where(VSW[*, latidx] lt 450, /null), latidx]^2 + 595d*VSW[where(VSW[*, latidx] lt 450, /null), latidx] -1.28e5
    Temperature[where(VSW[*, latidx] ge 450, /null)] = -0.521d*VSW[where(VSW[*, latidx] ge 450, /null), latidx]^2 + 1220d*VSW[where(VSW[*, latidx] ge 450, /null), latidx] -3.24e5
    Temperature = (Temperature * !CONST.K/!CONST.E)


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
  Tcx = (0.2d * sig * v_step * 1d2)^(-1d) / 60 / 60 / 24 / 365.25d

  tidx = where(time ge ymin and time le ymax)
  Time_tmp = time[tidx]
  NSW_tmp = NSW[tidx, *]
  VSW_tmp = VSW[tidx, *]

  SOLAR_P_Flux_Integ = replicate(!values.d_nan, time_tmp.length, 19, 5)
  for ee = 0, Tcx.length-1 do begin
    for tt = 0, Time_tmp.length-1 do begin
      for ll = 0, 19-1 do begin
        Tcx_tmp = Tcx[ee]
        tidx = where(time gt Time_tmp[tt] - Tcx_tmp*3 and time le  + Time_tmp[tt])

        t_abs = abs(time[tidx]-Time_tmp[tt])
        ex = exp(-t_abs/Tcx_tmp)

        dt = abs(mean(t_abs[1:-1]-t_abs[0:-2]))
        ex_norm = ex/total(ex)
        SOLAR_P_Flux_Integ[tt, ll, ee] = alog10(total(SOLAR_P_Flux[tidx, ll, ee] * ex_norm))
      endfor
    endfor
  endfor
  
  Time_long = time
  time = time_tmp
  ;Time Integration of Solar Wind Proton Flux


  ; DEFINE SECTOR

  ; average RC
  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  rc = rbn_properties[0:1, *]
  ; average RC

  ;  average opening angle
  open_angle = reform(rbn_properties[2, *])
  ;  average opening angle


  ;  average FWHM
  FWHM = reform(rbn_properties[3, *])
  ;  average FWHM


  ; sector lon in RC frame
  num_sec = 4
  lb_arr = linspace(0, 360, num_sec+1)
  lb_arr = lb_arr-20
  lb_lon_mat = []
  for ll = 0, lb_arr.length-2 do $
    lb_lon_mat = [[lb_lon_mat], [lb_arr[ll]:lb_arr[ll+1]-2]]

  lidx_tmp = where(lb_arr lt 0, /null, tmp)
  if tmp ne 0 then lb_arr[lidx_tmp] = lb_arr[lidx_tmp]+360
  co_lb = ['black', 'red', 'green', 'blue']
  sector_name = ['Nose', 'North', 'Tail', 'South']
  ; sector lon in RC frame

  ; making sector grid
  for esa = 2, 6 do begin
    eidx = esa-2

    !null = execute('sector_grid_esa'+strcompress(esa, /rem)+' = list()')

    for lbidx = 0, num_sec-1 do begin
      lon_rc_tmp = lb_lon_mat[*, lbidx]
      lat_rc_tmp = [open_angle[eidx]-FWHM[eidx]/2:open_angle[eidx]+FWHM[eidx]/2] ;  rc lat boundary = FWHM
      res = meshgrid(lon_rc_tmp, lat_rc_tmp)
      lat_mat = res.remove()
      lon_mat = res.remove()

      res = conv_coord_ec_rc(lon_mat, lat_mat, rc[0, eidx], rc[1, eidx], /reverse, nose_POS = [255.6, 5.14])

      lon_pos_bound = []
      lat_pos_bound = []
      cnt = 0
      for lonidx = 0, lon_rc_tmp.length-1 do begin
        for latidx = 0, lat_rc_tmp.length-1 do begin
          tmp1 = min(abs(lon_arr - res.lon[lonidx, latidx]), lon_min)
          tmp2 = min(abs(lat_arr - res.lat[lonidx, latidx]), lat_min)
          if (tmp1 gt 1) or (tmp2 gt 1) then stop

          if cnt ne 0 then begin
            if total(abs(lon_pos_bound-lon_arr[lon_min])+abs(lat_pos_bound-lat_arr[lat_min]) eq 0) eq 0 then begin
              lon_pos_bound = [lon_pos_bound, lon_arr[lon_min]]
              lat_pos_bound = [lat_pos_bound, lat_arr[lat_min]]
            endif
          endif else begin
            lon_pos_bound = [lon_pos_bound, lon_arr[lon_min]]
            lat_pos_bound = [lat_pos_bound, lat_arr[lat_min]]
          endelse; comparison

          cnt = cnt+1
        endfor ;  lat
      endfor ; lon
      ;      print, cnt
      pos = [[lon_pos_bound], [lat_pos_bound]]
      !null = execute('sector_grid_esa'+strcompress(esa, /rem)+'.add, pos')
    endfor; sector boundary
  endfor ; energy
  ; making sector grid


  ;  ; draw sector grid for sanity check
  ;  win = window(dim = [800, 600], /buffer)
  ;  win.refresh, /disable
  ;  for esa = 2, 6 do begin
  ;    !null = execute('sector_grid = sector_grid_esa'+strcompress(esa, /rem))
  ;    for yidx = 0, 13 do begin
  ;      for ram = 0, 1 do begin
  ;        sp = spec_plot(rbn_map_res[*, *, yidx, esa-2, ram], lon_arr, lat_arr, xr = [360, 0], yr = [-90, 90], current = win, pos = [0.1, 0.1, 0.9, 0.9])
  ;        for lbidx = 0, num_sec-1 do begin
  ;          pos_tmp = sector_grid[lbidx]
  ;          sc = scatterplot(pos_tmp[*, 0], pos_tmp[*, 1], over = sp, symbol = 'X', sym_color = co_lb[lbidx])
  ;        endfor ; sector boundary
  ;        win.refresh
  ;        win.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\IPS_FLUX\temporary\Grid_ESA'+strcompress(esa, /rem)+'_'+strcompress(yidx+2009, /rem)+'_'+strcompress(ram, /rem)+'_v20240617.png'
  ;        win.erase
  ;      endfor ;  ram
  ;    endfor ; year
  ;  endfor ; esa
  ;  ; draw sector grid for sanity check
  ;  win.close


  ; store sector averaged flux
  ENA_Flux = replicate(!values.d_nan, 14, 5, num_sec, 2) ; time x energy x sector x ram
  P_1AU_Flux = replicate(!values.d_nan, time.length, 5, num_sec, 2) ; time x energy x sector x ram

  for esa = 2, 6 do begin
    !null = execute('sector_grid = sector_grid_esa'+strcompress(esa, /rem))
    for yidx = 0, 13 do begin
      for ram = 0, 1 do begin
        for lbidx = 0, num_sec-1 do begin

          pos_tmp = sector_grid[lbidx]
          sz = size(pos_tmp)

          ; ena flux
          rbn_map_tmp = reform(rbn_map_res[*, *, yidx, esa-2, ram])
          ;          rbn_map_tmp[where(rbn_map_tmp eq 0, /null)] = !values.f_nan
          flux_tmp = []
          for posidx = 0, sz[1]-1 do begin
            tmp1 = min(abs(pos_tmp[posidx, 0]-lon_arr), minidx1)
            tmp2 = min(abs(pos_tmp[posidx, 1]-lat_arr), minidx2)
            if (tmp1 ne 0) or (tmp2 ne 0) then stop
            flux_tmp = [flux_tmp, rbn_map_tmp[minidx1, minidx2]]
          endfor
          if n_elements(flux_tmp) eq 0 then stop
          ENA_Flux[yidx, esa-2, lbidx, ram] = mean(flux_tmp, /nan)
          ; ena flux

          ; IPS proton flux
          sol_p_tmp = SOLAR_P_Flux_Integ[*, *, esa-2]
          for tt = 0, time.length-1 do begin
            tmp = interpol(reform(sol_p_tmp[tt, *]), SOL_LAT_EC, pos_tmp[*, 1])
            P_1AU_Flux[tt, esa-2, lbidx, ram] = mean(tmp, /nan)
          endfor
          ;          if esa eq 5 and lbidx eq 3 then stop
          ; IPS proton flux

        endfor ; sector boundary
      endfor ;  ram
    endfor ; year
  endfor ; esa
  ; store sector averaged flux


  for esa = 2, 6 do begin

    for lbidx = 0, 3 do begin
      ;    lbidx = 3
      ;      esa = 5
      flux1 = ENA_Flux[*, esa-2, lbidx, 0]
      flux1 = flux1-min(flux1)
      flux1 = flux1/max(flux1)
      flux2 = ENA_Flux[*, esa-2, lbidx, 1]
      flux2 = flux2-min(flux2)
      flux2 = flux2/max(flux2)

      win = window(dim = [800, 1400], /buffer)
      win.refresh, /disable
      pos = make_plot_pos(0.1, 0.1, 0.9, 0.9, 2, /col, gap = 0.1)
      p = plot(time_ibex, flux1, pos = pos[*, -1], current = win, co = 'red', symbol = 'o', thick = 3, ytitle = 'Normalized log flux', title = 'ESA'+strcompress(esa, /rem)+', '+sector_name[lbidx], font_size = 15)
      ptmp = plot(time_ibex+0.5, flux2, over = p, co = 'red', symbol = 'X')

      flux_sol = P_1AU_Flux[*, esa-2, lbidx, 1]
      flux_sol = flux_sol-min(flux_sol)
      flux_sol = flux_sol/max(flux_sol)
      ptmp1 = plot(time, flux_sol, over = p, co = 'gray', symbol = 'D')

      ;  ptmp1 = plot(time+2.4, flux_sol, over = p, co = 'green', symbol = 'D')


      time_shift = linspace(0, 10, 100)
      rocc = replicate(!values.f_nan, time_shift.length)
      for tidx = 0, time_shift.length-1 do begin

        flux_tmp = interpol(flux_sol, time+time_shift[tidx], time_ibex)
        res = r_correlate(flux_tmp, flux1)
        rocc[tidx] = res[0]
      endfor


      tmp = max(rocc, mxidx)
      ptmp1 = plot(time+time_shift[mxidx], flux_sol, over = p, co = 'magenta', symbol = 'D')
      p = plot(time_shift, rocc, pos = pos[*, -2], current = win, ytitle = 'ROCC', xtitle = 'time shift [year]', font_size = 15)
      print, 'ESA'+strcompress(esa, /rem), sector_name[lbidx]
      print, time_shift[mxidx]

      a1 = 4.15
      a2 = 0.531
      a3 = 67.3
      sig = (a1-a2 * alog(e_step[esa-2]))^2 * (1 - exp(-a3/e_step[esa-2]))^4.5 * 1e-16
      Tcx = (0.2d * sig * v_step[esa-2] * 1d2)^(-1d) / 60 / 60 / 24 / 365.25d

      Vtravel = sqrt(e_step[esa-2] * 1d3 * 2 / !const.mp *!const.e) /!const.AU * 60d*60d*24d*365.25 ; AU/year
      Ttravel = (time_shift[mxidx])/2d
      D = Ttravel * Vtravel
      print, string(D)+'AU'

      print, 'Tau', Tcx
      Print, 'V', Vtravel
      tx = text(0.5, 0.51, 'dT = '+string(time_shift[mxidx])+'years', font_size = 15, align = 0.5, vertical_align = 0.5)
      tx = text(0.5, 0.48, 'D = '+string(D)+'AU', font_size = 15, align = 0.5, vertical_align = 0.5)

      fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\IPS_FLUX\V-T_20240617\'
      file_mkdir, fpath
      win.refresh
      win.save, fpath + 'ESA'+strcompress(esa, /rem)+ sector_name[lbidx]+'_v20240617.png'
      win.close

    endfor



    sp = spec_plot(reform(SOLAR_P_Flux[*, *, esa-2]), time_long, sol_lat_ec, $
      xr = [ymin, ymax], yr = [-90, 90], /data_log, $
      title = string(e_step[esa-2])+'keV', ytitle = 'Lat_HG', xtitle = 'Year', $
      xminor = 1, xtickinterval = 2, yminor = 2, ytickinterva = 30, font_size = 15);, $
    cb = color_bar(sp, ytitle = 'PSD [s3/m6]', /ylog)

    sp.save, fpath+'SolarProton_'+strcompress(esa, /rem)+'_V-T.png'
    sp.close
    
    sp = spec_plot(10^reform(SOLAR_P_Flux_Integ[*, *, esa-2]), time, sol_lat_ec, $
      xr = [ymin, ymax], yr = [-90, 90], /data_log, $
      title = string(e_step[esa-2])+'keV', ytitle = 'Lat_HG', xtitle = 'Year', $
      xminor = 1, xtickinterval = 2, yminor = 2, ytickinterva = 30, font_size = 15);, $
    ;      data_min = 1e-1, data_max = 1e10)
    ;    cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]', /ylog)
    cb = color_bar(sp, ytitle = 'PSD [s3/m6]', /ylog)

    sp.save, fpath+'SolarProton_Integrated_'+strcompress(esa, /rem)+'_V-T.png'
    sp.close

  endfor







end