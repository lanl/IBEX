pro IBEX_DATA_CSV_TO_SAV


  ;  ; new Theseus
  ;
  ;  for maps_idx = 0, 1 do begin
  ;    if maps_idx eq 0 then ver = '_GAM_v20240413'
  ;    if maps_idx eq 1 then ver = '_svGP_v20240413'
  ;    for midx = 0, 0 do begin
  ;      if midx eq 0 then begin
  ;        mapname = 'Theseus'
  ;        lon_arr = [1:360-1:2.]
  ;        lat_arr = [-90+1:90-1:2.]
  ;        mf = 1d
  ;        cg_Str = 'cg'
  ;      endif
  ;      if midx eq 1 then begin
  ;        mapname = 'ISOC'
  ;        lon_arr = [3:360-3:6.]
  ;        lat_arr = [-90+3:90-3:6.]
  ;        mf = 1d-3
  ;        cg_Str = 'cg_sp'
  ;      endif
  ;
  ;      dpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\'+mapname+'-L\' +'SAV'+ver+'\'
  ;      file_mkdir, dpath
  ;
  ;      for ram = 0, 1 do begin
  ;        if ram eq 0 then begin
  ;          str_fn = 'ram'
  ;          str = 'Ram'
  ;          type = 'AB'
  ;        endif
  ;        if ram eq 1 then begin
  ;          str_fn = 'antiram'
  ;          str = 'Aram'
  ;          type = 'AB'
  ;        endif
  ;
  ;        for yidx = 2009, 2022 do begin
  ;          year = string(yidx, format = '(I4)')
  ;
  ;          for ll = 2, 6 do begin
  ;            file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps'+ver+'\separated_maps\ribbon_'+cg_Str+'\'+str_fn+'\data\'
  ;            file_name_csv = file_search(file_path_csv+'ribbon_'+cg_Str+'_'+str_fn+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
  ;
  ;            sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
  ;            header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;
  ;            rbn_tmp = sed_data.FIELD3
  ;            if typename(sed_data.FIELD3) eq 'STRING' then rbn_tmp[where(rbn_tmp eq 'NA', /null)] = 'NaN'
  ;
  ;            rbn_sig_tmp = sed_data.FIELD4
  ;            if typename(sed_data.FIELD4) eq 'STRING' then rbn_sig_tmp[where(rbn_sig_tmp eq 'NA', /null)] = 'NaN'
  ;
  ;
  ;            rbn_tmp = double(rbn_tmp)*mf
  ;            rbn_sig_tmp = double(rbn_sig_tmp)*mf
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_rbn = rbn_tmp')
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV = rbn_sig_tmp')
  ;
  ;            file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps'+ver+'\separated_maps\gdf_'+cg_Str+'\'+str_fn+'\data\'
  ;            file_name_csv = file_search(file_path_csv+'gdf_'+cg_Str+'_'+str_fn+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')
  ;            sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
  ;            header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;
  ;
  ;            gdf_tmp = sed_data.FIELD3
  ;            if typename(sed_data.FIELD3) eq 'STRING' then gdf_tmp[where(gdf_tmp eq 'NA', /null)] = 'NaN'
  ;            gdf_sig_tmp = sed_data.FIELD4
  ;            if typename(sed_data.FIELD4) eq 'STRING' then gdf_sig_tmp[where(gdf_sig_tmp eq 'NA', /null)] = 'NaN'
  ;
  ;            gdf_tmp = double(gdf_tmp)*mf
  ;            gdf_sig_tmp = double(gdf_sig_tmp)*mf
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_gdf = gdf_tmp')
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev = gdf_sig_tmp')
  ;          endfor
  ;
  ;
  ;
  ;          ESA2_tot_map = fltarr(lon_arr.length, lat_arr.length)
  ;          ESA2_rbn_map = ESA2_tot_map & ESA3_rbn_map = ESA2_tot_map & ESA4_rbn_map = ESA2_tot_map & ESA5_rbn_map = ESA2_tot_map & ESA6_rbn_map = ESA2_tot_map
  ;          ESA2_RBN_STDDEV_map = ESA2_tot_map & ESA3_RBN_STDDEV_map = ESA2_tot_map & ESA4_RBN_STDDEV_map = ESA2_tot_map & ESA5_RBN_STDDEV_map = ESA2_tot_map & ESA6_RBN_STDDEV_map = ESA2_tot_map
  ;          ESA2_gdf_map = ESA2_tot_map & ESA3_gdf_map = ESA2_tot_map & ESA4_gdf_map = ESA2_tot_map & ESA5_gdf_map = ESA2_tot_map & ESA6_gdf_map = ESA2_tot_map
  ;          ESA2_gdf_stddev_map = ESA2_tot_map & ESA3_gdf_stddev_map = ESA2_tot_map & ESA4_gdf_stddev_map = ESA2_tot_map & ESA5_gdf_stddev_map = ESA2_tot_map & ESA6_gdf_stddev_map = ESA2_tot_map
  ;
  ;          kk = 0
  ;          for ii = 0, lon_arr.length-1 do begin
  ;            for jj = 0, lat_arr.length-1 do begin
  ;              for ll = 2, 6 do begin
  ;                !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf[kk]')
  ;                !null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_rbn[kk]')
  ;                !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf_stddev[kk]')
  ;                !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV[kk]')
  ;              endfor
  ;              kk += 1
  ;            endfor
  ;          endfor
  ;
  ;          for ll = 2, 6 do begin
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map = ESA'+strcompress(ll, /rem)+'_rbn_map')
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_map = ESA'+strcompress(ll, /rem)+'_gdf_map')
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map')
  ;            !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map = ESA'+strcompress(ll, /rem)+'_gdf_stddev_map')
  ;          endfor
  ;
  ;          SAVE, FILE = dpath +mapname+'-L_RBN_SEP_'+year+'_'+str+'.sav', /compress, lon_arr, lat_arr, $
  ;            ESA2_rbn_MAP, ESA2_RBN_STDDEV_MAP, ESA3_rbn_MAP, ESA3_RBN_STDDEV_MAP, ESA4_rbn_MAP, ESA4_RBN_STDDEV_MAP, ESA5_rbn_MAP, ESA5_RBN_STDDEV_MAP, ESA6_rbn_MAP, ESA6_RBN_STDDEV_MAP, $
  ;            ESA2_gdf_MAP, ESA2_gdf_stddev_MAP, ESA3_gdf_MAP, ESA3_gdf_stddev_MAP, ESA4_gdf_MAP, ESA4_gdf_stddev_MAP, ESA5_gdf_MAP, ESA5_gdf_stddev_MAP, ESA6_gdf_MAP, ESA6_gdf_stddev_MAP
  ;        endfor ; year
  ;
  ;      endfor ; ram
  ;
  ;    endfor ; map
  ;  endfor ; maps
  ;
  ;  stop

  ; Other information from count rate data
  for maps_idx = 1, 1 do begin
    if maps_idx eq 1 then ver = '_svGP_v20240413'
    for midx = 0, 0 do begin
      if midx eq 0 then begin
        mapname = 'Theseus'
        lon_arr = [1:360-1:2.]
        lat_arr = [-90+1:90-1:2.]
        mf = 1d
        cg_Str = 'cg'
      endif

      dpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\'+mapname+'-L\SAV'+ver+'\CountRate_Time\'
      file_mkdir, dpath

      for ram = 0, 1 do begin
        if ram eq 0 then begin
          str_fn = 'ram'
          str = 'Ram'
          type = 'AB'
        endif
        if ram eq 1 then begin
          str_fn = 'antiram'
          str = 'Aram'
          type = 'AB'
        endif

        for yidx = 2009, 2022 do begin
          year = string(yidx, format = '(I4)')

          for ll = 2, 6 do begin
            file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps'+ver+'\count_rate_maps\'+str_fn+'\data\'
            file_name_csv = file_search(file_path_csv+'theseus_'+str_fn+'_'+year+type+'_'+strcompress(ll, /rem)+'.csv')

            sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
            header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

            ACQ_Time = sed_data.FIELD6
            if typename(sed_data.FIELD6) eq 'STRING' then ACQ_Time[where(ACQ_Time eq 'NA', /null)] = 'NaN'
            if total(ACQ_Time eq 'NaN') ne 0 then stop
            ACQ_Time = time_double(strmid(ACQ_Time, 0, 10) + '/' + strmid(ACQ_Time, 11, 8))

            CountRate = sed_data.FIELD3
            if typename(sed_data.FIELD3) eq 'STRING' then CountRate[where(CountRate eq 'NA', /null)] = 'NaN'

            CountRate_se = sed_data.FIELD4
            if typename(sed_data.FIELD4) eq 'STRING' then CountRate_se[where(CountRate_se eq 'NA', /null)] = 'NaN'
          endfor



          ESA2_ACQ_map = fltarr(lon_arr.length, lat_arr.length)
          ESA3_ACQ_map = ESA2_ACQ_map & ESA4_ACQ_map = ESA2_ACQ_map & ESA5_ACQ_map = ESA2_ACQ_map & ESA6_ACQ_map = ESA2_ACQ_map
          ESA2_countrate_map = ESA2_ACQ_map & ESA3_countrate_map = ESA2_ACQ_map & ESA4_countrate_map = ESA2_ACQ_map & ESA5_countrate_map = ESA2_ACQ_map & ESA6_countrate_map = ESA2_ACQ_map
          ESA2_countrateSE_map = ESA2_ACQ_map & ESA3_countrateSE_map = ESA2_ACQ_map & ESA4_countrateSE_map = ESA2_ACQ_map & ESA5_countrateSE_map = ESA2_ACQ_map & ESA6_countrateSE_map = ESA2_ACQ_map

          kk = 0
          for ii = 0, lon_arr.length-1 do begin
            for jj = 0, lat_arr.length-1 do begin
              for ll = 2, 6 do begin
                !null = execute('ESA'+strcompress(ll, /rem)+'_ACQ_map[ii, jj] = ACQ_Time[kk]')
                !null = execute('ESA'+strcompress(ll, /rem)+'_countrate_map[ii, jj] = CountRate[kk]')
                !null = execute('ESA'+strcompress(ll, /rem)+'_countrateSE_map[ii, jj] = CountRate_se[kk]')
              endfor
              kk += 1
            endfor
          endfor

          for ll = 2, 6 do begin
            !null = execute('ESA_ACQ_map = double(ESA'+strcompress(ll, /rem)+'_ACQ_map)')
            tic
            YEAR_str = time_string(ESA_ACQ_map, tformat = 'YYYY')
            FDOTY = time_double(YEAR_str+'-01-01/00:00:00') ; first day of the year
            LDOTY = time_double(strcompress(YEAR_str+1, /rem)+'-01-01/00:00:00') ; first day of the year
            TSITY = LDOTY-FDOTY ; Total second in the year
            SSFDOTY = (ESA_ACQ_map-FDOTY)/TSITY ; Second since the first day of the year

            !null = execute('ESA'+strcompress(ll, /rem)+'_FRAC_map = float(YEAR_str)+SSFDOTY')
          ENDFOR

          SAVE, FILE = dpath +mapname+'-L_CNT_ACQ_'+year+'_'+str+'.sav', /compress, lon_arr, lat_arr, $
            ESA2_ACQ_map, ESA3_ACQ_map, ESA4_ACQ_map, ESA5_ACQ_map, ESA6_ACQ_map, $
            ESA2_FRAC_map, ESA3_FRAC_map, ESA4_FRAC_map, ESA5_FRAC_map, ESA6_FRAC_map, $
            ESA2_countrate_map, ESA3_countrate_map, ESA4_countrate_map, ESA5_countrate_map, ESA6_countrate_map, $
            ESA2_countrateSE_map, ESA3_countrateSE_map, ESA4_countrateSE_map, ESA5_countrateSE_map, ESA6_countrateSE_map

        endfor ; year

      endfor ; ram

    endfor ; map
  endfor ; maps

  ; Other information from count rate data

  stop

  ;  ; total maps
  ;
  ;  for midx = 1, 1 do begin
  ;    if midx eq 0 then begin
  ;      mapname = 'Theseus'
  ;      lon_arr = [1:360-1:2.]
  ;      lat_arr = [-90+1:90-1:2.]
  ;      mf = 1d
  ;      cg_Str = 'cg'
  ;      esa_str = ''
  ;    endif
  ;    if midx eq 1 then begin
  ;      mapname = 'ISOC'
  ;      lon_arr = [3:360-3:6.]
  ;      lat_arr = [-90+3:90-3:6.]
  ;      mf = 1d-3
  ;      cg_Str = 'cg_sp'
  ;      esa_str = 'esa'
  ;    endif
  ;
  ;    dpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\'+mapname+'-D\' +'SAV\'
  ;    file_mkdir, dpath
  ;
  ;    for ram = 0, 1 do begin
  ;      if ram eq 0 then begin
  ;        str_fn = 'ram'
  ;        str = 'Ram'
  ;
  ;        type = 'AB'
  ;      endif
  ;      if ram eq 1 then begin
  ;        str_fn = 'antiram'
  ;        str = 'Aram'
  ;
  ;        type = 'AB'
  ;      endif
  ;
  ;      for yidx = 2009, 2021 do begin
  ;        year = string(yidx, format = '(I4)')
  ;
  ;        for ll = 2, 6 do begin
  ;          file_path_csv = 'D:\Data\IBEX_skymaps\'+mapname+'_skymaps\'+cg_Str+'\'+str_fn+'\data\'
  ;          file_name_csv = file_search(file_path_csv+cg_Str+'_'+str_fn+'_'+year+type+'_'+esa_str+strcompress(ll, /rem)+'.csv')
  ;          sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
  ;          header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;
  ;          tot_tmp = sed_data.FIELD3
  ;          if typename(sed_data.FIELD3) eq 'STRING' then tot_tmp[where(tot_tmp eq 'NA', /null)] = 'NaN'
  ;
  ;          tot_sig_tmp = sed_data.FIELD4
  ;          if typename(sed_data.FIELD4) eq 'STRING' then tot_sig_tmp[where(tot_sig_tmp eq 'NA', /null)] = 'NaN'
  ;
  ;
  ;          tot_tmp = double(tot_tmp)*mf
  ;          tot_sig_tmp = double(tot_sig_tmp)*mf
  ;          !null = execute('ESA'+strcompress(ll, /rem)+'_tot = tot_tmp')
  ;          !null = execute('ESA'+strcompress(ll, /rem)+'_tot_STDDEV = tot_sig_tmp')
  ;
  ;        endfor
  ;
  ;
  ;
  ;        ESA2_tot_map = fltarr(lon_arr.length, lat_arr.length)
  ;        ESA3_tot_map = ESA2_tot_map & ESA4_tot_map = ESA2_tot_map & ESA5_tot_map = ESA2_tot_map & ESA6_tot_map = ESA2_tot_map
  ;        ESA2_tot_STDDEV_map = ESA2_tot_map & ESA3_tot_STDDEV_map = ESA2_tot_map & ESA4_tot_STDDEV_map = ESA2_tot_map & ESA5_tot_STDDEV_map = ESA2_tot_map & ESA6_tot_STDDEV_map = ESA2_tot_map
  ;
  ;        kk = 0
  ;        for ii = 0, lon_arr.length-1 do begin
  ;          for jj = 0, lat_arr.length-1 do begin
  ;            for ll = 2, 6 do begin
  ;              !null = execute('ESA'+strcompress(ll, /rem)+'_tot_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_tot[kk]')
  ;              !null = execute('ESA'+strcompress(ll, /rem)+'_tot_STDDEV_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_tot_STDDEV[kk]')
  ;            endfor
  ;            kk += 1
  ;          endfor
  ;        endfor
  ;
  ;        for ll = 2, 6 do begin
  ;          !null = execute('ESA'+strcompress(ll, /rem)+'_tot_map = ESA'+strcompress(ll, /rem)+'_tot_map')
  ;          !null = execute('ESA'+strcompress(ll, /rem)+'_tot_STDDEV_map = ESA'+strcompress(ll, /rem)+'_tot_STDDEV_map')
  ;        endfor
  ;
  ;        SAVE, FILE = dpath +mapname+'-D_tot_SEP_'+year+'_'+str+'.sav', /compress, lon_arr, lat_arr, $
  ;          ESA2_tot_MAP, ESA2_tot_STDDEV_MAP, ESA3_tot_MAP, ESA3_tot_STDDEV_MAP, ESA4_tot_MAP, ESA4_tot_STDDEV_MAP, ESA5_tot_MAP, ESA5_tot_STDDEV_MAP, ESA6_tot_MAP, ESA6_tot_STDDEV_MAP
  ;      endfor ; year
  ;
  ;    endfor ; ram
  ;
  ;  endfor ; map



  ;  ; Survival Probability
  ;
  ;  for midx = 0, 0 do begin
  ;    if midx eq 0 then begin
  ;      mapname = 'Theseus'
  ;      lon_arr = [1:360-1:2.]
  ;      lat_arr = [-90+1:90-1:2.]
  ;      mf = 1d
  ;      cg_Str = 'cg'
  ;    endif
  ;
  ;    dpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\'
  ;    file_mkdir, dpath
  ;
  ;
  ;    survp_map = fltarr(2022-2009+1, 2, lon_arr.length, lat_arr.length, 5)
  ;
  ;    for ram = 0, 1 do begin
  ;      if ram eq 0 then begin
  ;        str_fn = 'ram'
  ;        str = 'Ram'
  ;
  ;        type = 'AB'
  ;      endif
  ;      if ram eq 1 then begin
  ;        str_fn = 'antiram'
  ;        str = 'Aram'
  ;
  ;        type = 'AB'
  ;      endif
  ;
  ;      for yidx = 2009, 2022 do begin
  ;        year = string(yidx, format = '(I4)')
  ;
  ;        for ll = 2, 6 do begin
  ;          file_path_csv = 'D:\Data\IBEX_skymaps\Theseus_skymaps\survival_probability_maps\inertial_frame\'
  ;
  ;          file_name_csv = file_search(file_path_csv+'sp_'+str_fn+'_'+year+'AB_'+strcompress(ll, /rem)+'.csv')
  ;          sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
  ;          header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  ;
  ;          rbn_tmp = sed_data.FIELD3
  ;          if typename(sed_data.FIELD3) eq 'STRING' then rbn_tmp[where(rbn_tmp eq 'NA', /null)] = 'NaN'
  ;
  ;          rbn_tmp = double(rbn_tmp)*mf
  ;          !null = execute('survp'+strcompress(ll, /rem)+' = rbn_tmp')
  ;
  ;        endfor
  ;
  ;
  ;
  ;
  ;
  ;        kk = 0
  ;        for ii = 0, lon_arr.length-1 do begin
  ;          for jj = 0, lat_arr.length-1 do begin
  ;            for ll = 2, 6 do begin
  ;              !null = execute('survp_map[yidx-2009, ram, ii, jj, ll-2] =  survp'+strcompress(ll, /rem)+'[kk]')
  ;            endfor
  ;            kk += 1
  ;          endfor
  ;        endfor
  ;
  ;
  ;
  ;      endfor ; year
  ;    endfor ; ram
  ;    SAVE, FILE = dpath+'surv_map_2009_2022.sav', survp_map
  ;
  ;  endfor ; map

  stop
  ; -------------------------- According to sky map pipeline ----------------------------
end