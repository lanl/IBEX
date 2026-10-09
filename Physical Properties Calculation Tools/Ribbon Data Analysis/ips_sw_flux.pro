function maxwellian_240505, x, p
  if n_elements(p.dim) gt 1 then return, p[*, 0] / p[*, 1]^3 / sqrt(!dpi)^3 *exp(-(x - p[*, 2])^2/p[*, 1]^2) $
  else return, p[0] / p[1]^3 / sqrt(!dpi)^3*exp(-(x - p[2])^2/p[1]^2)
end

pro IPS_SW_FLUX
  !EXCEPT = 0

  nh = 0.2d

  ; solar wind data prep
  e_step = [0.71,1.11,1.74,2.73,4.29]
  v_step = sqrt(2d / !const.mp * e_step * 1d3 * !const.e) ; m/s,  esa 1 - 6

  ymin = 1990
  ymax = 2022

  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'


  SOLAR_P_PSD = replicate(!values.d_nan, time.length, sol_lat_ec.length, v_step.length) ; time x lat x energy
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
    SOLAR_P_PSD[*, latidx, *] = res;psd2flux(res[*, 1:-1]*1d-12,transpose(rebin(e_step[1:-1], 5, time.length)) , psd_units = 3)
  endfor
  ; solar wind data prep


  e_step = [0.71,1.11,1.74,2.73,4.29]
  emat = transpose(rebin(e_step, 5, 790, 19), [1, 2, 0])

  SOLAR_P_FLUX = psd2flux(SOLAR_P_PSD*1e-12, emat, psd_units = 3, mass = !const.mp)


;  for esa = 2, 6 do begin
;    dr = [1E-5, 1e13]
;    ALPHA = -2.2D
;    sp = spec_plot(SOLAR_P_Flux[*, *, esa-2], time, sol_lat_ec, data_min = dr[0]/(e_step[0])^ALPHA * (e_step[esa-2])^ALPHA, data_max = dr[1]/(e_step[0])^ALPHA * (e_step[esa-2])^ALPHA, xtitle = 'Time', ytitle = 'Latitude', title = 'PSD, ESA'+strcompress(esa, /rem), xr = [1990, 2022], /data_log)
;    cb = color_bar(sp, ytitle = 'Flux [#/cm2-sr-s-keV]', /ylog)
;    sp.save, 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Solar_Wind\IPS_Flux_ESA'+strcompress(esa, /rem)+'.png'
;    sp.close
;  endfor


  ESA = 5
  LAT_ARR = [80, 65, 50, -10, -30, -50]
  CO = ['RED', 'RED', 'RED', 'BLUE', 'BLUE', 'BLUE']
  LS = [2, 0, 1, 1, 0, 2]
  thk = [1, 3, 1, 1, 3, 1]
  
  p = objarr(lat_arr.length)

  win = window(dim = [800, 400])
  FOR LIDX = 0, LAT_ARR.LENGTH-1 DO BEGIN
    TMP = MIN(ABS(sol_lat_ec-(LAT_ARR[LIDX]-7.25)), MNIDX)
    IF TMP GT 10 THEN STOP
    P[lidx] = PLOT(time, SOLAR_P_Flux[*, MNIDX, esa-2], name = strcompress(LAT_ARR[lidx], /rem)+'$\deg$', current = win, pos = [0.1, 0.1, 0.95, 0.9], font_size = 20, title = 'Solar Wind Proton Flux at 2.73 keV', XTITLE = 'Year', Ytitle = 'Flux', /YLOG, xr = [2000, 2022], xtickinterval = 2, xminor = 1, /OVER, CO = CO[LIDX], YR = [1E-1, 1E10], LINESTYLE = LS[LIDX], THICK = thk[lidx])
  ENDFOR
  
  lgd = legend(target = p, pos = [0.70, 0.8], /auto_text_color, sample_width = 0.1, shadow = 0, transparency = 100, linestyle = 6, font_size = 20)

  win.save, 'U:\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Solar_Wind\ProtonFluxATRibbon.png'
  win.close
  STOP
end