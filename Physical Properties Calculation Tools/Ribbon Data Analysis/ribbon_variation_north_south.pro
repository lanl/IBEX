Pro Ribbon_variation_North_South

  MAPNAME = 'Theseus'
  SEPNAME = 'L'
  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  N_SAMPLE = 1000

  path_str = strsplit(cpath, '\', /extract)
  cd, cpath

  !EXCEPT = 0
  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'

  e_step = [0.71,1.11,1.74,2.73,4.29]

  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

  lon_hp = data.field2
  lat_hp = data.field3
  ts = data.field4
  hs = data.field5
  TRIANGULATE, lon_hp, lat_hp, tr_hp
  hp_dist = ts+hs
  ;  hp load
  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  RC_Circ_Funsten2013 = [[0, 0, 0], $
    [0, 0, 0], $
    [74.8, 43.1, 218.5], $
    [73.3, 40.5, 220.3], $
    [73.2, 39.8, 219.6], $
    [74.4, 37.7, 217.9], $
    [79.2, 32.4, 214.2]]

  RC_Ellip_Funsten2013 = [[0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0], $
    [74.9, 73.2, 97.4, 42.2, 219.8], $
    [75.4, 71.0, 111.3, 40.2, 220.6], $
    [74.4, 71.8, 100.0, 39.7, 219.9], $
    [75.7, 70.9, 76.6, 37.6, 218.8], $
    [80.3, 75.7, 65.3, 32.5, 215.5]]



  ; ************************** INPUT **************************

  DPATH = strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-'+SEPNAME+'\'
  FPATH = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\Ribbon_North_South_Mean\'
  file_mkdir, FPATH
  FPATH1 = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\RC_Summary_mom_dist_colored\'
  file_mkdir, FPATH1
  ; ************************** INPUT **************************
  co_y = rgb_vector(14, ct = 33)
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'

  dl = 0
  lonidx1 = [8-dl:8+dl];[7, 8, 9]
  lonidx2 = [108-dl:108+dl];[107, 108, 109]

  for esa = 2, 6 do $
    !NULL = EXECUTE('esa'+strcompress(esa, /rem)+'_RBN_res = replicate(!values.f_nan, 180, 90, 14)')
  ram = 0
  str = 'Ram'
  for yidx = 2009, 2022 do begin
    survp =  reform(survp_map[*, ram, *, *, *])
    year = string(yidx, format = '(I4)')
    RESTORE, dpath +'SAV_'+ver+'\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      !NULL = EXECUTE('esa'+strcompress(esa, /rem)+'_RBN_res[*, *, yidx-2009] = esa'+ESA_STR+'_RBN_map')
    ENDFOR ; ESA

    ;    if yidx eq 2012 or yidx eq 2020 then begin
    ;      sp = spec_plot(esa5_rbn_map, lon_arr, lat_arr, xr = [360, 0])
    ;      p = plot(replicate(lon_arr[lonidx1[0]], 90), lat_arr, over = sp, co = 'magenta', thick = 2)
    ;      p = plot(replicate(lon_arr[lonidx2[0]], 90), lat_arr, over = sp, co = 'magenta', thick = 2)
    ;      p = plot(replicate(lon_arr[lonidx1[-1]], 90), lat_arr, over = sp, co = 'magenta', thick = 2)
    ;      p = plot(replicate(lon_arr[lonidx2[-1]], 90), lat_arr, over = sp, co = 'magenta', thick = 2)
    ;    endif
  endfor

  FOR ESA = 2, 6 DO BEGIN
    ESA_STR = strcompress(esa, /rem)
    !NULL = EXECUTE('esa'+strcompress(esa, /rem)+'_RBN_res = esa'+strcompress(esa, /rem)+'_RBN_res/transpose(survp[*, *, *, esa-2], [1,2,0])')
  ENDFOR ; ESA




  ;  p = plot(replicate(lon_arr[1], 90), lat_arr, over = sp, co = 'magenta', thick = 2)
  ;  p = plot(replicate(lon_arr[110], 90), lat_arr, over = sp, co = 'magenta', thick = 2)

  win = window(dim = [800, 600], /buffer)
  win.refresh, /disable
  ;  win = window(dim = [800, 500])

  for esa = 2, 6 do begin
    tx = text(0.7, 0.82, 'North', font_size = 20)
    !NULL = EXECUTE('esa_tmp = esa'+strcompress(esa, /rem)+'_RBN_res')

    nflux = mean(esa_tmp[lonidx1, *, *], dim =1)
    sflux = mean(esa_tmp[lonidx2, *, *], dim =1)


    yr = [0, max([max(nflux), max(sflux)])*1.2]

    p = plot(lat_arr, nflux[*, 0], co = co_y[*, 0], title = string(e_step[esa-2], format = '(f4.2)')+'keV', font_size = 20, xr = [-90, 90], yr = yr, current = win, pos = [0.15, 0.13, 0.87, 0.90], ytitle = 'Flux [#/cm2-s-sr-keV]', xtitle = 'Lat$_{EC}$ [$\deg$]')

    lon_peak_N = replicate(!values.f_nan, 14)

    tmp = max(reform(nflux[*, 0]), mxidx)
    sc = scatterplot(lat_arr[mxidx], nflux[mxidx, 0], over = p, symbol = '*', sym_color = co_y[*, 0])
    lon_peak_N[0] = lat_arr[mxidx]
    for yidx = 2010, 2022 do begin
      p = plot(lat_arr, nflux[*, yidx-2009], co = co_y[*, yidx-2009], over = p)
      tmp = max(reform(nflux[*, yidx-2009]), mxidx)
      sc = scatterplot(lat_arr[mxidx], nflux[mxidx, yidx-2009], over = p, symbol = '*', sym_color = co_y[*, yidx-2009])
      lon_peak_N[yidx-2009] = lat_arr[mxidx]
    endfor



    tx = text(0.3, 0.82, 'South', font_size = 20)

    lon_peak_S = replicate(!values.f_nan, 14)

    for yidx = 2009, 2022 do begin
      p = plot(lat_arr, sflux[*, yidx-2009], co = co_y[*, yidx-2009], over = p)
      tmp = max(reform(sflux[*, yidx-2009]), mxidx)
      sc = scatterplot(lat_arr[mxidx], sflux[mxidx, yidx-2009], over = p, symbol = 'S', sym_thick = 2, sym_color = co_y[*, yidx-2009])
      lon_peak_S[yidx-2009] = lat_arr[mxidx]
    endfor

    p1 = plot(replicatE(mean(lon_peak_N), 2), yr, over = p, linestyle = 2, thick = 2, co = 'gray')
    p1 = plot(replicatE(mean(lon_peak_S), 2), yr, over = p, linestyle = 2, thick = 2, co = 'gray')

    ;    CB_TMP1 = [2009:2022]
    ;    CB_TMP2 = transpose(REBIN(CB_TMP1, CB_TMP1.length, 3))
    ;    CB = SPEC_PLOT(CB_TMP2, FINDGEN(3), CB_TMP1, title = '                Year', font_size = 12, ybound = [[CB_TMP1-0.5], [CB_TMP1+0.5]], yr = [2008.5, 2022.5], xr = [0, 2], YTICKINTERVAL = 1, YMINOR = 0, XTICKLEN = 0, XTICKFORMAT = '(a1)', YTICKFORMAT = '(a1)', CURRENT = win, POS = [P.POSITION[2]+0.02, P.POSITION[1], P.POSITION[2]+0.04, P.POSITION[3]], rgb_table = 13)
    ;    ax = axis('Y', target = cb, location = 'right', tickfont_size = 12, tickinterval = 1)

    p.xtickname = strcompress(abs(fix(p.xtickname)), /rem)

    win.refresh
    win.save, FPATH+'NS_Comparison_ESA'+strcompress(esa, /rem)+'.png', res = 150
    win.save, FPATH1+'NS_Comparison_ESA'+strcompress(esa, /rem)+'.png', res = 150
    win.erase
  endfor
  win.close

  cd, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate'
  RC_FIT_ELLIPSE_PLOT_rand_20250608
  stop
end