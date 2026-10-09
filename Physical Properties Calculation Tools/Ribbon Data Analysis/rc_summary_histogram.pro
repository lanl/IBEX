pro RC_SUMMARY_histogram, MAPNAME, SEPNAME, VER, cpath

  tol = 1d-15
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]
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
  win = window(dim = [800, 800], /buffer)
  win.refresh, /disable

  fname = mapname+'-'+sepname+'_RC_Iteration'
  DPATH = dp+mapname+'-'+sepname+'\'

  YEAR_MIN = 2009
  if mapname eq 'ISOC' then BEGIN
    if sepname eq 'L' then YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
    if sepname eq 'D' then YEAR_MAX = 2019 ; ISOC = 2019, THESEUS = 2020
    lon_num = 60
  endif
  if mapname eq 'Theseus' then BEGIN
    YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
    lon_num = 180
  endif
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

  moment_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  moment24_stack_error = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  flux_stack_error = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
  peak_lat_error = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit


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

        !null = execute('moment_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
        !null = execute('moment24_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
        !null = execute('flux_stack_error[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa
        !NULL = EXECUTE('peak_lat_error[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS_error')
      endfor ; esa
    endfor ; year
  ENDFOR ; ram
  ; data stacking

  BV = GreatCircle([255.6, 5.14], [226.99, 34.82], npath = 1000) ; ISMF 227.28, 34.62 Zirnstein et al. 2016b 2023, nose direction 259, 5 Funsten et al. 2013

  ; ============================ Longitudinal Distribution of Moments ============================
  win = window(dim = [900, 800], /buffer)
  win.refresh, /disable
  POS1 = [0.1, 0.08, 0.85, 0.7]
  POS2 = [0.1, 0.7, 0.85, 0.95]

  average_mom = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram
  average_mom2_4 = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram
  stddev_mom = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram
  stddev_mom2_4 = replicate(!values.d_nan, 5, 4, 2) ; esa x mom x ram

  average_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram
  average_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram
  stddev_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram
  stddev_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length) ; esa x mom x ram


  average4_mom = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram
  average4_mom2_4 = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram
  stddev4_mom = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram
  stddev4_mom2_4 = replicate(!values.d_nan, 5, 4, 2, 4) ; esa x mom x ram

  average4_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram
  average4_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram
  stddev4_mom_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram
  stddev4_mom2_4_year = replicate(!values.d_nan, 5, 4, 2, year_arr.length, 4) ; esa x mom x ram


  num_sec = 4
  lb_arr = linspace(0, 360, num_sec+1)
  lb_arr = lb_arr-10
  sector_name = ['Nose', 'North', 'Tail', 'South']

  e_step = [0.71,1.11,1.74,2.73,4.29]
  e_color = ['blue','green','yellow','orange','red']

  ;  win = window(dim = [800, 800], /buffer)
  ;  win.refresh, /disable

  ;  win3 = window(dim = [800, 800], /buffer)
  ;  win3.refresh, /disable

  win = window(dim = [1800, 1600], /buffer)
  win.refresh, /disable
  pos = make_plot_pos(0.20, 0.1, 0.95, 0.95, 4, /col, gap = 0.04)


  co = rgb_vector(year_arr.length, ct = 13)
  ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  FOR ram = 0, 1 DO BEGIN
    IF ram THEN str = 'ARam' ELSE str = 'Ram'

    for momidx = 0, 3 do begin
      pos_tmp = make_plot_pos(pos[0, -momidx-1], pos[1, -momidx-1], pos[2, -momidx-1], pos[3, -momidx-1], 5, /row, gap = 0.025)

      if momidx eq 0 then begin
        mrg = [65., 90]
        intv = 5
        RGB_TABLE = 33
        mom_str = 'Angular Radius'
        mom_unit = '[$\deg$]'
        mom_tmp = moment_stack
        mom_stddev_tmp = moment_stack_error
      endif
      if momidx eq 1 then BEGIN
        mrg = [10, 50.]
        intv = 10
        RGB_TABLE = 33
        mom_str = 'FWHM'
        mom_unit = '[$\deg$]'
        mom_tmp = moment24_stack
        mom_stddev_tmp = moment24_stack_error
      endif
      if momidx eq 2 then BEGIN
        mrg = [-0.2, 0.2]
        intv = 0.1
        ;        mrg = [-1d, 1]
        RGB_TABLE = 70
        mom_str = 'Skewness'
        mom_unit = ''
        mom_tmp = moment24_stack
        mom_stddev_tmp = moment24_stack_error
      ENDIF
      if momidx eq 3 then BEGIN
        mrg = [-0.7, 0.7]
        intv = 0.3
        ;        mrg = [2d, 10]
        RGB_TABLE = 33
        mom_str = 'Kurtosis'
        mom_unit = ''
        mom_tmp = moment24_stack
        mom_stddev_tmp = moment24_stack_error
      endif

      for esa = 2, 6 do begin


        ESA_STR = strcompress(esa, /rem)

        ytmp = reform(mom_tmp[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram
        ytmp_error = reform(mom_stddev_tmp[momidx, *, *, esa-2, ram]); moment x lon x year x esa x ram

        NBIN = 20

        HIST_RES = REPLICATE(!VALUES.D_NAN, NBIN, year_arr.LENGTH)
        p = objarr(year_arr.length)
        p3 = objarr(year_arr.length/3 + 1)
        cnt = 0
        for yy = YEAR_MIN-YEAR_MIN, YEAR_MAX-YEAR_MIN DO BEGIN
          TMP =  HISTOGRAM(YTMP[*, YY], MIN = MRG[0], MAX = MRG[1], NBINS = 20, LOC = LOC)
          HIST_RES[*, YY] = DOUBLE(TMP)/MAX(TMP)
          if ((yy mod 3) eq 0) then begin
            ;            p3[cnt] = PLOT((loc[0:-2]+loc[1:-1])/2, HIST_RES[0:-2, YY], co = co[*, yy], name = string(yy+year_min, format = '(I4)'), current = win3, pos = [0.15, 0.1, 0.90, 0.90], XTITLE = MOM_STR+MOM_UNIT, YTITLE = 'norm. # of samples', FONT_SIZE = 15, xr = [MRG[0], MRG[1]], yr = [0, 1.1], title = 'ESA'+esa_str+', '+mom_str)
            cnt += 1
          endif
          ;          p[yy] = PLOT((loc[0:-2]+loc[1:-1])/2, HIST_RES[0:-2, YY], co = co[*, yy], name = string(yy+year_min, format = '(I4)'), current = win, pos = [0.15, 0.1, 0.90, 0.90], XTITLE = MOM_STR+MOM_UNIT, YTITLE = 'norm. # of samples', FONT_SIZE = 15, xr = [MRG[0], MRG[1]], yr = [0, 1.1], title = 'ESA'+esa_str+', '+mom_str)
        ENDFOR
        ;        lgd = legend(target = p3, pos = [0.9, 0.9], /auto_text_color, shadow = 0, linestyle = 6, transparency = 100, sample_width = 0, vertical_spacing = 0.01)
        ;        lgd = legend(target = p, pos = [0.9, 0.9], /auto_text_color, shadow = 0, linestyle = 6, transparency = 100, sample_width = 0, vertical_spacing = 0.01)

        ;        win.save, file_tmp+'Moment_Histogram_Line_1year_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_'+str+'_ESA'+esa_str+'.png'
        ;        win.erase
        ;        win3.save, file_tmp+'Moment_Histogram_Line_3year_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_'+str+'_ESA'+esa_str+'.png'
        ;        win3.erase

        if esa eq 2 then begin
          ext = {YTITLE:'YEAR'}
          tx = text(pos_tmp[0, 0]*0.4, (pos_tmp[1, 0]+pos_tmp[3, 0])/2, mom_str, align = 0.5, vertical_align = 0.5, font_size = 20)
        endif else begin
          ext = {ytickformat:'(a1)'}
        endelse

        if momidx eq 0 then begin
          tx = text((pos_tmp[0, esa-2]+pos_tmp[2, esa-2])/2, (1d + pos_tmp[3, esa-2])/2, 'E '+string(e_step[ESA-2], format = '(f5.2)')+' keV', align = 0.5, vertical_align = 0.5, font_size = 25)
        endif

        SP = SPEC_PLOT(HIST_RES[0:-2, *], (loc[0:-2]+loc[1:-1])/2, year_arr, xminor = 0, yminor = 1, ytickinterval = 2, xtickinterval = intv, _extra = ext, rgb_table = 61, current = win, xr = [MRG[0], MRG[1]], yr = [year_min, year_max], pos = pos_tmp[*, esa-2], XTITLE = MOM_STR+MOM_UNIT, FONT_SIZE = 15, data_min = 0, data_max = 1)
        ;        val_mean = total(HIST_RES[0:-2, *]*rebin((loc[0:-2]+loc[1:-1])/2, loc.length-1, year_arr.length), 1)/total(HIST_RES[0:-2, *], 1)

        val_mean = total(ytmp/ytmp_error^2, 1, /nan)/total(1/ytmp_error^2, 1, /nan)

        sc = scatterplot(val_mean, year_arr, symbol = '.', sym_thick = 3, sym_color = 'yellow', over = sp)


        ;        CB = COLOR_BAR(SP, YTITLE = 'norm. # of samples', font_size = 15)

        ;        SP = SPEC_PLOT(HIST_RES[0:-2, *], (loc[0:-2]+loc[1:-1])/2, year_arr, rgb_table = 61, current = win, xr = [MRG[0], MRG[1]], yr = [year_min, year_max], pos = [0.15, 0.1, 0.80, 0.90], XTITLE = MOM_STR+MOM_UNIT, YTITLE = 'YEAR', FONT_SIZE = 15, data_min = 0, data_max = 1, title = 'ESA'+esa_str+', '+mom_str)
        ;        CB = COLOR_BAR(SP, YTITLE = 'norm. # of samples', font_size = 15)

        ;        win.save, file_tmp+'Moment_Histogram_Spec_'+STRCOMPRESS(momidx+1, /REM)+mom_str+'_'+str+'_ESA'+esa_str+'.png'
        ;        win.erase



      endfor ; esa

    endfor ; mom

    y = dindgen(10)
    x = linspace(0, 1, 256)

    img = bindgen(256)
    img = rebin(img, 256, 10)

    CB = spec_plot(img, x, y, ytickformat = '(a1)', yminor = 0, ymajor = 0, xminor = 0, xtickinterval = 1, xTITLE = 'norm. # of samples', font_size = 15, pos = [pos[0, 0], pos[1, 0]*0.4, pos[2, 0], pos[1, 0]*0.60], current = win, rgb_table = 61)

    win.save, file_tmp+'Moment_Histogram_Spec_Summary_'+str+'.png'
    win.erase

    ; ===================================================================== NUMERICAL MOMENTS =====================================================================
  endfor ; ram





  win.close
  ; ============================ Longitudinal Distribution of Moments ============================


end