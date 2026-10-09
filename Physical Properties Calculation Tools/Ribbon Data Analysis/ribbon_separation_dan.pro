
function GAUSSIAN_TMP, X, p
  ;P[0] = AMPLITUDE
  ;P[1] = CENTER
  ;P[2] = STDDEV

  return, P[0]*EXP(-((X-P[1])/P[2]/SQRT(2))^2)
end

function SKEW_GAUSSIAN_TMP, X, p
  ;P[0] = AMPLITUDE
  ;P[1] = CENTER
  ;P[2] = STDDEV
  ;P[3] = SKEWNESS PARAMETER, ALPHA

  return, GAUSSIAN_TMP(X, P[0:2])*ERFC(-P[3]*(X-P[1])/P[2]/SQRT(2))
end


function SUPERPOSED_GAUSSIAN_TMP, X, p

  ;P[0] = AMPLITUDE = 100D
  ;P[1] = HP_DISTANCE = 100D
  ;P[2] = distance = 100
  ;P[3] = RIBBON_CENTER = 50D
  ;P[4] = RIBBON_WIDTH = 30D
  ;P[5] = SLOPE = 0D


  AMPLITUDE = P[0]
  HP_DISTANCE = P[1]
  distance = P[2]
  RIBBON_CENTER = P[3]
  RIBBON_WIDTH = P[4]
  SLOPE = P[5]

  f1 = DBLARR(X.LENGTH)
  for p0 = 1, distance, 2 do begin
    p1 = p0*SLOPE
    par = [AMPLITUDE/(HP_DISTANCE + p0)^2d, RIBBON_CENTER + p1, RIBBON_WIDTH]
    f = gaussian_tmp(x, par)
    f1 = f1+f
  endfor

  return, F1
end


function SUPERPOSED_GAUSSIAN_TMP_wgdf, X, p

  ;P[0] = AMPLITUDE = 100D
  ;P[1] = HP_DISTANCE = 100D
  ;P[2] = distance = 100
  ;P[3] = RIBBON_CENTER = 50D
  ;P[4] = RIBBON_WIDTH = 30D
  ;P[5] = SLOPE = 0D


  AMPLITUDE = P[0]
  HP_DISTANCE = P[1]
  distance = P[2]
  RIBBON_CENTER = P[3]
  RIBBON_WIDTH = P[4]
  SLOPE = P[5]

  f1 = DBLARR(X.LENGTH)
  for p0 = 1, distance, 2 do begin
    p1 = p0*SLOPE
    par = [AMPLITUDE/(HP_DISTANCE + p0)^2d, RIBBON_CENTER + p1, RIBBON_WIDTH]
    f = gaussian_tmp(x, par)
    f1 = f1+f
  endfor
  f1 = f1+ p[6]*x^2 + p[7]*x+p[8]

  return, F1
end

