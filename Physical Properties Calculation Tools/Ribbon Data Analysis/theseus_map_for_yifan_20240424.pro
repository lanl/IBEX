pro Theseus_MAP_FOR_YIFAN_20240424

  y_end = 2018

  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  survp =  reform(survp_map[*, 0, *, *, *])

  esa_maps = replicate(!values.f_nan, 180, 90, y_end-2009 +1, 5)
  esa_stddev_maps = replicate(!values.f_nan, 180, 90, y_end-2009 +1, 5)
  for yy = 2009, y_end do begin
    file = file_search('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV_svGP_v20240413\Theseus-L_RBN_SEP_'+strcompress(yy, /rem)+'_Ram.sav')
    restore, file
    for esa = 2, 6 do begin
      !null = execute('esa_maps[*, *, yy-2009, esa-2] = ESA'+strcompress(esa, /rem)+'_RBN_MAP/reform(survp[yy-2009, *, *, esa-2])')
      !null = execute('esa_stddev_maps[*, *, yy-2009, esa-2] = ESA'+strcompress(esa, /rem)+'_RBN_STDDEV_MAP/reform(survp[yy-2009, *, *, esa-2])')

    endfor
  endfor
  esa_maps_avg = mean(esa_maps, dim = 3, /nan)
  esa_stddev_maps_avg = sqrt(mean(esa_stddev_maps^2, dim = 3, /nan))

  sp = spec_plot(esa_maps_avg[*, *, 0], lon_Arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', title = 'Theseus!CESA 2', xr = [360, 0], data_min = 0, data_max = 250)
  cb = color_bar(sp, ytitle = 'Flux')

  sp = spec_plot(esa_maps_avg[*, *, 3], lon_Arr, lat_arr, xtitle = 'Lon', ytitle = 'Lat', title = 'Theseus!CESA 5', xr = [360, 0], data_min = 0, data_max = 25)
  cb = color_bar(sp, ytitle = 'Flux')
  
  for esa = 2, 6 do begin
    openw, lun, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV_svGP_v20240413\cgsp_Theseus_MEAN2009-'+string(y_end, format = '(I4)')+'_ESA'+strcompress(esa, /rem)+'.dat', /get_lun
    printf, lun, 'Lon'+string(9B)+'Lat'+string(9B)+'       Flux'+string(9B)+'     STDERR'
    for lo = 0, lon_arr.length-1 do begin
      for la = 0, lat_arr.length-1 do begin
        printf, lun, string(lon_arr[lo], format = '(I3)')+string(9B)+string(lat_arr[la], format = '(I3)')+string(9B)+ $
          string(esa_maps_avg[lo, la, esa-2], format = '(f11.7)')+string(9B)+string(esa_stddev_maps_avg[lo, la, esa-2], format = '(f11.7)')
      endfor ; lat
    endfor ; lon
    free_lun, lun
  endfor
  
end