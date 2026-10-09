pro example_rcmap_plot_symbol, p, p0, T0, sym_str, co

  B = [227.28, 34.62]
  ns = conv_coord_ec_rc(P0, T0, B[0], B[1])
  ns.lon = ns.lon+180
  p = polarplot(replicate(ns.lat, 2), replicate(ns.lon, 2)*!dtor, symbol = 'D', /sym_filled, over = p, sym_size = 1, sym_color = co)
  tx = text(cos(!dtor*ns.lon)*ns.lat, sin(!dtor*ns.lon)*ns.lat, sym_str, /data, font_size = 12, font_color = co, target = p)
end

pro Example_RCframe_skymap_Paper2_20251031
  Load_IBEX_color_table
  tvlct,red,green,blue,/get

  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  SEPNAME = 'L'
  MAPNAME = 'Theseus'

  fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\SampleMaps\'+VER+'\Paper2\'
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



  ;; TS
  ;  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  ;  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))
  ;
  ;  lon_hp = data.field1
  ;  lat_hp = data.field2
  ;  ts = data.field3
  ;  hs = data.field4
  ;  TRIANGULATE, lon_hp, lat_hp, tr_hp
  ;  hp_dist = ts+hs
  ;  ts_mat = griddata(lon_hp, lat_hp, hp_dist, /natural, /grid, triangles = tr_hp, xout = [1:359:2], yout = [-89:89:2])
  ;
  ;
  ;  res = meshgrid(LON_ARR, lat_arr)
  ;  lat_mat = res.remove()
  ;  lon_mat = res.remove()
  ;  t0 = RC_C_LONLAT[1, 2] ; ecliptic latitude in degree (not colat or polar angle)
  ;  p0 = RC_C_LONLAT[1, 1] ; ecliptic longitude in degree
  ;
  ;
  ;  res = conv_coord_ec_rc(lON_mat, lat_mat+90, p0, t0, /reverse)
  ;  P1 = RES.LON
  ;  T1 = RES.LAT
  ;  LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
  ;  LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)
  ;
  ;  ts_mat = INTERPOLATE(ts_mat, LON_IDX, LAT_IDX, /DOUBLE)
  ;; TS

  res = meshgrid(lon_arr, lat_rc)
  lat_mat = res.remove()
  lon_mat = res.remove()

  res = meshgrid(LON_ARR, lat_arr)
  lat_mat_ec = res.remove()
  lon_mat_ec = res.remove()

  rlim = 120
  lat_no = where(lat_rc gt rlim)

  B = [227.28, 34.62]

  cbmax = [1200,400,150,100,40,15]

  e_step = [0.71,1.11,1.74,2.73,4.29]


  for esa = 2, 6 do begin
    GDF_STR = 'RBN'
    ESA_STR = strcompress(esa, /rem)
    e_str = string(e_step[esa-2], format = '(f4.2)')+' keV'

    survp_ec = survp[*, *, esa-2] ; in ec

    P0 = RC_C_LONLAT[ESA-2, 1] ; rc pos
    T0 = RC_C_LONLAT[ESA-2, 2] ; rc pos

    !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
    !NULL = EXECUTE('peak_pos = [[lon_arr], [reform(ESA'+ESA_STR+'_MOM2_4[0, *])]]')
    !NULL = EXECUTE('peak_pos_stddev = reform(ESA'+ESA_STR+'_MOM2_4_error[0, *])')
    !NULL = EXECUTE('PEAK_FIT = ESA'+ESA_STR+'_PEAK_FIT[*, 1]') ; ellipse fit

    !NULL = EXECUTE('peak_flux = reform(ESA'+ESA_STR+'_FLUX[0, *])')
    major_ax = [[replicate(rc_e_PAR[esa-2, 2]+180, fix(rc_e_PAR[esa-2, 0])+1), replicate(rc_e_PAR[esa-2, 2], fix(rc_e_PAR[esa-2, 0])+1)], [linspace(rc_e_PAR[esa-2, 0], 0, fix(rc_e_PAR[esa-2, 0])+1), linspace(0, rc_e_PAR[esa-2, 0], fix(rc_e_PAR[esa-2, 0])+1)]]
    minor_ax = [[replicate(rc_e_PAR[esa-2, 2]+90, fix(rc_e_PAR[esa-2, 1])+1), replicate(rc_e_PAR[esa-2, 2]-90, fix(rc_e_PAR[esa-2, 1])+1)], [linspace(rc_e_PAR[esa-2, 1], 0, fix(rc_e_PAR[esa-2, 1])+1), linspace(0, rc_e_PAR[esa-2, 1], fix(rc_e_PAR[esa-2, 1])+1)]]

    ; 111111111111111 esa map from rc to ec
    conv = conv_coord_ec_rc(lON_mat, lat_mat-90, P0, T0)
    P1 = conv.LON
    T1 = conv.LAT
    LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
    LAT_IDX = interpol(dindgen(lat_rc.length), lat_rc, T1)

    ESA_MAP = INTERPOLATE(esa_map, LON_IDX, LAT_IDX, /DOUBLE) ; RC -> EC
    ESA_MAP = ESA_MAP/survp_ec

    ; peak pos
    peak_in_ec = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], P0, T0, /REVERSE)
    peak_upper_in_ec = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]-peak_pos_stddev, P0, T0, /REVERSE)
    peak_lower_in_ec = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1]+peak_pos_stddev, P0, T0, /REVERSE)
    Fit_in_ec = conv_coord_ec_rc(peak_pos[*, 0], PEAK_FIT, P0, T0, /REVERSE)
    Major_ax_in_ec = conv_coord_ec_rc(major_ax[*, 0], major_ax[*, 1], P0, T0, /REVERSE)
    Minor_ax_in_ec = conv_coord_ec_rc(minor_ax[*, 0], minor_ax[*, 1], P0, T0, /REVERSE)
    ; 111111111111111 esa map from rc to ec

    ; 222222222222222 ec to b
    res = conv_coord_ec_rc(lon_mat_ec, lat_mat_ec+90, B[0], B[1], /reverse)
    P1 = RES.LON
    T1 = RES.LAT
    LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
    LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

    ESA_MAP_B = INTERPOLATE(ESA_MAP, LON_IDX, LAT_IDX, /DOUBLE)

    ; peak pos
    peak_in_b = conv_coord_ec_rc(peak_in_ec.LON, peak_in_ec.LAT, B[0], B[1])
    peak_in_b = [[peak_in_b.LON + 180], [peak_in_b.LAT]]

    peak_upper_in_B = conv_coord_ec_rc(peak_upper_in_ec.LON, peak_upper_in_ec.LAT, B[0], B[1])
    peak_upper_in_B = [[peak_upper_in_B.LON + 180], [peak_upper_in_B.LAT]]

    peak_lower_in_B = conv_coord_ec_rc(peak_lower_in_ec.LON, peak_lower_in_ec.LAT, B[0], B[1])
    peak_lower_in_B = [[peak_lower_in_B.LON + 180], [peak_lower_in_B.LAT]]

    Fit_in_B = conv_coord_ec_rc(Fit_in_ec.LON, Fit_in_ec.LAT, B[0], B[1])
    Fit_in_B = [[Fit_in_B.LON + 180], [Fit_in_B.LAT]]

    Major_ax_in_B = conv_coord_ec_rc(Major_ax_in_ec.LON, Major_ax_in_ec.LAT, B[0], B[1])
    Major_ax_in_B = [[Major_ax_in_B.LON + 180], [Major_ax_in_B.LAT]]

    Minor_ax_in_B = conv_coord_ec_rc(Minor_ax_in_ec.LON, Minor_ax_in_ec.LAT, B[0], B[1])
    Minor_ax_in_B = [[Minor_ax_in_B.LON + 180], [Minor_ax_in_B.LAT]]
    ; 222222222222222 ec to b

    ESA_MAP_B[*, lat_no] = !values.d_nan

    win = window(dim = [600, 600])
    ;  win.refresh, /disable
    pos = [0.02, 0.05, 0.82, 0.85]

    ; 111111111111111 RC FRAME RIBBON MAP WITH PEAK POSITION
    tx = text((pos[0]+pos[2])/2, 0.90, $
      year+', Ram, E '+e_str+'!CRibbon Map', $
      font_size = 20, alignment = 0.5)


    ext = {start_angle:180, dradii:2, dphi:2, current:win, xtickformat:'(a1)', ytickformat:'(a1)', xr:[rlim, -rlim], yr:[rlim, -rlim]}
    p = plot([0, 0], [0, 0], /nodata, current = win, xtickformat='(a1)', ytickformat='(a1)', xr=[rlim, -rlim], yr=[rlim, -rlim], pos = pos, axis_style = 0)
    pp = pplot(ESA_MAP_B, lat_mat, lon_mat, cal = 'mean', _extra = ext, data_min = 0, data_max = cbmax[esa-1], over = p, pos = pos, rgb_table = [[red],[green],[blue]], /no_earth, axis_style = 0)
    cb = color_bar(pp, ytitle = 'ENA Flux [#/cm2-s-sr-keV]', gap = 0.035)
    for ii = 1, 4 do pp_tmp = polarplot(replicate(30.*ii, 361), findgen(361)*!DTOR, over = pp, co = 'white', thick = 1, linestyle = 1)
    pp_tmp = plot([-rlim, rlim], [0, 0], over = pp, co = 'orange', thick = 1, linestyle = 1)
    pp_tmp = plot([0, 0], [-rlim, rlim], over = pp, co = 'orange', thick = 1, linestyle = 1)

    for ii = 0, 4 do tx = text(30.*ii/sqrt(2), 30.*ii/sqrt(2), string(30.*ii, format = '(I3)')+'$\deg$', /data, font_color = 'white', font_size = 12)


    example_rcmap_plot_symbol, p, p0, T0, 'RC', 'yellow'
    ;    example_rcmap_plot_symbol, p, B[0], B[1], 'B', 'yellow'
    example_rcmap_plot_symbol, p, 255.6, 5.14d, 'Nose', 'yellow'
    example_rcmap_plot_symbol, p, 255, 35, 'V1', 'yellow'
    example_rcmap_plot_symbol, p, 289, -32, 'V2', 'yellow'
    example_rcmap_plot_symbol, p, 0, 90, 'EN', 'yellow'
    example_rcmap_plot_symbol, p, 0, -90, 'ES', 'brown'

    p = polarplot(peak_in_b[*, 1], (peak_in_b[*, 0])*!dtor, symbol = '.', over = p, sym_thick = 3, sym_color = 'magenta', linestyle = 6)
    ;    p = polarplot(peak_upper_in_B[*, 1], (peak_upper_in_B[*, 0])*!dtor, over = p, color = 'red')
    ;    p = polarplot(peak_lower_in_B[*, 1], (peak_lower_in_B[*, 0])*!dtor, over = p, color = 'red')

    win.save, fpath+'01_Coord_Example_Ribbon_Map_'+year+str+'_ENA'+esa_str+'.png'
    win.erase
    ; 111111111111111 RC FRAME RIBBON MAP WITH PEAK POSITION

    ; 222222222222222 PEAK POSITION, STDDEV, FIT
    tx = text((pos[0]+pos[2])/2, 0.90, $
      year+', Ram, E '+e_str+'!CEllipse Fit', $
      font_size = 20, alignment = 0.5)

    rlim = 120
    ext = {start_angle:180, dradii:2, dphi:2, current:win, xtickformat:'(a1)', ytickformat:'(a1)', xr:[rlim, -rlim], yr:[rlim, -rlim]}
    p = plot([0, 0], [0, 0], /nodata, current = win, xtickformat='(a1)', ytickformat='(a1)', xr=[rlim, -rlim], yr=[rlim, -rlim], pos = pos, axis_style = 0)
    for ii = 1, 4 do pp_tmp = polarplot(replicate(30.*ii, 361), findgen(361)*!DTOR, over = p, co = 'black', thick = 1, linestyle = 1)
    pp_tmp = plot([-rlim, rlim], [0, 0], over = p, co = 'orange', thick = 1, linestyle = 1)
    pp_tmp = plot([0, 0], [-rlim, rlim], over = p, co = 'orange', thick = 1, linestyle = 1)

    for ii = 0, 4 do tx = text(30.*ii/sqrt(2), 30.*ii/sqrt(2), string(30.*ii, format = '(I3)')+'$\deg$', /data, font_color = 'black', font_size = 12)


    ;    example_rcmap_plot_symbol, p, p0, T0, 'RC', 'brown'
    ;    example_rcmap_plot_symbol, p, B[0], B[1], 'B', 'brown'
    example_rcmap_plot_symbol, p, 255.6, 5.14d, 'Nose', 'brown'
    example_rcmap_plot_symbol, p, 255, 35, 'V1', 'brown'
    example_rcmap_plot_symbol, p, 289, -32, 'V2', 'brown'
    example_rcmap_plot_symbol, p, 0, 90, 'EN', 'brown'
    example_rcmap_plot_symbol, p, 0, -90, 'ES', 'brown'

    p = polarplot(peak_in_b[*, 1], (peak_in_b[*, 0])*!dtor, symbol = '.', over = p, sym_thick = 3, sym_color = 'black', linestyle = 6)
    p = polarplot(peak_upper_in_B[*, 1], (peak_upper_in_B[*, 0])*!dtor, over = p, color = 'gray', thick = 2)
    p = polarplot(peak_lower_in_B[*, 1], (peak_lower_in_B[*, 0])*!dtor, over = p, color = 'gray', thick = 2)
    p = polarplot(Fit_in_B[*, 1], (Fit_in_B[*, 0])*!dtor, over = p, color = 'magenta', thick = 2)
    p = polarplot(Major_ax_in_B[*, 1], (Major_ax_in_B[*, 0])*!dtor, over = p, color = 'red')
    p = polarplot(Minor_ax_in_B[*, 1], (Minor_ax_in_B[*, 0])*!dtor, over = p, color = 'blue')

    win.save, fpath+'02_Coord_Example_Ribbon_Fit_'+year+str+'_ENA'+esa_str+'.png'
    win.CLOSE
    ; 222222222222222 PEAK POSITION, STDDEV, FIT



    win = window(dim = [800, 600])
    pos = [0.15, 0.1, 0.95, 0.85]
    ; 333333333333333 flux vs peak pos
    sc = scatterplot(peak_flux, peak_pos_stddev, pos = pos, /xlog, /ylog, ytickunit = 'scientific', xtitle = 'Peak Flux [#/cm2-s-sr-keV]', ytitle = 'Peak Pos. Uncertainty [$\deg$]', font_size = 20, symbol = '*', title = year+', Ram, E '+e_str+'!CFlux-P.P. Uncertainty', current = win)
    win.save, fpath+'03_Flux-PP_sig_'+year+str+'_ENA'+esa_str+'_RC.png'
    win.CLOSE
    ; 333333333333333 flux vs peak pos

    
  endfor
stop
end

