pro Example_RCframe_skymap, MAPNAME, SEPNAME, VER, cpath
  Load_IBEX_color_table
  tvlct,red,green,blue,/get


  ;  MAPNAME = 'Theseus'
  ;  SEPNAME = 'L'
  ;  VER = '240308_GAM' ; 230223c --> rcfit bug fixed, gaussian random sampling
  ;  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\'
  fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\SampleMaps\'+VER+'\'
  file_mkdir, fpath

  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'


  DPATH = dp+MAPNAME+'-'+SEPNAME+'\'
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'

  str = 'Ram'
  yidx = 2012
  year = string(yidx, format = '(I4)')


  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'

  survp =  reform(survp_map[yidx-2009, 0, *, *, *])


  restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'


  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

  lon_hp = data.field1
  lat_hp = data.field2
  ts = data.field3
  hs = data.field4
  TRIANGULATE, lon_hp, lat_hp, tr_hp
  hp_dist = ts+hs
  ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, /grid, triangles = tr_hp, xout = [1:359:2], yout = [-89:89:2])


  res = meshgrid(LON_ARR, lat_arr)
  lat_mat = res.remove()
  lon_mat = res.remove()
  t0 = RC_C_LONLAT[1, 2] ; ecliptic latitude in degree (not colat or polar angle)
  p0 = RC_C_LONLAT[1, 1] ; ecliptic longitude in degree


  res = conv_coord_ec_rc(lON_mat, lat_mat+90, p0, t0, /reverse)
  P1 = RES.LON
  T1 = RES.LAT
  LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
  LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

  ts_mat = INTERPOLATE(ts_mat, LON_IDX, LAT_IDX, /DOUBLE)


  ;  win = window(dim = [600, 600])
  ;  ;  win.refresh, /disable
  ;  pos = [0.02, 0.1, 0.82, 0.9]
  ;
  ;  tx = text((pos[0]+pos[2])/2, 0.95, $
  ;    'HP distance', $
  ;    font_size = 18, alignment = 0.5)
  ;
  ;  rlim = 120
  ;  ext = {start_angle:180, dradii:2, dphi:2, current:win, xtickformat:'(a1)', ytickformat:'(a1)', xr:[rlim, -rlim], yr:[rlim, -rlim]}
  ;  p = plot([0, 0], [0, 0], /nodata, current = win, xtickformat='(a1)', ytickformat='(a1)', xr=[rlim, -rlim], yr=[rlim, -rlim], pos = pos, axis_style = 0)
  ;  pp = pplot(ts_mat, lat_mat, lon_mat, cal = 'mean', _extra = ext, data_min = 0, data_max = 500, over = p, pos = pos, rgb_table = [[red],[green],[blue]], /no_earth, axis_style = 0)
  ;  cb = color_bar(pp, ytitle = 'HP distance [AU]')
  ;  for ii = 1, 4 do pp_tmp = polarplot(replicate(30.*ii, 361), findgen(361)*!DTOR, over = pp, co = 'white', thick = 1, linestyle = 1)
  ;  pp_tmp = plot([-rlim, rlim], [0, 0], over = pp, co = 'orange', thick = 1, linestyle = 1)
  ;  pp_tmp = plot([0, 0], [-rlim, rlim], over = pp, co = 'orange', thick = 1, linestyle = 1)
  ;
  ;  win.save, fpath+'HP_Distance1.png'
  ;  win.close
  ;  stop



  res = meshgrid(lon_arr, lat_rc)
  lat_mat = res.remove()
  lon_mat = res.remove()

  lat_no = where(lat_rc gt 120)


  cbmax = [1200,400,150,100,40,15]

  for esa = 2, 6 do begin
    GDF_STR = 'RBN'
    ESA_STR = strcompress(esa, /rem)


    survp_tmp = survp[*, *, esa-2] ; in ec
    P0 = RC_C_LONLAT[ESA-2, 1]
    T0 = RC_C_LONLAT[ESA-2, 2]

    ; 111111111111111 esa map from rc to ec
    conv = conv_coord_ec_rc(lON_mat, lat_mat-90, P0, T0)
    P1 = conv.LON
    T1 = conv.LAT
    LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
    LAT_IDX = interpol(dindgen(lat_rc.length), lat_rc, T1)
    survp_tmp = INTERPOLATE(survp_tmp, LON_IDX, LAT_IDX, /DOUBLE)
    ; 111111111111111 esa map from rc to ec

    !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
    esa_map = esa_map/survp_tmp
    esa_map[*, lat_no] = !values.d_nan


    win = window(dim = [600, 600])
    ;  win.refresh, /disable
    pos = [0.02, 0.1, 0.82, 0.9]


    tx = text((pos[0]+pos[2])/2, 0.95, $
      ''+year+', Ram, ESA'+ESA_STR+', RC frame', $
      font_size = 18, alignment = 0.5)

    rlim = 120
    ext = {start_angle:180, dradii:2, dphi:2, current:win, xtickformat:'(a1)', ytickformat:'(a1)', xr:[rlim, -rlim], yr:[rlim, -rlim]}
    p = plot([0, 0], [0, 0], /nodata, current = win, xtickformat='(a1)', ytickformat='(a1)', xr=[rlim, -rlim], yr=[rlim, -rlim], pos = pos, axis_style = 0)
    pp = pplot(esa_map, lat_mat, lon_mat, cal = 'mean', _extra = ext, data_min = 0, data_max = cbmax[esa-1], over = p, pos = pos, rgb_table = [[red],[green],[blue]], /no_earth, axis_style = 0)
    cb = color_bar(pp, ytitle = 'ENA Flux [#/cm2-s-sr-keV]', gap = 0.035)
    for ii = 1, 4 do pp_tmp = polarplot(replicate(30.*ii, 361), findgen(361)*!DTOR, over = pp, co = 'white', thick = 1, linestyle = 1)
    pp_tmp = plot([-rlim, rlim], [0, 0], over = pp, co = 'orange', thick = 1, linestyle = 1)
    pp_tmp = plot([0, 0], [-rlim, rlim], over = pp, co = 'orange', thick = 1, linestyle = 1)

    win.save, fpath+'Coord_Example_'+year+str+'_ENA'+esa_str+'_RC_WOGRID.png'

    for ii = 0, 4 do tx = text(30.*ii/sqrt(2), 30.*ii/sqrt(2), string(30.*ii, format = '(I3)')+'$\deg$', /data, font_color = 'white', font_size = 12)

    rc =  RC_e_LONLAT[1, [1:2]]
    ;259, 5
    ns = conv_coord_ec_rc(259, 5, rc[0], rc[1])
    ns.lon = ns.lon+180
    p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'D', over = p, sym_size = 1, sym_color = 'yellow')
    tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'Nose', /data, font_size = 12, font_color = 'yellow')

    ns = conv_coord_ec_rc(255, 35, rc[0], rc[1])
    ns.lon = ns.lon+180
    p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'D', over = p, sym_size = 1, sym_color = 'yellow')
    tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V1', /data, font_size = 12, font_color = 'yellow')

    ns = conv_coord_ec_rc(289, -32, rc[0], rc[1])
    ns.lon = ns.lon+180
    p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'D', over = p, sym_size = 1, sym_color = 'yellow')
    tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, 'V2', /data, font_size = 12, font_color = 'yellow')

    en = conv_coord_ec_rc(0, 90, rc[0], rc[1])
    en.lon = en.lon+180
    p = polarplot(replicate(en.lat, 2), replicate(en.lon, 2)*!dtor, symbol = 'D', over = p, sym_size = 1, sym_color = 'yellow')
    tx = text(cos(!dtor*en.lon)*en.lat, sin(!dtor*en.lon)*en.lat, 'EN', /data, font_size = 12, font_color = 'yellow')

    en = conv_coord_ec_rc(0, -90, rc[0], rc[1])
    en.lon = en.lon+180
    p = polarplot(replicate(en.lat, 2), replicate(en.lon, 2)*!dtor, symbol = 'D', over = p, sym_size = 1, sym_color = 'brown')
    tx = text(cos(!dtor*en.lon)*en.lat, sin(!dtor*en.lon)*en.lat, 'ES', /data, font_size = 12, font_color = 'brown')

    ;  p = polarplot(ESA3_PEAK_POS, (lon_arr+180)*!dtor, over = p, sym_size = 1, sym_color = 'black', symbol = '*', linestyle = 6)

    win.save, fpath+'Coord_Example_'+year+str+'_ENA'+esa_str+'_RC.png'
    win.close


    ; ec frame

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
    ESA_MAP = ESA_MAP/survp_tmp
    ; 111111111111111 esa map from rc to ec

    ec_map_single_plot, esa, ESA_MAP, 1, 'RBN'

    !NULL = EXECUTE('peak_pos = [[lon_arr], [ESA'+ESA_STR+'_PEAK_POS]]')
    TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], p0, t0, /REVERSE)
    ;    oplot, 360-tmp.lon, tmp.lat, psym = 2, color = 1

    oplot, replicate(360-259, 2), replicate(5, 2), psym = 4, color = 170
    xyouts, 360-259, 5, 'Nose', /data, color = 170, charsize=2.0

    oplot, replicate(360-(259-180), 2), replicate(-5, 2), psym = 4, color = 170
    xyouts, 360-(259-180), -5, 'Tail', /data, color = 170, charsize=2.0

    oplot, replicate(360-RC_C_LONLAT[esa-2, 1], 2), replicate(RC_C_LONLAT[esa-2, 2], 2), psym = 4, color = 170
    xyouts, 360-RC_C_LONLAT[esa-2, 1], RC_C_LONLAT[esa-2, 2], 'RC', /data, color = 170, charsize=2.0

    oplot, replicate(360-255, 2), replicate(35, 2), psym = 4, color = 170
    xyouts, 360-255, 35, 'V1', /data, color = 170, charsize=2.0

    oplot, replicate(360-289, 2), replicate(-32, 2), psym = 4, color = 170
    xyouts, 360-289, -32, 'V2', /data, color = 170, charsize=2.0



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


    write_png, fpath+'Coord_Example_'+year+str+'_ENA'+esa_str+'_EC.png',tvrd(/true)
    wdelete, 0

  endfor

end

