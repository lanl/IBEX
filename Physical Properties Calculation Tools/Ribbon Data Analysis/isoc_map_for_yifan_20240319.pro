pro ISOC_MAP_FOR_YIFAN_20240319


  ;  esa_maps = replicate(!values.f_nan, 60, 30, 2013-2009 +1, 5)
  ;  esa_stddev_maps = replicate(!values.f_nan, 60, 30, 2013-2009 +1, 5)
  ;  for yy = 2009, 2013 do begin
  ;    file = file_search('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\SAV_v20240319\ISOC-L_RBN_SEP_'+strcompress(yy, /rem)+'_Ram.sav')
  ;    restore, file
  ;    for esa = 2, 6 do begin
  ;      !null = execute('esa_maps[*, *, yy-2009, esa-2] = ESA'+strcompress(esa, /rem)+'_RBN_MAP')
  ;      !null = execute('esa_stddev_maps[*, *, yy-2009, esa-2] = ESA'+strcompress(esa, /rem)+'_RBN_STDDEV_MAP')
  ;    endfor
  ;
  ;  endfor
  ;  esa_maps_avg = mean(esa_maps, dim = 3, /nan)
  ;  esa_stddev_maps_avg = sqrt(mean(esa_stddev_maps^2, dim = 3, /nan))
  ;
  ;  for esa = 2, 6 do begin
  ;    openw, lun, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\SAV_v20240319\ISOC_MEAN2009-2013_ESA'+strcompress(esa, /rem)+'.dat', /get_lun
  ;    printf, lun, 'Lon'+string(9B)+'Lat'+string(9B)+'       Flux'+string(9B)+'     STDERR'
  ;    for lo = 0, lon_arr.length-1 do begin
  ;      for la = 0, lat_arr.length-1 do begin
  ;        printf, lun, string(lon_arr[lo], format = '(I3)')+string(9B)+string(lat_arr[la], format = '(I3)')+string(9B)+ $
  ;          string(esa_maps_avg[lo, la, esa-2], format = '(f11.7)')+string(9B)+string(esa_stddev_maps_avg[lo, la, esa-2], format = '(f11.7)')
  ;      endfor ; lat
  ;    endfor ; lon
  ;    free_lun, lun
  ;  endfor
  ;  stop
  ;


  ; princeton isoc
  LON_ARR = [3:360-3:6]
  Lat_ARR = [-90+3:90-3:6]

  esa_maps = replicate(!values.f_nan, 60, 30, 2013-2009 +1, 5)
  esa_stddev_maps = replicate(!values.f_nan, 60, 30, 2013-2009 +1, 5)
  for yy = 2009, 2013 do begin
    file = file_search('U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\ribbonmedian\SAV\IBEX-HI_CG_ram_'+strcompress(yy, /rem)+'.sav')
    restore, file
    for esa = 2, 6 do begin
      !null = execute('esa_maps[*, *, yy-2009, esa-2] = ESA'+strcompress(esa, /rem)+'_RIBBON_FLUX')
      !null = execute('esa_stddev_maps[*, *, yy-2009, esa-2] = SQRT(ESA'+strcompress(esa, /rem)+'_RIBBON_VAR)')
    endfor

  endfor
  esa_maps_avg = mean(esa_maps, dim = 3, /nan)
  esa_stddev_maps_avg = sqrt(mean(esa_stddev_maps^2, dim = 3, /nan))

  for esa = 2, 6 do begin
    openw, lun, 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\ribbonmedian\SAV\ISOC_MEAN2009-2013_ESA'+strcompress(esa, /rem)+'.dat', /get_lun
    printf, lun, 'Lon'+string(9B)+'Lat'+string(9B)+'       Flux'+string(9B)+'     STDERR'
    for lo = 0, lon_arr.length-1 do begin
      for la = 0, lat_arr.length-1 do begin
        printf, lun, string(lon_arr[lo], format = '(I3)')+string(9B)+string(lat_arr[la], format = '(I3)')+string(9B)+ $
          string(esa_maps_avg[lo, la, esa-2], format = '(f11.7)')+string(9B)+string(esa_stddev_maps_avg[lo, la, esa-2], format = '(f11.7)')
      endfor ; lat
    endfor ; lon
    free_lun, lun
  endfor
  stop


end