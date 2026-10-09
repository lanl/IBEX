pro IBEX_DATA_CSV_TO_SAV

    mapname = 'ISOC'
    ver = '230328'
    file_name_csv = 'C:\Users\375303\nwalia\data\3.28.23_ISOC\Results_Ecliptic_Lauren.csv'
    dpath = 'C:\Users\375303\nwalia\data\3.28.23_ISOC\'
    file_mkdir, dpath +'SAV\'
  
    sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
    header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  
    for ram = 0, 1 do begin
      if ram eq 0 then begin
        didx = where(sed_data.FIELD9 eq 'Tabular, Ram, CG')
        str = 'Ram'
      endif
      if ram eq 1 then begin
        didx = where(sed_data.FIELD9 eq 'Tabular, Antiram, CG')
        str = 'Aram'
      endif
      rbn = sed_data.FIELD5[didx]
      gdf = sed_data.FIELD3[didx]
      rbn[where(rbn eq 'NA')] = 'NaN'
      gdf[where(gdf eq 'NA')] = 'NaN'
      
      rbn_se = sed_data.FIELD6[didx]
      gdf_se = sed_data.FIELD4[didx]
      rbn_se[where(rbn_se eq 'NA')] = 'NaN'
      gdf_se[where(gdf_se eq 'NA')] = 'NaN'
  
      data_year = sed_data.FIELD7[didx]
      data_energy = sed_data.FIELD8[didx]
  
      for yidx = 2020, 2021 do begin
        year = string(yidx, format = '(I4)')
        yyidx = where(data_year eq yidx)
  
        rbn_year = rbn[yyidx]
        gdf_year = gdf[yyidx]
        
        rbn_se_year = rbn_se[yyidx]
        gdf_se_year = gdf_se[yyidx]        

        esa = data_energy[yyidx]
  
        for ll = 2, 6 do begin
          eidx = where(esa eq ll)
  
          rbn_tmp = double(rbn_year[eidx])
          gdf_tmp = double(gdf_year[eidx])
  
          rbn_se_tmp = double(rbn_se_year[eidx])
          gdf_se_tmp = double(gdf_se_year[eidx])

  
          !null = execute('ESA'+strcompress(ll, /rem)+'_rbn = rbn_tmp')
          !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV = rbn_se_tmp')
          !null = execute('ESA'+strcompress(ll, /rem)+'_gdf = gdf_tmp')
          !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev = gdf_se_tmp')
        endfor
  
        lon_arr = [3:360-3:6.]
        lat_arr = [-90+3:90-3:6.]
  
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
        SAVE, FILE = dpath +'SAV\ISOC-L_RBN_SEP_'+year+'_'+str+'.sav', /compress, lon_arr, lat_arr, $
          ESA2_rbn_MAP, ESA2_RBN_STDDEV_MAP, ESA3_rbn_MAP, ESA3_RBN_STDDEV_MAP, ESA4_rbn_MAP, ESA4_RBN_STDDEV_MAP, ESA5_rbn_MAP, ESA5_RBN_STDDEV_MAP, ESA6_rbn_MAP, ESA6_RBN_STDDEV_MAP, $
          ESA2_gdf_MAP, ESA2_gdf_stddev_MAP, ESA3_gdf_MAP, ESA3_gdf_stddev_MAP, ESA4_gdf_MAP, ESA4_gdf_stddev_MAP, ESA5_gdf_MAP, ESA5_gdf_stddev_MAP, ESA6_gdf_MAP, ESA6_gdf_stddev_MAP
      endfor
  
    endfor

stop
  mapname = 'Theseus'
  ver = '230323'

  file_path_csv = 'C:\Users\375303\nwalia\data\3.23.23_LRS\Theseus_Standard_3.23.23\'
  dpath = 'C:\Users\375303\nwaliadata\3.23.23_LRS\'
  file_mkdir, dpath +'SAV\'

  for ram = 0, 1 do begin
    if ram eq 0 then begin
      str_fn = 'ram'
      str = 'Ram'
    endif
    if ram eq 1 then begin
      str_fn = 'antiram'
      str = 'Aram'
    endif

    for yidx = 2009, 2021 do begin
      year = string(yidx, format = '(I4)')

      for ll = 2, 6 do begin
        file_name_csv = file_search(file_path_csv+'SeparationEcliptic'+year+'_'+str_fn+'_'+strcompress(ll, /rem)+'.csv')
        sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
        header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

        rbn_tmp = sed_data.FIELD5
        rbn_sig_tmp = sed_data.FIELD6

        gdf_tmp = sed_data.FIELD3
        gdf_sig_tmp = sed_data.FIELD3

        !null = execute('ESA'+strcompress(ll, /rem)+'_rbn = rbn_tmp')
        !null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV = rbn_sig_tmp')
        !null = execute('ESA'+strcompress(ll, /rem)+'_gdf = gdf_tmp')
        !null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev = gdf_sig_tmp')
      endfor

      lon_arr = [1:360-1:2.]
      lat_arr = [-90+1:90-1:2.]

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

      SAVE, FILE = dpath +'SAV\Theseus-L_RBN_SEP_'+year+'_'+str+'.sav', /compress, lon_arr, lat_arr, $
        ESA2_rbn_MAP, ESA2_RBN_STDDEV_MAP, ESA3_rbn_MAP, ESA3_RBN_STDDEV_MAP, ESA4_rbn_MAP, ESA4_RBN_STDDEV_MAP, ESA5_rbn_MAP, ESA5_RBN_STDDEV_MAP, ESA6_rbn_MAP, ESA6_RBN_STDDEV_MAP, $
        ESA2_gdf_MAP, ESA2_gdf_stddev_MAP, ESA3_gdf_MAP, ESA3_gdf_stddev_MAP, ESA4_gdf_MAP, ESA4_gdf_stddev_MAP, ESA5_gdf_MAP, ESA5_gdf_stddev_MAP, ESA6_gdf_MAP, ESA6_gdf_stddev_MAP
    endfor

  endfor

end