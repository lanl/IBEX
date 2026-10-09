pro sample_mapplot



  MAPNAME = 'Theseus'
  SEPNAME = 'L'
  VER = '230418' ; 230223c --> rcfit bug fixed, gaussian random sampling
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\'


  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'


  DPATH = dp+MAPNAME+'-'+SEPNAME+'\'
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'

  str = 'Ram'
  yidx = 2010
  year = string(yidx, format = '(I4)')

  restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

  ec_str = 'EC'
  GDF_STR = 'RBN'

  ESA = 3
  
  for esa = 2, 6 do begin
  ESA_STR = strcompress(esa, /rem)
  !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')

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
  ESA_MAP = INTERPOLATE(esa_map, LON_IDX, LAT_IDX, /DOUBLE)
  ; 111111111111111 esa map from rc to ec

  ec_map_single_plot, esa, ESA_MAP, 1, title = year+str+', ESA'+esa_str

  !NULL = EXECUTE('peak_pos = [[lon_arr], [ESA'+ESA_STR+'_PEAK_POS]]')
  TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], p0, t0, /REVERSE)
  oplot, 360-tmp.lon, tmp.lat, psym = 2, color = 1

  oplot, replicate(360-259, 2), replicate(5, 2), psym = 4, color = 170
  xyouts, 360-259, 5, 'Nose', /data, color = 170, charsize=2.0

  oplot, replicate(360-(259-180), 2), replicate(-5, 2), psym = 4, color = 170
  xyouts, 360-(259-180), -5, 'Tail', /data, color = 170, charsize=2.0

  oplot, replicate(360-RC_C_LONLAT[esa-2, 1], 2), replicate(RC_C_LONLAT[esa-2, 2], 2), psym = 4, color = 170
  xyouts, 360-RC_C_LONLAT[esa-2, 1], RC_C_LONLAT[esa-2, 2], 'RC', /data, color = 170, charsize=2.0

  ;  oplot, replicate(360-259, 2), replicate(5, 2), psym = 4, color = 170
  ;  xyouts, 360-255, 35, 'V1', /data, color = 170, charsize=2.0



  BV = map_2points(259d, 5d, p0, t0, npath = 1000)
  oplot, 360-BV[0, *], BV[1, *], color = 170


  BV11 = map_2points(0, -90, RC_C_LONLAT[esa-2, 1], RC_C_LONLAT[esa-2, 2], npath = 1000)
  oplot, 360-BV11[0, *], BV11[1, *], color = 255
  BV12 = map_2points(0, 90, RC_C_LONLAT[esa-2, 1], RC_C_LONLAT[esa-2, 2], npath = 1000)
  oplot, 360-BV12[0, *], BV12[1, *], color = 255

  bv11_rc = conv_coord_ec_rc(BV11[0, *], BV11[1, *], p0, t0)
  bv12_rc = conv_coord_ec_rc(BV12[0, *], BV12[1, *], p0, t0)

  xx = linspace(0, 180, 1000)
  bv0_RC = conv_coord_ec_rc(replicate(0, xx.length), xx, p0, t0, /reverse)
  oplot, 360-bv0_RC.lon, bv0_RC.lat, color = 180
  bv1_RC = conv_coord_ec_rc(replicate(180, xx.length), xx, p0, t0, /reverse)
  oplot, 360-bv1_RC.lon, bv1_RC.lat, color = 180
  bv2_RC = conv_coord_ec_rc(replicate(90, xx.length), xx, p0, t0, /reverse)
  oplot, 360-bv2_RC.lon, bv2_RC.lat, color = 180
  bv3_RC = conv_coord_ec_rc(replicate(270, xx.length), xx, p0, t0, /reverse)
  oplot, 360-bv3_RC.lon, bv3_RC.lat, color = 180
  

  write_png, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\SampleMaps\Coord_Example_'+year+str+'_ENA'+esa_str+'.png',tvrd(/true)
  wdelete, 0
  
  endfor
  
  stop
  ;
  BV_rc = conv_coord_ec_rc(BV[0, *], BV[1, *], p0, t0)

  bv11_rc = conv_coord_ec_rc(BV11[0, *], BV11[1, *], p0, t0)
  bv12_rc = conv_coord_ec_rc(BV12[0, *], BV12[1, *], p0, t0)

  bv21_rc = conv_coord_ec_rc(BV21[0, *], BV21[1, *], p0, t0)
  bv22_rc = conv_coord_ec_rc(BV22[0, *], BV22[1, *], p0, t0)
  stop


  pp = polarplot(bv11_rc.lat, bv11_rc.lon*!DTOR, sym_color = 'blue', symbol = '.', linestyle = 0, xr = [-120, 120], yr = [-120, 120])
  pp = polarplot(bv12_rc.lat, bv12_rc.lon*!DTOR, sym_color = 'blue', symbol = '.', linestyle = 0, xr = [-120, 120], yr = [-120, 120], over = pp)

  pp = polarplot(bv21_rc.lat, bv21_rc.lon*!DTOR, sym_color = 'red', symbol = '.', linestyle = 0, xr = [-120, 120], yr = [-120, 120], over = pp)
  pp = polarplot(bv22_rc.lat, bv22_rc.lon*!DTOR, sym_color = 'red', symbol = '.', linestyle = 0, xr = [-120, 120], yr = [-120, 120], over = pp)

  pp = polarplot(bv_rc.lat, bv_rc.lon*!DTOR, sym_color = 'orange', symbol = '.', linestyle = 0, xr = [-120, 120], yr = [-120, 120], over = pp)

  stop
  ;  TMP1 = conv_coord_ec_rc(TMP.lon, TMP.lat, p0, t0)
  ;  pp = polarplot(TMP1.lat, TMP1.lon*!DTOR, symbol = '*', linestyle = 0)


end