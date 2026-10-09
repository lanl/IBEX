Pro Ribbon_Shape_Comp
  win = window(dim = [2000, 2000], /buffer)
  win.refresh, /disable

  win1 = window(dim = [2000, 2000], /buffer)
  win1.refresh, /disable
  for yidx = 2009, 2021 do begin
    year = strcompress(yidx, /rem)

    ver = '230609'
    path = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\TheseusRibbonSep_RC_Peak_Moment_'+ver+'\'
    restore, path + 'Theseus-L_RBN_SEP_'+year+'_Ram.sav'
    otos = [[[ESA2_RBN_MAP]], [[ESA3_RBN_MAP]], [[ESA4_RBN_MAP]], [[ESA5_RBN_MAP]], [[ESA6_RBN_MAP]]]

    ver = '230705'
    path = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\TheseusRibbonSep_RC_Peak_Moment_'+ver+'\'
    restore, path + 'Theseus-L_RBN_SEP_'+year+'_Ram.sav'
    ntos = [[[ESA2_RBN_MAP]], [[ESA3_RBN_MAP]], [[ESA4_RBN_MAP]], [[ESA5_RBN_MAP]], [[ESA6_RBN_MAP]]]

    ver = '230725b'
    path = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\TheseusRibbonSep_RC_Peak_Moment_'+ver+'\'
    restore, path + 'Theseus-L_RBN_SEP_'+year+'_Ram.sav'
    ntns = [[[ESA2_RBN_MAP]], [[ESA3_RBN_MAP]], [[ESA4_RBN_MAP]], [[ESA5_RBN_MAP]], [[ESA6_RBN_MAP]]]

    ver = '230725b'
    fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\'+ver+'\RibbonProfileComp_avg\'
    file_mkdir, fpath

    fpath_p = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\'+ver+'\RibbonProfileComp_point\'
    file_mkdir, fpath_p


    lb_arr = linspace(0, 360, 4+1)
    lb_arr = lb_arr-10
    lidx_tmp = where(lb_arr lt 0, /null, tmp)
    if tmp ne 0 then lb_arr[lidx_tmp] = lb_arr[lidx_tmp]+360

    co_lb = ['black', 'red', 'green', 'blue']
    sector_name = ['Nose', 'North', 'Tail', 'South']

    y = linspace(0.05, 0.95, 6)
    y = reverse(y[0:-2])
    tx = text(0.5, 0.97, year, font_size = 30, align = 0.5, current = win)
    tx = text(0.5, 0.97, year, font_size = 30, align = 0.5, current = win1)
    for esa = 2, 6 do begin
      esa_str = strcompress(esa, /rem)

      pos = make_plot_pos(0.05, y[esa-2], 0.97, y[esa-2]+0.14, 4, /row, gap = 0.03)
      for lbidx = 0, lb_arr.length-2 do begin
        if lbidx eq 0 then $
          lon_idxr1 = where(lon_arr ge lb_arr[lbidx] or lon_arr lt lb_arr[lbidx+1]) else $
          lon_idxr1 = where(lon_arr ge lb_arr[lbidx] and lon_arr lt lb_arr[lbidx+1])

        flux_otos = mean(reform(otos[lon_idxr1, *, esa-2]), dim = 1)
        flux_ntos = mean(reform(ntos[lon_idxr1, *, esa-2]), dim = 1)
        flux_ntns = mean(reform(ntns[lon_idxr1, *, esa-2]), dim = 1)

        if lbidx eq 0 then yt = 'Norm. Flux' else yt = ''

        p = plot(lat_rc, flux_otos/max(flux_otos), pos = pos[*, lbidx], xr = [0, 180], co = 'black', title = year+'ESA'+esa_str+', '+sector_name[lbidx], xtitle = 'Lat_RC', ytitle = yt, font_size = 15, current = win)
        p1 = plot(lat_rc, flux_ntos/max(flux_ntos), over = p, co = 'blue')
        p1 = plot(lat_rc, flux_ntns/max(flux_ntns), over = p, co = 'red')

        flux_otos = reform(otos[lon_idxr1[20], *, esa-2])
        flux_ntos = reform(ntos[lon_idxr1[20], *, esa-2])
        flux_ntns = reform(ntns[lon_idxr1[20], *, esa-2])

        p = plot(lat_rc, flux_otos/max(flux_otos), pos = pos[*, lbidx], xr = [0, 180], co = 'black', title = year+'ESA'+esa_str+', '+sector_name[lbidx]+', RC Lon='+string(lon_arr[lon_idxr1[20]], format = '(I3)')+'$\deg$', xtitle = 'Lat_RC', ytitle = yt, font_size = 15, current = win1)
        p1 = plot(lat_rc, flux_ntos/max(flux_ntos), over = p, co = 'blue')
        p1 = plot(lat_rc, flux_ntns/max(flux_ntns), over = p, co = 'red')


      endfor ; bound
    endfor; esa

    win.refresh
    win.save, fpath+'Summary_'+year+'.png', res = 150
    win.erase

    win1.refresh
    win1.save, fpath_p+'Summary_'+year+'.png', res = 150
    win1.erase
  endfor; year
  win.close
  stop
end