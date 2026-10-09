function ips_interp, var, t1, l1, t2, l2

  idxr1 = interpol(findgen(t1.length), t1, t2)
  idx2 = interpol(findgen(l1.length), l1, l2)
  return, interpolate(var, idxr1, idx2)

end


pro anti_corr

  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  cd, cpath

  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'
  tidx = where(time ge 2000 and time le 2023)
  time_ips = time[tidx]
  NSW_ips = NSW[tidx, *]
  VSW_ips = VSW[tidx, *]
  PDYN_ips = PDYN[tidx, *]
  ; sol_lat_ec

  ;  open solar wind boundary
  ;south

  VSW_s = VSW_ips[*, 0:8]
  lat = sol_lat_ec[0:8]
  lat_bound_s = replicate(!values.f_nan, time_ips.length)
  for ii = 0, time_ips.length-1 do begin
    VSW_s[ii, [where(VSW_s[ii, 1:-1]-VSW_s[ii, 0:-2] gt 0, /null)]] = !values.f_nan
    if total(VSW_s[ii, *] lt 500) eq 0 then continue
    if total(VSW_s[ii, *] gt 500) eq 0 then continue
    lat_bound_s[ii] = interpol(lat, VSW_s[ii, *], 500, /nan)
  endfor
  ;north
  VSW_n = VSW_ips[*, 10:18]
  lat = sol_lat_ec[10:18]
  lat_bound_n = replicate(!values.f_nan, time_ips.length)
  for ii = 0, time_ips.length-1 do begin
    VSW_n[ii, [where(VSW_n[ii, 1:-1]-VSW_n[ii, 0:-2] lt 0, /null)]] = !values.f_nan
    if total(VSW_n[ii, *] lt 500) eq 0 then continue
    if total(VSW_n[ii, *] gt 500) eq 0 then continue
    lat_bound_n[ii] = interpol(lat, VSW_n[ii, *], 500, /nan)
  endfor
  ;  open solar wind boundary

  ; omni ssn
  restore, 'D:\Data\omni\OMNI_1HR_1MIN_2000_2023.sav'
  T_TMP = JULDAY(1, 1, 1970, 0, 0, time_omni_1hr)

  jd2year, T_TMP, time_omni
  ; omni ssn


  tol = 1d-15

  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  data = read_csv('C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\HPmodel.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

  lon_hp = data.field1
  lat_hp = data.field2
  ts = data.field3
  hs = data.field4
  TRIANGULATE, lon_hp, lat_hp, tr_hp
  hp_dist = ts+hs


  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]

  mapname = 'Theseus'
  sepname = 'L'
  DPATH = dp+'Theseus-L\'
  fname = mapname+'-'+sepname+'_RC_Iteration'
  YEAR_MIN = 2009
  YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  year_arr = [YEAR_MIN:YEAR_MAX]
  year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]
  lon_num = 180


  fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
  fit_par_sig_circ = replicate(!values.d_nan, 3, year_arr.length, 5, 2); RLonLat x year x esa x ram

  fit_par_ellip = replicate(!values.d_nan, 6, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot,sig x year x esa x ram
  fit_par_sig_ellip = replicate(!values.d_nan, 5, year_arr.length, 5, 2); R,Lon,Lat,Ellip,Rot x year x esa x ram


  moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

  moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit

  map_stack = replicate(!values.d_nan, lon_num, 90, year_arr.length, 5, 2); moment x lon x year x esa x ram
  map_sig_stack = replicate(!values.d_nan, lon_num, 90, year_arr.length, 5, 2); moment x lon x year x esa x ram

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
      restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav'

      FOR ESA = 2, 6 DO BEGIN
        ESA_STR = strcompress(esa, /rem)
        if rc_c_lonlat[esa-2, 3] gt 0 then begin
          fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
          fit_par_sig_circ[*, (yidx-year_min), esa-2, ram] = reform([rc_c_PAR_SIG[esa-2, 0], rc_c_PAR_SIG[esa-2, 2], rc_c_PAR_SIG[esa-2, 1]]); RLonLat x year x esa
        endif

        if rc_e_lonlat[esa-2, 3] gt 0 then begin
          fit_par_ellip[*, (yidx-year_min), esa-2, ram] = [reform(rc_e_lonlat[esa-2, 0:2]), (1-(reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2), reform(rc_e_PAR[esa-2, 2]), reform(rc_e_lonlat[esa-2, 3])]; R,Lon,Lat,Ellip,Rot,sig x year x esa

          fit_par_sig_ellip[*, (yidx-year_min), esa-2, ram] = $
            [reform(sqrt(rc_E_PAR_SIG[esa-2, 0]^2+rc_E_PAR_SIG[esa-2, 1]^2)), $ ;R
            reform(rc_E_PAR_SIG[esa-2, 4]), $ ;Lon
            reform(rc_E_PAR_SIG[esa-2, 3]), $ ;Lat
            reform((reform(rc_e_PAR[esa-2, 1])/reform(rc_e_PAR[esa-2, 0]))^2*sqrt(2/rc_e_PAR[esa-2, 0]^2*rc_E_PAR_SIG[esa-2, 0]^2 + 2/rc_e_PAR[esa-2, 1]^2*rc_E_PAR_SIG[esa-2, 1]^2)), $ ;Ellip
            reform(rc_E_PAR_SIG[esa-2, 2])] ; Rot
        endif

        ;        reform(rc_e_PAR[esa-2, 1]/rc_e_PAR[esa-2, 0] * sqrt((rc_E_PAR_SIG[esa-2, 0]/rc_e_PAR[esa-2, 0])^2+(rc_E_PAR_SIG[esa-2, 1]/rc_e_PAR[esa-2, 1])^2)) ; ellipticity

        !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
        !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
        !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')

        !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
        !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
        !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')

        !NULL = EXECUTE('map_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')
        !NULL = EXECUTE('map_sig_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_stddev_MAP')


      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking

flux_stack = flux_stack[*, *, 0:9, *, *]
moment24_stack = moment24_stack[*, *, 0:9, *, *]
  idx = [0:179]
  flux4 = reform(flux_stack[0, idx, *, 4-2, 0], idx.length*10)
  fwhm4 = reform(moment24_stack[1, idx, *, 4-2, 0], idx.length*10)
  flux5 = reform(flux_stack[0, idx, *, 5-2, 0], idx.length*10)
  fwhm5 = reform(moment24_stack[1, idx, *, 5-2, 0], idx.length*10)
  print, 'ESA4', r_correlate(flux4, fwhm4)
  print, 'ESA5', r_correlate(flux5, fwhm5)


  for ii = 0, 179, 2 do begin
    idx = [0:ii]
    flux4 = reform(flux_stack[0, idx, *, 4-2, 0], idx.length*10)
    fwhm4 = reform(moment24_stack[1, idx, *, 4-2, 0], idx.length*10)
    flux5 = reform(flux_stack[0, idx, *, 5-2, 0], idx.length*10)
    fwhm5 = reform(moment24_stack[1, idx, *, 5-2, 0], idx.length*10)
    print, '===================================='
    print, 'ESA4', 0, ii, r_correlate(flux4, fwhm4)
    print, 'ESA5', 0, ii, r_correlate(flux5, fwhm5)
  endfor

  print, '===================================='

  for ii = 70, 90, 2 do begin
    idx = [ii-70:ii]
    flux4 = reform(flux_stack[0, idx, *, 4-2, 0], idx.length*10)
    fwhm4 = reform(moment24_stack[1, idx, *, 4-2, 0], idx.length*10)
    flux5 = reform(flux_stack[0, idx, *, 5-2, 0], idx.length*10)
    fwhm5 = reform(moment24_stack[1, idx, *, 5-2, 0], idx.length*10)
    print, 'ESA4', ii-70, ii, r_correlate(flux4, fwhm4)
    print, 'ESA5', ii-70, ii, r_correlate(flux5, fwhm5)
    print, '===================================='
  endfor

  stop





end