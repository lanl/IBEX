pro ibex_theseus_flux

  lon_arr = [1:359:2]
  lat_arr = [-89:89:2]

  GDF_FLUX = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)
  GDF_stddev = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)

  Ribbon_FLUX = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)
  Ribbon_stddev = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)

  TOTAL_FLUX = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)
  TOTAL_stddev = replicate(!values.f_nan, lon_arr.length, lat_arr.length, 14, 5)


  FOR yy = 2009, 2022 do begin
    file = file_search('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV_GAM_v20240413\Theseus-L_RBN_SEP_'+string(yy, format = '(I4)')+'_Ram.sav')
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

  V2 = [289, -32]

  lonidx = value_locate(lon_arr, V2[0])
  latidx = value_locate(lat_arr, V2[1])

  gdf_flux_v2 = reform(GDF_Flux[lonidx, latidx, *, *])
  gdf_stddev_v2 = reform(GDF_stddev[lonidx, latidx, *, *])

  RBN_flux_v2 = reform(RIBBON_Flux[lonidx, latidx, *, *])
  RBN_stddev_v2 = reform(RIBBON_stddev[lonidx, latidx, *, *])

  TOT_flux_v2 = reform(TOTAL_Flux[lonidx, latidx, *, *])
  TOT_stddev_v2 = reform(TOTAL_stddev[lonidx, latidx, *, *])

  openw, lun, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ForJeongbhin\GDF_AT_V2.txt', /get_lun
  str_wrt = 'Year'+string(9B)
  for esa = 2, 6 do !null = execute('str_wrt = str_wrt + "Flux_ESA'+string(esa, format = '(I1)')+'[#/cm2-sr-s-keV]"+string(9B)+"Uncertainty_ESA'+string(esa, format = '(I1)')+'[#/cm2-sr-s-keV]"+string(9B)')
  printf, lun, str_wrt
  for yy = 2009, 2022 do begin
    str_wrt = string(yy, format = '(I4)')+string(9B)
    for esa = 2, 6 do str_wrt = str_wrt + string(gdf_flux_v2[yy-2009, esa-2])+string(9B)+string(gdf_stddev_v2[yy-2009, esa-2])+string(9B)
    printf, lun, str_wrt
  endfor
  free_lun, lun


  openw, lun, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ForJeongbhin\RBN_AT_V2.txt', /get_lun
  str_wrt = 'Year'+string(9B)
  for esa = 2, 6 do !null = execute('str_wrt = str_wrt + "Flux_ESA'+string(esa, format = '(I1)')+'[#/cm2-sr-s-keV]"+string(9B)+"Uncertainty_ESA'+string(esa, format = '(I1)')+'[#/cm2-sr-s-keV]"+string(9B)')
  printf, lun, str_wrt
  for yy = 2009, 2022 do begin
    str_wrt = string(yy, format = '(I4)')+string(9B)
    for esa = 2, 6 do str_wrt = str_wrt + string(RBN_flux_v2[yy-2009, esa-2])+string(9B)+string(RBN_stddev_v2[yy-2009, esa-2])+string(9B)
    printf, lun, str_wrt
  endfor
  free_lun, lun

  openw, lun, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ForJeongbhin\TOT_AT_V2.txt', /get_lun
  str_wrt = 'Year'+string(9B)
  for esa = 2, 6 do !null = execute('str_wrt = str_wrt + "Flux_ESA'+string(esa, format = '(I1)')+'[#/cm2-sr-s-keV]"+string(9B)+"Uncertainty_ESA'+string(esa, format = '(I1)')+'[#/cm2-sr-s-keV]"+string(9B)')
  printf, lun, str_wrt
  for yy = 2009, 2022 do begin
    str_wrt = string(yy, format = '(I4)')+string(9B)
    for esa = 2, 6 do str_wrt = str_wrt + string(TOT_flux_v2[yy-2009, esa-2])+string(9B)+string(TOT_stddev_v2[yy-2009, esa-2])+string(9B)
    printf, lun, str_wrt
  endfor
  free_lun, lun



  stop


end