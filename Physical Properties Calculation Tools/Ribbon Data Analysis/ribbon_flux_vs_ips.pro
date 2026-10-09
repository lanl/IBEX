function maxwellian_240505, x, p
  if n_elements(p.dim) gt 1 then return, p[*, 0] / p[*, 1]^3 / sqrt(!dpi)^3 *exp(-(x - p[*, 2])^2/p[*, 1]^2) $
  else return, p[0] / p[1]^3 / sqrt(!dpi)^3*exp(-(x - p[2])^2/p[1]^2)
end

pro ribbon_flux_VS_IPS

  !EXCEPT = 0
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

  lon_mat = dblarr(180, 90)
  lat_mat = dblarr(180, 90)
  hp_mat = dblarr(180, 90)
  ts_mat = dblarr(180, 90)
  kk = 0
  for ii = 0, 179 do begin
    for jj = 0, 89 do begin
      lon_mat[ii, jj] = lon_hp[kk]
      lat_mat[ii, jj] = lat_hp[kk]
      hp_mat[ii, jj] = hp_dist[kk]
      ts_mat[ii, jj] = ts[kk]
      kk += 1
    endfor
  endfor




  nh = 0.2d


  ; ribbon data prep
  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  cd, cpath
  SEPNAME = 'L'
  MAPNAME = 'Theseus'

  fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\'+ $
    MAPNAME+'-'+SEPNAME+'_RC_Iteration\'+ver+'\RibbonVSSolarWind\'
  file_mkdir, fpath

  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  path_str = strsplit(cpath, '\', /extract)
  cd, cpath
  DPATH = strjoin(path_str[0:5], '\')+'\Data\'+MAPNAME+'-'+SEPNAME+'\'


  ; ************************** INPUT **************************
  year_min = 2009
  year_max = 2022
  time_ibex = [year_min:year_mAX]

  ; acquisition time
  frac_year = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
  FOR ram = 0, 1 DO BEGIN
    for yidx = year_min, year_max do begin
      IF ram THEN str = 'ARam' ELSE str = 'Ram'
      year = string(yidx, format = '(I4)')

      RESTORE, dpath +'SAV_'+ver+'\CountRate_Time\' +mapname+'-L_CNT_ACQ_'+year+'_'+str+'.sav'
      for esa = 2, 6 do $
        !null = execute('frac_year[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_FRAC_MAP')
    endfor
  endfor
  ; acquisition time



  rbn_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram
  rbn_sig_map_res = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x ram

  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  FOR ram = 0, 1 DO BEGIN
    for yidx = year_min, year_max do begin
      IF ram THEN str = 'ARam' ELSE str = 'Ram'
      survp =  reform(survp_map[*, ram, *, *, *])

      year = string(yidx, format = '(I4)')
      RESTORE, dpath +'SAV_'+ver+'\'+MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'
      for esa = 2, 6 do begin
        !null = execute('rbn_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
        !null = execute('rbn_sig_map_res[*, *, yidx-year_min, esa-2, ram] = ESA'+strcompress(esa, /rem)+'_RBN_stddev_MAP / reform(survp[yidx-year_min, *, *, esa-2])')
      endfor ; esa
    endfor ; year
  endfor ; ram
  ;  rbn_map_res = alog10(rbn_map_res)

  ; ribbon data prep

  for esa = 2, 6 do begin
    rbn_map = mean(rbn_map_res[*, *, *, esa-2, 0], dim = 3)
    rbn_map[where(rbn_map eq 0, /null)] = !values.f_nan
    ec_map_single_plot, ESA, rbn_map, 1, 'RBN', cb_title = 'Flux [#/cm2-sr-s-keV]'
    write_png, fpath+'ESA'+string(esa, format = '(I1)')+'RBN_FLX_AVG.png',tvrd(/true)
  endfor ; esa

  ; solar wind data prep
  e_step = [0.71,1.11,1.74,2.73,4.29]
  v_step = sqrt(2d / !const.mp * e_step * 1d3 * !const.e) ; m/s,  esa 1 - 6

  ymin = 1990
  ymax = 2022

  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'

  SOLAR_P_Flux = replicate(!values.d_nan, time.length, sol_lat_ec.length, v_step.length) ; time x lat x energy
  Temperature_arr = replicate(!values.d_nan, time.length, sol_lat_ec.length) ; time x lat x energy

  for latidx = 0, sol_lat_ec.length-1 do begin
    Density = NSW[*, latidx] * 1d6; m-3

    Temperature = replicate(7.23, time.length) ; Fixed temperature MEAN(T_OMNI) ; constant T assumption
    ;    Temperature = interpol(SMOOTH(T, 60*24*30., /EDGE_TRUNCATE, /NAN), time_ace, time) ; Uniform T MEAN(T_OMNI)

    Temperature[where(VSW[*, latidx] lt 450, /null)] = -0.162d*VSW[where(VSW[*, latidx] lt 450, /null), latidx]^2 + 595d*VSW[where(VSW[*, latidx] lt 450, /null), latidx] -1.28e5
    Temperature[where(VSW[*, latidx] ge 450, /null)] = -0.521d*VSW[where(VSW[*, latidx] ge 450, /null), latidx]^2 + 1220d*VSW[where(VSW[*, latidx] ge 450, /null), latidx] -3.24e5
    Temperature = (Temperature * !CONST.K/!CONST.E)
    Temperature_arr[*, latidx] = Temperature

    theta1 = sqrt(2d * Temperature / !const.mp * !const.e)

    Velo = VSW[*, latidx] * 1d3; m/s

    p = [[Density], [theta1], [Velo]]

    res = []
    for ii = 0, v_step.length-1 do $
      res = [[res], [maxwellian_240505(v_step[ii], p)]]
    SOLAR_P_Flux[*, latidx, *] = res;psd2flux(res[*, 1:-1]*1d-12,transpose(rebin(e_step[1:-1], 5, time.length)) , psd_units = 3)
  endfor

  ; NSW, VSW, TIME
  ; solar wind data prep



  WIN = WINDOW(DIM = [1000, 850], /BUFFER)
  WIN.REFRESH, /DISABLE
  pos = [0.14, 0.10, 0.88, 0.89]
  xr = [2005, 2023]
  yr = [100, 800]
  FOR RAM = 0, 0 DO BEGIN
    for esa = 5, 5 do begin
      fpath_tmp = fpath+'ESA'+string(esa, format = '(I1)')+'_ram'+string(ram, format = '(I1)')+'\'
      file_mkdir, fpath_tmp
      FOR LON_IDX = 1, LON_ARR.LENGTH-1 DO BEGIN
        FOR LAT_IDX = 76, LAT_ARR.LENGTH-1 DO BEGIN

          T_RIBBON = REFORM(frac_year[LON_IDX, LAT_IDX, *, ESA-2, RAM])
          FLUX_RIBBON = REFORM(RBN_MAP_RES[LON_IDX, LAT_IDX, *, ESA-2, RAM])
          SIG_RIBBON = REFORM(RBN_SIG_MAP_RES[LON_IDX, LAT_IDX, *, ESA-2, RAM])
          if total(FLUX_RIBBON eq 0) ne 0 then continue

          if esa lt 5 then err = 0.2 else err = 0.3
          if total(SIG_RIBBON/FLUX_RIBBON gt err) ne 0 then continue

          LIDX = VALUE_LOCATE(SOL_LAT_EC, LAT_ARR[LAT_IDX])
          VSW_TMP = VSW[*, LIDX]

          ep = errorplot(T_RIBBON, FLUX_RIBBON, SIG_RIBBON, $
            title = 'E = '+string(e_step[esa-2], format = '(f4.2)')+' keV!CLon$_{EC}$='+string(LON_ARR[LON_IDX], format = '(I3)')+'$\deg$, Lat$_{EC}$='+string(Lat_ARR[Lat_IDX], format = '(I3)')+'$\deg$', $
            xtitle = 'Year', $
            ytitle = 'IBEX-Hi!CENA Flux', $
            Font_size = 20, thick = 2, errorbar_thick = 2, $
            color = 'gray', errorbar_color = 'gray', $
            xr = xr, xminor = 3, xtickinterval = 4, $
            YR = [MIN(FLUX_RIBBON-SIG_RIBBON)*0.8, MAX(FLUX_RIBBON+SIG_RIBBON)*1.1], yminor = 0, current = win, pos = pos)
          ax = ep.axes[3]
          ax.hide = 1

          shft = 4
          ep1 = errorplot(T_RIBBON-shft, FLUX_RIBBON, SIG_RIBBON, over = ep, $
            color = 'black', errorbar_color = 'black', thick = 2, errorbar_thick = 2)

         
          p = plot(time + 0, vsw_tmp, $
            thick = 3, color = 'blue', xr = xr, yr = yr, current = win, pos = pos, axis_style = 0)
       
          ar = arrow([2015, 2012.], [300., 300.], /data, thick = 3, target = p, head_size = 0.7)
          tx = text((2012. +2015)/2, 260, string(shft, format = '(I2)')+'yrs', font_size = 25, align = 0.5, /data, target = p)


          ax = axis('Y', target = p, location='right', title = 'V$_{Solar Wind}$', tickfont_size = 20, color = 'blue', $
            tickinterval = 100, minor = 0)

          WIN.REFRESH
          WIN.SAVE, fpath_tmp+'Lon'+string(LON_ARR[LON_IDX], format = '(I3.3)')+'_Lat'+string(LAT_ARR[LAT_IDX], format = '(I3)')+ '.png', res = 150
          stop
          WIN.ERASE
          stop
        ENDFOR
      ENDFOR
    ENDFOR
  ENDFOR

  WIN.CLOSE









end