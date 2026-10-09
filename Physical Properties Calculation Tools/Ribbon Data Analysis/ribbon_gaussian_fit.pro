function ribbon_gauss, var, p, $
  _EXTRA=extra

  F = fltarr(var.length)

  for ii = 0, p[0]-1 do F = p[1+ii*3] * exp( -((var-p[3+ii*3])/p[2+ii*3])^2 / 2 ) + F

  return, F
end

function ribbon_skew_gauss, var, p, $
  _EXTRA=extra

  F = fltarr(var.length)

  for ii = 0, p[0]-1 do F = p[1+ii*4] * exp( -((var-p[3+ii*4])/p[2+ii*4])^2 / 2 ) * (1+erfc((p[4+ii*4]*(var-p[3+ii*4])/p[2+ii*4]) / sqrt(2))) + F

  return, F
end


function ribbon_generalized_gauss, var, p, $
  _EXTRA=extra

  F = fltarr(var.length)

  for ii = 0, p[0]-1 do F = p[1+ii*4] * exp( -(abs(var-p[3+ii*4])/p[2+ii*4]/sqrt(2))^p[4+ii*4] )  + F

  IF P[-1] EQ 1 THEN F = ALOG(F)
  return, F
end

;function ribbon_skew_gauss_fit_run, lat_rc, Flux_tmp, Flux_stddev_tmp, n_pop, Init_Guess
;
;  ii = 0
;  fit_flag = 0
;  while fit_flag eq 0 do begin
;    ii += 1
;    ;
;    ;    ; 1 pop
;    ;    pc_max2 = !null
;    ;    parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
;    ;      limits:[0d, 0], PARNAME:'', MPSIDE:2}, 4)
;    ;
;    ;    parinfo.value = [1, Init_Guess[0], Init_Guess[2], Init_Guess[3]]
;    ;    parinfo.limits = [[n_pop, n_pop], $
;    ;      [Init_Guess[0]/10, Init_Guess[0]], $
;    ;      [Init_Guess[2]/2, Init_Guess[2]*2], $
;    ;      [Init_Guess[1]-4, Init_Guess[1]+4]]
;
;
;    ; 2 pop
;    pc_max2 = !null
;    parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
;      limits:[0d, 0], PARNAME:'', MPSIDE:2}, 1+n_pop*4)
;
;    parinfo[0].fixed = 1
;
;    fit_str = ['N_pop']
;    for n = 1, n_pop do fit_str = [fit_str, 'A'+strcompress(n, /rem), 'T'+strcompress(n, /rem), 'D'+strcompress(n, /rem), 'alpha'+strcompress(n, /rem)]
;    parinfo.PARNAME = fit_str
;
;
;
;    limit = replicate(!values.f_nan, 2, 1+n_pop*3)
;
;    if n_pop eq 2 then begin
;      limit = [[n_pop, n_pop], $
;        [Init_Guess[0]/10, Init_Guess[0]], $
;        [Init_Guess[2]/2, Init_Guess[2]*2], $
;        [Init_Guess[1]-4, Init_Guess[1]+4], $
;        [-4, 4], $
;        [Init_Guess[0]/100, Init_Guess[0]], $
;        [1, 10], $
;        [Init_Guess[1]-50, Init_Guess[1]+30], $
;        [-4, 4]]
;    endif
;
;    parinfo.limits = limit
;
;    initial_guess = mean(limit, dim = 1)
;
;    initial_guess[1:-1] = initial_guess[1:-1] + (randomu(seed, n_elements(initial_guess[1:-1])) - 0.5)*initial_guess[1:-1]*0.05
;    parinfo.value = initial_guess
;
;    p3 = mpfitfun('ribbon_skew_gauss', lat_rc, Flux_tmp, replicate(1, Flux_stddev_tmp.length), pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /quiet)
;
;    ;    fit_flag = 0
;    if (npegged le 1) and (status ge 6) then $
;      fit_flag = 1
;
;
;    ;    idx0 = where(reform(limit[0, 1:-1]) eq p3[1:-1], tmp0)
;    ;    idx1 = where(reform(limit[1, 1:-1]) eq p3[1:-1], tmp1)
;    ;    if tmp0 ne 0 then print, 'Iter # ', ii, ', Status ', status, ', # of pegged', npegged, ', Par', fit_str[idx0+1]+', Lower'
;    ;    if tmp1 ne 0 then print, 'Iter # ', ii, ', Status ', status, ', # of pegged', npegged, ', Par', fit_str[idx1+1]+', Upper'
;
;    ;    if n_pop eq 2 then stop
;    ;    if n_pop eq 3 then stop
;    if ii gt 10 then break
;  endwhile
;
;  ;  yfit1 = ribbon_skew_gauss(lat_rc, p3, thcik = 2)
;  ;  print, total((Flux_tmp-yfit1)^2/Flux_tmp.length)
;  ;  yfit2 = ribbon_gauss(lat_rc, pc_max2)
;  ;  print, total((Flux_tmp-yfit2)^2/Flux_tmp.length)
;
;  ;  p = plot(lat_rc, flux_tmp, thick = 2)
;  ;  p = plot(lat_rc, yfit1, /over, co = 'red')
;  ;  ;  p = plot(lat_rc, yfit2, /over, co = 'blue')
;  ;  fit_comp_co = ['green', 'orange', 'magenta']
;  ;  for ff = 0, 1 do begin
;  ;    par_tmp = [1, p3[1+4*ff:4+4*ff]]
;  ;    yfit2 = ribbon_skew_gauss(lat_rc, par_tmp)
;  ;    p = plot(lat_rc, yfit2, co = fit_comp_co[ff], over = p)
;  ;  endfor
;
;  ;  p = plot(lat_rc, flux_tmp-ribbon_gauss(lat_rc, [1, p3[1:3]]))
;
;  dof = lat_rc.length-3*n_pop
;  chis = total((Flux_tmp-yfit)^2/Flux_stddev_tmp^2) / dof
;
;  return, {chis:chis, par:p3, fit_flag:fit_flag}
;end
;
;
;
;function ribbon_gauss_fit_run, lat_rc, Flux_tmp, Flux_stddev_tmp, n_pop, Init_Guess
;
;  common var1, lonidx
;  ii = 0
;  fit_flag = 0
;  while fit_flag eq 0 do begin
;    ii+=1
;
;    ; 1 pop
;    pc_max2 = !null
;    parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
;      limits:[0d, 0], PARNAME:'', MPSIDE:2}, 4)
;    parinfo[0].fixed = 1
;
;    IG = [1, Init_Guess[0], Init_Guess[2], Init_Guess[1]]
;
;    parinfo.value = IG
;    parinfo.limits = [[1, 1], $
;      [IG[1]/2, IG[1]*(2 - 1./2)], $
;      [IG[2]/3, IG[2]*(2 - 1./3)], $
;      [IG[3]-4, IG[3]+4]]
;
;
;    p1 = mpfitfun('ribbon_gauss', lat_rc, Flux_tmp, replicate(1, Flux_stddev_tmp.length), pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /quiet)
;
;    if (npegged le 1) and (status ge 6) then begin
;
;      y_rem = flux_tmp-yfit
;      y_rem[where(y_rem le 0, /null)] = !values.f_nan
;
;      m0 = max(y_rem)
;      m1 = total(y_rem*lat_rc, /nan)/total(y_rem, /nan)
;      m2 = sqrt(total(y_rem*(lat_rc-m1)^2, /nan)/total(y_rem, /nan))
;
;
;      yy = ribbon_gauss(lat_rc, [1, m0, m2, m1])
;      p11 = mpfitfun('ribbon_gauss', lat_rc, Flux_tmp-yy, replicate(1, Flux_stddev_tmp.length), pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /quiet)
;
;      initial_guess = [2, p11[1], p11[2], p11[3], m0, m2, m1]
;
;      pc_max2 = !null
;      parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
;        limits:[0d, 0], PARNAME:'', MPSIDE:2}, 1+n_pop*3)
;      parinfo[0].fixed = 1
;
;      fit_str = ['N_pop']
;      for n = 1, n_pop do fit_str = [fit_str, 'A'+strcompress(n, /rem), 'T'+strcompress(n, /rem), 'D'+strcompress(n, /rem)]
;      parinfo.PARNAME = fit_str
;
;      parinfo.value = initial_guess
;
;      parinfo.limits = [[n_pop, n_pop], $
;        [initial_guess[1]/1.25, initial_guess[1]*(2-1./1.25)], $
;        [initial_guess[2]/1.25, initial_guess[2]*(2-1./1.25)], $
;        [initial_guess[3]-5, initial_guess[3]+5], $
;        [initial_guess[4]/1.25, initial_guess[4]*(2-1./1.25)], $
;        [initial_guess[5]/2, initial_guess[5]*(2-1./2)], $
;        [initial_guess[6]-10, initial_guess[6]+10]]
;    endif else begin
;      ; 2 pop
;      pc_max2 = !null
;      parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
;        limits:[0d, 0], PARNAME:'', MPSIDE:2}, 1+n_pop*3)
;
;      parinfo[0].fixed = 1
;
;      fit_str = ['N_pop']
;      for n = 1, n_pop do fit_str = [fit_str, 'A'+strcompress(n, /rem), 'T'+strcompress(n, /rem), 'D'+strcompress(n, /rem)]
;      parinfo.PARNAME = fit_str
;
;
;
;      limit = replicate(!values.f_nan, 2, 1+n_pop*3)
;
;      if n_pop eq 1 then begin
;        limit = [[n_pop, n_pop], $
;          [Init_Guess[0]/2, Init_Guess[0]], $
;          [Init_Guess[2]/2, Init_Guess[2]], $
;          [Init_Guess[1]-4, Init_Guess[1]+4]]
;      endif
;      if n_pop eq 2 then begin
;        limit = [[n_pop, n_pop], $
;          [Init_Guess[0]/10, Init_Guess[0]], $
;          [Init_Guess[2]/2, Init_Guess[2]*2], $
;          [Init_Guess[1]-4, Init_Guess[1]+4], $
;          [Init_Guess[0]/100, Init_Guess[0]*0.8], $
;          [Init_Guess[2]/2, Init_Guess[2]*2], $
;          [Init_Guess[1]-50, Init_Guess[1]+30]]
;      endif
;      if n_pop eq 3 then begin
;        limit = [[n_pop, n_pop], $
;          [Init_Guess[0]/2, Init_Guess[0]], $ ; #1
;          [Init_Guess[2]/2, Init_Guess[2]], $ ; #1
;          [Init_Guess[1]-4, Init_Guess[1]+4], $ ; #1
;          [Init_Guess[0]/50, Init_Guess[0]/4], $ ; #2
;          [Init_Guess[2]/2, Init_Guess[2]*5], $ ; #2
;          [Init_Guess[1]-40, Init_Guess[1]+40], $ ; #2
;          [Init_Guess[0]/100, Init_Guess[0]/20], $ ; #3
;          [Init_Guess[2]/2, Init_Guess[2]*10], $ ; #3
;          [Init_Guess[1]-50, Init_Guess[1]+50]] ; #3
;      endif
;      parinfo.limits = limit
;
;      initial_guess = mean(limit, dim = 1)
;      parinfo.value = initial_guess
;
;    endelse
;
;    p3 = mpfitfun('ribbon_gauss', lat_rc, Flux_tmp, replicate(1, Flux_stddev_tmp.length), pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /quiet)
;    if (npegged le 1) and (status ge 6) then $
;      fit_flag = 1
;
;    ;    parinfo.value = [2, p1[1], p1[2], p1[3], 0.5, 10, 50]
;    ;    parinfo.limits = [[n_pop, n_pop], $
;    ;      [0, p1[1]*2], $
;    ;      [0.1, p1[1]*2], $
;    ;      [p1[3]-20, p1[3]+20], $
;    ;      [0, 2], $
;    ;      [0.1, 40], $
;    ;      [30, 120]]
;    ;    p33 = mpfitfun('ribbon_gauss', lat_rc, Flux_tmp, replicate(1, Flux_stddev_tmp.length), pc_max2, status = status3, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged3, yfit = yfit3, /quiet)
;    ;    if (npegged3 le 1) and (status3 ge 6) then $
;    ;      fit_flag3 = 1
;
;
;
;
;    if ii gt 10 then break
;  endwhile
;
;  ;  if lonidx eq 34 then stop
;
;  ;  if fit_flag ne 1 then stop
;  ;  yfit1 = ribbon_gauss(lat_rc, p3)
;  ;  print, total((Flux_tmp-yfit1)^2/Flux_tmp.length)
;  ;  yfit2 = ribbon_gauss(lat_rc, pc_max2)
;  ;  print, total((Flux_tmp-yfit2)^2/Flux_tmp.length)
;
;  ;  p = errorplot(lat_rc, flux_tmp, Flux_stddev_tmp, yr = [-1, 5])
;  ;  p = plot(lat_rc, yfit1, /over, co = 'red', thick = 2)
;  ;  ;  p = plot(lat_rc, yfit2, /over, co = 'blue')
;  ;  fit_comp_co = ['green', 'orange', 'magenta']
;  ;  for ff = 0, n_pop-1 do begin
;  ;    par_tmp = [1, p3[1+3*ff:3+3*ff]]
;  ;    yfit1 = ribbon_gauss(lat_rc, par_tmp)
;  ;    p = plot(lat_rc, yfit1, co = fit_comp_co[ff], over = p, thick = 2)
;  ;  endfor
;
;  ;  p = plot(lat_rc, flux_tmp-ribbon_gauss(lat_rc, [1, p3[1:3]]))
;
;  dof = lat_rc.length-3*n_pop
;  chis = total((Flux_tmp-yfit)^2/Flux_stddev_tmp^2) / dof
;
;  return, {chis:chis, par:p3, fit_flag:fit_flag}
;end


