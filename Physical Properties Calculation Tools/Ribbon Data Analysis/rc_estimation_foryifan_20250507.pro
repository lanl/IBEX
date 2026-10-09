pro rc_estimation_foryifan_20250507

cd, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate'

  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  RC_Circ_Funsten2013 = [[74.8, 43.1, 218.5], $
    [73.3, 40.5, 220.3], $
    [73.2, 39.8, 219.6], $
    [74.4, 37.7, 217.9], $
    [79.2, 32.4, 214.2]]

  RC_Ellip_Funsten2013 = [[74.9, 73.2, 97.4, 42.2, 219.8], $
    [75.4, 71.0, 111.3, 40.2, 220.6], $
    [74.4, 71.8, 100.0, 39.7, 219.9], $
    [75.7, 70.9, 76.6, 37.6, 218.8], $
    [80.3, 75.7, 65.3, 32.5, 215.5]]


  lat_rc = [1d:180-1d:2d]
  LON_ARR = [1d:360-1d:2d]
  LAT_ARR = [-90+1d:90-1d:2d]

  y_end = '2018'
  wotail = 0
  if wotail then tail_str = 'WO_Tail' else tail_str = 'W_Tail'
  tailidx = [68:113]

  ; Yifan's Model
  path = 'U:\Data\new_ribbon_center_position_5.7\new_ribbon_center_position_5.7\'
  MFP = [500, 1000, 2000, 5000]
  for midx = 0, MFP.length-1 do begin
    dpath = path+strcompress(MFP[midx], /rem)+'au\'

    rc_c_lonlat_sim = REPLICATE(!VALUES.D_NAN, 5, 4) ; esa x Rlonlatsigsr

    FOR ESA = 2, 6 DO BEGIN

      ESA_STR = strcompress(esa, /rem)
      readcol, dpath+'array_ESA'+strcompress(esa, /rem)+'.txt', Lon_T, Lat_T, Flux_T, format = 'F, F, F, F'

      RBN_MAP = transpose(reform(Flux_T, 90, 180))

      ; 111111111111111 esa map from ec to rc
      res = meshgrid(LON_ARR, lat_arr)
      lat_mat = res.remove()
      lon_mat = res.remove()
      t0 = RC_Circ_Funsten2013[1, esa-2] ; ecliptic latitude in degree (not colat or polar angle)
      p0 = RC_Circ_Funsten2013[2, esa-2] ; ecliptic longitude in degree

      RCC_ARR = []
      RCE_ARR = []

      TIC
      ITER = 10

      FOR RCIDX = 0, ITER DO BEGIN
        print, 'ESA', esa, RCIDX, iter
        IF RCIDX EQ 0 THEN begin
          RC = [P0, T0]
          initial_guess_c = RC_Circ_Funsten2013[*, esa-2]
          initial_guess_e = RC_Ellip_Funsten2013[*, esa-2]
        ENDIF ELSE begin
          ;          RC = [RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]] ; [RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]]
          rc = [RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]]
          initial_guess_c = RC_SPG.PAR_C
          initial_guess_e = RC_SPG.PAR_E
        ENDELSE

        res = conv_coord_ec_rc(lON_mat, lat_mat+90, RC[0], RC[1], /reverse, nose_POS = [255.6, 5.14])
        P1 = RES.LON
        T1 = RES.LAT
        LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
        LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)

        !NULL = EXECUTE('esa_RBN_rc_map = INTERPOLATE(RBN_MAP, LON_IDX, LAT_IDX, /DOUBLE)') ; Now we use mean of multiple samples
        esa_RBN_stddev_rc_map = esa_RBN_rc_map
        esa_RBN_stddev_rc_map[*] = 0d

        RES_PEAK = RIBBON_PEAK_ESTIMATE(esa_RBN_rc_map, esa_RBN_stddev_rc_map, RC, lon_arr, lat_rc, N_SAMPLE = 1)

        if wotail then RES_PEAK.PEAK_RAND_RES[tailidx] = !values.d_nan

        RC_SPG = RC_FIT_RAND(LON_ARR, reform(RES_PEAK.PEAK_RAND_RES), RC, ESA, initial_guess_c, initial_guess_e, Error = replicate(1d, lon_arr.length));, ERROR = 1/sqrt(reform(RES_PEAK.flux[1, *])));, N_SAMPLE = 500)

        RCC_ARR = [[RCC_ARR], [RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]]]
        RCE_ARR = [[RCE_ARR], [RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]]]
        if (map_2points(RC[0], rc[1], RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]))[0] lt 1e-2 then break
      ENDFOR
      TOC
      ;      rc_c_lonlat_sim[esa-2, *] = [RC_SPG.PAR_c[0], RC_SPG.PAR_c[2], RC_SPG.PAR_c[1], RC_SPG.SIG_C]


      rc_c_lonlat_sim[esa-2, *] = [(RC_SPG.PAR_E[0]+RC_SPG.PAR_E[1])/2, RC_SPG.PAR_E[4], RC_SPG.PAR_E[3], RC_SPG.SIG_E]


    ENDFOR ; ESA


    openw, lun, path+Tail_STR+'_Simulation_RC_mu_'+strcompress(MFP[midx], /rem)+'au.txt', /get_lun
    printf, lun, 'ESA'+string(9B)+'Lon_EC'+string(9B)+'Lat_EC'+string(9B)+string(9B)+'DeltaR_avg'
    for ee = 0, 4 do begin
      printf, lun, string(ee+2, format = '(I3)')+string(9B)+ $
        string(rc_c_lonlat_sim[ee, 1], format = '(f6.2)')+string(9B)+string(rc_c_lonlat_sim[ee, 2], format = '(f6.2)')+string(9B)+ $
        string(rc_c_lonlat_sim[ee, -1], format = '(f10.2)')
    endfor
    free_lun, lun

    ;    co = ['black', 'blue', 'green', 'orange', 'red']
    ;    lon_sig = rc_c_lonlat[*, -1]
    ;    lat_sig = rc_c_lonlat[*, -1]
    ;
    ;    sc = plot([0, 0], [0, 0], /nodata, xr = [235, 205], yr = [30, 50], title = 'Sim mu_'+strcompress(MFP[midx], /rem)+'au')
    ;    for ee = 0, 4 do begin
    ;      p = scatterplot(replicate(rc_c_lonlat_sim[ee, 1], 2), replicate(rc_c_lonlat_sim[ee, 2], 2), symbol = 'D', over = sc, sym_color = co[ee], sym_thick = 3)
    ;      p = plot([rc_c_lonlat_sim[ee, 1]-lon_sig[ee], rc_c_lonlat_sim[ee, 1]+lon_sig[ee]], replicate(rc_c_lonlat_sim[ee, 2], 2), over = sc, co = co[ee])
    ;      p = plot(replicate(rc_c_lonlat_sim[ee, 1], 2), [rc_c_lonlat_sim[ee, 2]-lat_sig[ee], rc_c_lonlat_sim[ee, 2]+lat_sig[ee]], over = sc, co = co[ee])
    ;    endfor
  endfor ; mean free path


