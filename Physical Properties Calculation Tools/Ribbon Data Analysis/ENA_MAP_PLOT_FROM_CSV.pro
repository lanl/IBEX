pro ENA_MAP_PLOT_FROM_CSV, ver
  Load_IBEX_color_table
  tvlct,red,green,blue,/get
  co = [[red], [green], [blue]]


  ;  ver = '240313_GAM' ;20240208a - GAM

  ;  ver = 'GAM_v20240325'
  ;  ver = 'svGP_v20240325'

  print, 'Plotting Maps'
  print, ver

  str_fn = 'ram' ; ram, antiram, 6month
  type = 'AB' ; AB or BA for yearly, A or B for 6month
  cg_Str = 'cg' ;cg_sp, sc_frame, sc_frame_sp
  str = str_fn
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

  if str_fn eq '6month' then str = '6mo'

  fpath = 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\MapPlot\'+ver+'\'
  file_mkdir, fpath



  for midx = 0, 0 do begin
    if midx eq 0 then begin
      mapname = 'Theseus'
      lon_arr = [1:360-1:2.]
      lat_arr = [-90+1:90-1:2.]
      mf = 1d
    endif
    if midx eq 1 then begin
      mapname = 'ISOC'
      lon_arr = [3:360-3:6.]
      lat_arr = [-90+3:90-3:6.]
      mf = 1d;1d-3
    endif

    YEAR_MIN = 2009
    YEAR_MAX = 2022

    esa_maps_GDF = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
    esa_maps_RBN = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
    esa_maps_TOT = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)

    esa_maps_STDDEV_GDF = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)
    esa_maps_STDDEV_RBN = dblarr(lon_arr.length, lat_arr.length, 5, YEAR_MAX-YEAR_MIN+1)

    for yidx = YEAR_MIN, YEAR_MAX do begin
      year = string(yidx, format = '(I4)')

      for ll = 2, 6 do begin
        file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps_'+ver+'\separated_maps\ribbon_'+cg_Str+'\'+str_fn+'\data\'

        if midx eq 0 then file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
        if midx eq 1 then file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str+'_'+year+type+'_esa'+strcompress(ll, /rem)+'.csv')
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

        file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps_'+ver+'\separated_maps\gdf_'+cg_Str+'\'+str_fn+'\data\'
        if midx eq 0 then file_name_csv = file_search(file_path_csv+'gdf_'+cg_Str+'_'+str+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
        if midx eq 1 then file_name_csv = file_search(file_path_csv+'gdf_'+cg_Str+'_'+str+'_'+year+type+'_esa'+strcompress(ll, /rem)+'.csv')
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

      kk = 0
      for ii = 0, lon_arr.length-1 do begin
        for jj = 0, lat_arr.length-1 do begin
          for ll = 2, 6 do begin
            !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf[kk]')
            !null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_rbn[kk]')
            !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf_stddev[kk]')
            !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV[kk]')
          endfor
          kk += 1
        endfor
      endfor

      for ll = 2, 6 do begin
        !null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map = ESA'+strcompress(ll, /rem)+'_rbn_map')
        !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_map = ESA'+strcompress(ll, /rem)+'_gdf_map')
        !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map')
        !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map = ESA'+strcompress(ll, /rem)+'_gdf_stddev_map')
      endfor

      ec_str = 'EC'



      FOR GDF = 0, 2 DO BEGIN
        IF GDF EQ 0 THEN GDF_STR = 'GDF'
        IF GDF EQ 1 THEN GDF_STR = 'RBN'
        IF GDF EQ 2 THEN GDF_STR = 'TOT'
        FOR ESA = 2, 6 DO BEGIN
          ESA_STR = strcompress(esa, /rem)
          IF GDF NE 2 THEN BEGIN
            !NULL = EXECUTE('esa_maps_'+GDF_STR+'[*, *, esa-2, yidx-year_min] = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
            !NULL = EXECUTE('esa_maps_STDDEV_'+GDF_STR+'[*, *, esa-2, yidx-year_min] = ESA'+ESA_STR+'_'+GDF_STR+'_STDDEV_MAP')
          ENDIF

          IF GDF EQ 2 THEN !NULL = EXECUTE('esa_maps_'+GDF_STR+'[*, *, esa-2, yidx-year_min] = ESA'+ESA_STR+'_RBN_MAP + ESA'+ESA_STR+'_GDF_MAP')
        ENDFOR ; ESA
      ENDFOR ; GDF

    endfor ; year


    ; ======================================= plot =======================================

    restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'


    Map_Type = 'Mollweide'
    FPATH_tmp = fpath+mapname+'\'+cg_Str+'\'+str_fn+'\'+type+'\MapPlot_'+Map_Type+'\'
    FILE_MKDIR, FPATH_tmp


    FOR GDF = 0, 2 DO BEGIN
      IF GDF EQ 0 THEN GDF_STR = 'GDF'
      IF GDF EQ 1 THEN GDF_STR = 'RBN'
      IF GDF EQ 2 THEN GDF_STR = 'TOT'

      !NULL = EXECUTE('ESA_MAPS = esa_maps_'+GDF_STR)


      surv = transpose(reform(SURVP_MAP[*, 0, *, *, *]), [1, 2, 3, 0])
      ESA_MAPS = ESA_MAPS/surv




      FPATH_TMP1 = FPATH_tmp+GDF_STR+'\'
      FILE_MKDIR, FPATH_TMP1

      if Map_Type eq 'Mollweide' $
        then ec_map_plot_total, esa_maps, 1, GDF_STR, str, /Mollweide, /row_style $
      else ec_map_plot_total, esa_maps, 1, GDF_STR, str, /row_style
      write_png, FPATH_TMP1+'AllYear_'+ec_str+'_'+GDF_STR+'.png',tvrd(/true)
      WDELETE, 0

;      if gdf lt 2 then begin
;
;        !NULL = EXECUTE('ESA_MAPS_STDDEV = esa_maps_STDDEV_'+GDF_STR)
;        surv = transpose(reform(SURVP_MAP[*, 0, *, *, *]), [1, 2, 3, 0])
;        ESA_MAPS = ESA_MAPS/surv
;
;        if Map_Type eq 'Mollweide' $
;          then ec_map_plot_total, esa_maps_STDDEV/ESA_MAPS, 1, GDF_STR, str, /std, /Mollweide, /row_style $
;        else ec_map_plot_total, esa_maps_STDDEV/ESA_MAPS, 1, GDF_STR, str, /std, /row_style
;        write_png, FPATH_TMP1+'AllYear_'+ec_str+'_'+GDF_STR+'_STDDEV.png',tvrd(/true)
;        WDELETE, 0
;      endif

      flux_idx = 1
      map_str = GDF_STR

      FPATH_TMP_TMP = FPATH_TMP1+'SingleMaps\'
      FILE_MKDIR, FPATH_TMP_TMP

      for yidx = 2009, 2022 DO BEGIN
        year = string(yidx, format = '(I4)')

        FOR ESA = 2, 6 DO BEGIN

          ESA_STR = strcompress(esa, /rem)
          cb_title = 'Differential Flux [#/(cm^2 s sr keV)]; ~'+string(e_step[ESA-1], format = '(f4.2)')+' keV'
          title = 'ESA '+ESA_STR
          flux_map = REFORM(esa_maps[*, *, esa-2, yidx-year_min])
          ec_map_single_plot, ESA, flux_map, flux_idx, map_str, cb_title = cb_title, /mollweide
          write_png, FPATH_TMP_TMP+YEAR+'_ESA'+ESA_STR+'_'+ec_str+'_'+GDF_STR+'.png',tvrd(/true)
          ;          IF (ESA_STR eq '4') and (YEAR eq '2010') then write_png, FPATH_tmp+YEAR+'_ESA'+ESA_STR+'_'+ec_str+'_'+GDF_STR+'.png',tvrd(/true)
        ENDFOR ; ESA
      ENDFOR ; YEAR
      WDELETE, 0


    ENDFOR ; GDF





  endfor ; map




end