function ribbon_generalized_gauss_fit_run, lat_rc, Flux_tmp, Flux_stddev_tmp, n_pop, Init_Guess, Init_Constraint = Init_Constraint, LOG = LOG

  ii = 0
  fit_flag = 0
  while fit_flag eq 0 do begin
    ii += 1


    ; 2 pop
    pc_max2 = !null
    parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
      limits:[0d, 0], PARNAME:'', MPSIDE:2}, 1+8+1)

    parinfo[0].fixed = 1
    parinfo[-1].fixed = 1

    fit_str = ['N_pop']
    for n = 1, n_pop do fit_str = [fit_str, 'A'+strcompress(n, /rem), 'T'+strcompress(n, /rem), 'D'+strcompress(n, /rem), 'alpha'+strcompress(n, /rem)]
    fit_str = [fit_str, 'LOG']
    parinfo.PARNAME = fit_str



    limit = replicate(!values.f_nan, 2, 1+n_pop*3)

    if ~keyword_set(Init_Constraint) then begin
      limit = [[n_pop, n_pop], $
        [0.1, Init_Guess[0]*1.1], $
        [Init_Guess[2]/2, Init_Guess[2]*2], $
        [Init_Guess[1]-4, Init_Guess[1]+4], $
        [1, 3], $
        [0.01, 1], $
        [5, 40], $
        [Init_Guess[1]-20, Init_Guess[1]+20], $
        [4, 10], $
        [LOG, LOG]]
      parinfo.limits = limit
      initial_guess = mean(limit, dim = 1)
      initial_guess[5] = 0.5
      if ii ne 0 then initial_guess[1:-1] = initial_guess[1:-1] + (randomu(seed, n_elements(initial_guess[1:-1])) - 0.5)*initial_guess[1:-1]*0.01
      initial_guess[-1] = LOG
      parinfo.value = initial_guess
    endif

    if keyword_set(Init_Constraint) then begin
      initial_guess = Init_Constraint
      if ii ne 0 then initial_guess[1:-1] = initial_guess[1:-1] + (randomu(seed, n_elements(initial_guess[1:-1])) - 0.5)*initial_guess[1:-1]*0.01
      initial_guess[-1] = LOG
      parinfo.value = initial_guess

      limit = [[2, 2], $
        [initial_guess[1]-initial_guess[1]*0.2, initial_guess[1]+initial_guess[1]*0.2], $ ; peak
        [initial_guess[2]-initial_guess[2]*0.2, initial_guess[2]+initial_guess[2]*0.2], $ ; width
        [initial_guess[3]-initial_guess[3]*0.1, initial_guess[3]+initial_guess[3]*0.1], $ ; pos
        [1, 3], $
        [initial_guess[5]-initial_guess[5]*0.2, initial_guess[5]+initial_guess[5]*0.2], $ ; peak
        [initial_guess[6]-initial_guess[6]*0.2, initial_guess[6]+initial_guess[6]*0.2], $ ; width
        [initial_guess[7]-initial_guess[7]*0.1, initial_guess[7]+initial_guess[7]*0.1], $ ; pos
        [2, 10], $
        [LOG, LOG]]
      parinfo.limits = limit
    endif


    IF LOG EQ 1 THEN BEGIN
      FTMP = ALOG(Flux_tmp)
      FIDX = WHERE(FINITE(FTMP))
      p3 = mpfitfun('ribbon_generalized_gauss', lat_rc[FIDX], FTMP[FIDX], replicate(1, FIDX.length), pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /QUIET)

    ENDIF ELSE p3 = mpfitfun('ribbon_generalized_gauss', lat_rc, Flux_tmp, replicate(1, Flux_stddev_tmp.length), pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /quiet)

    ;    fit_flag = 0
    if (npegged EQ 0) and (status ge 6) then $
      fit_flag = 1
    lh = p3[1:-2] eq reform(limit[0, 1:-2])
    uh = p3[1:-2] eq reform(limit[1, 1:-2])
    ;    IF TOTAL(NPEGGED) NE 0 THEN STOP

    if keyword_set(Init_Constraint) and fit_flag eq 0 then Init_Constraint = !null

    ;    idx0 = where(reform(limit[0, 1:-1]) eq p3[1:-1], tmp0)
    ;    idx1 = where(reform(limit[1, 1:-1]) eq p3[1:-1], tmp1)
    ;    if tmp0 ne 0 then print, 'Iter # ', ii, ', Status ', status, ', # of pegged', npegged, ', Par', fit_str[idx0+1]+', Lower'
    ;    if tmp1 ne 0 then print, 'Iter # ', ii, ', Status ', status, ', # of pegged', npegged, ', Par', fit_str[idx1+1]+', Upper'

    ;    if n_pop eq 2 then stop
    ;    if n_pop eq 3 then stop
    if ii gt 10 then break
  endwhile

  ;  yfit1 = ribbon_skew_gauss(lat_rc, p3, thcik = 2)
  ;  print, total((Flux_tmp-yfit1)^2/Flux_tmp.length)
  ;  yfit2 = ribbon_gauss(lat_rc, pc_max2)
  ;  print, total((Flux_tmp-yfit2)^2/Flux_tmp.length)

  ;  p = plot(lat_rc, flux_tmp, thick = 2)
  ;  p = plot(lat_rc, yfit1, /over, co = 'red')
  ;  ;  p = plot(lat_rc, yfit2, /over, co = 'blue')
  ;  fit_comp_co = ['green', 'orange', 'magenta']
  ;  for ff = 0, 1 do begin
  ;    par_tmp = [1, p3[1+4*ff:4+4*ff]]
  ;    yfit2 = ribbon_skew_gauss(lat_rc, par_tmp)
  ;    p = plot(lat_rc, yfit2, co = fit_comp_co[ff], over = p)
  ;  endfor

  ;  p = plot(lat_rc, flux_tmp-ribbon_gauss(lat_rc, [1, p3[1:3]]))

  dof = lat_rc.length-3*n_pop
  chis = total((Flux_tmp-yfit)^2/Flux_stddev_tmp^2) / dof
  if fit_flag eq 0 then stop
  return, {chis:chis, par:p3, fit_flag:fit_flag}
