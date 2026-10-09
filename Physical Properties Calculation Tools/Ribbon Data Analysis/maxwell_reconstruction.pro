function maxwellian_240429, x, p
  if n_elements(p.dim) gt 1 then return, p[*, 0] / p[*, 1]^3 / sqrt(!dpi)^3 *exp(-(x - p[*, 2])^2/p[*, 1]^2) $
  else return, p[0] / p[1]^3 / sqrt(!dpi)^3*exp(-(x - p[2])^2/p[1]^2)
end

pro maxwell_reconstruction

  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]
  v_step = sqrt(2d / !const.mp * e_step * 1d3 * !const.e) ;  esa 1 - 6

  ymin = 2005
  ymax = 2022

  TIME = []
  N = []
  T = []
  FLOW = []
  for yidx = ymin, ymax do begin
    ystr = string(yidx, format = '(I4)')

    for mm = 1, 12 do begin
      mstr = string(mm, format = '(I2.2)')
      file = file_search('D:\Data\omni\hro2_1min\'+ystr+'\omni_hro2_1min_'+ystr+mstr+'*.cdf')
      if file eq '' then stop
      data = read_cdf(file, var = ['FLOW_SPEED', 'T', 'PROTON_DENSITY', 'EPOCH'])

      TIME = [TIME, DATA.EPOCH]
      N = [N, DATA.PROTON_DENSITY]
      T = [T, DATA.T]
      FLOW = [FLOW, DATA.FLOW_SPEED]
    endfor
  endfor
  N[WHERE(N GE 999)] = !VALUES.F_NAN
  T[WHERE(T GE 9E6)] = !VALUES.F_NAN
  FLOW[WHERE(FLOW GE 9E4)] = !VALUES.F_NAN

  TIME = CONV_TIME(TIME, /FROM_EPOCH, /TO_TIME) ;  EPOCH --> TIME DOUBLE
  N = N * 1d6 ; /CC --> M-3
  T = (T * !CONST.K/!CONST.E) ; K --> eV --> m/s
  theta = sqrt(2d * T / !const.mp * !const.e)
  FLOW = FLOW*1d3 ; km/s --> m/s

  p1 = [[n], [theta], [flow]]
  x = v_step


  ; polytropic index

  idx = where(finite(n+t))
  res = regress(alog10(n[idx]), alog10(t[idx]),const = const, corr = corr)
  PRINT, RES+1, const, corr

  idx = where(finite(FLOW+t))
  res = regress(alog10(FLOW[idx]), alog10(t[idx]),const = const, corr = corr)
  PRINT, RES+1, const, corr
  gam_res = res+1
  const_res = const

  ;
  ;  ll = linspace(0, n.length-1, 10000)
  ;  ;  ll = [0:n.length-1:60*24]
  ;  ll = round(ll)
  ;  gam = replicate(!values.f_nan, ll.length)
  ;  cor = replicate(!values.f_nan, ll.length)
  ;  con = replicate(!values.f_nan, ll.length)
  ;
  ;  for ii = 0, ll.length-2 do begin
  ;    FLOW_smooth = FLOW[ll[ii]:ll[ii+1]]
  ;    T_smooth = T[ll[ii]:ll[ii+1]]
  ;    idx = where(finite(FLOW_smooth+T_smooth), TMP)
  ;    IF TMP EQ 0 THEN CONTINUE
  ;    res = regress(alog10(FLOW_smooth[idx]), alog10(T_smooth[idx]),const = const, corr = corr)
  ;    gam[ii] = res+1
  ;    con[ii] = const
  ;    cor[ii] = corr
  ;  endfor

  ;      p = plot(gam, YTITLE = '$\gamma$', title = 'Polytropic Index')
  ;      p = plot(con, YTITLE = 'C', title = 'Const.')
  ;      p = plot(cor, YTITLE = 'Lin. CC', title = 'Correlation')

  ;  gam_res = total(gam * abs(cor), /nan)/total(abs(cor), /nan)
  ;  const_res = total(con * abs(cor), /nan)/total(abs(cor), /nan)
  ;
  ;  idx = where(abs(cor) gt 0.5)
  ;  gam_res = mean(gam[idx])
  ;  const_res = mean(con[idx])
  ; polytropic index

  res = []
  for ii = 0, v_step.length-1 do begin
    res = [[res], [maxwellian_240429(v_step[ii], p1)]]
  endfor

  res[WHERE(res EQ 0)] = !VALUES.D_NAN

  e_step_mat = transpose(rebin(e_step, e_step.length, time.length))
  res_flux = psd2flux(res, e_step_mat, psd_units = 3)

  time_jul = julday(1, 1, 1970, 0, 0, time)
  CALDAT, time_jul, Mo, D, Y, H, M, S
  time_ace = float(y) + (mo-1)/12. + (d-1)/30. /12.  + (h/24. + m/60./24. + s/60./60./24.)/365.25

  psd_ace = res

  co = ['blue', 'green', 'orange', 'red', 'magenta']
;  for ii = 2, 6 do $
;    p = plot(time_jul, SMOOTH(res[*, ii-1], 60*24*30., /EDGE_TRUNCATE, /NAN), font_size = 15, /YLOG, YR = [1E-25, 1E-6], co = co[ii-2], /over, xtickunit = 'year', xtickinterval = 1, xminor = 0)

  ;
  ;  stop
  ; Using IPS data
  restore, 'C:\Users\368809\sjnoh\Data\IPS\IPS2022.sav'

  tidx = where(time ge ymin and time le ymax)

  Time = time[tidx]
  NSW = NSW[tidx, *]
  VSW = VSW[tidx, *]
  TSW = NSW

  ENA_Flux = replicate(!values.d_nan, time.length, sol_lat_ec.length, 5) ; time x lat x energy

  for latidx = 0, sol_lat_ec.length-1 do begin
    Density = NSW[*, latidx] * 1d6; m-3

    Temperature = replicate(7.23, time.length) ; Fixed temperature MEAN(T_OMNI) ; constant T assumption
    ;    Temperature1 = interpol(SMOOTH(T, 60*24., /EDGE_TRUNCATE, /NAN), time_ace, time) ; Uniform T MEAN(T_OMNI)
    ;    Temperature = Density^(gam_res-1) * 10d^(const_res) ; Polytropic


    ; V-T relation
    Temperature[where(VSW[*, latidx] lt 450, /null)] = -0.162d*VSW[where(VSW[*, latidx] lt 450, /null), latidx]^2 + 595d*VSW[where(VSW[*, latidx] lt 450, /null), latidx] -1.28e5
    Temperature[where(VSW[*, latidx] ge 450, /null)] = -0.521d*VSW[where(VSW[*, latidx] ge 450, /null), latidx]^2 + 1220d*VSW[where(VSW[*, latidx] ge 450, /null), latidx] -3.24e5
    Temperature = (Temperature * !CONST.K/!CONST.E)
;    Temperature1 = VSW[*, latidx]^(gam_res[0]-1) * 10d^(const_res) ; Polytropic
    
    
    TSW[*, latidx] = temperature
    theta1 = sqrt(2d * Temperature / !const.mp * !const.e)

    Velo = VSW[*, latidx] * 1d3; m/s

    p = [[Density], [theta1], [Velo]]

    res = []
    for ii = 0, v_step.length-1 do $
      res = [[res], [maxwellian_240429(v_step[ii], p)]]

    ENA_Flux[*, latidx, *] = res[*, 1:-1];psd2flux(res[*, 1:-1]*1d-12,transpose(rebin(e_step[1:-1], 5, time.length)) , psd_units = 3)

    ;    if latidx eq 9 then stop
  endfor

  stop

  for esa = 2, 6 do begin
    sp = spec_plot(reform(ENA_Flux[*, *, esa-2]), time, sol_lat_ec, $
      xr = [ymin, ymax], yr = [-90, 90], /data_log, $
      title = string(e_step[esa-1])+'keV', ytitle = 'Lat_HG', xtitle = 'Year', $
      xminor = 1, xtickinterval = 2, yminor = 2, ytickinterva = 30, font_size = 15);, $
    ;      data_min = 1e-1, data_max = 1e10)
    ;    cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]', /ylog)
    cb = color_bar(sp, ytitle = 'PSD [s3/m6]', /ylog)

    sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\IPS_FLUX\ESA'+strcompress(esa, /rem)+'_V-T.png'
    sp.close
  endfor
  ;  stop
  ;  ;  p = plot(psd_ace[*, 4])
  ;
  ;  ii = 5
  ;  p = plot(time_ace, SMOOTH(psd_ace[*, ii-1], 60*24*30., /EDGE_TRUNCATE, /NAN), /YLOG, YR = [1E-25, 1E-6], co = co[ii-2], xtickinterval = 1, xminor = 0)
  ;  esa = 5
  ;  p = plot(time, ENA_Flux[*, 9, esa-2], over = p)
  ;
  ;  p = plot(time_ace, SMOOTH(flow, 60*24*30., /EDGE_TRUNCATE, /NAN), co = 'red', xtickinterval = 1, xminor = 0)
  ;  p = plot(time, VSW[*, 9]*1d3, over = p)
  ;
  ;  p = plot(time_ace, SMOOTH(N, 60*24*30., /EDGE_TRUNCATE, /NAN), co = 'red', xtickinterval = 1, xminor = 0)
  ;  p = plot(time, NSW[*, 9]*1d6, over = p)
  ;
  ;  p = plot(time_ace, SMOOTH(T, 60*24*30., /EDGE_TRUNCATE, /NAN), co = 'red', xtickinterval = 1, xminor = 0, font_size = 15, ytitle = 'T [eV]')
  ;
  ;  stop

end