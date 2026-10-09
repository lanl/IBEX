PRO HP_SURFACE_NORMAL


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
  ;  sp = spec_plot(lon_mat)
  ;  sp = spec_plot(lat_mat)
  ;  sp = spec_plot(hp_mat)

  sph_rect, hp_mat, lat_mat, lon_mat, x = x, y = y, z = z, /to_rect


  sph_rect, 1d, 34.82, 226.99, x = xb, y = yb, z = zb, /to_rect

  B = [xb, yb, zb]
  B_norm = B/sqrt(total(B^2))

  comp1 = replicate(!values.d_nan, 180, 90, 3)
  comp2 = replicate(!values.d_nan, 180, 90, 3)
  surf_norm = replicate(!values.d_nan, 180, 90, 3)
  surf_norm_dot_b = replicate(!values.d_nan, 180, 90)

  win = window(dim = [1000, 600], /buffer)
  win.refresh, /disable
  n_p = 2
  for n_p = 1, 5 do begin
    ;    for ii = n_p, 179-n_p do begin
    ;      for jj = n_p, 89-n_p do begin
    for ii = 0, 179 do begin
      for jj = 0, 89 do begin

        itmp = ii
        jtmp =jj

        i1 = itmp-n_p
        i2 = itmp+n_p
        j1 = jtmp-n_p
        j2 = jtmp+n_p

        if i2 gt 179 then i2 = i2-179
        comp1[ii, jj, *] = [x[i1, jj]-x[i2, jj], y[i1, jj]-y[i2, jj], z[i1, jj]-z[i2, jj]]


        case 1 of
          j2 gt 89: begin
            j2 = 89*2-j2
            itmp = itmp+90
            if itmp gt 179 then itmp = itmp-180
            comp2[ii, jj, *] = [x[ii, j1]-x[itmp, j2], y[ii, j1]-y[itmp, j2], z[ii, j1]-z[itmp, j2]]
          end
          j1 lt 0: begin
            j1 = -j1
            itmp = itmp+90
            if itmp gt 179 then itmp = itmp-180
            comp2[ii, jj, *] = [x[itmp, j1]-x[ii, j2], y[itmp, j1]-y[ii, j2], z[itmp, j1]-z[ii, j2]]
          end
          else: comp2[ii, jj, *] = [x[ii, j1]-x[ii, j2], y[ii, j1]-y[ii, j2], z[ii, j1]-z[ii, j2]]
        endcase

        ;        if j2 gt 89 then begin
        ;          ;          stop
        ;          j2 = 89*2-j2
        ;          itmp = itmp+90
        ;          if itmp gt 179 then itmp = itmp-180
        ;          comp2[ii, jj, *] = [x[ii, j1]-x[itmp, j2], y[ii, j1]-y[itmp, j2], z[ii, j1]-z[itmp, j2]]
        ;        endif else if j1 lt 0 then begin
        ;          ;          stop
        ;          j1 = -j1
        ;          itmp = itmp+90
        ;          if itmp gt 179 then itmp = itmp-180
        ;          comp2[ii, jj, *] = [x[itmp, j1]-x[ii, j2], y[itmp, j1]-y[ii, j2], z[itmp, j1]-z[ii, j2]]
        ;        endif else comp2[ii, jj, *] = [x[ii, j1]-x[ii, j2], y[ii, j1]-y[ii, j2], z[ii, j1]-z[ii, j2]]

        surf_norm[ii, jj, *] = crossp(reform(comp1[ii, jj, *]), reform(comp2[ii, jj, *]))

        sn_tmp = reform(surf_norm[ii, jj, *])
        sn_tmp = sn_tmp/sqrt(total(sn_tmp^2))
        surf_norm_dot_b[ii, jj] = total(sn_tmp*B_norm)
      endfor
    endfor


    ;    for ii = 0, n_p do begin
    ;      for jj = 0, n_p do begin
    ;        comp1[ii, jj, *] = [x[ii-n_p, jj]-x[ii+n_p, jj], y[ii-n_p, jj]-y[ii+n_p, jj], z[ii-n_p, jj]-z[ii+n_p, jj]]
    ;        comp2[ii, jj, *] = [x[ii, jj-n_p]-x[ii, jj+n_p], y[ii, jj-n_p]-y[ii, jj+n_p], z[ii, jj-n_p]-z[ii, jj+n_p]]
    ;        surf_norm[ii, jj, *] = crossp(reform(comp1[ii, jj, *]), reform(comp2[ii, jj, *]))
    ;
    ;        sn_tmp = reform(surf_norm[ii, jj, *])
    ;        sn_tmp = sn_tmp/sqrt(total(sn_tmp^2))
    ;        surf_norm_dot_b[ii, jj] = total(sn_tmp*B_norm)
    ;      endfor
    ;    endfor

    ec_map_single_plot, 1, acos(surf_norm_dot_b)*!RADEG, 0, data_range = [0, 180], cb_title = 'degree', title = 'Angle btw B and S', RT = 70

    loadct, 13
    oplot, 360-[226.99, 226.99], [34.82,34.82], psym = 2, color = 10, thick = 3
    xyouts, 360-226.99, 34.82, 'B', /data, color = 1, charsize=2.0

    oplot, 360-[255.6, 255.6], [5.14,5.14], psym = 2, color = 10, thick = 3
    xyouts, 360-255.6, 5.14, 'Nose', /data, color = 1, charsize=2.0

    oplot, 360-[255.6, 255.6]-180, [-5.14,-5.14], psym = 2, color = 10, thick = 3
    xyouts, 360-255.6-180, -5.14, 'Tail', /data, color = 1, charsize=2.0

    win1 = window(dim = [1200, 1400], /buffer)
    win1.refresh, /disable

    pos = make_plot_pos(0.1, 0.07, 0.9, 0.95, 2, /col, gap = 0.07)
    sp = spec_plot(acos(surf_norm_dot_b)*!RADEG, [1:359:2], [-89:89:2], pos = pos[*, -1], font_size = 20, ytitle = 'Lat$_{EC}$ [$\deg$]', title = 'Angle between !sB!r!u^!n$_{ISM}$ and !ss!r!u^!n', data_min = 0, data_max = 180, xr = [360, 0], yr = [-90, 90], rgb_table = 70, current = win1)
    cb = color_bar(sp, title = 'degree', width = 0.02, font_size = 20)
    sc = scatterplot(226.99, 34.82, symbol = '*', sym_color = 'magenta', sym_size = 1, sym_thick = 3, over = sp)
    tx = text(226.99, 34.82, 'B', font_color = 'magenta', /data, font_size = 20)

    sc = scatterplot(255.6, 5.14, symbol = '*', sym_color = 'green', sym_size = 1, sym_thick = 3, over = sp)
    tx = text(255.6, 5.14, 'Nose', font_color = 'green', /data, font_size = 20)

    sc = scatterplot(255.6-180, -5.14, symbol = '*', sym_color = 'green', sym_size = 1, sym_thick = 3, over = sp)
    tx = text(255.6-180, -5.14, 'Tail', font_color = 'green', /data, font_size = 20)



    Lon_rc = [0:360d]
    lat_rc = replicate(90d, Lon_rc.length)
    TMP = conv_coord_ec_rc(Lon_rc, lat_rc, 226.99, 34.82, /REVERSE)
    lon = tmp.lon
    lat = tmp.lat
    idx = sort(lon)
    p = plot(lon[idx], lat[idx], over = sp, co = 'black', thick = 2, linestyle = 2)
    tx = text(100, 40, '90$\deg$ from B', font_size = 15, /data)

    oplot, 360-lon, lat, color = 1, thick = 2, linestyle = 2
    xyouts, 320, 40, '90 from B', /data, color = 1, charsize=2.0


    Lon_rc = [0:360d]
    lat_rc = replicate(60d, Lon_rc.length)
    TMP = conv_coord_ec_rc(Lon_rc, lat_rc, 226.99, 34.82, /REVERSE)
    lon = tmp.lon
    lat = tmp.lat
    idx = sort(lon)
    p = plot(lon[idx], lat[idx], over = sp, co = 'dark gray', thick = 2, linestyle = 2)
    tx = text(100, 70, '60$\deg$ from B', font_size = 15, /data, co = 'dark gray')

    oplot, 360-lon, lat, color = 250, thick = 2, linestyle = 2
    xyouts, 320, 75, '60 from B', /data, color = 250, charsize=2.0



    ; ENA skymap
    esa_maps_GDF = dblarr(180, 90)
    esa_maps_RBN = dblarr(180, 90)
    esa_maps_TOT = dblarr(180, 90)
    lon_arr = [1:359:2]
    lat_arr = [-89:89:2]

    yidx = 2012
    year = string(yidx, format = '(I4)')
    mf = 1d
    esa = 3
    file_path_csv = 'D:\Data\IBEX_skymaps\Theseus_skymaps_svGP_v20240612\separated_maps\ribbon_cg\ram\data\'
    e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

    file_name_csv = file_search(file_path_csv+'ribbon_cg_ram_'+year+'AB_'+strcompress(esa, /rem)+'.csv')
    sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
    header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

    rbn_tmp = sed_data.FIELD3
    if typename(sed_data.FIELD3) eq 'STRING' then rbn_tmp[where(rbn_tmp eq 'NA', /null)] = 'NaN'

    rbn_sig_tmp = sed_data.FIELD4
    if typename(sed_data.FIELD4) eq 'STRING' then rbn_sig_tmp[where(rbn_sig_tmp eq 'NA', /null)] = 'NaN'

    rbn_tmp = double(rbn_tmp)*mf
    rbn_sig_tmp = double(rbn_sig_tmp)*mf

    file_path_csv = 'D:\Data\IBEX_skymaps\Theseus_skymaps_svGP_v20240612\separated_maps\gdf_cg\ram\data\'
    file_name_csv = file_search(file_path_csv+'gdf_cg_ram_'+year+'AB_'+strcompress(esa, /rem)+'.csv')
    sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
    header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

    gdf_tmp = sed_data.FIELD3
    if typename(sed_data.FIELD3) eq 'STRING' then gdf_tmp[where(gdf_tmp eq 'NA', /null)] = 'NaN'
    gdf_sig_tmp = sed_data.FIELD4
    if typename(sed_data.FIELD4) eq 'STRING' then gdf_sig_tmp[where(gdf_sig_tmp eq 'NA', /null)] = 'NaN'

    gdf_tmp = double(gdf_tmp)*mf
    gdf_sig_tmp = double(gdf_sig_tmp)*mf

    kk = 0
    for ii = 0, lon_arr.length-1 do begin
      for jj = 0, lat_arr.length-1 do begin
        for ll = 2, 6 do begin
          esa_maps_GDF[ii, jj] = gdf_tmp[kk]
          esa_maps_RBN[ii, jj] = rbn_tmp[kk]
        endfor
        kk += 1
      endfor
    endfor

    esa_maps_tot = esa_maps_GDF + esa_maps_RBN
    restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
    survp = reform(SURVP_MAP[yidx-2009, 0, *, *, esa-1])
    sp = spec_plot(esa_maps_RBN/survp, [1:359:2], [-89:89:2], pos = pos[*, -2], font_size = 20, xtitle = 'Lon$_{EC}$ [$\deg$]', ytitle = 'Lat$_{EC}$ [$\deg$]', title = '2022, Ram, ESA 3', data_min = 0, data_max = 100, xr = [360, 0], yr = [-90, 90], rgb_table = 13, current = win1)
    cb = color_bar(sp, title = 'Flux', width = 0.02, font_size = 20)
    sc = scatterplot(226.99, 34.82, symbol = '*', sym_color = 'magenta', sym_size = 1, sym_thick = 3, over = sp)
    tx = text(226.99, 34.82, 'B', font_color = 'magenta', /data, font_size = 20, target = sp)

    sc = scatterplot(255.6, 5.14, symbol = '*', sym_color = 'green', sym_size = 1, sym_thick = 3, over = sp)
    tx = text(255.6, 5.14, 'Nose', font_color = 'green', /data, font_size = 20, target = sp)

    sc = scatterplot(255.6-180, -5.14, symbol = '*', sym_color = 'green', sym_size = 1, sym_thick = 3, over = sp)
    tx = text(255.6-180, -5.14, 'Tail', font_color = 'green', /data, font_size = 20, target = sp)


    Lon_rc = [0:360d]
    lat_rc = replicate(90d, Lon_rc.length)
    TMP = conv_coord_ec_rc(Lon_rc, lat_rc, 226.99, 34.82, /REVERSE)
    lon = tmp.lon
    lat = tmp.lat
    idx = sort(lon)
    p = plot(lon[idx], lat[idx], over = sp, co = 'white', thick = 2, linestyle = 2)
    tx = text(100, 40, '90$\deg$ from B', font_size = 15, /data, co = 'white', target = sp)

    Lon_rc = [0:360d]
    lat_rc = replicate(60d, Lon_rc.length)
    TMP = conv_coord_ec_rc(Lon_rc, lat_rc, 226.99, 34.82, /REVERSE)
    lon = tmp.lon
    lat = tmp.lat
    idx = sort(lon)
    p = plot(lon[idx], lat[idx], over = sp, co = 'gray', thick = 2, linestyle = 2)
    tx = text(100, 70, '60$\deg$ from B', font_size = 15, /data, co = 'gray', target = sp)


    ;

    win1.refresh
    win1.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\Surface_Normal_smooth'+string(n_p, format = '(I1)')+'.png'
    win1.close
    
    write_png,'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\Surface_Normal_smooth'+string(n_p, format = '(I1)')+'_DG.png',tvrd(/true)





    ;3d scatter plot
    pch = PLOT3D(reform(x, 180*90), reform(y, 180*90), reform(z, 180*90),/SYM_FILLED,AXIS_STYLE=2,/PERSPECTIVE, $
      Aspect_Ratio=1, Aspect_Z=1, WINDOW_TITLE='Convex Hull', symbol = '.', linestyle = 6, /nodata, xr = [-400, 400], yr = [-250, 550], zr = [-400, 400])
    mesh_obj, 4, vert1, pol1, ts_mat
    p = polygon(vert1,connectivity=pol1,/data,$
      clip=0,fill_color = 'gray', linestyle = 6, target = pch, transparency = 0)


    mesh_obj, 4, vert, pol, hp_mat

    co = reform(acos(surf_norm_dot_b)*!RADEG, 180*90)
    co = bytscl(co, min = 0, max = 180)
    p = polygon(vert,connectivity=pol,/data,$
      clip=0,rgb_table = 70, vert_colors = co, linestyle = 6, target = pch, transparency = 30)

    p = plot3d([-B_norm[0], B_norm[0]]*700, [-B_norm[1], B_norm[1]]*700, [-B_norm[2], B_norm[2]]*700, over = pch, thick = 2)
    
    pch.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\HPmodel_Surface_Normal_smooth'+string(n_p, format = '(I1)')+'.png'
    pch.close


  endfor



END