end

;function ribbon_gauss_fit_run, lat_rc, Flux_tmp, Flux_stddev_tmp, n_pop, Init_Guess
;
;
;
;  ; 2 pop
;  pc_max2 = !null
;  parinfo = replicate({value:0.D, fixed:0, limited:[1,1], $
;    limits:[0d, 0], PARNAME:'', MPSIDE:2}, 1+n_pop*3)
;
;  parinfo[0].fixed = 1
;
;  fit_str = ['N_pop']
;  for n = 1, n_pop do fit_str = [fit_str, 'A'+strcompress(n, /rem), 'T'+strcompress(n, /rem), 'D'+strcompress(n, /rem)]
;  parinfo.PARNAME = fit_str
;
;  initial_guess = n_pop
;  for n = 1, n_pop do $
;    initial_guess = [initial_guess, Init_Guess[0]/(n^2), Init_Guess[2]*(n^2), Init_Guess[1]]
;  parinfo.value = initial_guess
;
;  limit = [n_pop, n_pop]
;  for n = 1, n_pop do $
;    limit = [[limit], $
;    [parinfo[1+(n-1)*3].value/10, parinfo[1+(n-1)*3].value*2], $
;    [parinfo[2+(n-1)*3].value/5, parinfo[2+(n-1)*3].value*50], $
;    [parinfo[3+(n-1)*3].value-5, parinfo[3+(n-1)*3].value+5]]
;  parinfo.limits = limit
;
;  p3 = mpfitfun('ribbon_gauss', lat_rc, Flux_tmp, !null, pc_max2, status = status, parinfo = parinfo, ftol = 1D-40, xtol = 1D-40, gtol = 1D-40, BESTNORM = BESTNORM, maxiter = 1e4, niter = niter, npegged = npegged, yfit = yfit, /quiet)
;  fit_flag = 0
;  if (npegged le 1) and (status ge 6) then $
;    fit_flag = 1
;
;
;  stop
;
;  ;    yfit1 = ribbon_gauss(lat_rc, p3)
;  ;    print, total((Flux_tmp-yfit1)^2/Flux_tmp.length)
;  ;    yfit2 = ribbon_gauss(lat_rc, pc_max2)
;  ;    print, total((Flux_tmp-yfit2)^2/Flux_tmp.length)
;
;  dof = lat_rc.length-3*n_pop
;  chis = total((Flux_tmp-yfit)^2/Flux_stddev_tmp^2) / dof
;
;  return, {chis:chis, par:p3, fit_flag:fit_flag}
;end




