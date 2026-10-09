pro test_sav_to_csv
  str = 'Ram'

sep = 'L'
  path = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-'+sep+'\TheseusRibbonSep_RC_Peak_Moment_230512\'
  file = path+'Theseus-'+sep+'_RBN_SEP_2011_'+str+'.sav'

  restore, file

  cb_range = fltarr(2, 2, 5)
  ec_str = 'EC'
  esar_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)
  esar_stddev_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)

  esag_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)
  esag_stddev_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)

  FOR ESA = 2, 6 DO BEGIN
    ESA_STR = strcompress(esa, /rem)
    !NULL = EXECUTE('esar_map = ESA'+ESA_STR+'_RBN_MAP')
    !NULL = EXECUTE('esar_stddev_map = ESA'+ESA_STR+'_RBN_STDDEV_MAP')


    !NULL = EXECUTE('esag_map = ESA'+ESA_STR+'_gdf_MAP')
    !NULL = EXECUTE('esag_stddev_map = ESA'+ESA_STR+'_gdf_STDDEV_MAP')


    P0 = RC_C_LONLAT[ESA-2, 1]
    T0 = RC_C_LONLAT[ESA-2, 2]

    ; 111111111111111 esa map from rc to ec
    res = meshgrid(LON_ARR, lat_rc)
    lat_mat = res.remove()
    lon_mat = res.remove()
    conv = conv_coord_ec_rc(lON_mat, lat_mat-90, P0, T0)
    P1 = conv.LON
    T1 = conv.LAT
    ;      T1 = T1-90
    LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
    LAT_IDX = interpol(dindgen(lat_rc.length), lat_rc, T1)
    ESAr_MAP = INTERPOLATE(esar_map, LON_IDX, LAT_IDX, /DOUBLE)
    esar_stddev_map = INTERPOLATE(esar_stddev_map, LON_IDX, LAT_IDX, /DOUBLE)

    ESAg_MAP = INTERPOLATE(esag_map, LON_IDX, LAT_IDX, /DOUBLE)
    esag_stddev_map = INTERPOLATE(esag_stddev_map, LON_IDX, LAT_IDX, /DOUBLE)

    ; 111111111111111 esa map from rc to ec
    esar_maps[*, *, esa-2] = ESAr_MAP
    esar_stddev_maps[*, *, esa-2] = esar_stddev_map

    esag_maps[*, *, esa-2] = ESAg_MAP
    esag_stddev_maps[*, *, esa-2] = esag_stddev_map

  ENDFOR ; ESA

  for esa = 2, 6 do begin
    lon = []
    lat = []
    est_gdf = []
    se_gdf = []
    est_ribbon = []
    se_ribbon = []

    for lo = 0, lon_arr.length-1 do begin
      for la = 0, lat_arr.length-1 do begin
        lon = [lon, lon_arr[lo]]
        lat = [lat, lat_arr[la]]
        est_gdf = [est_gdf, esag_maps[lo, la, esa-2]]
        se_gdf = [se_gdf, esag_stddev_maps[lo, la, esa-2]]
        est_ribbon = [est_ribbon, esar_maps[lo, la, esa-2]]
        se_ribbon = [se_ribbon, esar_stddev_maps[lo, la, esa-2]]
      endfor
    endfor
    stop
    WRITE_CSV, path+'Theseus-L_RBN_SEP_2011_'+str+'_esa'+string(esa, format = '(I1)')+'.csv', lon, lat, est_gdf, se_gdf, est_ribbon, se_ribbon, header = ['lon', 'lat', 'est_gdf', 'se_gdf',  'est_ribbon',  'se_ribbon']
  endfor
  stop

end