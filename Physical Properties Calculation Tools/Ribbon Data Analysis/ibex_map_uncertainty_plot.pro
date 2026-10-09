pro IBEX_MAP_UNCERTAINTY_PLOT

  ver = 'svGP_v20240413'
  Load_IBEX_color_table
  tvlct,red,green,blue,/get
  co = [[red], [green], [blue]]


  YEAR_MIN = 2009
  YEAR_MAX = 2022

  print, 'Plotting Theseus Maps', ver

  str_fn = 'ram' ; ram, antiram, 6month
  type = 'AB' ; AB or BA for yearly, A or B for 6month
  cg_Str = 'cg' ;cg_sp, sc_frame, sc_frame_sp
  str = str_fn
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

  fpath = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\MapPlot\'
  file_mkdir, fpath


  mapname = 'Theseus'
  lon_arr = [1:360-1:2.]
  lat_arr = [-90+1:90-1:2.]
  mf = 1d

  yidx = 2012
  year = string(yidx, format = '(I4)')

  ll = 3
  file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps_'+ver+'\separated_maps\ribbon_'+cg_Str+'\'+str_fn+'\data\'

  file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')

  sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

  rbn_tmp = sed_data.FIELD3
  if typename(sed_data.FIELD3) eq 'STRING' then rbn_tmp[where(rbn_tmp eq 'NA', /null)] = 'NaN'

  rbn_sig_tmp = sed_data.FIELD4
  if typename(sed_data.FIELD4) eq 'STRING' then rbn_sig_tmp[where(rbn_sig_tmp eq 'NA', /null)] = 'NaN'

  rbn_tmp = double(rbn_tmp)*mf
  rbn_sig_tmp = double(rbn_sig_tmp)*mf
  ESA_rbn = rbn_tmp
  ESA_RBN_STDDEV = rbn_sig_tmp


  ESA_rbn_map = fltarr(lon_arr.length, lat_arr.length)
  ESA_rbn_stddev_map = fltarr(lon_arr.length, lat_arr.length)

  kk = 0
  for ii = 0, lon_arr.length-1 do begin
    for jj = 0, lat_arr.length-1 do begin
      ESA_rbn_map[ii, jj] = ESA_rbn[kk]
      ESA_rbn_stddev_map[ii, jj] = ESA_rbn_stddev[kk]
      kk += 1
    endfor
  endfor

  ec_str = 'EC'





  ; ======================================= plot =======================================

  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'


  Map_Type = 'Cylindrical'
  FPATH_TMP_TMP = fpath+'Theseus_SingleMaps\'
  FILE_MKDIR, FPATH_TMP_TMP

  surv = reform(SURVP_MAP[yidx-2009, 0, *, *, ll-2])
  ESA_rbn_map = ESA_rbn_map/surv
  ESA_rbn_stddev_map = ESA_rbn_stddev_map/surv

  ESA_STR = strcompress(ll, /rem)

  cb_title = 'Differential Flux [#/(cm^2 s sr keV)]; ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
  title = 'ESA '+ESA_STR
  ec_map_single_plot, ll, ESA_rbn_map, 1, 'RBN', cb_title = cb_title
  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN.png',tvrd(/true)
  WDELETE, 0



  cb_title = 'Standard Error [#/(cm^2 s sr keV)]; ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
  title = 'ESA '+ESA_STR
  ec_map_single_plot, ll, ESA_rbn_stddev_map, 3, 'RBN', cb_title = cb_title
  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_STDDEV.png',tvrd(/true)
  WDELETE, 0


  cb_title = 'Fractional Error (stddev/flux); ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
  title = 'ESA '+ESA_STR
  esa_map = ESA_rbn_stddev_map/ESA_rbn_map
  esa_map[where(~finite(esa_map))] = !values.d_nan
  ec_map_single_plot, ll, esa_map, 4, 'RBN', cb_title = cb_title
  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_FractionalError.png',tvrd(/true)
  WDELETE, 0

;  sig_draws = covmat_randsample(year, ll, 0, ver, n_sample = 2000) ; map draws in EC
;
;  ESA_rbn_stddev_map1 = stddev(sig_draws, dim = 3, /nan)/surv
;
;  cb_title = 'Standard Error [#/(cm^2 s sr keV)]; ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
;  title = 'ESA '+ESA_STR
;  ec_map_single_plot, ll, ESA_rbn_stddev_map1, 3, 'RBN', cb_title = cb_title
;  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_STDDEV1.png',tvrd(/true)
;  WDELETE, 0
;
;
;  cb_title = 'Fractional Error (stddev/flux); ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
;  title = 'ESA '+ESA_STR
;  esa_map1 = ESA_rbn_stddev_map1/ESA_rbn_map
;  esa_map1[where(~finite(esa_map1))] = !values.d_nan
;  ec_map_single_plot, ll, esa_map1, 4, 'RBN', cb_title = cb_title
;  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_FractionalError1.png',tvrd(/true)
;  WDELETE, 0

  mapname = 'ISOC'
  lon_arr = [3:360-3:6.]
  lat_arr = [-90+3:90-3:6.]
  mf = 1d;1d-3

  ver = 'Official'
  print, 'Plotting ISOC Maps', ver

  FPATH_TMP_TMP = fpath+'ISOC_SingleMaps\'
  FILE_MKDIR, FPATH_TMP_TMP
  
  str_fn = 'ram' ; ram, antiram, 6month
  type = 'AB' ; AB or BA for yearly, A or B for 6month
  cg_Str = 'cg_sp' ;cg_sp, sc_frame, sc_frame_sp
  str = str_fn
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

  file = file_search('U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\ribbonmedian\SAV\IBEX-HI_CG_ram_'+year+'.sav')
  restore, file

  !null = execute('ESA_rbn_map = ESA'+strcompress(ll, /rem)+'_RIBBON_FLUX')
  !null = execute('ESA_rbn_stddev_map = sqrt(ESA'+strcompress(ll, /rem)+'_RIBBON_VAR)')

  ; ======================================= plot =======================================
  year = string(yidx, format = '(I4)')

  ESA_STR = strcompress(ll, /rem)
  cb_title = 'Differential Flux [#/(cm^2 s sr keV)]; ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
  title = 'ESA '+ESA_STR
  ec_map_single_plot, ll, ESA_rbn_map, 1, 'RBN', cb_title = cb_title
  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_ISOC.png',tvrd(/true)
  WDELETE, 0

  cb_title = 'Standard Error [#/(cm^2 s sr keV)]; ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
  title = 'ESA '+ESA_STR
  ec_map_single_plot, ll, ESA_rbn_stddev_map, 3, 'RBN', cb_title = cb_title
  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_STDDEV_ISOC.png',tvrd(/true)
  WDELETE, 0


  cb_title = 'Fractional Error (stddev/flux); ~'+string(e_step[ll-1], format = '(f4.2)')+' keV'
  title = 'ESA '+ESA_STR
  esa_map = ESA_rbn_stddev_map/ESA_rbn_map
  esa_map[where(~finite(esa_map))] = !values.d_nan
  ec_map_single_plot, ll, esa_map, 4, 'RBN', cb_title = cb_title
  write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_EC_RBN_FractionalError_ISOC.png',tvrd(/true)
  WDELETE, 0
stop




end