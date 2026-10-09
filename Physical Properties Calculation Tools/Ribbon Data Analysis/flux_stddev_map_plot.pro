pro ec_to_rc_tmp, esa_map, lon_Arr, lat_rc, p0, t0

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
end

pro flux_stddev_map_plot

  fpath = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Map_flux_stddev_230416

  year = 2009
  ystr = string(year, format = '(I4)')
  str = 'Ram'
  ESA = 3


  for midx = 0, 1 do begin
    for sidx = 0, 1 do begin
      if midx eq 0 and sidx eq 0 then continue
      if midx eq 0 then map_name = 'ISOC' else map_name = 'Theseus'
      if sidx eq 0 then Sep_name = 'D' else Sep_name = 'L'
      fstr = '' ; '_stddev'
      file = file_search('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\' $
        +map_name+'-'+Sep_name+'\'+map_name+'RibbonSep_RC_Peak_Moment_230412\'+map_name+'-'+Sep_name+'_RBN_SEP_'+ystr+'_'+str+'.sav')
      restore, file
      P0 = RC_C_LONLAT[ESA-2, 1]
      T0 = RC_C_LONLAT[ESA-2, 2]
      !null = execute('esa_map = ESA'+string(ESA, format = '(I1)')+'_RBN'+fstr+'_MAP')
      ec_to_rc_tmp, esa_map, lon_Arr, lat_rc, p0, t0
      ec_map_single_plot, esa, ESA_MAP, 1, data_range = data_range, title = 'Flux, ESA'+string(ESA, format = '(I1)')
      write_png, fpath+'\'+map_name+'-'+Sep_name+'_RBN_SEP_'+ystr+'_'+str+fstr+'.png',tvrd(/true)
    endfor
  endfor


  for midx = 0, 1 do begin
    for sidx = 0, 1 do begin
      if midx eq 0 and sidx eq 0 then continue
      if midx eq 0 then map_name = 'ISOC' else map_name = 'Theseus'
      if sidx eq 0 then Sep_name = 'D' else Sep_name = 'L'
      fstr = '_stddev' ; ''
      file = file_search('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\' $
        +map_name+'-'+Sep_name+'\'+map_name+'RibbonSep_RC_Peak_Moment_230412\'+map_name+'-'+Sep_name+'_RBN_SEP_'+ystr+'_'+str+'.sav')
      restore, file
      P0 = RC_C_LONLAT[ESA-2, 1]
      T0 = RC_C_LONLAT[ESA-2, 2]
      !null = execute('esa_map = ESA'+string(ESA, format = '(I1)')+'_RBN'+fstr+'_MAP')
      ec_to_rc_tmp, esa_map, lon_Arr, lat_rc, p0, t0
      ec_map_single_plot, esa, ESA_MAP, 1, data_range = [0, 20], title = 'STDDEV, ESA'+string(ESA, format = '(I1)')
      write_png, fpath+'\'+map_name+'-'+Sep_name+'_RBN_SEP_'+ystr+'_'+str+fstr+'.png',tvrd(/true)
    endfor
  endfor


  stop



end