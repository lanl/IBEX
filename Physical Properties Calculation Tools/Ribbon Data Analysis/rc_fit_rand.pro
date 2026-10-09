function circ_Fit_in_RC_run, peak_pos, esa $
  , ERROR = ERROR $
  , initial_guess = initial_guess

  common funsten2013, RC_Circ_Funsten2013, RC_Ellip_Funsten2013

  parinfo = replicate({value:0d, fixed:0, limited:[1,1], $
    limits:[-100.D,100], PARNAME:''}, 5)

  if ~keyword_set(initial_guess) then begin
    parinfo[0].value = RC_Ellip_Funsten2013[0, esa]
    parinfo[1].value = RC_Ellip_Funsten2013[1, esa]
    parinfo[2].value = RC_Ellip_Funsten2013[2, esa]
    parinfo[3].value = RC_Ellip_Funsten2013[1, esa]
    parinfo[4].value = RC_Ellip_Funsten2013[2, esa]
  endif
  if keyword_set(initial_guess) then begin
    parinfo[0].value = initial_guess[0]
    parinfo[1].value = initial_guess[1]
    parinfo[2].value = initial_guess[2]
    parinfo[3].value = initial_guess[3]
    parinfo[4].value = initial_guess[4]
  endif
  parinfo[0].limits = [20, 160d]
  parinfo[1].limits = [0, 89d]
  parinfo[2].limits = [0, 360d]
  parinfo[3].limits = [0, 89d]
  parinfo[4].limits = [0, 360d]

  parinfo[3:4].fixed = 1


  parinfo[0:4].PARNAME(0) = ['radius', 'theta0', 'phi0', 'theta00', 'phi00']
  parameter = !null

  peak_pos_tmp = peak_pos
  idx1 = where(finite(peak_pos_tmp[*, 1]))
  peak_pos_tmp = peak_pos_tmp[idx1, *]
  error1 = error[idx1]
  if total(~finite(peak_pos_tmp[*, 1])) ne 0 then stop

  idx = sort(peak_pos_tmp[*, 0])
  peak_pos_tmp = peak_pos_tmp[idx, *]
  error1 = error1[idx]


  tmp = 1
  kk = 0
  while tmp ne 0 do begin
    tmp = 0
    par_tmp = initial_guess[0:2]+(initial_guess[0:2]*0.1*(randomu(seed, 3, /double)-0.5))
    parinfo[0:2].value = par_tmp
    ph = mpfitfun('circ_fit_from_rc', peak_pos_tmp, peak_pos_tmp[*, 1], error1, !null, status = status, parinfo = parinfo, BESTNORM = BESTNORM, BEST_resid = BEST_resid, PERROR = PERROR, /nan, /quiet)
    for jj = 0, 2 do tmp = tmp+((parinfo[jj].limits[0] eq ph[jj]) or (parinfo[jj].limits[1] eq ph[jj]))
    for jj = 0, 2 do tmp = tmp+((parinfo[jj].value eq ph[jj]))
    if status le 0 then tmp = 1
    if tmp eq 0 then break
    kk += 1
    ;    print, esa, kk, ph
    if kk gt 1000 then break
  endwhile

  ;  if status le 0 then stop
  yfit = circ_fit_from_rc(peak_pos_tmp, ph, /all)

  DOF     = N_ELEMENTS(peak_pos_tmp[*, 0]) - 3 ; deg of freedom
  if n_elements(error1) eq n_elements(peak_pos_tmp[*, 1]) then chir_ellip = total(((peak_pos_tmp[*, 1]-yfit.lat_match)^2/error1^2))/(DOF) $
  else chir_ellip = total(((peak_pos_tmp[*, 1]-yfit.lat_match)^2/abs(yfit.lat_match)))/(DOF)

  if n_elements(perror) eq 0 then PERROR = replicate(-1, 5)
  if kk gt 1000 then return, {parameter:ph, para_name:parinfo.PARNAME, PERROR:PERROR, Chi2:-1} else return, {parameter:ph, para_name:parinfo.PARNAME, PERROR:PERROR, Chi2:chir_ellip}