Pro Ribbon_Gaussian_Fit
  common var1, lonidx

  MAPNAME = 'Theseus'
  SEPNAME = 'L'
  ver = 'svGP_v20240413'
  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  N_SAMPLE = 1000

  path_str = strsplit(cpath, '\', /extract)
  cd, cpath

  !EXCEPT = 0
  restore, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\surv_map_2009_2022\surv_map_2009_2022.sav'
  survp =  reform(survp_map[*, 0, *, *, *])


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
  DPATH = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\TheseusRibbonSep_RC_Peak_Moment_svGP_v20240413\'
  DPATH_map = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV_svGP_v20240413\'
  FPATH = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\Gauss_Fit\'
  file_mkdir, FPATH
  ; ************************** INPUT **************************
  co_e = rgb_vector(5, ct = 13)
  co_y = rgb_vector(14, ct = 13)

  dl = 0
  lonidx1 = [8-dl:8+dl];[7, 8, 9]
  lonidx2 = [108-dl:108+dl];[107, 108, 109]

  for esa = 2, 6 do begin
    !NULL = EXECUTE('esa'+strcompress(esa, /rem)+'_RBN_res = replicate(!values.f_nan, 180, 90, 14)')
    !NULL = EXECUTE('esa'+strcompress(esa, /rem)+'_RBN_stddev_res = replicate(!values.f_nan, 180, 90, 14)')
    !NULL = EXECUTE('esa'+strcompress(esa, /rem)+'_NUM_MOM_res = replicate(!values.f_nan, 4, 180, 14)')
  endfor
  ram = 0
  str = 'Ram'
  for yidx = 2009, 2022 do begin
    year = string(yidx, format = '(I4)')
    RESTORE, dpath +MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'

    RESTORE, DPATH_map +MAPNAME+'-'+SEPNAME+'_RBN_SEP_'+year+'_'+str+'.sav'

    FOR ESA = 2, 6 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      !NULL = EXECUTE('esa'+ESA_STR+'_NUM_MOM_res[*, *, yidx-2009] = esa'+ESA_STR+'_NUM_MOM')

      ; coord transform
      res = meshgrid(LON_ARR, lat_arr)
      lat_mat = res.remove()
      lon_mat = res.remove()
      t0 = RC_E_LONLAT[esa-2, 2] ; ecliptic latitude in degree (not colat or polar angle)
      p0 = RC_E_LONLAT[esa-2, 1] ; ecliptic longitude in degree

      res = conv_coord_ec_rc(lON_mat, lat_mat+90, p0, t0, /reverse, nose_POS = [255.6, 5.14])
      P1 = RES.LON
      T1 = RES.LAT
      LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
      LAT_IDX = interpol(dindgen(LAT_ARR.length), LAT_ARR, T1)
      ; coord transform

      !NULL = EXECUTE('esa'+ESA_STR+'_RBN_res[*, *, yidx-2009] = INTERPOLATE(esa'+ESA_STR+'_RBN_map/reform(survp[yidx-2009, *, *, esa-2]), LON_IDX, LAT_IDX, /DOUBLE)')
      !NULL = EXECUTE('esa'+ESA_STR+'_RBN_stddev_res[*, *, yidx-2009] = INTERPOLATE(esa'+ESA_STR+'_RBN_STDDEV_MAP/reform(survp[yidx-2009, *, *, esa-2]), LON_IDX, LAT_IDX, /DOUBLE)')
    ENDFOR ; ESA

  endfor


  ;  for yidx = 2009, 2022 do begin
  ;    rbn_tmp = esa5_rbn_res[*, *, yidx-2009]
  ;    rbn_stddev_tmp = esa5_rbn_stddev_res[*, *, yidx-2009]
  ;    file_mkdir, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV_svGP_v20240413\ESA5forFit\'+strcompress(yidx, /rem)
  ;    for lidx = 0, 179 do begin
  ;      openw, lun, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV_svGP_v20240413\ESA5forFit\'+strcompress(yidx, /rem)+'\Y'+strcompress(yidx, /rem)+'_L'+string(lidx, format = '(I3.3)')+'.txt', /get_lun
  ;      for latidx = 0, 89 do $
  ;      printf, lun, [lat_rc[latidx], rbn_tmp[lidx, latidx], rbn_stddev_tmp[lidx, latidx]]
  ;      free_lun, lun
  ;    endfor
  ;  endfor
  ;stop


  ; 33333333333333333333 Generalized Gaussian 33333333333333333333
  n_pop_res = replicate(!values.f_nan, 180, 14, 5)
  no_good_fit_res = replicate(!values.f_nan, 180, 14, 5)
  par_save = replicate(!values.f_nan, 180, 14, 5, 9)
  ESA_RBN_RES = replicate(!values.f_nan, 180, 90, 14, 5, 2) ; lon x lat x year x energy x primary/secondary

  tic
  win = window(dim = [800, 600], /buffer)
  win.refresh, /disable

  FPATH = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\GeneralizedGauss_Fit\'
  file_mkdir, FPATH

  LOG = 0
  fit_comp_co = ['green', 'orange', 'magenta']
  for yidx = 2009, 2022 do begin
    year = string(yidx, format = '(I4)')

    print, 'Year', year, string(9B), systime()
    FOR ESA = 5, 5 DO BEGIN
      ESA_STR = strcompress(esa, /rem)
      FPATH_tmp = FPATH+'ESA'+ESA_STR+'\'+year+'\LOG'+STRCOMPRESS(LOG, /REM)+'\'
      file_mkdir, FPATH_tmp
      print, 'ESA', ESA_STR

      init_constraint_count = 0

      for lonidx = 0, 179 do begin
        !NULL = EXECUTE('Flux_tmp = reform(ESA'+ESA_STR+'_RBN_RES[lonidx, *, yidx-2009])')
        !NULL = EXECUTE('Flux_stddev_tmp = reform(ESA'+ESA_STR+'_RBN_stddev_res[lonidx, *, yidx-2009])')
        !NULL = EXECUTE('Init_Guess = max(Flux_tmp)')
        !NULL = EXECUTE('Init_Guess = [Init_Guess, reform(ESA'+ESA_STR+'_NUM_MOM_res[*, lonidx, yidx-2009])]')

        ; gaussian fit
        n_pop = 2
        if Init_Constraint_count eq 0 then res2 = ribbon_generalized_gauss_fit_run(lat_rc, Flux_tmp, Flux_stddev_tmp, n_pop, Init_Guess, LOG = LOG) $
        else res2 = ribbon_generalized_gauss_fit_run(lat_rc, Flux_tmp, Flux_stddev_tmp, n_pop, Init_Guess, init_constraint = par2, LOG = LOG)

        chis2 = res2.chis
        par2 = res2.par
        fit_flag2 = res2.fit_flag
        if fit_flag2 ne 0 then init_constraint_count = 1

        if fit_flag2 eq 0 then begin
          no_good_fit_res[lonidx, yidx-2009, esa-2] = 1
          init_constraint_count = 0
          ;          continue
        endif

        n_pop_res[lonidx, yidx-2009, esa-2] = 2

        ; gaussian fit

        fit_co = 'red'
        line_style = 0
        title_str = 'Good Fit'
        if fit_flag2 eq 0 then begin
          line_style = 2
          fit_co = 'blue'
          title_str = 'Bad Fit'
        endif

        PAR2[-1] = 0
        yfit = ribbon_generalized_gauss(lat_rc, par2)

        ep = errorplot(lat_rc, Flux_tmp, Flux_stddev_tmp, xr = [0, 180], yr = [0.01, CEIL(MAX(Flux_tmp+Flux_stddev_tmp) * 0.1)*10], YLOG = LOG, thick = 2, current = win, xtitle = 'Lon_RC', ytitle = 'Flux', title = 'ESA'+esa_str+', Lon'+string(lon_arr[lonidx], format = '(I3)')+'!C'+title_str)
        p = plot(lat_rc, yfit, over = ep, co = fit_co, linestyle = line_style, thick = 2)

        par_save[lonidx, yidx-2009, esa-2, 0] = 2
        if par2[1] gt par2[5] then begin
          par_tmp = [1, par2[1:4]]
          yfit1 = ribbon_generalized_gauss(lat_rc, par_tmp)
          p = plot(lat_rc, yfit1, over = ep, co = fit_comp_co[0])
          ESA_RBN_RES[lonidx, *, yidx-2009, esa-2, 0] = yfit1
          par_save[lonidx, yidx-2009, esa-2, 1:4] = par2[1:4]

          par_tmp = [1, par2[5:8]]
          yfit1 = ribbon_generalized_gauss(lat_rc, par_tmp)
          p = plot(lat_rc, yfit1, over = ep, co = fit_comp_co[1])
          ESA_RBN_RES[lonidx, *, yidx-2009, esa-2, 1] = yfit1
          par_save[lonidx, yidx-2009, esa-2,5:8] = par2[5:8]
        endif else begin
          par_tmp = [1, par2[5:8]]
          yfit1 = ribbon_generalized_gauss(lat_rc, par_tmp)
          p = plot(lat_rc, yfit1, over = ep, co = fit_comp_co[0])
          ESA_RBN_RES[lonidx, *, yidx-2009, esa-2, 0] = yfit1
          par_save[lonidx, yidx-2009, esa-2, 1:4] = par2[5:8]

          par_tmp = [1, par2[1:4]]
          yfit1 = ribbon_generalized_gauss(lat_rc, par_tmp)
          p = plot(lat_rc, yfit1, over = ep, co = fit_comp_co[1])
          ESA_RBN_RES[lonidx, *, yidx-2009, esa-2, 1] = yfit1
          par_save[lonidx, yidx-2009, esa-2,5:8] = par2[1:4]
        endelse

        win.save, FPATH_tmp+'ESA'+esa_str+'_Lon'+string(lon_arr[lonidx], format = '(I3.3)')+'_'+year+'.png'
        win.erase
      endfor ; lon
      fit_flag = reform(no_good_fit_res[*, yidx-2009, 5-2])
      no_idx = where(fit_flag eq 1, no_tmp)
      yes_idx = where(fit_flag eq 0, yes_tmp)

      rbn_tmp = reform(ESA5_RBN_RES[*, *, yidx-2009])
      sp = spec_plot(rbn_tmp, lon_arr, lat_rc, data_min = 0.01, data_max = 30, /data_log, title = 'Observation', xtitle = 'Lon_EC', ytitle = 'Lat_EC', font_size = 15, xr = [0, 360], yr = [0, 180])
      cb = color_bar(sp, ytitle = 'Flux')
      if no_tmp ne 0 then sc = scatterplot(lon_arr[no_idx], replicate(10, no_tmp), symbol = '.', sym_thick = 3, sym_color = 'gray', over = sp)
      ;    if yes_tmp ne 0 then sc = scatterplot(lon_arr[yes_idx], replicate(10, yes_tmp), symbol = '.', sym_thick = 3, sym_color = 'white', over = sp)
      if no_tmp ne 0 then begin
        for ii = 0, no_idx.length-1 do begin
          xx = [lon_arr[no_idx[ii]]-1, lon_arr[no_idx[ii]]+1, lon_arr[no_idx[ii]]+1, lon_arr[no_idx[ii]]-1]
          yy = [180, 180, 0, 0]
          py = polygon(xx, yy, target = sp, /fill_background, fill_color = 'gray', fill_transparency = 70, linestyle = 6, /data)
        endfor
      endif
      sp.save, fpath_tmp+'Observation_'+year+'.png'
      sp.close

      rbn_tmp = reform(ESA_RBN_RES[*, *, yidx-2009, 3, 0]); esa5
      sp = spec_plot(rbn_tmp, lon_arr, lat_rc, data_min = 0.01, data_max = 30, /data_log, title = 'Primary', xtitle = 'Lon_EC', ytitle = 'Lat_EC', font_size = 15, xr = [0, 360], yr = [0, 180])
      cb = color_bar(sp, ytitle = 'Flux')
      if no_tmp ne 0 then sc = scatterplot(lon_arr[no_idx], replicate(10, no_tmp), symbol = '.', sym_thick = 3, sym_color = 'gray', over = sp)
      ;    if yes_tmp ne 0 then sc = scatterplot(lon_arr[yes_idx], replicate(10, yes_tmp), symbol = '.', sym_thick = 3, sym_color = 'white', over = sp)
      if no_tmp ne 0 then begin
        for ii = 0, no_idx.length-1 do begin
          xx = [lon_arr[no_idx[ii]]-1, lon_arr[no_idx[ii]]+1, lon_arr[no_idx[ii]]+1, lon_arr[no_idx[ii]]-1]
          yy = [180, 180, 0, 0]
          py = polygon(xx, yy, target = sp, /fill_background, fill_color = 'gray', fill_transparency = 70, linestyle = 6, /data)
        endfor
      endif

      sp.save, fpath_tmp+'Fit_Primary_'+year+'.png'
      sp.close

      rbn_tmp = reform(ESA_RBN_RES[*, *, yidx-2009, 3, 1]); esa5
      sp = spec_plot(rbn_tmp, lon_arr, lat_rc, data_min = 0.01, data_max = 30, /data_log, title = 'Secondary', xtitle = 'Lon_EC', ytitle = 'Lat_EC', font_size = 15, xr = [0, 360], yr = [0, 180])
      cb = color_bar(sp, ytitle = 'Flux')
      if no_tmp ne 0 then sc = scatterplot(lon_arr[no_idx], replicate(10, no_tmp), symbol = '.', sym_thick = 3, sym_color = 'gray', over = sp)
      ;    if yes_tmp ne 0 then sc = scatterplot(lon_arr[yes_idx], replicate(10, yes_tmp), symbol = '.', sym_thick = 3, sym_color = 'white', over = sp)
      if no_tmp ne 0 then begin
        for ii = 0, no_idx.length-1 do begin
          xx = [lon_arr[no_idx[ii]]-1, lon_arr[no_idx[ii]]+1, lon_arr[no_idx[ii]]+1, lon_arr[no_idx[ii]]-1]
          yy = [180, 180, 0, 0]
          py = polygon(xx, yy, target = sp, /fill_background, fill_color = 'gray', fill_transparency = 70, linestyle = 6, /data)
        endfor
      endif

      sp.save, fpath_tmp+'Fit_Secondary_'+year+'.png'
      sp.close
      stop
      
    ENDFOR ; ESA

   
  endfor ; year
  win.close
  ; 33333333333333333333 Generalized Gaussian 33333333333333333333



  fit_vars = ['# of fit functions', 'A1', 'sig1', 'd1', 'A2', 'sig2', 'd2', 'A3', 'sig3', 'd3']
  save, file = FPATH+'Fit_Result.sav', /compress $
    , par_save, n_pop_res, no_good_fit_res, fit_vars, lon_arr


  stop
end