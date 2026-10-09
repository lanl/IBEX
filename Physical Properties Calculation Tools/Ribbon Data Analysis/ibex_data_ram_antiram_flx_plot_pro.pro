PRO IBEX_DATA_RAM_ANTIRAM_flx_PLOT_pro, MAPNAME, SEPNAME, VER, cpath
  Load_IBEX_color_table
  tvlct,red,green,blue,/get
  co = [[red], [green], [blue]]

  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  DPATH = DP+MAPNAME+'-'+SEPNAME+'\'
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+VER+'\'

  YEAR_MIN = 2009
  if mapname eq 'ISOC' then IF SEPNAME eq 'D' then YEAR_MAX = 2019 else YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  if mapname eq 'Theseus' then YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020

  win = window(dim = [3600, 2800], /buffer)
  win.refresh, /disable
  pos1 = make_plot_pos(0.05, 0.75, 0.95, 0.95, 3, /row, gap = 0.09)
  pos2 = make_plot_pos(0.05, 0.525, 0.95, 0.725, 3, /row, gap = 0.09)
  pos11 = [[pos1], [pos2]]

  pos1 = make_plot_pos(0.05, 0.255, 0.95, 0.455, 3, /row, gap = 0.09)
  pos2 = make_plot_pos(0.05, 0.030, 0.95, 0.230, 3, /row, gap = 0.09)
  pos22 = [[pos1], [pos2]]

  FOR ABIDX = 0, 0 DO BEGIN
    IF ABIDX THEN AB = 'AB' ELSE AB = 'BA'

    for RAM = 0, 1 do begin
      if RAM eq 0 then str = 'Ram' else str = 'ARam'

      FPATH = DPATH_NEW+'MapPlot\'+STR+'\'
      FILE_MKDIR, FPATH
      for yidx = YEAR_MIN, YEAR_MAX do begin
        year = string(yidx, format = '(I4)')

        restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav'

        cb_range = fltarr(2, 2, 5)
        ec_str = 'EC'
        FOR GDF = 0, 2 DO BEGIN
          IF GDF EQ 0 THEN GDF_STR = 'GDF'
          IF GDF EQ 1 THEN GDF_STR = 'RBN'
          IF GDF EQ 2 THEN GDF_STR = 'TOT'
          esa_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)

          FOR ESA = 2, 6 DO BEGIN
            ESA_STR = strcompress(esa, /rem)
            IF GDF NE 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
            IF GDF EQ 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_RBN_MAP + ESA'+ESA_STR+'_GDF_MAP')

            P0 = RC_C_LONLAT[ESA-2, 1]
            T0 = RC_C_LONLAT[ESA-2, 2]

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
            esa_maps[*, *, esa-2] = ESA_MAP

          ENDFOR ; ESA


          ec_map_plot, esa_maps, 1, GDF_STR
          FPATH_TMP = fpatH+GDF_STR+'\'
          FILE_MKDIR, FPATH_TMP
          write_png, FPATH_TMP+YEAR+'_'+ec_str+'_'+GDF_STR+'.png',tvrd(/true)

        ENDFOR ; GDF


        ec_str = 'RC'
        FOR GDF = 0, 2 DO BEGIN
          IF GDF EQ 0 THEN GDF_STR = 'GDF'
          IF GDF EQ 1 THEN GDF_STR = 'RBN'
          IF GDF EQ 2 THEN GDF_STR = 'TOT'
          esa_maps = dblarr(LON_ARR.LENGTH, LAT_ARR.LENGTH, 5)

          FOR ESA = 2, 6 DO BEGIN
            ESA_STR = strcompress(esa, /rem)
            IF GDF NE 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
            IF GDF EQ 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_RBN_MAP + ESA'+ESA_STR+'_GDF_MAP')

            esa_maps[*, *, esa-2] = ESA_MAP
          ENDFOR ; ESA

          RC_map_plot, esa_maps, 1, GDF_STR
          FPATH_TMP = fpatH+GDF_STR+'\'
          FILE_MKDIR, FPATH_TMP
          write_png, FPATH_TMP+YEAR+'_'+ec_str+'_'+GDF_STR+'.png',tvrd(/true)


        ENDFOR ; GDF


      ENDFOR ; YEAR
    ENDFOR ; RAM
  ENDFOR ; AB
  WDELETE, 0

END