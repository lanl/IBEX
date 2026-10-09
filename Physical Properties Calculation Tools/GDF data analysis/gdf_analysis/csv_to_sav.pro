pro CSV_TO_SAV


  mapname = 'Theseus'
  ver = '230808'
  file_path_csv = '/Users/nwalia/data/svgp_tot_and_gdf/Theseus_skymaps/cg/antiram/data/'
  dpath = '/Users/nwalia/data/svgp_tot_and_gdf/Theseus_skymaps/cg/antiram/data/'
  
  ;file_path_csv = '/Users/nwalia/data/RS_8Aug23/cg_fractional_time/'
  ;dpath = '/Users/nwalia/data/RS_8Aug23/cg_fractional_time/'
  
  file_mkdir, dpath +'SAV/'
    ram = 1
  for ram = 0, 1 do begin
    if ram eq 0 then begin
      str_fn = 'ram'
      str = 'Ram'
    endif
    if ram eq 1 then begin
      str_fn = 'antiram'
      str = 'Aram'
    endif

    for yidx = 2009, 2022 do begin
      year = string(yidx, format = '(I4)')

      for ll = 2, 6 do begin
        ;file_name_csv = file_path_csv+'cg_ram_'+year+'AB_'+strcompress(ll, /rem)+'.csv'
        file_name_csv = file_path_csv+'cg_antiram_'+year+'AB_'+strcompress(ll, /rem)+'.csv'
        ;file_name_csv = file_path_csv+'gdf_sc_frame_sp_ram_'+year+'A_'+year+'B_'+str_fn+'_esa'+strcompress(ll, /rem)+'.csv
        sed_data = READ_CSV(file_name_csv, HEADER=SedHeader, N_TABLE_HEADER=1, TABLE_HEADER=SedTableHeader)
        header = STRSPLIT(SedTableHeader, ',', /EXTRACT)

        ;rbn_tmp = sed_data.FIELD5
        ;rbn_sig_tmp = sed_data.FIELD6

        cdate_tmp = sed_data.FIELD6
        yr = float(cdate_tmp[*].Substring(0, 3))
        mn = float(cdate_tmp[*].Substring(5,6))
        dy = float(cdate_tmp[*].Substring(8,9))
        h = float(cdate_tmp[*].Substring(11,12))
        m = float(cdate_tmp[*].Substring(14,15))
        s = float(cdate_tmp[*].Substring(17,18))

        cdate_updated = yr + ((30.4375*(mn-1) + dy-1)*24+h+m/60+s/3600)*3600/31557600.0
       
        ;print, cdate_tmp
        ;gdf_sig_tmp = sed_data.FIELD4

        ;!null = execute('ESA'+strcompress(ll, /rem)+'_rbn = rbn_tmp')
        ;!null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV = rbn_sig_tmp')
        !null = execute('ESA'+strcompress(ll, /rem)+'_cdate = cdate_updated')
        ;!null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev = gdf_sig_tmp')
        ;!null = execute('print, ESA'+strcompress(ll, /rem)+'_cdate')
      endfor
     

      lon_arr = [1:360-1:2.]
      lat_arr = [-90+1:90-1:2.]

      ESA2_tot_map = fltarr(lon_arr.length, lat_arr.length)
      ;ESA2_rbn_map = ESA2_tot_map & ESA3_rbn_map = ESA2_tot_map & ESA4_rbn_map = ESA2_tot_map & ESA5_rbn_map = ESA2_tot_map & ESA6_rbn_map = ESA2_tot_map
      ;ESA2_RBN_STDDEV_map = ESA2_tot_map & ESA3_RBN_STDDEV_map = ESA2_tot_map & ESA4_RBN_STDDEV_map = ESA2_tot_map & ESA5_RBN_STDDEV_map = ESA2_tot_map & ESA6_RBN_STDDEV_map = ESA2_tot_map
      ;ESA2_gdf_map = ESA2_tot_map & ESA3_gdf_map = ESA2_tot_map & ESA4_gdf_map = ESA2_tot_map & ESA5_gdf_map = ESA2_tot_map & ESA6_gdf_map = ESA2_tot_map
      ;ESA2_gdf_stddev_map = ESA2_tot_map & ESA3_gdf_stddev_map = ESA2_tot_map & ESA4_gdf_stddev_map = ESA2_tot_map & ESA5_gdf_stddev_map = ESA2_tot_map & ESA6_gdf_stddev_map = ESA2_tot_map
      ESA2_cdate_map = ESA2_tot_map & ESA3_cdate_map = ESA2_tot_map & ESA4_cdate_map = ESA2_tot_map & ESA5_cdate_map = ESA2_tot_map & ESA6_cdate_map = ESA2_tot_map
      
     

      kk = 0
      for ii = 0, lon_arr.length-1 do begin
        for jj = 0, lat_arr.length-1 do begin
          for ll = 2, 6 do begin
            !null = execute('ESA'+strcompress(ll, /rem)+'_cdate_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_cdate[kk]')
            ;!null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_rbn[kk]')
            ;!null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_gdf_stddev[kk]')
            ;!null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map[ii, jj] = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV[kk]')
          endfor
          kk += 1
        endfor
      endfor
      
      ;stop

      for ll = 2, 6 do begin
        ;!null = execute('ESA'+strcompress(ll, /rem)+'_rbn_map = ESA'+strcompress(ll, /rem)+'_rbn_map')
        !null = execute('ESA'+strcompress(ll, /rem)+'_cdate_map = ESA'+strcompress(ll, /rem)+'_cdate_map')
        ;!null = execute('ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map = ESA'+strcompress(ll, /rem)+'_RBN_STDDEV_map')
        ;!null = execute('ESA'+strcompress(ll, /rem)+'_gdf_stddev_map = ESA'+strcompress(ll, /rem)+'_gdf_stddev_map')
      endfor
      

      ;SAVE, FILE = dpath +'SAV/Theseus-L_RBN_SEP_cdate_'+year+'A_'+year+'B_'+str+'.sav', /compress, lon_arr, lat_arr, $
      SAVE, FILE = dpath +'SAV/Theseus-L_RBN_SEP_cdate_'+year+'A_'+year+'B_'+str+'.sav', /compress, lon_arr, lat_arr, $
        ;ESA2_rbn_MAP, ESA2_RBN_STDDEV_MAP, ESA3_rbn_MAP, ESA3_RBN_STDDEV_MAP, ESA4_rbn_MAP, ESA4_RBN_STDDEV_MAP, ESA5_rbn_MAP, ESA5_RBN_STDDEV_MAP, ESA6_rbn_MAP, ESA6_RBN_STDDEV_MAP, $
        ;ESA2_gdf_MAP, ESA2_gdf_stddev_MAP, ESA3_gdf_MAP, ESA3_gdf_stddev_MAP, ESA4_gdf_MAP, ESA4_gdf_stddev_MAP, ESA5_gdf_MAP, ESA5_gdf_stddev_MAP, ESA6_gdf_MAP, ESA6_gdf_stddev_MAP
        ESA2_cdate_MAP, ESA3_cdate_MAP, ESA4_cdate_MAP, ESA5_cdate_MAP, ESA6_cdate_MAP
    endfor

  endfor

end