end


;pro RC_estimation_ForYifan_20250507
;
;  cd, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate'
;  RC_DAYEH_LONLAT = [[217.41, 44.36], $
;    [219.72, 41.50], $
;    [220.51, 39.96], $
;    [218.08, 38.44], $
;    [214.68, 34.13]]
;
;  RC_Circ_Funsten2013 = [[74.8, 43.1, 218.5], $
;    [73.3, 40.5, 220.3], $
;    [73.2, 39.8, 219.6], $
;    [74.4, 37.7, 217.9], $
;    [79.2, 32.4, 214.2]]
;
;  RC_Ellip_Funsten2013 = [[74.9, 73.2, 97.4, 42.2, 219.8], $
;    [75.4, 71.0, 111.3, 40.2, 220.6], $
;    [74.4, 71.8, 100.0, 39.7, 219.9], $
;    [75.7, 70.9, 76.6, 37.6, 218.8], $
;    [80.3, 75.7, 65.3, 32.5, 215.5]]
;
;
;  lat_rc = [1d:180-1d:2d]
;  LON_ARR = [1d:360-1d:2d]
;  LAT_ARR = [-90+1d:90-1d:2d]
;
;
;
;
;  ; Yifan's Model
;  path = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Sim_Yifan\new_ribbon_center_position5.6\new_ribbon_center_position5.6\'
;  MFP = [500, 1000, 2000, 5000]
;  for midx = 0, MFP.length-1 do begin
;    dpath = path+strcompress(MFP[midx], /rem)+'au\'
;
;    rc_c_lonlat_sim = REPLICATE(!VALUES.D_NAN, 5, 4) ; esa x Rlonlatsigsr
;
;    readcol, dpath+'arrayRC_peak_2.txt', Lat_T2, Lat_T3, Lat_T4, Lat_T5, Lat_T6, Lon_T, format = 'F, F, F, F'
;    FOR ESA = 2, 6 DO BEGIN
;      ESA_STR = strcompress(esa, /rem)
;
;      !null = execute('lat_t = lat_t'+strcompress(ESA, /rem))
;
;      TIC
;      t0 = RC_Circ_Funsten2013[1, esa-2] ; ecliptic latitude in degree (not colat or polar angle)
;      p0 = RC_Circ_Funsten2013[2, esa-2] ; ecliptic longitude in degree
;
;      RC = [P0, T0]
;      initial_guess_c = RC_Circ_Funsten2013[*, esa-2]
;      initial_guess_e = RC_Ellip_Funsten2013[*, esa-2]
;
;      wotail = 0
;      tailidx = [68:113]
;      if wotail then lat_t[tailidx] = !values.d_nan
;
;      RC_SPG = RC_FIT_RAND(Lon_T*!radeg, lat_t*!radeg, RC, ESA, initial_guess_c, initial_guess_e, Error = replicate(1d, Lon_T.length));, ERROR = 1/sqrt(reform(RES_PEAK.flux[1, *])));, N_SAMPLE = 500)
;
;      RCC_ARR = [RC_SPG.PAR_C[2], RC_SPG.PAR_C[1]]
;      RCE_ARR = [RC_SPG.PAR_E[4], RC_SPG.PAR_E[3]]
;      TOC
;      rc_c_lonlat_sim[esa-2, *] = [(RC_SPG.PAR_E[0]+RC_SPG.PAR_E[1])/2, RC_SPG.PAR_E[4], RC_SPG.PAR_E[3], RC_SPG.SIG_E]
;    ENDFOR ; ESA
;
;    openw, lun, path+'RibbonCenter_MFP'+strcompress(MFP[midx], /rem)+'au.txt', /get_lun
;    printf, lun, 'ESA'+string(9B)+'Lon_EC'+string(9B)+'Lat_EC'+string(9B)+string(9B)+'DeltaR_avg'
;    for ee = 0, 4 do begin
;      printf, lun, string(ee+2, format = '(I3)')+string(9B)+ $
;        string(rc_c_lonlat_sim[ee, 1], format = '(f6.2)')+string(9B)+string(rc_c_lonlat_sim[ee, 2], format = '(f6.2)')+string(9B)+ $
;        string(rc_c_lonlat_sim[ee, -1], format = '(f10.2)')
;    endfor
;    free_lun, lun
;  endfor ; mean free path
;
;  stop
;
;
;end