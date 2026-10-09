pro Ribbon_Slice_Profile_Draw, ver, cpath
  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  cd, cpath
  e_step = [0.71,1.11,1.74,2.73,4.29]
  str = 'ram'

  type = ['Symm', 'SkewP', 'SkewN', 'KurtP', 'KurtN']
  ;  ESA = ['4', '5', '2', '4', '5']
  ;  year = ['2012', '2012', '2010', '2013', '2010']
  ;  Lon = [100, 200, 150, 30, 345]

  ESA = ['4', '5', '2', '3', '5']
  year = ['2012', '2015', '2015', '2011', '2011']
  Lon = [318, 300, 350, 32, 340]

  yr = [70, 7, 180, 55, 8];*1.5
  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'
  mapname = 'Theseus'
  sepname = 'L'
  DPATH = dp+mapname+'-'+sepname+'\'

  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'

  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  survp =  reform(survp_map[*, 0, *, *, *])

  for num = 0, type.length-1 do begin

    restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year[num]+'_'+str+'.sav'

    !null = min(abs(lon_arr-lon[num]), lidx)

    !null = execute('esa_map = ESA'+esa[num]+'_RBN_MAP')
    !null = execute('esa_err_map = ESA'+esa[num]+'_RBN_STDDEV_MAP')
    !null = execute('mom_tmp1 = ESA'+esa[num]+'_NUM_MOM')
    !null = execute('mom_tmp2 = ESA'+esa[num]+'_MOM2_4')

    esa_map = esa_map/survp[double(year[num])-2009, *, *, double(esa[num])-2]
    esa_err_map = sqrt(esa_err_map^2/survp[double(year[num])-2009, *, *, double(esa[num])-2])


    slice = reform(esa_map[lidx, *])
    slice_Err = reform(esa_err_map[lidx, *])

    mom = [reform(mom_tmp1[0, lidx]), reform(mom_tmp2[1:3, lidx])]

    win = window(dim = [800, 600], /buffer)
    win.refresh, /disable

    ;  p = plot(lat_rc, slice, xr = [0, 180], thick = 2, font_size = 20, xtitle = 'Lon$_{RC}$ [$\deg$]', ytitle = 'Flux [#/cm2-s-sr-keV]', title = year+', ESA '+esa+', Lon$_{RC}$ = '+string(lon, format = '(I3)')+'$\deg$', current = win, pos = [0.15, 0.13, 0.95, 0.9])

    p = errorplot(lat_rc, slice, slice_Err, xr = [0, 180], yr = [0, yr[num]], thick = 2, font_size = 20, $
      xtitle = 'Polar Angle $\phi$ [$\deg$]', ytitle = 'Flux [#/cm2-s-sr-keV]', title = year[num]+', E '+string(e_step[fix(ESA[num])-2], format = '(f5.2)')+' keV, Lon$_{RC}$ = '+string(lon[num], format = '(I3)')+'$\deg$', current = win, pos = [0.15, 0.13, 0.95, 0.9])
      tx = text(0.65, 0.80, 'Radius: '+string(mom[0], format = '(f6.2)')+'$\deg$', font_size = 15)
    tx = text(0.65, 0.75, 'FWHM: '+string(mom[1], format = '(f6.2)')+'$\deg$', font_size = 15)
    tx = text(0.65, 0.70, 'Skewness: '+string(mom[2], format = '(f5.2)'), font_size = 15)
    tx = text(0.65, 0.65, 'Kurtosis: '+string(mom[3], format = '(f5.2)'), font_size = 15)
    ;  p = errorplot(lat_rc, slice, slice_err, xr = [0, 180])

    fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\SampleMaps\'+VER+'\Ribbon_Slice_Example\'
    file_mkdir, fpath

    win.refresh
    win.save, fpath + type[num] + '_' + year[num] + '_' + str + 'ESA' + esa[num] + '_Lon' + string(lon[num], format = '(I3.3)') + '_112023.png'
    win.close
  endfor
end