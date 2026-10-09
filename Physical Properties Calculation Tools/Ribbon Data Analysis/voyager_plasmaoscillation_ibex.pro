pro Voyager_PlasmaOscillation_IBEX




  ; ribbon data prep
  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  cd, cpath
  SEPNAME = 'L'
  MAPNAME = 'Theseus'


  fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\'+ $
    MAPNAME+'-'+SEPNAME+'_RC_Iteration\'+ver+'\Ribbon_Distance\'
  file_mkdir, fpath

  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  path_str = strsplit(cpath, '\', /extract)
  cd, cpath
  DPATH = strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-'+SEPNAME+'\'


  ; ************************** INPUT **************************
  year_min = 2009
  year_max = 2022
  time_ibex = [year_min:year_mAX]

  ; acquisition time
  frac_year = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
  FOR ram = 0, 1 DO BEGIN
    for yidx = year_min, year_max do begin
      IF ram THEN str = 'ARam' ELSE str = 'Ram'
      year = string(yidx, format = '(I4)')

      RESTORE, dpath +'SAV_'+ver+'\CountRate_Time\' +mapname+'-L_CNT_ACQ_'+year+'_'+str+'.sav'
      for esa = 2, 6 do $
        !null = execute('frac_year[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_FRAC_MAP')
    endfor
  endfor
  ; acquisition time



  rbn_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
  rbn_sig_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram

  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  FOR ram = 0, 1 DO BEGIN
    for yidx = year_min, year_max do begin
      IF ram THEN str = 'ARam' ELSE str = 'Ram'
      survp =  reform(survp_map[*, ram, *, *, *])

      year = string(yidx, format = '(I4)')
      RESTORE, dpath +'SAV_'+ver+'\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'
      for esa = 2, 6 do begin
        !null = execute('rbn_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
        !null = execute('rbn_sig_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_stddev_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
      endfor ; esa
    endfor ; year
  endfor ; ram
  ;  rbn_map_res = alog10(rbn_map_res)


end