PRO HP_polygon_ribbon_overlap


  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

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
  stop
  ;  sp = spec_plot(lon_mat)
  ;  sp = spec_plot(lat_mat)
  ;  sp = spec_plot(hp_mat)

  sph_rect, hp_mat, lat_mat, lon_mat, x = x, y = y, z = z, /to_rect


  sph_rect, 1d, 34.82, 226.99, x = xb, y = yb, z = zb, /to_rect

  B = [xb, yb, zb]
  B_norm = B/sqrt(total(B^2))



  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\TheseusRibbonSep_RC_Peak_Moment_230809\Theseus-L_RBN_SEP_2022_Ram.sav'

  cb_range = fltarr(2, 2, 5)
  ec_str = 'EC'
  FOR GDF = 0, 0 DO BEGIN
    IF GDF EQ 0 THEN GDF_STR = 'GDF'
    IF GDF EQ 1 THEN GDF_STR = 'RBN'
    IF GDF EQ 2 THEN GDF_STR = 'TOT'

    IF STRUPCASE(GDF_STR) EQ 'GDF' THEN cbmax = [1200,250,100,60,25,12]
    IF STRUPCASE(GDF_STR) EQ 'RBN' THEN cbmax = [1200,250,100,60,25,7]
    IF STRUPCASE(GDF_STR) EQ 'TOT' THEN cbmax = [1200,400,200,100,40,15]


    esa_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      IF GDF NE 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
      IF GDF EQ 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_RBN_MAP + ESA'+ESA_STR+'_GDF_MAP')

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
      esa_maps[*, *, esa-2] = ESA_MAP



      ;3d scatter plot
      pch = PLOT3D(reform(x, 180*90), reform(y, 180*90), reform(z, 180*90),/SYM_FILLED,AXIS_STYLE=2,/PERSPECTIVE, $
        Aspect_Ratio=1, Aspect_Z=1, WINDOW_TITLE='Year 2012'+', '+gdf_str+', ESA'+ESA_STR, symbol = '.', linestyle = 6, /nodata, xr = [-400, 400], yr = [-250, 550], zr = [-400, 400], $
        title = 'Year 2012'+', '+gdf_str+', ESA'+ESA_STR, font_size = 15)
      mesh_obj, 4, vert1, pol1, ts_mat
      p = polygon(vert1,connectivity=pol1,/data,$
        clip=0,fill_color = 'gray', linestyle = 6, target = pch, transparency = 0)

      if GDF eq 0 then loc = ts_mat + (hp_mat-ts_mat)/2
      if GDF eq 1 then loc = hp_mat
      if GDF eq 2 then loc = hp_mat

      mesh_obj, 4, vert, pol, loc
      co = reform(esa_maps[*, *, esa-2], 180*90)
      co = bytscl(co, min = 0, max = cbmax[esa-1])
      p = polygon(vert,connectivity=pol,/data,$
        clip=0,rgb_table = 13, vert_colors = co, linestyle = 6, target = pch, transparency = 30)
      p = plot3d([-B_norm[0], B_norm[0]]*700, [-B_norm[1], B_norm[1]]*700, [-B_norm[2], B_norm[2]]*700, over = pch, thick = 2)
      pch.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\skymap_example1.png'

    ENDFOR ; ESA
  ENDFOR ; GDF
  stop








END