function Ribbon_Separation_Dan, esa_rc_map, esa_stddev_rc_map, RC, lon_arr, lat_rc, ESA

  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  ;  hp load
  XX = LINSPACE(0, 180, 1E4)


  parinfo = replicate({value:0d, fixed:0, limited:[1, 1], $
    limits:[-100.D,100], PARNAME:''}, 4)
  initial_guess = [200, 75., 10., 0.] ; ['AMPLITUDE', 'CENTER', 'STDDEV', 'SKEWNESS PARAMETER']
  parinfo.value = initial_guess
  initial_guess_limit = [[0, 1d8], $ ;'AMPLITUDE'
    [0, 180d], $ ;'CENTER'
    [1, 50.], $ ;'STDDEV'
    [-100, 100]] ; 'SKEWNESS PARAMETER'
  parinfo.limits = initial_guess_limit
  parinfo[0:3].PARNAME = ['AMPLITUDE', 'CENTER', 'STDDEV', 'SKEWNESS PARAMETER']

  ; 222222222222222 Lat Mask, Fit area seting
  if esa le 5 then mskidx = where(lat_rc ge 55 and lat_rc le 95) else mskidx = where(lat_rc ge 50 and lat_rc le 100)
  latidx = where(lat_rc ge 75-45 and lat_rc le 75+45)
  ; 222222222222222 Lat Mask, Fit area seting


  esa_rbn_map = esa_rc_map
  esa_gdf_map = esa_rc_map
  esa_rbn_map[*] = 0

  esa_rbn_stddev_map = esa_stddev_rc_map
  esa_gdf_stddev_map = esa_stddev_rc_map
  esa_rbn_stddev_map[*] = 0

  err = 0
  pkoff = 0
  lowcnt = 0
  narrow = 0
  FIT_FUNC = REPLICATE(!VALUES.F_NAN, LON_ARR.LENGTH)
  bb = []
  for lonidx = 0, LON_ARR.LENGTH-1 do begin
    JUMP:
    esa_fit_tmp = reform(esa_rc_map[lonidx, *])
    esa_fit_tmp[mskidx] = !values.d_nan
    esa_stddev_fit_tmp = reform(esa_stddev_rc_map[lonidx, *])
    esa_stddev_fit_tmp[mskidx] = !values.d_nan

    idx_finite = where(finite(esa_fit_tmp[latidx]), /null)

    if n_elements(idx_finite) lt 3 then begin
      lowcnt += 1
      continue
    endif

    lat_fit = lat_rc[latidx[idx_finite]]
    esa_fit = esa_fit_tmp[latidx[idx_finite]]
    esa_stddev_fit = esa_stddev_fit_tmp[latidx[idx_finite]]

    ;        c = poly_fit(lat_fit, esa_fit, 4, measure_errors = esa_stddev_fit, /double)


    cc = svdfit(lat_fit, esa_fit, 5, measure_errors = esa_stddev_fit, /double, yfit = yfit)

    x = lat_rc[latidx]
    ;        ygdf = c[4]*x^4+c[3]*x^3+c[2]*x^2+c[1]*x+c[0]
    ygdf = cc[4]*x^4+cc[3]*x^3+cc[2]*x^2+cc[1]*x+cc[0]

    ygdf1 = cc[4]*xx^4+cc[3]*xx^3+cc[2]*xx^2+cc[1]*xx+cc[0]

    ;    m1_gdf = total(ygdf1*xx) / total(ygdf1) ; MEAN
    ;    m2_gdf = sqrt(total(ygdf1*(xx-m1_gdf)^2) / total(ygdf1)) ; STDDEV

    m1_gdf = total(ygdf*x) / total(ygdf) ; MEAN
    m2_gdf = sqrt(total(ygdf*(x-m1_gdf)^2) / total(ygdf)) ; STDDEV

    rbn1 = reform(esa_rc_map[lonidx, latidx]) - ygdf
    rbn_err = reform(esa_stddev_rc_map[lonidx, latidx])

    !null = MAX(rbn1, MXIDX1)
    RP_EC = conv_coord_ec_rc(lon_arr[lonidx], lat_rc[latidx[mxidx1]], RC[0], RC[1], /reverse)
    ts_mat = griddata(lon_hp, lat_hp, hp_dist, /nearest, triangles = tr_hp, xout = replicate(rp_ec.lon, 2), yout = replicate(rp_ec.lat, 2))

    parinfo_spg = replicate({value:0d, fixed:0, limited:[1, 1], $
      limits:[-100.D,100], PARNAME:''}, 6)
    parinfo_spg[1:2].FIXED = 1
    ;    parinfo_spg.value = [PH1[0]*200, ts_mat[0], 500d, ph[1], PH1[2], 0d] ; ['AMPLITUDE', 'HP_DISTANCE', 'distance', 'RIBBON_CENTER', 'RIBBON_WIDTH', 'SLOPE']
    parinfo_spg.limits = [[0, 3d10], $ ;'AMPLITUDE'
      [50, 500d], $ ;'HP_DISTANCE'
      [1, 1000D], $ ;'distance'
      [0, 180D], $ ; 'RIBBON_CENTER'
      [1, 100D], $ ; 'RIBBON_WIDTH'
      [-1, 1D]] ; 'SLOPE'
    parinfo_spg[0:5].PARNAME = ['AMPLITUDE', 'HP_DISTANCE', 'distance', 'RIBBON_CENTER', 'RIBBON_WIDTH', 'SLOPE']

    norm2_tmp = fltarr(3)
    status2_tmp = fltarr(3)
    ph2_tmp = fltarr(6, 3)
    pe2_tmp = fltarr(6, 3)
    yfit_tmp = fltarr(x.length, 3)
    for sidx = -1, 1 do begin

      parinfo_spg.value = [initial_guess[0]*200+randomu(seed, 1)*1.0, ts_mat[0], 500d, 75+randomu(seed, 1)*10., 15+randomu(seed, 1)*1.0, double(sidx)*1e-1 + randomu(seed, 1)*0.01] ; ['AMPLITUDE', 'HP_DISTANCE', 'distance', 'RIBBON_CENTER', 'RIBBON_WIDTH', 'SLOPE']
      ph2 = mpfitfun('SUPERPOSED_GAUSSIAN_TMP', x, rbn1, REPLICATE(1D, rbn1.LENGTH), !null, status = status2, yfit = yfit2, parinfo = parinfo_SPG, covar = covar2, BESTNORM = BESTNORM2, BEST_resid = BEST_resid2, PERROR = PERROR2, /quiet, /nan, ftol = tol, xtol = tol)

      norm2_tmp[sidx+1] = bestnorm2
      status2_tmp[sidx+1] = status2
      ph2_tmp[*, sidx+1] = ph2
      pe2_tmp[*, sidx+1] = perror2
      yfit_tmp[*, sidx+1] = yfit2

    endfor

    !null = min(norm2_tmp, minidx)
    bestnorm2 = norm2_tmp[minidx]
    status2 = status2_tmp[minidx]
    ph2 = ph2_tmp[*, minidx]
    perror2 = pe2_tmp[*, minidx]
    yfit2 = yfit_tmp[*, minidx]
    YSPG = SUPERPOSED_GAUSSIAN_TMP(XX, PH2)
    m12 = total(yspg*xx) / total(yspg) ; MEAN
    m22 = sqrt(total(yspg*(xx-m12)^2) / total(yspg)) ; STDDEV
    if status2 lt 0 then stop
    if total(perror2 eq 0) gt 2 then bestnorm2 = 1e9



    mnidx = 2
    if bestnorm2 eq 1e9 then continue
    yy = yfit2

    rbn_ratio_tmp = yy/(ygdf+yy)
    gdf_ratio_tmp = ygdf/(ygdf+yy)

    !null = max(yy, mxidx)
    if esa le 5 then begin
      if x[mxidx] lt 50 or x[mxidx] gt 100 then begin
        pkoff += 1
        ;        print, x[mxidx]
        ;        stop
        continue
      endif
    endif else begin
      if x[mxidx] lt 45 or x[mxidx] gt 105 then begin
        pkoff += 1
        continue
      endif
    endelse


    ;    if esa le 5 then begin
    ;      if x[mxidx] lt 65 or x[mxidx] gt 85 then begin
    ;        pkoff += 1
    ;        ;        print, x[mxidx]
    ;        ;        stop
    ;        continue
    ;      endif
    ;    endif else begin
    ;      if x[mxidx] lt 60 or x[mxidx] gt 90 then begin
    ;        pkoff += 1
    ;        continue
    ;      endif
    ;    endelse
    ;
    ;    if lonidx eq 84 then stop
    ;    if bnorm gt 1 then stop
    latmxidx = where(lat_rc eq x[mxidx], /null)
    if esa_rc_map[lonidx, latmxidx] lt sqrt(total(esa_stddev_rc_map[lonidx, [latmxidx-2:latmxidx+2]]^2))/5.*2. then begin
      err = err+1
      continue
    endif

    ;    m2 = [m2, m21, m22]
    ;    m2 = m2[mnidx]
    m2 = m22
    if esa lt 6 then begin
      if m2 lt 4 or m2 gt 15 then begin
        narrow += 1
        continue
      endif
    endif else begin
      if m2 lt 4 or m2 gt 18 then begin
        narrow += 1
        continue
      endif
    endelse


    if m22 gt m2_gdf then begin
      print, lon_arr[lonidx], m22, m2_gdf
    endif

    rbn_ratio = replicate(0d, lat_rc.length)
    rbn_ratio[latidx] = rbn_ratio_tmp

    gdf_ratio = replicate(1d, lat_rc.length)
    gdf_ratio[latidx] = gdf_ratio_tmp

    esa_rbn_map[lonidx, *] = rbn_ratio * esa_rc_map[lonidx, *]
    esa_gdf_map[lonidx, *] = gdf_ratio * esa_rc_map[lonidx, *]

    esa_rbn_stddev_map[lonidx, *] = sqrt(rbn_ratio) * esa_stddev_rc_map[lonidx, *]
    esa_gdf_stddev_map[lonidx, *] = sqrt(gdf_ratio) * esa_stddev_rc_map[lonidx, *]

    ;    esa_rbn_stddev_map[lonidx, *] = sqrt(esa_stddev_rc_map[lonidx, *]^2 + esa_stddev_rc_map[lonidx, *]^2*rbn_ratio^2)
    ;    esa_gdf_stddev_map[lonidx, *] = sqrt(esa_stddev_rc_map[lonidx, *]^2 + esa_stddev_rc_map[lonidx, *]^2*gdf_ratio^2)

    FIT_FUNC[LONIDX] = MNIDX
    ;    IF TOTAL(YY) LT (MEAN(ESA_RC_MAP, /NAN)-STDDEV(ESA_RC_MAP, /NAN)) THEN STOP;GOTO, JUMP
  ENDFOR ; LON

  RETURN, {RBN:esa_rbn_map, RBN_STDDEV:esa_rbn_stddev_map, GDF:esa_gdf_map, GDF_STDDEV:esa_gdf_stddev_map, LON_ARR:LON_ARR, LAT_RC:LAT_RC, FUNC:FIT_FUNC}

end