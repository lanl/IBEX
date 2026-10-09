function ips_interp, var, t1, l1, t2, l2

  idxr1 = interpol(findgen(t1.length), t1, t2)
  idx2 = interpol(findgen(l1.length), l1, l2)
  return, interpolate(var, idxr1, idx2)

end


;pro map_plot_tmp, map_tmp, dmin, dmax, cb = cb
;  !P.BACKGROUND = 0
;  !P.COLOR = 0
;  !p.position=0
;  !p.font=1
;  !p.multi=[0,3,2,0,0]
;  device, retain=2
;
;  p0lon = 255.6 ;180.+75.7
;  p0lat = 0;nose_lat
;  ; ISMF 227.28, 34.62 Zirnstein et al. 2016b 2023, nose direction 259, 5 Funsten et al. 2013
;
;
;  ascii_map=reverse(map_tmp,1)
;  imSize=SIZE(ascii_map)
;  magnifiedImg = CONGRID(ascii_map, 5.*imsize[1],6.*imsize[2])
;  this_map = bytscl(magnifiedImg, min = dmin, max = dmax, top=255)
;  MAP_SET, p0lat,360.-p0lon,0, /advance,position=[0., 0., 1., 1.],/ISOTROPIC,/noborder,limit=map_limits,/cylindrical
;  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=-90, LONMIN=0, LATMAX=90, LONMAX=360)
;  pos = fltarr(4)
;  pos[0] = Startx / float(!d.x_vsize)
;  pos[1] = Starty / float(!d.y_vsize)
;  pos[2] = (Startx + xsize) / float(!d.x_vsize)
;  pos[3] = (Starty + ysize) / float(!d.y_vsize)
;
;  device, decomposed=0
;  loadct, 13, /SILENT
;
;  ;        load_ibex_color_table
;  imdisp, remap, /noscale, /usepos, pos=pos, CHARSIZE = 5;[*, ie]
;
;  LAT_MARK = [-90,-60,-30,0,30,60,90]
;  LAT_MARK_STR = STRING((LAT_MARK), FORMAT = '(I3)')
;
;  LON_MARK = [-180:180:30.]
;  LON_MARK_STR = STRING(-(LON_MARK), FORMAT = '(I4)')
;
;  MAP_GRID, latdel=30, londel=30,/LABEL, color=fsc_color('white'), /horizon, $
;    lats = LAT_MARK, latnames=LAT_MARK_STR, $
;    lons = LON_MARK, lonnames=STRCOMPRESS(LON_MARK_STR, /REM), $
;    latlab=0, glinestyle=1, glinethick=0.5, charthick=1.5, charsize=2.0
;
;  if keyword_set(cb) then begin
;    gap = 0.0
;    load_ibex_color_table
;    fsc_colorbar, range=[dmin, dmax],/overplot,position=[pos[0], pos[1]-gap-0.02, pos[2], pos[1]-gap], charsize=3,$
;      divisions=colorbar_divisions,/horizontal,title=cb, format = '(f6.1)', color=fsc_color('white')
;    ;    XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+5, cb, charsize=4.0, charthick=2.0, ALIGNMENT = 0.5, /DEVICE
;  endif
;
;
;end


pro ENA_response_Comp_IPS, ver, cpath

