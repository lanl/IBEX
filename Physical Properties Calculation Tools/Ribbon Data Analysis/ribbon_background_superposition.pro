Pro Ribbon_Background_Superposition, YIDX, MAPNAME, SEPNAME, ver, cpath, N_SAMPLE
  MAPNAME = 'Theseus'
  SEPNAME = 'L'
  ver = 'svGP_v20240413'; 'svGP_v20250323_patialfit' ;'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
stop
  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'
  DPATH = dp+MAPNAME+'-'+SEPNAME+'\'

  for sub = 0, 1 do begin

    if sub eq 1 then fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\ribbon_maps\'
    if sub eq 0 then fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\ribbon_maps\OriginalMaps\'
    file_mkdir, fpath

    lon_arr = [1:359:2]
    lat_arr = [-89:89:2]

    GDF_FLUX = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)
    GDF_stddev = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)

    Ribbon_FLUX = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)
    Ribbon_stddev = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)

    TOTAL_FLUX = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)
    TOTAL_stddev = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)

    win = window(dim = [800, 400], /buffer)
    win.refresh, /disable

    win1 = window(dim = [800, 400*14], /buffer)
    win1.refresh, /disable
    pos = make_plot_pos(0.1, 0.02, 0.94, 0.99, 14, /col, gap = 0.012)
    FOR yy = 2009, 2022 do begin
      file = file_search(DPATH+'SAV_GAM_v20240413\Theseus-L_RBN_SEP_'+string(yy, format = '(I4)')+'_Ram.sav')
      restore, file
      FOR ESA = 2, 6 DO BEGIN
        !NULL = EXECUTE('RIBBON_FLUX[*, *, YY-2009, ESA-2] = ESA'+STRING(ESA, FORMAT = '(I1)')+'_RBN_MAP')
        !NULL = EXECUTE('RIBBON_stddev[*, *, YY-2009, ESA-2] = ESA'+STRING(ESA, FORMAT = '(I1)')+'_RBN_STDDEV_MAP')
        !NULL = EXECUTE('GDF_FLUX[*, *, YY-2009, ESA-2] = ESA'+STRING(ESA, FORMAT = '(I1)')+'_GDF_MAP')
        !NULL = EXECUTE('GDF_stddev[*, *, YY-2009, ESA-2] = ESA'+STRING(ESA, FORMAT = '(I1)')+'_GDF_STDDEV_MAP')
        !NULL = EXECUTE('TOTAL_FLUX[*, *, YY-2009, ESA-2] = ESA'+STRING(ESA, FORMAT = '(I1)')+'_GDF_MAP + ESA'+STRING(ESA, FORMAT = '(I1)')+'_RBN_MAP')
        !NULL = EXECUTE('TOTAL_stddev[*, *, YY-2009, ESA-2] = SQRT(ESA'+STRING(ESA, FORMAT = '(I1)')+'_GDF_STDDEV_MAP^2 + ESA'+STRING(ESA, FORMAT = '(I1)')+'_RBN_STDDEV_MAP^2)')
      ENDFOR
    ENDFOR

    ribbon_flux_min = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 5)
    ribbon_flux_max = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 5)
    for esa = 2, 6 do begin
      ribbon_flux_min[*, *, esa-2] = min(RIBBON_FLUX[*, *, *, esa-2], dim = 3)
      ribbon_flux_max[*, *, esa-2] = max(RIBBON_FLUX[*, *, *, esa-2], dim = 3)




      if sub eq 1 then mx = max(RIBBON_FLUX[*, *, *, esa-2]-rebin(ribbon_flux_min[*, *, esa-2], lon_arr.length, lat_arr.length, 14))
      if sub eq 0 then mx = max(RIBBON_FLUX[*, *, *, esa-2])

      if sub eq 1 then begin
        sp = spec_plot(ribbon_flux_min[*, *, esa-2], lon_arr, lat_arr, xr = [360, 0], current = win, font_size = 13, xtitle = 'Lon$_{EC}$', ytitle = 'Lat$_{EC}$', title = 'ESA'+strcompress(esa, /rem)+', '+strcompress(yy, /rem), data_min = 0, data_max = max(ribbon_flux_min[*, *, esa-2]), pos = [0.1, 0.11, 0.9, 0.91])
        cb = color_bar(sp, gap = 0.02, width = 0.02, title = 'Flux')
        win.refresh
        win.save, fpath+'_ESA'+strcompress(esa, /rem)+'_baseline.png', res = 150
        win.erase

        sp = spec_plot(ribbon_flux_max[*, *, esa-2], lon_arr, lat_arr, xr = [360, 0], current = win, font_size = 13, xtitle = 'Lon$_{EC}$', ytitle = 'Lat$_{EC}$', title = 'ESA'+strcompress(esa, /rem)+', '+strcompress(yy, /rem), data_min = 0, data_max = max(ribbon_flux_max[*, *, esa-2]), pos = [0.1, 0.11, 0.9, 0.91])
        cb = color_bar(sp, gap = 0.02, width = 0.02, title = 'Flux')
        win.refresh
        win.save, fpath+'_ESA'+strcompress(esa, /rem)+'_MaxFlux.png', res = 150
        win.erase
      endif

      for yy = 2009, 2022 do begin
        if sub eq 1 then sp = spec_plot(RIBBON_FLUX[*, *, yy-2009, esa-2]-ribbon_flux_min[*, *, esa-2], lon_arr, lat_arr, xr = [360, 0], current = win, font_size = 13, xtitle = 'Lon$_{EC}$', ytitle = 'Lat$_{EC}$', title = 'ESA'+strcompress(esa, /rem)+', '+strcompress(yy, /rem), data_min = 0, data_max = mx, pos = [0.1, 0.11, 0.9, 0.91])
        if sub eq 0 then sp = spec_plot(RIBBON_FLUX[*, *, yy-2009, esa-2], lon_arr, lat_arr, xr = [360, 0], current = win, font_size = 13, xtitle = 'Lon$_{EC}$', ytitle = 'Lat$_{EC}$', title = 'ESA'+strcompress(esa, /rem)+', '+strcompress(yy, /rem), data_min = 0, data_max = mx, pos = [0.1, 0.11, 0.9, 0.91])
        cb = color_bar(sp, gap = 0.02, width = 0.02, title = 'Flux')
        win.refresh
        win.save, fpath+'ESA'+strcompress(esa, /rem)+'_'+strcompress(yy, /rem)+'.png', res = 150
        win.erase
      endfor

      for yy = 2009, 2022 do begin
        if sub eq 1 then sp = spec_plot(RIBBON_FLUX[*, *, yy-2009, esa-2]-ribbon_flux_min[*, *, esa-2], lon_arr, lat_arr, xr = [360, 0], current = win1, font_size = 13, xtitle = 'Lon$_{EC}$', ytitle = 'Lat$_{EC}$', title = 'ESA'+strcompress(esa, /rem)+', '+strcompress(yy, /rem), data_min = 0, data_max = mx, pos = pos[*, -1-(yy-2009)])
        if sub eq 0 then sp = spec_plot(RIBBON_FLUX[*, *, yy-2009, esa-2], lon_arr, lat_arr, xr = [360, 0], current = win1, font_size = 13, xtitle = 'Lon$_{EC}$', ytitle = 'Lat$_{EC}$', title = 'ESA'+strcompress(esa, /rem)+', '+strcompress(yy, /rem), data_min = 0, data_max = mx, pos = pos[*, -1-(yy-2009)])
        cb = color_bar(sp, gap = 0.01, width = 0.01, title = 'Flux')
      endfor
      win1.refresh
      win1.save, fpath+'ESA'+strcompress(esa, /rem)+'_Summary.png', res = 150
      win1.erase
    endfor
    win.close
    win1.close
  endfor
end