end

function Ellipse_Fit_in_RC_run, peak_pos, esa $
  , ERROR = ERROR $
  , initial_guess = initial_guess

  common funsten2013, RC_Circ_Funsten2013, RC_Ellip_Funsten2013

  parinfo = replicate({value:0d, fixed:0, limited:[1,1], $
    limits:[-100.D,100], PARNAME:''}, 7)

  if ~keyword_set(initial_guess) then begin
    parinfo[0].value = RC_Ellip_Funsten2013[0, esa]
    parinfo[1].value = RC_Ellip_Funsten2013[1, esa]
    parinfo[2].value = RC_Ellip_Funsten2013[2, esa]
    parinfo[3].value = RC_Ellip_Funsten2013[3, esa]
    parinfo[4].value = RC_Ellip_Funsten2013[4, esa]
    parinfo[5].value = RC_Ellip_Funsten2013[3, esa]
    parinfo[6].value = RC_Ellip_Funsten2013[4, esa]
  endif
  if keyword_set(initial_guess) then begin
    parinfo[0].value = initial_guess[0]
    parinfo[1].value = initial_guess[1]
    parinfo[2].value = initial_guess[2]
    parinfo[3].value = initial_guess[3]
    parinfo[4].value = initial_guess[4]
    parinfo[5].value = initial_guess[5]
    parinfo[6].value = initial_guess[6]
  endif
  parinfo[0].limits = [20, 160d]
  parinfo[1].limits = [20, 160d]
  parinfo[2].limits = [-3600, 3600d]
  parinfo[3].limits = [0, 89d]
  parinfo[4].limits = [0, 360d]
  parinfo[5].limits = [0, 89d]
  parinfo[6].limits = [0, 360d]

  parinfo[5:6].fixed = 1


  parinfo[0:6].PARNAME(0) = ['a', 'b', 'rotation angle', 'theta0', 'phi0', 'theta00', 'phi00']
  parameter = !null

  peak_pos_tmp = peak_pos
  idx1 = where(finite(peak_pos_tmp[*, 1]))
  peak_pos_tmp = peak_pos_tmp[idx1, *]
  error1 = error[idx1]
  ;  if total(~finite(peak_pos_tmp[*, 1])) ne 0 then stop

  idx = sort(peak_pos_tmp[*, 0])
  peak_pos_tmp = peak_pos_tmp[idx, *]
  error1 = error1[idx]

  tmp = 1
  kk = 0
  d = 5d
  while tmp ne 0 do begin
    tmp = 0
    par_tmp = initial_guess[0:4]+(initial_guess[0:4]*0.1d*(randomu(seed, 5, /double)-0.5))
    ;    print, par_tmp
    ;    jump1:
    ;    par_tmp[2] = (d + kk*d)+(randomu(seed, 1, /double)-0.5)
    ;    if par_tmp[2] gt 180-d then begin
    ;      kk = 0
    ;      goto, jump1
    ;    endif
    parinfo[0:4].value = par_tmp
    ph = mpfitfun('ellip_fit_from_rc', peak_pos_tmp, peak_pos_tmp[*, 1], error1, npegged=npegged, status = status, parameter, parinfo = parinfo, BESTNORM = BESTNORM, BEST_resid = BEST_resid, PERROR = PERROR, /nan, /quiet)
    for jj = 0, 4 do tmp = tmp+((parinfo[jj].limits[0] eq ph[jj]) or (parinfo[jj].limits[1] eq ph[jj]))
    for jj = 0, 4 do tmp = tmp+((parinfo[jj].value eq ph[jj]))
    
    if status le 0 then tmp = 1
    ;        if tmp ne 0 then print, ph, status
    if tmp eq 0 then break
    kk += 1
    ;    stop
    ;    print, esa, kk, ph
    ;    stop
    if kk gt 1000 then break
  endwhile
  ;  print, ph, status
  ;  if status le 0 then stop

  yfit = ellip_fit_from_rc(peak_pos_tmp, ph, /all)

  DOF     = N_ELEMENTS(peak_pos_tmp[*, 0]) - 5 ; deg of freedom
  if n_elements(error1) eq n_elements(peak_pos_tmp[*, 1]) then chir_ellip = total(((peak_pos_tmp[*, 1]-yfit.lat_match)^2/error1^2))/(DOF) $
  else chir_ellip = total(((peak_pos_tmp[*, 1]-yfit.lat_match)^2/abs(yfit.lat_match)))/(DOF)

  if n_elements(perror) eq 0 then PERROR = replicate(-1, 7)
  if kk gt 1000 then return, {parameter:ph, para_name:parinfo.PARNAME, PERROR:PERROR, Chi2:-1} else return, {parameter:ph, para_name:parinfo.PARNAME, PERROR:PERROR, Chi2:chir_ellip}

