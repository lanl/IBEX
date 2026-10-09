
; TOTAL FLUX
pro Ribbon_width_Overplot_Theseus_ISOC_with_official_240626
  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  survp =  reform(survp_map[*, 0, *, *, *])

  MAPNAME  = 'Theseus'
  VER = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  SEPNAME = 'L'

  tol = 1d-15

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


  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  fname = mapname+'-'+sepname+'_RC_Iteration'
  DPATH = dp+mapname+'-'+sepname+'\'

  YEAR_MIN = 2009
  YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  lon_num = 180
  lat_num = 90
  year_arr = [YEAR_MIN:YEAR_MAX]
  year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]

  fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
  fit_par_sig_circ = replicate(!values.d_nan, 3, year_arr.length, 5, 2); RLonLat x year x esa x ram

  fit_par_ellip = replicate(!values.d_nan, 6, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot,sig x year x esa x ram
  fit_par_sig_ellip = replicate(!values.d_nan, 5, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot x year x esa x ram


  moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

  Ribbon_stack = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
  GDF_stack = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
  TOTAL_stack = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

  moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
  Ribbon_stack_error = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
  GDF_stack_error = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
  TOTAL_stack_error = replicate(!values.d_nan, lon_num, lat_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored\'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FILE_MKDIR, file_tmp

  ; data stacking
  for yidx = year_min, YEAR_MAX do begin
    FOR ram = 0, 0 DO BEGIN
      IF ram THEN str = 'ARam' ELSE str = 'Ram'

      year = string(yidx, format = '(I4)')
      restore, DPATH_NEW+mapname+'-'+SEpname+'_RBN_SEP_'+year+'_'+str+'.sav'

      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        if rc_c_lonlat[esa-2, 3] gt 0 then begin
          fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
          fit_par_sig_circ[*, (yidx-year_min), esa-2, ram] = reform([rc_c_PAR_SIG[esa-2, 0], rc_c_PAR_SIG[esa-2, 2], rc_c_PAR_SIG[esa-2, 1]]); RLonLat x year x esa
        endif

        if rc_e_lonlat[esa-2, 3] gt 0 then begin
          fit_par_ellip[*, (yidx-year_min), esa-2, ram] = [reform(rc_e_lonlat[esa-2, 0:2]), sqrt(1-(reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2), reform(rc_e_PAR[esa-2, 2]), reform(rc_e_lonlat[esa-2, 3])]; R,Lon,Lat,Ellip,Rot,sig x year x esa

          fit_par_sig_ellip[*, (yidx-year_min), esa-2, ram] = $
            [reform(sqrt(rc_E_PAR_SIG[esa-2, 0]^2+rc_E_PAR_SIG[esa-2, 1]^2)), $ ;R
            reform(rc_E_PAR_SIG[esa-2, 4]), $ ;Lon
            reform(rc_E_PAR_SIG[esa-2, 3]), $ ;Lat
            reform(rc_e_PAR[esa-2, 1]/rc_e_PAR[esa-2, 0] * sqrt((rc_E_PAR_SIG[esa-2, 0]/rc_e_PAR[esa-2, 0])^2+(rc_E_PAR_SIG[esa-2, 1]/rc_e_PAR[esa-2, 1])^2)), $ ;Ellip
            reform(rc_E_PAR_SIG[esa-2, 2])] ; Rot
        endif

        !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
        !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
        !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')
        !NULL = EXECUTE('Ribbon_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')
        !NULL = EXECUTE('GDF_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_GDF_MAP')

        !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
        !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
        !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')
        !NULL = EXECUTE('Ribbon_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_STDDEV_MAP')
        !NULL = EXECUTE('GDF_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_GDF_STDDEV_MAP')
      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking

  ; ============================ Longitudinal Distribution of Moments ============================
  win = window(dim = [900, 800], /buffer)
  win.refresh, /disable

  num_sec = 4
  lb_arr = linspace(0, 360, num_sec+1)
  lb_arr = lb_arr-10
  sector_name = ['Nose', 'North', 'Tail', 'South']

  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  FOR ram = 0, 1 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    ; ================== sky map rotation =========================
    for yidx = year_min, YEAR_MAX do begin
      for esa = 2, 6 do begin
        ESA_STR = strcompress(esa, /rem)

        ; ----------------------- TOTAL -----------------------
        esa_map = (reform(Ribbon_stack[*, *, yidx-year_min, esa-2, 0])+reform(GDF_stack[*, *, yidx-year_min, esa-2, 0]))/reform(survp[yidx-year_min, *, *, esa-2])
        esa_map_error = SQRT((reform(Ribbon_stack_error[*, *, yidx-year_min, esa-2, 0])^2 + reform(GDF_stack_error[*, *, yidx-year_min, esa-2, 0])^2)/reform(survp[yidx-year_min, *, *, esa-2]))
        ; ----------------------- TOTAL -----------------------

        P0 = fit_par_circ[1, (yidx-year_min), esa-2, 0]
        T0 = fit_par_circ[2, (yidx-year_min), esa-2, 0]

        ; 111111111111111 esa map from rc to ec
        res = meshgrid(LON_ARR, lat_rc)
        lat_mat = res.remove()
        lon_mat = res.remove()
        conv = conv_coord_ec_rc(lON_mat, lat_mat-90, P0, T0, nose_POS = [255.6, 5.14])
        P1 = conv.LON
        T1 = conv.LAT
        ;      T1 = T1-90
        LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
        LAT_IDX = interpol(dindgen(lat_rc.length), lat_rc, T1)

        ESA_MAP = INTERPOLATE(esa_map, LON_IDX, LAT_IDX, /DOUBLE)
        esa_map_error = INTERPOLATE(esa_map_error, LON_IDX, LAT_IDX, /DOUBLE)

        res = meshgrid(LON_ARR, lat_arr)
        lat_mat = res.remove()
        lon_mat = res.remove()
        res = conv_coord_ec_rc(lON_mat, lat_mat+90, RC_DAYEH_LONLAT[0, esa-2], RC_DAYEH_LONLAT[1, esa-2], /reverse, nose_POS = [255.6, 5.14])
        P1 = RES.LON
        T1 = RES.LAT
        LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
        LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

        ESA_MAP_RC = INTERPOLATE(ESA_MAP, LON_IDX, LAT_IDX, /DOUBLE)
        esa_map_error_RC = INTERPOLATE(esa_map_error, LON_IDX, LAT_IDX, /DOUBLE)

        TOTAL_stack[*, *, yidx-year_min, esa-2, 0] = ESA_MAP_RC
        TOTAL_stack_ERROR[*, *, yidx-year_min, esa-2, 0] = esa_map_error_RC

        ; 111111111111111 esa map from rc to ec
      endfor ; esa
    endfor ; year
    ; ================== sky map rotation =========================
  endfor ; ram

  Ribbon_mat_theseus = TOTAL_stack
  Ribbon_mat_theseus_STDDEV = TOTAL_stack_ERROR
  lon_theseus = lon_arr
  lat_theseus = lat_rc


  e_step = [0.71,1.11,1.74,2.73,4.29]
  e_color = ['blue','green','yellow','orange','red']

  lon_isoc = [3:360-3:6]
  lat_isoc = [3:180-3:6]
  LON_ARR = lon_isoc
  Lat_ARR = [-90+3:90-3:6]


  ;  data_read
  mapname = 'ISOC'
  ver = '20240325' ; 230809, ISOC_official
  file_tmp = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\ISOC-L_RC_Iteration\'+ver+'\RC_Summary_mom_dist_colored\Ribbon_Flux_Theseus_ISOC'

  str_fn = 'ram' ; ram, antiram, 6month
  type = 'AB' ; AB or BA for yearly, A or B for 6month
  cg_Str = 'cg_sp' ;cg_sp, sc_frame, sc_frame_sp
  str = str_fn
  midx = 1
  mf = 1d

  esa_maps_GDF = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
  esa_maps_RBN = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
  esa_maps_TOT = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)

  esa_maps_GDF_stddev = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
  esa_maps_RBN_stddev = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
  esa_maps_TOT_stddev = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)

  for yidx = YEAR_MIN, YEAR_MAX do begin
    year = string(yidx, format = '(I4)')

    for ll = 2, 6 do begin
      file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps_v'+ver+'\separated_maps\ribbon_'+cg_Str+'\'+str_fn+'\data\'
      if midx eq 0 then file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
      if midx eq 1 then file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
      if ver eq '230809' then file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str+'_'+year+type+'_esa'+strcompress(ll, /rem)+'.csv')
      sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
      header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

      rbn_tmp = sed_data.FIELD3
      if typename(sed_data.FIELD3) eq 'STRING' then rbn_tmp[where(rbn_tmp eq 'NA', /null)] = 'NaN'

      rbn_sig_tmp = sed_data.FIELD4
      if typename(sed_data.FIELD4) eq 'STRING' then rbn_sig_tmp[where(rbn_sig_tmp eq 'NA', /null)] = 'NaN'

      rbn_tmp = double(rbn_tmp)*mf
      rbn_sig_tmp = double(rbn_sig_tmp)*mf
      !null = execute('ESA'+strcompress(ll, /rem)+'_rbn = rbn_tmp')
      !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV = rbn_sig_tmp')

      file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps_v'+ver+'\separated_maps\gdf_'+cg_Str+'\'+str_fn+'\data\'
      if midx eq 0 then file_name_csv = file_search(file_path_csv+'gdf_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
      if midx eq 1 then file_name_csv = file_search(file_path_csv+'gdf_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
      if ver eq '230809' then file_name_csv = file_search(file_path_csv+'gdf_'+cg_Str+'_'+str+'_'+year+type+'_esa'+strcompress(ll, /rem)+'.csv')
      sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
      header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

      gdf_tmp = sed_data.FIELD3
      if typename(sed_data.FIELD3) eq 'STRING' then gdf_tmp[where(gdf_tmp eq 'NA', /null)] = 'NaN'
      gdf_sig_tmp = sed_data.FIELD4
      if typename(sed_data.FIELD4) eq 'STRING' then gdf_sig_tmp[where(gdf_sig_tmp eq 'NA', /null)] = 'NaN'

      gdf_tmp = double(gdf_tmp)*mf
      gdf_sig_tmp = double(gdf_sig_tmp)*mf
      !null = execute('ESA'+strcompress(ll, /rem)+'_gdf = gdf_tmp')
      !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev = gdf_sig_tmp')
    endfor

    ESA2_tot_map = fltarr(lon_arr.length, lat_arr.length)
    ESA2_rbn_map = ESA2_tot_map & ESA3_rbn_map = ESA2_tot_map & ESA4_rbn_map = ESA2_tot_map & ESA5_rbn_map = ESA2_tot_map & ESA6_rbn_map = ESA2_tot_map
    ESA2_RBN_STDDEV_map = ESA2_tot_map & ESA3_RBN_STDDEV_map = ESA2_tot_map & ESA4_RBN_STDDEV_map = ESA2_tot_map & ESA5_RBN_STDDEV_map = ESA2_tot_map & ESA6_RBN_STDDEV_map = ESA2_tot_map
    ESA2_gdf_map = ESA2_tot_map & ESA3_gdf_map = ESA2_tot_map & ESA4_gdf_map = ESA2_tot_map & ESA5_gdf_map = ESA2_tot_map & ESA6_gdf_map = ESA2_tot_map
    ESA2_gdf_stddev_map = ESA2_tot_map & ESA3_gdf_stddev_map = ESA2_tot_map & ESA4_gdf_stddev_map = ESA2_tot_map & ESA5_gdf_stddev_map = ESA2_tot_map & ESA6_gdf_stddev_map = ESA2_tot_map
    ESA2_TOT_map = ESA2_tot_map & ESA3_TOT_map = ESA2_tot_map & ESA4_TOT_map = ESA2_tot_map & ESA5_TOT_map = ESA2_tot_map & ESA6_TOT_map = ESA2_tot_map
    ESA2_TOT_stddev_map = ESA2_tot_map & ESA3_TOT_stddev_map = ESA2_tot_map & ESA4_TOT_stddev_map = ESA2_tot_map & ESA5_TOT_stddev_map = ESA2_tot_map & ESA6_TOT_stddev_map = ESA2_tot_map

    kk = 0
    for ii = 0, lon_arr.length-1 do begin
      for jj = 0, lat_arr.length-1 do begin
        for ll = 2, 6 do begin
          !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf[kk]')
          !null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_rbn[kk]')
          !null = execute('ESA'+strcompress(ll, /rem)+'_TOT_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_rbn[kk] + ESA'+strcompress(ll, /rem)+'_gdf[kk]')
          !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf_stddev[kk]')
          !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV[kk]')
          !null = execute('ESA'+strcompress(ll, /rem)+'_TOT_STDDEV_map[ii, jj] = SQRT(ESA'+strcompress(ll, /rem)+'_RBN_STDDEV[kk]^2 + ESA'+strcompress(ll, /rem)+'_RBN_STDDEV[kk]^2)')
        endfor
        kk += 1
      endfor
    endfor

    for ll = 2, 6 do begin
      !null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map = ESA'+strcompress(ll, /rem)+'_rbn_map')
      !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_map = ESA'+strcompress(ll, /rem)+'_gdf_map')
      !null = execute('ESA'+strcompress(ll, /rem)+'_TOT_map = ESA'+strcompress(ll, /rem)+'_TOT_map')
      !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map')
      !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map = ESA'+strcompress(ll, /rem)+'_gdf_stddev_map')
      !null = execute('ESA'+strcompress(ll, /rem)+'_tot_stddev_map = sqrt(ESA'+strcompress(ll, /rem)+'_gdf_stddev_map^2 + ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map^2)')
    endfor

    ec_str = 'EC'

    FOR GDF = 0, 2 DO BEGIN
      IF GDF EQ 0 THEN GDF_STR = 'GDF'
      IF GDF EQ 1 THEN GDF_STR = 'RBN'
      IF GDF EQ 2 THEN GDF_STR = 'TOT'
      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        !NULL = EXECUTE('esa_maps_'+GDF_STR+'[*, *, esa-2, yidx-year_min] = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
        !NULL = EXECUTE('esa_maps_'+GDF_STR+'_stddev[*, *, esa-2, yidx-year_min] = ESA'+ESA_STR+'_'+GDF_STR+'_STDDEV_MAP')
      ENDFOR ; ESA
    ENDFOR ; GDF

  endfor ; year
  ;  data_read

  Ribbon_mat_ISOC = replicate(!values.f_nan, 60, 30, 14, 5, 2)
  Ribbon_mat_ISOC_STDDEV = replicate(!values.f_nan, 60, 30, 14, 5, 2)
  for yidx = year_min, year_max do begin
    ;    file = file_search('U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\ISOC-L\ribbonmedian\SAV\IBEX-HI_CG_ram_'+string(yidx, format = '(I4)')+'.sav')
    ;    restore, file

    for esa = 2, 6 do begin
      ;      !null = execute('Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0] = ESA'+string(esa, format = '(I1)')+'_RIBBON_FLUX')
      ;      !null = execute('Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0] = ESA'+string(esa, format = '(I1)')+'_RIBBON_VAR')

      ; TOTAL
      Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0] = esa_maps_TOT[*, *, esa-2, yidx-year_min]
      Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0] = esa_maps_TOT_stddev[*, *, esa-2, yidx-year_min]
      ; TOTAL

      Ribbon_mat_ISOC[where(Ribbon_mat_ISOC_STDDEV eq 0)] = !values.d_nan

      res = meshgrid(LON_ARR, lat_arr)
      lat_mat = res.remove()
      lon_mat = res.remove()
      res = conv_coord_ec_rc(lON_mat, lat_mat+90, RC_DAYEH_LONLAT[0, esa-2], RC_DAYEH_LONLAT[1, esa-2], /reverse, nose_POS = [255.6, 5.14])
      P1 = RES.LON
      T1 = RES.LAT
      LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
      LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

      Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0] = INTERPOLATE(Ribbon_mat_ISOC[*, *, yidx-year_min, esa-2, 0], LON_IDX, LAT_IDX, /DOUBLE)
      Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0] = INTERPOLATE(Ribbon_mat_ISOC_STDDEV[*, *, yidx-year_min, esa-2, 0], LON_IDX, LAT_IDX, /DOUBLE)
    endfor


  endfor
  ;  Ribbon_mat_ISOC_STDDEV = sqrt(Ribbon_mat_ISOC_STDDEV)


  azim_range = [0:360:30.]
  for yidx = year_min, YEAR_MAX do begin
    for esa = 2, 6 do begin
      ESA_STR = strcompress(esa, /rem)

      for az = 0, azim_range.length-2 do begin
        lidx_i = where(lon_isoc ge azim_range[az] and lon_isoc lt azim_range[az+1])
        lidx_t = where(lon_theseus ge azim_range[az] and lon_theseus lt azim_range[az+1])

        ribbon_i = mean(reform(Ribbon_mat_isoc[lidx_i, *, yidx-year_min, esa-2, 0]), dim = 1, /nan)
        ribbon_sig_i = sqrt(mean(reform(Ribbon_mat_isoc_STDDEV[lidx_i, *, yidx-year_min, esa-2, 0])^2, dim = 1, /nan))

        ribbon_t = mean(reform(Ribbon_mat_theseus[lidx_t, *, yidx-year_min, esa-2, 0]), dim = 1, /nan)
        ribbon_sig_t = sqrt(mean(reform(Ribbon_mat_theseus_STDDEV[lidx_t, *, yidx-year_min, esa-2, 0])^2, dim = 1, /nan))

        ; flux comparison
        p = errorplot(lat_theseus, ribbon_t, ribbon_sig_t/2, font_size = 15, xtitle = '$\phi$ [$\deg$]', ytitle = 'Flux', $
          title = 'Year'+string(yidx, format = '(I4)')+', ESA'+ESA_STR+'!C$\lambda$ = '+string(fix(azim_range[az]), format = '(I3)')+'$\deg$ - '+string(fix(azim_range[az+1]), format = '(I3)')+'$\deg$', current = win)
        p = errorplot(lat_isoc, ribbon_i, ribbon_sig_i/2, over = p, co = 'blue', errorbar_color = 'blue')
        ; flux comparison


        ; FWHM
        mx = max(ribbon_t, mxidx, /nan)
        LAT_LH = INTERPOL(lat_theseus[0:mxidx], ribbon_t[0:mxidx], mx*0.5, /nan)
        LAT_UH = INTERPOL(lat_theseus[mxidx:-1], ribbon_t[mxidx:-1], mx*0.5, /nan)
        FWHM_t = LAT_UH-LAT_LH

        mx = max(ribbon_i, mxidx, /nan)
        LAT_LH = INTERPOL(lat_isoc[0:mxidx], ribbon_i[0:mxidx], mx*0.5, /nan)
        LAT_UH = INTERPOL(lat_isoc[mxidx:-1], ribbon_i[mxidx:-1], mx*0.5, /nan)
        FWHM_i = LAT_UH-LAT_LH

        ;        idx01 = [mxidx-round(FWHM_t*2/6):mxidx+round(FWHM_t*2/6)];where(ribbon_i gt mx*0.1)
        ;        idx01 = idx01[where(idx01 ge 0 and idx01 le lat_isoc.length-1, /null)]
        ;        if total(~finite(ribbon_i[idx01[0]:idx01[-1]])) gt 3 then FWHM_i = !values.f_nan
        ;
        ;        tx = text(0.65, 0.8, 'Theseus'+string(FWHM_t, format = '(f6.2)')+'$\deg$', font_size = 15)
        ;        tx = text(0.65, 0.75, 'ISOC     '+string(FWHM_i, format = '(f6.2)')+'$\deg$', font_size = 15, font_color = 'blue')
        ; FWHM


        f_path = file_tmp+'TOTAL_Flux_Theseus_ISOC\'
        file_mkdir, f_path
        win.refresh
        win.save, f_path+'ESA'+ESA_STR+'_Year'+string(yidx, format = '(I4)')+'_Azimuth'+string(fix(azim_range[az]), format = '(I3.3)')+'-'+string(fix(azim_range[az+1]), format = '(I3.3)')+'.png', res = 150
        win.erase

      endfor ; azimuth
    endfor ; esa
  endfor ; year




  stop



end