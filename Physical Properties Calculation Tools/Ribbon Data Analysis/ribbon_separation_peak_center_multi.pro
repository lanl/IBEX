Pro Ribbon_Separation_Peak_Center_MULTI, YIDX, MAPNAME, SEPNAME, ver, cpath, N_SAMPLE
  MAPNAME = 'Theseus'
  yidx = 2013
  SEPNAME = 'L'
  VER = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\'
  N_SAMPLE = 1000

  path_str = strsplit(cpath, '\', /extract)
  cd, cpath

  !EXCEPT = 0
  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'

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
  ;  hp load
  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  RC_Circ_Funsten2013 = [[0, 0, 0], $
    [0, 0, 0], $
    [74.8, 43.1, 218.5], $
    [73.3, 40.5, 220.3], $
    [73.2, 39.8, 219.6], $
    [74.4, 37.7, 217.9], $
    [79.2, 32.4, 214.2]]

  RC_Ellip_Funsten2013 = [[0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0], $
    [74.9, 73.2, 97.4, 42.2, 219.8], $
    [75.4, 71.0, 111.3, 40.2, 220.6], $
    [74.4, 71.8, 100.0, 39.7, 219.9], $
    [75.7, 70.9, 76.6, 37.6, 218.8], $
    [80.3, 75.7, 65.3, 32.5, 215.5]]



  ; ************************** INPUT **************************

  DPATH = strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-'+SEPNAME+'\'

  ; ************************** INPUT **************************
  co = rgb_vector(5)
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+ver+'\'
  FILE_MKDIR, DPATH_NEW
  FOR ram = 0, 1 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'
    survp = reform(SURVP_MAP[*, ram, *, *, *])

    IF MAPNAME EQ 'Theseus' then BEGIN
      year = string(yidx, format = '(I4)')
      if Sepname eq 'D' then RESTORE, dpath +'SAV\'+MAPNAME+'-'+SEPNAME+'_tot_SEP_'+year+'_'+str+'.sav'
      ;      if Sepname eq 'D' then RESTORE, strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-L\SAV\'+MAPNAME+'-L_RBN_SEP_'+year+'_'+str+'.sav'
      if Sepname eq 'L' then RESTORE, dpath +'SAV\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'
      lat_rc = [1:179:2.]
      fit_func = fltarr(lon_arr.length, 5)
    ENDIF
    IF MAPNAME EQ 'ISOC' then BEGIN
      year = string(yidx, format = '(I4)')
      if Sepname eq 'D' then RESTORE, dpath+'SAV\'+year+'_flux_cg.sav'
      ;      if Sepname eq 'D' then RESTORE, strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-L\SAV\'+MAPNAME+'-L_RBN_SEP_'+year+'_'+str+'.sav'
      if Sepname eq 'L' then RESTORE, dpath +'SAV\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'
      lat_rc = [3:177:6.]
      LON_ARR = [3:357:6.]
      LAT_ARR = [-87:87:6.]
      fit_func = fltarr(LON_ARR.length, 5)
    ENDIF

    rc_c_lonlat = REPLICATE(!VALUES.D_NAN, 5, 4) ; esa x Rlonlatsigsr
    rc_e_lonlat = REPLICATE(!VALUES.D_NAN, 5, 4) ; esa x Rlonlatsig
    rc_e_PAR = REPLICATE(!VALUES.D_NAN, 5, 5) ; esa x A,B,ROT,lon,lat

    rc_c_PAR_SIG = REPLICATE(!VALUES.D_NAN, 5, 3) ; esa x R,lon,lat
    rc_E_PAR_SIG = REPLICATE(!VALUES.D_NAN, 5, 5) ; esa x A,B,ROT,lon,lat

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      print, YEAR, 'ESA'+esa_str

      ; 111111111111111 esa map from ec to rc
      res = meshgrid(LON_ARR, lat_arr)
      lat_mat = res.remove()
      lon_mat = res.remove()
      t0 = RC_DAYEH_LONLAT[1, esa-2] ; ecliptic latitude in degree (not colat or polar angle)
      p0 = RC_DAYEH_LONLAT[0, esa-2] ; ecliptic longitude in degree

      RCC_ARR = []
      RCE_ARR = []
      TIC
      ITER = 10

      FOR RCIDX = 0, ITER DO BEGIN
        IF RCIDX EQ 0 THEN begin
          RC = [P0, T0]
          initial_guess_c = RC_Circ_Funsten2013[*, esa]
          initial_guess_e = RC_Ellip_Funsten2013[*, esa]
        ENDIF ELSE begin
          RC = [RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]] ; [RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]]
          ;          rc = [RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]]
          initial_guess_c = RC_SPG.PAR_C
          initial_guess_e = RC_SPG.PAR_E
        ENDELSE

        res = conv_coord_ec_rc(lON_mat, lat_mat+90, RC[0], RC[1], /reverse)
        P1 = RES.LON
        T1 = RES.LAT
        LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
        LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

        ; Ribbon Separation, Only for XX-D
        if Sepname eq 'D' then begin
          esa_rc_map = INTERPOLATE(ESA_MAP, LON_IDX, LAT_IDX, /DOUBLE)
          esa_stddev_rc_map = INTERPOLATE(esa_stddev_map, LON_IDX, LAT_IDX, /DOUBLE)
          RES = Ribbon_Separation_Dan(esa_rc_map, esa_stddev_rc_map, RC, lon_arr, lat_rc, ESA)
          fit_func[*, esa-2] = res.func
          esa_RBN_rc_map = RES.RBN
          esa_GDF_rc_map = RES.GDF
          esa_RBN_stddev_rc_map = RES.RBN_STDDEV
          esa_GDF_stddev_rc_map = RES.GDF_STDDEV
        endif
        ; Ribbon Separation, Only for XX-D

        if Sepname eq 'L' then begin
          ;          !NULL = EXECUTE('esa'+ESA_STR+'_RBN_STDDEV_map = esa'+ESA_STR+'_RBN_map+esa'+ESA_STR+'_RBN_STDDEV_map')
          ;          !NULL = EXECUTE('esa'+ESA_STR+'_GDF_STDDEV_map = esa'+ESA_STR+'_GDF_map+esa'+ESA_STR+'_GDF_STDDEV_map')
          !NULL = EXECUTE('esa_RBN_rc_map = INTERPOLATE(esa'+ESA_STR+'_RBN_map, LON_IDX, LAT_IDX, /DOUBLE)')
          !NULL = EXECUTE('esa_GDF_rc_map = INTERPOLATE(esa'+ESA_STR+'_GDF_map, LON_IDX, LAT_IDX, /DOUBLE)')
          !NULL = EXECUTE('esa_RBN_stddev_rc_map = INTERPOLATE(esa'+ESA_STR+'_RBN_STDDEV_map, LON_IDX, LAT_IDX, /DOUBLE)')
          !NULL = EXECUTE('esa_GDF_stddev_rc_map = INTERPOLATE(esa'+ESA_STR+'_GDF_STDDEV_map, LON_IDX, LAT_IDX, /DOUBLE)')

          if mapname eq 'Theseus' then begin
            esa_RBN_rc_map = esa_RBN_rc_map/transpose(reform(survp[yidx-2009, *, *, esa-1]))
            esa_GDF_rc_map = esa_GDF_rc_map/transpose(reform(survp[yidx-2009, *, *, esa-1]))
          endif
        endif
        
        ;        N_SAMPLE = 1000
        RES_PEAK = RIBBON_PEAK_ESTIMATE(esa_RBN_rc_map, esa_RBN_stddev_rc_map, esa_GDF_rc_map, RC, lon_arr, lat_rc, N_SAMPLE = N_SAMPLE)

        RC_SPG = RC_FIT_RAND(LON_ARR, reform(RES_PEAK.PEAK_RAND_RES), RC, ESA, initial_guess_c, initial_guess_e, Error = replicate(1d, lon_arr.length));, ERROR = 1/sqrt(reform(RES_PEAK.flux[1, *])));, N_SAMPLE = 500)

        RCC_ARR = [[RCC_ARR], [RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]]]
        RCE_ARR = [[RCE_ARR], [RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]]]

        if (map_2points(RC[0], rc[1], RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]))[0] lt 1e-2 then break
      ENDFOR
      TOC

      ;            print, rcidx, (map_2points(RC[0], rc[1], RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]))[0]
      !NULL = EXECUTE('ESA'+ESA_STR+'_RBN_MAP = esa_RBN_rc_map')
      !NULL = EXECUTE('ESA'+ESA_STR+'_GDF_MAP = esa_GDF_rc_map')
      !NULL = EXECUTE('ESA'+ESA_STR+'_RBN_STDDEV_MAP = esa_RBN_stddev_rc_map')
      !NULL = EXECUTE('ESA'+ESA_STR+'_GDF_STDDEV_MAP = esa_GDF_stddev_rc_map')

      rc_c_lonlat[esa-2, *] = [RC_SPG.PAR_c[0], RC_SPG.PAR_c[2], RC_SPG.PAR_c[1], RC_SPG.SIG_C]
      rc_e_lonlat[esa-2, *] = [(RC_SPG.PAR_E[0]+RC_SPG.PAR_E[1])/2, RC_SPG.PAR_E[4], RC_SPG.PAR_E[3], RC_SPG.SIG_E]
      rc_e_PAR[esa-2, *] = RC_SPG.PAR_E

      rc_c_PAR_SIG[esa-2, *] = RC_SPG.PAR_SIG_C ; esa x R,lon,lat
      rc_E_PAR_SIG[esa-2, *] = RC_SPG.PAR_SIG_E ; esa x A,B,ROT,lon,lat

      !NULL = EXECUTE('ESA'+ESA_STR+'_num_mom = RES_PEAK.num_mom')
      !NULL = EXECUTE('ESA'+ESA_STR+'_MOM2_4 = RES_PEAK.MOM2_4')
      !NULL = EXECUTE('ESA'+ESA_STR+'_flux = RES_PEAK.flux')
      !NULL = EXECUTE('ESA'+ESA_STR+'_peak_pos = REFORM(RES_PEAK.MOM2_4[0, *])')

      !NULL = EXECUTE('ESA'+ESA_STR+'_num_mom_error = RES_PEAK.num_mom_error')
      !NULL = EXECUTE('ESA'+ESA_STR+'_MOM2_4_error = RES_PEAK.MOM2_4_error')
      !NULL = EXECUTE('ESA'+ESA_STR+'_flux_error = RES_PEAK.flux_error')
      !NULL = EXECUTE('ESA'+ESA_STR+'_peak_pos_error = REFORM(stddev(RES_PEAK.peak_rand_res, dim = 2, /nan))')

      PEAK_FIT = [[RC_SPG.RES_C], [RC_SPG.RES_E]]
      !NULL = EXECUTE('ESA'+ESA_STR+'_PEAK_FIT = PEAK_FIT')
      ;      p = plot(RCC_ARR[0, *], RCC_ARR[1, *], TITLE = STRING(ESA), /over, co = co[*, esa-2], symbol = '*', xr = [200, 240], yr = [25, 55])

    ENDFOR ; ESA

    save, file = DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav', /COMPRESS, lon_arr, lat_arr, lat_rc, $
      esa2_flux, esa2_peak_FIT, esa2_peak_pos, esa2_num_mom, esa2_MOM2_4, esa2_rbn_map, esa2_gdf_map, esa2_rbn_stddev_map, esa2_gdf_stddev_map, $
      esa3_flux, esa3_peak_FIT, esa3_peak_pos, esa3_num_mom, esa3_MOM2_4, esa3_rbn_map, esa3_gdf_map, esa3_rbn_stddev_map, esa3_gdf_stddev_map, $
      esa4_flux, esa4_peak_FIT, esa4_peak_pos, esa4_num_mom, esa4_MOM2_4, esa4_rbn_map, esa4_gdf_map, esa4_rbn_stddev_map, esa4_gdf_stddev_map, $
      esa5_flux, esa5_peak_FIT, esa5_peak_pos, esa5_num_mom, esa5_MOM2_4, esa5_rbn_map, esa5_gdf_map, esa5_rbn_stddev_map, esa5_gdf_stddev_map, $
      esa6_flux, esa6_peak_FIT, esa6_peak_pos, esa6_num_mom, esa6_MOM2_4, esa6_rbn_map, esa6_gdf_map, esa6_rbn_stddev_map, esa6_gdf_stddev_map, $
      esa2_flux_error, esa2_peak_pos_error, esa2_num_mom_error, esa2_MOM2_4_error, $
      esa3_flux_error, esa3_peak_pos_error, esa3_num_mom_error, esa3_MOM2_4_error, $
      esa4_flux_error, esa4_peak_pos_error, esa4_num_mom_error, esa4_MOM2_4_error, $
      esa5_flux_error, esa5_peak_pos_error, esa5_num_mom_error, esa5_MOM2_4_error, $
      esa6_flux_error, esa6_peak_pos_error, esa6_num_mom_error, esa6_MOM2_4_error, $
      rc_c_lonlat, rc_e_lonlat, rc_e_PAR, rc_c_PAR_SIG, rc_E_PAR_SIG, fit_func

  endfor ; ram


end