end

FUNCTION RC_FIT_RAND, LON_ARR, PEAK_LAT, RC, ESA, initial_guess_c, initial_guess_e, ERROR = ERROR
  common funsten2013, RC_Circ_Funsten2013, RC_Ellip_Funsten2013
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

  lon_num = float(LON_ARR.LENGTH)

  tol = 1d-15


  ellip_fit_tmp = initial_guess_e; reform(RC_ELLIP_FUNSTEN2013[*, esa])
  ellip_fit_tmp = [ellip_fit_tmp, RC[1], RC[0]]
  circ_fit_tmp = initial_guess_c ;reform(RC_circ_FUNSTEN2013[*, esa])
  circ_fit_tmp = [circ_fit_tmp, RC[1], RC[0]]

  IF ~KEYWORD_SET(ERROR) THEN ERROR_tmp = replicate(1d, lon_arr.length) else ERROR_tmp = error
  ;  ERROR = replicate(1d, lon_arr.length)

  SZ = SIZE(REFORM(PEAK_LAT))

  if sz[0] eq 1 then n_sample = 1 else n_sample = SZ[2]
  FIT_C_RES = replicate(!VALUES.D_NAN, 3, n_sample)
  FIT_E_RES = replicate(!VALUES.D_NAN, 5, n_sample)

  FOR ITER = 0, n_sample-1 DO BEGIN
    peak_pos = [[lon_arr], [REFORM(PEAK_LAT[*, ITER])]]

    ;    ; 2023 04 22 ribbon drop due to symmetric gdf excluded
    ;    ridx = where(lon_Arr gt 120 and lon_arr lt 150)
    ;    peak_pos[ridx, 1] = !values.d_nan
    ;    ; 2023 04 22 ribbon drop due to symmetric gdf excluded

    ; 2025 03 23 S-T excluded
    ridx = where(lon_Arr gt 170 and lon_arr lt 220)
    peak_pos[ridx, 1] = !values.d_nan
    ; 2025 03 23 S-T excluded


    if total(finite(peak_pos[*, 1]))/lon_num lt 0.25 then begin
      res_C = {parameter:circ_fit_tmp, para_name:['radius', 'theta0', 'phi0', 'theta00', 'phi00'], PERROR:replicate(-1, 5), Chi2:-1}
      res_E = {parameter:ellip_fit_tmp, para_name:['a', 'b', 'rotation angle', 'theta0', 'phi0', 'theta00', 'phi00'], PERROR:replicate(-1, 5), Chi2:-1}
    endif else begin
      res_E = Ellipse_Fit_in_RC_run(peak_pos, esa, error = ERROR_tmp, initial_guess = ellip_fit_tmp)
      res_C = Circ_Fit_in_RC_run(peak_pos, esa, error = ERROR_tmp, initial_guess = circ_fit_tmp)

      ;      res = ellip_fit_from_rc(peak_pos, res_E.parameter, /all)
      ;      win = window(dim = [600, 600])
      ;      pp = polarplot( peak_pos[*, 1], peak_pos[*, 0]*!dtor, current = win, pos = [0, 0, 1, 1])
      ;      pp = polarplot(res.lat_match, peak_pos[*, 0]*!dtor, over = pp, color = 'red')

      ;ellipse rotate
      ;      print, res_e.parameter

      if res_e.parameter[0] lt res_e.parameter[1] then begin
        res_e.parameter[0:1] = [res_e.parameter[1], res_e.parameter[0]]
        ;        if res_e.parameter[2] ge 0 and res_e.parameter[2] lt 90 then res_e.parameter[2] = res_e.parameter[2]+90d
        ;        if res_e.parameter[2] ge 90 and res_e.parameter[2] lt 180 then res_e.parameter[2] = res_e.parameter[2]-90d
        res_e.parameter[2] = res_e.parameter[2]+90d
      endif
      ;
      while res_e.parameter[2] lt 0 or res_e.parameter[2] gt 180 do begin
        if res_e.parameter[2] lt 0 then res_e.parameter[2] = res_e.parameter[2]+180d
        if res_e.parameter[2] gt 180 then res_e.parameter[2] = res_e.parameter[2]-180d
      endwhile
      ;      print, res_e.parameter

      ;      print, res_e.parameter
      ;ellipse rotate
      IF RES_C.CHI2 GE 0 THEN FIT_C_RES[*, ITER] = RES_C.PARAMETER[0:-3]
      IF RES_E.CHI2 GE 0 THEN FIT_E_RES[*, ITER] = RES_E.PARAMETER[0:-3]
    endelse
  ENDFOR ; iteration

  ;  sc = scatterplot(findgen(1000), FIT_E_RES[2, *], yr = [0, 180])
  ;  print, mean(FIT_E_RES[2, *], /nan), stddev(FIT_E_RES[2, *], /nan)


  ; rotation angle to sin(rot), MODIFIED TO A NEW MEAN, STDDEV CALC METHOD, 07/27/2023
  rot_angle_save = REFORM(FIT_E_RES[2, *])
  rot_angle = reform(FIT_E_RES[2, *])
  ;  ridx = where(rot_angle gt 90, /null, rtmp)
  ;  if rtmp ne 0 then rot_angle[ridx] = 180-rot_angle[ridx]
  ; rotation angle to sin(rot), MODIFIED TO A NEW MEAN, STDDEV CALC METHOD, 07/27/2023

  ;  rot_angle_cos = cos(reform(FIT_E_RES[2, *])*!DTOR)
  ;  FIT_E_RES[2, *] = sin(FIT_E_RES[2, *]*!DTOR)


  ; rotation angle to sin(rot)

  if n_sample gt 1 then peak_pos = [[lon_arr], [REFORM(MEAN(PEAK_LAT, DIM = 2, /NAN))]]
  if n_sample eq 1 then peak_pos = [[lon_arr], [PEAK_LAT]]
  if TOTAL(FINITE(FIT_C_RES)) NE 0 then BEGIN
    if n_sample gt 1 then res_circ = circ_fit_from_rc(peak_pos, [MEAN(FIT_C_RES, DIM = 2, /NAN), RC[1], RC[0]], /all)
    if n_sample eq 1 then res_circ = circ_fit_from_rc(peak_pos, [FIT_C_RES, RC[1], RC[0]], /all)
    res_circ = res_circ.lat_match
    if n_sample gt 1 then PAR_sig_c = STDDEV(FIT_C_RES, DIM = 2, /NAN)
    if n_sample eq 1 then PAR_sig_c = fltarr(3)
    sig_C = stddev(abs(res_circ-peak_pos[*, 1]), /nan)
  endif ELSE BEGIN
    sig_C = -1
    PAR_sig_c = REPLICATE(-1, 3)
    RES_CIRC = REPLICATE(-1, LON_ARR.LENGTH)
  endelse

  if TOTAL(FINITE(FIT_E_RES)) NE 0 then BEGIN
    if n_sample gt 1 then res_ellip = ellip_fit_from_rc(peak_pos, [MEAN(FIT_E_RES, DIM = 2, /NAN), RC[1], RC[0]], /all)
    if n_sample eq 1 then res_ellip = ellip_fit_from_rc(peak_pos, [FIT_E_RES, RC[1], RC[0]], /all)
    res_ellip = res_ellip.lat_match
    if n_sample gt 1 then par_e = MEAN(FIT_E_RES, DIM = 2, /NAN)
    if n_sample eq 1 then par_e = FIT_E_RES

    if n_sample gt 1 then PAR_sig_E = STDDEV(FIT_E_RES, DIM = 2, /NAN)
    if n_sample eq 1 then PAR_sig_E = FIT_E_RES

    ; ; MODIFIED TO A NEW MEAN, STDDEV CALC METHOD (USING PROBABILITY DENSITY FUNCTION!), 07/27/2023
    ;    par_e[2] = MEAN(rot_angle, /NAN)
    ;    if MEAN(rot_angle_save, /NAN) gt 90 then par_e[2] = 180-par_e[2]
    ; MODIFIED TO A NEW MEAN, STDDEV CALC METHOD, 07/27/2023
    ; Yamartino method, https://en.wikipedia.org/wiki/Yamartino_method
    ;    PAR_sig_E[2] = STDDEV(rot_angle, /NAN)
    ;    SA = MEAN(sin(rot_angle*!DTOR))
    ;    CA = MEAN(COS(rot_angle*!DTOR))
    ;    EPS = SQRT(1-(SA^2+CA^2))
    ;    PAR_sig_E[2] = ASIN(EPS)*(1+(2/SQRT(3) - 1)*EPS^3)*!radeg

    HIST = HISTOGRAM(rot_angle, MIN = 0, MAX = 180, BINSIZE = 10, LOC = LOC)
    LOC = (LOC[0:-2]+LOC[1:-1])/2
    HIST = HIST[0:-2]
    MXX = MAX(HIST, MX)

    loc_mx =  LOC[MX]
    IF loc_mx gt 90 then begin
      ANG_RANGE = [loc_mx-90, loc_mx+90]
      LIDX = WHERE(LOC lt ANG_RANGE[0], TMP)
      LOC[LIDX] = LOC[LIDX]+180
      LLIDX = SORT(LOC)
      LOC = LOC[LLIDX]
      HIST = HIST[LLIDX]
    ENDIF

    IF loc_mx lt 90 then begin
      ANG_RANGE = [loc_mx-90, loc_mx+90]
      LIDX = WHERE(LOC GT ANG_RANGE[1], TMP)
      LOC[LIDX] = LOC[LIDX]-180
      LLIDX = SORT(LOC)
      LOC = LOC[LLIDX]
      HIST = HIST[LLIDX]
    ENDIF


    M1 = TOTAL(HIST*LOC)/TOTAL(HIST)
    M2 = SQRT(TOTAL(HIST*(LOC-M1)^2)/TOTAL(HIST))
    par_e[2] = M1
    PAR_sig_E[2] = M2
    ; ; MODIFIED TO A NEW MEAN, STDDEV CALC METHOD, 07/27/2023

    sig_E = stddev(abs(res_ellip-peak_pos[*, 1]), /nan)
  endif ELSE BEGIN
    sig_E = -1
    PAR_sig_E = REPLICATE(-1, 5)
    RES_ELLIP = REPLICATE(-1, LON_ARR.LENGTH)
    par_e = REPLICATE(-1, 5)
  endelse

  ;  print, PAR_E
  ;  print, PAR_sig_E

  if n_sample gt 1 then RETURN, {PAR_C:MEAN(FIT_C_RES, DIM = 2, /NAN), PAR_E:par_e, RES_C:res_circ, RES_E:res_ellip, SIG_C:SIG_C, SIG_E:SIG_E, PAR_SIG_C:PAR_SIG_C, PAR_SIG_E:PAR_SIG_E}
  if n_sample eq 1 then RETURN, {PAR_C:FIT_C_RES, PAR_E:par_e, RES_C:res_circ, RES_E:res_ellip, SIG_C:SIG_C, SIG_E:SIG_E, PAR_SIG_C:PAR_SIG_C, PAR_SIG_E:PAR_SIG_E}


end