;  ver = '2300705'
;  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\'
;  cd, cpath

  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'
  tidx = where(time ge 2000 and time le 2023)
  time_ips = time[tidx]
  NSW_ips = NSW[tidx, *]
  VSW_ips = VSW[tidx, *]
  PDYN_ips = PDYN[tidx, *]

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

  RC_DAYEH_LONLAT = [[217.41, 44.36], $
    [219.72, 41.50], $
    [220.51, 39.96], $
    [218.08, 38.44], $
    [214.68, 34.13]]



  pos0 = [0.1, 0.8, 0.9, 0.95]
  pos1 = [0.1, 0.65, 0.9, 0.8]
  pos2 = [0.1, 0.1, 0.9, 0.60]



  for data_idx = 2, 2 do begin ; 0: ISOC-D, 1:Theseus-D, 2:Theseus-L
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;    if data_idx eq 0 then begin
    ;      mapname = 'ISOC'
    ;      DPATH = dp+'ISOC-D\'
    ;      fname = mapname+'-D_RC_Iteration'
    ;      YEAR_MIN = 2009
    ;      YEAR_MAX = 2019 ; ISOC = 2019, THESEUS = 2020
    ;      year_arr = [2009.5:2019.5]
    ;      lon_num = 30
    ;    endif

    if data_idx eq 1 then begin
      mapname = 'Theseus'
      sepname = 'L'
      fname = mapname+'-'+sepname+'_RC_Iteration'
      DPATH = dp+'Theseus-D\'
      YEAR_MIN = 2009
      YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
      year_arr = [YEAR_MIN:YEAR_MAX]
      year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]
      lon_num = 180
    endif

    if data_idx eq 2 then begin
      mapname = 'Theseus'
      sepname = 'L'
      DPATH = dp+'Theseus-L\'
      fname = mapname+'-'+sepname+'_RC_Iteration'
      YEAR_MIN = 2009
      YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
      year_arr = [YEAR_MIN:YEAR_MAX]
      year_arr_tmp = [double(YEAR_MIN):double(YEAR_Max)]
      lon_num = 180
    endif


    fit_par_circ = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
    fit_par_ellip = replicate(!values.d_nan, 4, year_arr.length, 5, 2); RLonLatsig x year x esa x ram
    moment_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    moment24_stack = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    flux_stack = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    moment_stack_sig = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    moment24_stack_sig = replicate(!values.d_nan, 4, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram
    flux_stack_sig = replicate(!values.d_nan, 2, lon_num, year_arr.length, 5, 2); moment x lon x year x esa x ram

    peak_lat = replicate(!values.d_nan, lon_num, year_arr.length, 5, 2); lon x year x esa x ram, only for circle fit
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
          if rc_c_lonlat[esa-2, 3] gt 0 then $
            fit_par_circ[*, (yidx-year_min), esa-2, ram] = reform(rc_c_lonlat[esa-2, *]); RLonLat x year x esa
          if rc_e_lonlat[esa-2, 3] gt 0 then $
            fit_par_ellip[*, (yidx-year_min), esa-2, ram] = reform(rc_e_lonlat[esa-2, *]); RLonLat x year x esa
          !null = execute('moment_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom'); moment x lon x year x esa
          !null = execute('moment24_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4'); moment x lon x year x esa
          !null = execute('flux_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux'); moment x lon x year x esa

          !null = execute('moment_stack_sig[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_num_mom_error'); moment x lon x year x esa
          !null = execute('moment24_stack_sig[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_MOM2_4_error'); moment x lon x year x esa
          !null = execute('flux_stack_sig[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_flux_error'); moment x lon x year x esa

          !NULL = EXECUTE('peak_lat[*, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_PEAK_POS')
          !NULL = EXECUTE('map_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_MAP')
          ;          !NULL = EXECUTE('map_sig_stack[*, *, (yidx-year_min), esa-2, ram] = ESA'+ESA_STR+'_RBN_stddev_MAP')
        endfor ; esa
      endfor ; year
    ENDFOR ; ram
    ; data stacking

    num_sec = 4

    FOR ram = 0, 0 DO BEGIN
      IF ram THEN str = 'ARam' ELSE str = 'Ram'

      sector_flux = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5) ; year x sector x par/sig x esa
      sector_mean = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5) ; year x sector x par/sig x esa
      sector_fwhm = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5) ; year x sector x par/sig x esa
      sector_skew = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5) ; year x sector x par/sig x esa
      sector_kurt = replicate(!values.d_nan, year_arr.length, num_sec, 2, 5) ; year x sector x par/sig x esa

      sector_hpdist = replicate(!values.d_nan, year_arr.length, num_sec, 5) ; year x sector x esa
      sector_latec = replicate(!values.d_nan, year_arr.length, num_sec, 5) ; year x sector x esa


      for esa = 2, 6 do begin
        ESA_STR = strcompress(esa, /rem)



        lb_arr = linspace(0, 360, num_sec+1)
        lb_arr = lb_arr-10

        lidx_tmp = where(lb_arr lt 0, /null, tmp)
        if tmp ne 0 then lb_arr[lidx_tmp] = lb_arr[lidx_tmp]+360


        co = rgb_vector(year_arr.length)
        co_lb = ['black', 'red', 'green', 'blue']

        for yidx = 0, year_arr.length-1 do begin

          year_str = string(year_arr[yidx], format = '(I4)')
          peak_pos = [[lon_arr], [peak_lat[*, yidx, esa-2, ram]]]

          lon_tmp = reform(fit_par_circ[1, *, esa-2, ram]) & lat_tmp = reform(fit_par_circ[2, *, esa-2, ram])

          peak_lat_res = reform(peak_lat[*, *, esa-2, ram])

          ; Fixed RC Coordinate

          TMP = conv_coord_ec_rc(peak_pos[*, 0], peak_pos[*, 1], lon_tmp[yidx], lat_tmp[yidx], /REVERSE)
          LONEC = TMP.LON & LATEC = TMP.LAT
          hp_dist_tmp = griddata(lon_hp, lat_hp, hp_dist, /natural, triangles = tr_hp, xout = LONEC, yout = LATEC)

          TMP1 = conv_coord_ec_rc(LONEC, LATEC, reform(RC_DAYEH_LONLAT[0, esa-2]), reform(RC_DAYEH_LONLAT[1, esa-2]))


          for lbidx = 0, lb_arr.length-2 do begin

            if lbidx eq 0 then $
              lon_idxr1 = where(TMP1.lon ge lb_arr[lbidx] or TMP1.lon lt lb_arr[lbidx+1]) else $
              lon_idxr1 = where(TMP1.lon ge lb_arr[lbidx] and TMP1.lon lt lb_arr[lbidx+1])

            ;  This standar deviation is valid if the number of map draws is the same for all year and/or all sectors
            sector_flux[yidx, lbidx, *, esa-2] = [mean(flux_stack[0, lon_idxr1, yidx, esa-2, ram], /nan), sqrt(mean(flux_stack_sig[0, lon_idxr1, yidx, esa-2, ram]^2, /nan))]

            sector_mean[yidx, lbidx, *, esa-2] = [mean(moment_stack[0, lon_idxr1, yidx, esa-2, ram], /nan), sqrt(mean(moment_stack_sig[0, lon_idxr1, yidx, esa-2, ram]^2, /nan))]
            sector_fwhm[yidx, lbidx, *, esa-2] = [mean(moment24_stack[1, lon_idxr1, yidx, esa-2, ram], /nan), sqrt(mean(moment24_stack_sig[1, lon_idxr1, yidx, esa-2, ram]^2, /nan))]
            sector_skew[yidx, lbidx, *, esa-2] = [mean(moment24_stack[2, lon_idxr1, yidx, esa-2, ram], /nan), sqrt(mean(moment24_stack_sig[2, lon_idxr1, yidx, esa-2, ram]^2, /nan))]
            sector_kurt[yidx, lbidx, *, esa-2] = [mean(moment24_stack[3, lon_idxr1, yidx, esa-2, ram], /nan), sqrt(mean(moment24_stack_sig[3, lon_idxr1, yidx, esa-2, ram]^2, /nan))]

            sector_hpdist[yidx, lbidx, esa-2] = mean(hp_dist_tmp[lon_idxr1], /nan)
            sector_latec[yidx, lbidx, esa-2] = mean(LATEC[lon_idxr1], /nan)
          endfor

          ; Fixed RC Coordinate

        endfor ; year



        e_step = [0.45,0.71,1.11,1.74,2.73,4.29d]
        nose_lat = 5.14

        D_Dist = mean(sector_hpdist[*, *, esa-2], dim = 1, /nan)*!const.AU
        V = sqrt(2*e_step[esa-1]*1e3*!const.e/!const.MP)
        DT = 2*D_Dist/V/60/60/24/365.25

        sector_name = ['Nose', 'North', 'Tail', 'South']


        pdyn_interp = replicate(!values.f_nan, year_arr.length, lb_arr.length-1)
        for lbidx = 0, lb_arr.length-2 do pdyn_interp[*, lbidx] = ips_interp(pdyn_ips, time_ips, sol_lat_ec, year_arr, sector_latec[*, lbidx, esa-2])

        win = window(dim = [800, 1000], /buffer)
        win.refresh, /disable

        ;        for lbidx = 0, lb_arr.length-2 do p1 = plot(year_arr, pdyn_interp[*, lbidx], $
        ;          co = co_lb[lbidx], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)')

        xr1 = [2005, 2023]

        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = plot(year_arr, sector_latec[*, 0, esa-2], xr = xr1, yr = [-60, 60], pos = pos2, symbol = '*', co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Latitude', xtitle = 'Year', ytitle = 'Sector Latitude [$\deg$]', name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)
        for lbidx = 1, lb_arr.length-2 do p[lbidx] = plot(year_arr, sector_latec[*, lbidx, esa-2], symbol = '*', co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')
        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorLat_E'+esa_str+'_'+str+'.png', res = 150
        win.erase

        ; Ribbon characteristics change over time
        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr, sector_flux[*, 0, 0, esa-2]/mean(sector_flux[*, 0, 0, esa-2]), sector_flux[*, 0, 1, esa-2]/mean(sector_flux[*, 0, 0, esa-2])/2, $
          xr = xr1, yr = [0, 2], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Flux', xtitle = 'Year', ytitle = 'Norm. Flux', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_flux[*, lbidx, 0, esa-2]/mean(sector_flux[*, lbidx, 0, esa-2]), sector_flux[*, lbidx, 1, esa-2]/mean(sector_flux[*, lbidx, 0, esa-2])/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorFlux_E'+esa_str+'_'+str+'.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr, sector_mean[*, 0, 0, esa-2], sector_mean[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [60, 90], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Mean', xtitle = 'Year', ytitle = 'Mean [$\deg$]', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_mean[*, lbidx, 0, esa-2], sector_mean[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorMean_E'+esa_str+'_'+str+'.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr, sector_fwhm[*, 0, 0, esa-2], sector_fwhm[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [0, 55], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector FWHM', xtitle = 'Year', ytitle = 'FWHM [$\deg$]', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_fwhm[*, lbidx, 0, esa-2], sector_fwhm[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorFWHM_E'+esa_str+'_'+str+'.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr, sector_skew[*, 0, 0, esa-2], sector_skew[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [-0.4, 0.4], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Skewness', xtitle = 'Year', ytitle = 'Skewness', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_skew[*, lbidx, 0, esa-2], sector_skew[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorSkew_E'+esa_str+'_'+str+'.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')


        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr, sector_kurt[*, 0, 0, esa-2], sector_kurt[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [-0.4, 0.4], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Kurtosis', xtitle = 'Year', ytitle = 'Kurtosis', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr, sector_kurt[*, lbidx, 0, esa-2], sector_kurt[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorKurt_E'+esa_str+'_'+str+'.png', res = 150
        win.erase
        ; Ribbon characteristics change over time



        xr1 = [2001, 2020]
        ; Ribbon characteristics change over time - time shift
        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr-DT[0], sector_flux[*, 0, 0, esa-2]/mean(sector_flux[*, 0, 0, esa-2]), sector_flux[*, 0, 1, esa-2]/mean(sector_flux[*, 0, 0, esa-2])/2, $
          xr = xr1, yr = [0, 2], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Flux', xtitle = 'Year', ytitle = 'Norm. Flux', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr-DT[lbidx], sector_flux[*, lbidx, 0, esa-2]/mean(sector_flux[*, lbidx, 0, esa-2]), sector_flux[*, lbidx, 1, esa-2]/mean(sector_flux[*, lbidx, 0, esa-2])/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorFlux_E'+esa_str+'_'+str+'_TimeShift.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr-DT[0], sector_mean[*, 0, 0, esa-2], sector_mean[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [60, 90], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Mean', xtitle = 'Year', ytitle = 'Mean [$\deg$]', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr-DT[lbidx], sector_mean[*, lbidx, 0, esa-2], sector_mean[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorMean_E'+esa_str+'_'+str+'_TimeShift.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr-DT[0], sector_fwhm[*, 0, 0, esa-2], sector_fwhm[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [0, 55], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector FWHM', xtitle = 'Year', ytitle = 'FWHM [$\deg$]', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr-DT[lbidx], sector_fwhm[*, lbidx, 0, esa-2], sector_fwhm[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorFWHM_E'+esa_str+'_'+str+'_TimeShift.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')

        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr-DT[0], sector_skew[*, 0, 0, esa-2], sector_skew[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [-0.4, 0.4], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Skewness', xtitle = 'Year', ytitle = 'Skewness', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr-DT[lbidx], sector_skew[*, lbidx, 0, esa-2], sector_skew[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorSkew_E'+esa_str+'_'+str+'_TimeShift.png', res = 150
        win.erase


        p1 = plot(time_omni, SSN_1HR, current = win, pos = pos1, xr = xr1, yr = [0, 200], font_size = 15, xtickformat = '(a1)', co = 'gray', thick = 2, axis_style = 0)
        p1 = plot(time_ips, pdyn_ips[*, 9], current = win, pos = pos1, ytitle = 'Pdyn(IPS) [nPa]', xr = xr1, yr = [0, 3.5], font_size = 15, xtickformat = '(a1)', co = 'orange', font_color = 'orange')


        p1 = plot(time_ips, lat_bound_n, yr = [0, 90], co = 'red', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')
        p1 = plot(time_ips, abs(lat_bound_s), yr = [0, 90], co = 'blue', current = win, pos = pos0, ytitle = 'Lat$_{EC}$ [$\deg$]', xr = xr1, font_size = 15, xtickformat = '(a1)')

        p = objarr(lb_arr.length-1)
        p[0] = errorplot(year_arr-DT[0], sector_kurt[*, 0, 0, esa-2], sector_kurt[*, 0, 1, esa-2]/2, $
          xr = xr1, yr = [-0.4, 0.4], pos = pos2, $
          co = co_lb[0], errorbar_co = co_lb[0], title = 'ESA'+esa_str+', '+str+', Sector Kurtosis', xtitle = 'Year', ytitle = 'Kurtosis', $
          name = sector_name[0]+', '+ string(mean(sector_hpdist[*, 0, esa-2]), format = '(f5.1)')+'AU, '+string(DT[0], format = '(f4.1)')+'yrs', $
          font_size = 15, current = win)
        pp = plot(xr1, replicate(0, 2), over = p[0], co = 'gray', linestyle = 2)

        for lbidx = 1, lb_arr.length-2 do p[lbidx] = errorplot(year_arr-DT[lbidx], sector_kurt[*, lbidx, 0, esa-2], sector_kurt[*, lbidx, 1, esa-2]/2, $
          co = co_lb[lbidx], errorbar_co = co_lb[lbidx], over = p[0], name = sector_name[lbidx]+', '+ string(mean(sector_hpdist[*, lbidx, esa-2]), format = '(f5.1)')+'AU, '+string(DT[lbidx], format = '(f4.1)')+'yrs')

        lgd = legend(pos = [0.32, 0.28], target = p, /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
        win.refresh
        win.save, file_tmp+'SectorKurt_E'+esa_str+'_'+str+'_TimeShift.png', res = 150
        win.close
        ; Ribbon characteristics change over time - time shift


        ;        if ram eq 0 then begin
        ;
        ;          D_Dist = sector_hpdist*!const.AU
        ;          E = [0.71,1.11,1.74,2.73,4.29]
        ;          V = sqrt(2*E[esa-2]*1e3*!const.e/!const.MP)
        ;          DT = 2*D_Dist/V/60/60/24/365.25
        ;          print, str, '==================================='
        ;          print, str, 'ESA', esa_str
        ;          print, D_Dist/!const.AU
        ;          print, DT
        ;          print, str, '==================================='
        ;        endif

      endfor ; energy


    endfor ; ram

  endfor ; data type

  D_Dist = 100*!const.AU
  E = [0.45,0.71,1.11,1.74,2.73,4.29]
  V = sqrt(2*E*1e3*!const.e/!const.MP)
  DT = 2*D_Dist/V/60/60/24/365.25


end