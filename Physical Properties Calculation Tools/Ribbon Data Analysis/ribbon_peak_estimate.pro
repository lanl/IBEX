; DISTANCE FROM RC ESTIMATION
FUNCTION RIBBON_PEAK_ESTIMATE, esa_rc_map1, esa_stddev_rc_map, RC, lon_arr, lat_rc, n_sample = n_sample
  ;  hp load
  COMMON HP, LON_HP, LAT_HP, HP_DIST, TR_HP
  ;  hp load
  XX = LINSPACE(Lat_RC[0], Lat_RC[-1], 10000)

  cnt = 0 ; success
  dp2 = 0 ; double peak
  out = 0 ; peak outside RC_lo_hi

  rbngdf = 0 ; ribbon gdf ratio lt 0.05
  miss = 0 ; missing data points

  RC_lo_hi = [75-40, 75+40]

  if ~keyword_set(n_sample) then n_sample = 1000
  esa_rc_map = rebin(esa_rc_map1, lon_arr.length, lat_rc.length, n_sample) + randomn(seed, lon_arr.length, lat_rc.length, n_sample)*rebin(esa_stddev_rc_map, lon_arr.length, lat_rc.length, n_sample)

  if n_sample eq 1 then esa_rc_map = esa_rc_map1

  ; ================================================= LON SPAN =================================================

  num_mom = replicate(!values.D_NAN, 4, LON_ARR.LENGTH, n_sample)
  num_mom_ERROR = replicate(!values.D_NAN, 4, LON_ARR.LENGTH)
  mom2_4 = replicate(!values.D_NAN, 4, LON_ARR.LENGTH, n_sample)
  mom2_4_ERROR = replicate(!values.D_NAN, 4, LON_ARR.LENGTH)

  flux = replicate(!values.D_NAN, 2, LON_ARR.LENGTH, n_sample)

  for map_idx = 0, n_sample-1 do begin
    for jj = 0, LON_ARR.LENGTH-1 do begin

      RO1 = 0 & RO2 = 0 & RO = 0

      yy = reform(esa_rc_map[jj, *, map_idx])
      yy[where(yy lt 0, /null)] = 0
      ;      yygdf = reform(esa_gdf_map[jj, *])

      if TOTAL(YY GT 0) LT 3 then begin
        continue
      endif
      if total(yy, /nan) eq 0 then begin
        continue
      endif

      ye = reform(esa_stddev_rc_map[jj, *])


      FL_LIM = 0.05
      yy_tmp = smooth(yy, 2, /edge_truncate, /NAN)
      dyy_tmp = yy_tmp[1:-1]-yy_tmp[0:-2]
      ddyy_tmp = sign(dyy_tmp[1:-1]*dyy_tmp[0:-2])
      DEF_IDX = where(ddyy_tmp lt 0, /null, c)
      IF C EQ 0 THEN begin
        CONTINUE
      ENDIF
      MX = MAX(YY[DEF_IDX+1], MXIDX)

      if DEF_IDX[mxidx] le 1 or DEF_IDX[mxidx] ge YY.length-2 then begin
        continue
      endif
      if total(~finite(yy[DEF_IDX[MXIDX]-1:DEF_IDX[MXIDX]+1])) gt 0 then begin
        continue
      endif


      IF C EQ 1 THEN IDX = [0:YY.LENGTH-1]
      IF C GT 1 THEN BEGIN
        LB = -1
        LBCNT = -1
        WHILE LB LT 0 DO BEGIN
          IF MXIDX+LBCNT LT 0 THEN LB = 0
          IF MXIDX+LBCNT GE 0 THEN BEGIN
            IF YY[DEF_IDX[MXIDX+LBCNT]+1] LT FL_LIM*MX THEN LB = DEF_IDX[MXIDX+LBCNT]
          ENDIF
          LBCNT -= 1
        ENDWHILE

        UB = YY.LENGTH
        UBCNT = 1
        WHILE UB GT YY.LENGTH-1 DO BEGIN
          IF MXIDX+UBCNT GT DEF_IDX.LENGTH-1 THEN UB = YY.LENGTH-1
          IF MXIDX+UBCNT LE DEF_IDX.LENGTH-1 THEN BEGIN
            IF YY[DEF_IDX[MXIDX+UBCNT]+1] LT FL_LIM*MX THEN UB = DEF_IDX[MXIDX+UBCNT]
          ENDIF
          UBCNT += 1
        ENDWHILE
        IDX = [LB:UB]
      ENDIF

      IDX = [0:YY.LENGTH-1]

      !null = MAX(yy, MXIDX1)
      if lat_rc[MXIDX1] lt RC_lo_hi[0] or lat_rc[MXIDX1] gt RC_lo_hi[1] then begin
        out = out+1
        continue
      endif

      !null = max(yy, mxx)
      ;      if yy[mxx]/yygdf[mxx] lt 0.05 then begin
      ;        rbngdf += 1
      ;        continue
      ;      endif

      if total(~finite(yy[idx])) gt lon_arr.length/10 then begin
        miss += 1
        continue
      endif

      latidx = where(Lat_rc ge RC_lo_hi[0] and Lat_rc le RC_lo_hi[1])
      idxidx = where(finite(yy[latidx]))

      x_tmp = Lat_RC[latidx[idxidx]]
      f1 = yy[latidx[idxidx]]
      m1 = total(f1*x_tmp) / total(f1) ; MEAN
      IF m1 LT RC_lo_hi[0] OR m1 GT RC_lo_hi[1] THEN m1 = !VALUES.D_NAN
      m2 = sqrt(total(f1*(x_tmp-m1)^2) / total(f1)) ; STDDEV
      m3 = total(f1*((x_tmp-m1)/m2)^3) / total(f1) ; SKEWNESS
      m4 = total(f1*((x_tmp-m1)/m2)^4) / total(f1) - 3 ; KURTOSIS
      num_mom[*, jj, map_idx] = [m1, m2, m3, m4]


      ; FWHM
      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.5, /nan)
      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.5, /nan)
      FWHM = LAT_UH-LAT_LH
      ; FWHM

      ; R8020
      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.8, /nan)
      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.8, /nan)
      W1 = LAT_UH-LAT_LH
      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.2, /nan)
      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.2, /nan)
      W2 = LAT_UH-LAT_LH
      ; R8020






      ; R9010
      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.8, /nan)
      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.8, /nan)
      W1 = LAT_UH-LAT_LH
      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.2, /nan)
      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.2, /nan)
      W2 = LAT_UH-LAT_LH

      ;            R9010_RES[JJ] = W2/W1
      ; R9010

      ;      ; R9010
      ;      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.8)
      ;      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.8)
      ;      W1 = LAT_UH-LAT_LH
      ;      LAT_LH = INTERPOL(LAT_RC[IDX[0]:DEF_IDX[MXIDX]+1], YY[IDX[0]:DEF_IDX[MXIDX]+1], YY[DEF_IDX[MXIDX]+1]*0.2)
      ;      LAT_UH = INTERPOL(LAT_RC[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1:IDX[-1]], YY[DEF_IDX[MXIDX]+1]*0.2)
      ;      W2 = LAT_UH-LAT_LH
      ;


      ; MEAN-MODE
      IF LAT_RC.LENGTH EQ 30 THEN FIT_IDX = 2
      IF LAT_RC.LENGTH EQ 90 THEN FIT_IDX = 2
      IDX_TMP = [DEF_IDX[MXIDX]-FIT_IDX+1:DEF_IDX[MXIDX]+FIT_IDX+1]

      ;    COEFF = POLY_FIT(LAT_RC[IDX_TMP], YY[IDX_TMP], 2, /DOUBLE)
      COEFF = SVDFIT(LAT_RC[IDX_TMP], YY[IDX_TMP], 3, /DOUBLE, status = status, YFIT = YFIT)
      if status ne 0 then continue
      PEAK = -COEFF[1]/COEFF[2]/2D
      IF PEAK LT RC_lo_hi[0] OR PEAK GT RC_lo_hi[1] THEN PEAK = !VALUES.D_NAN
      ; MEAN-MODE


      ; moors' kurtosis
      yy_ttmp = YY[IDX]
      lat_ttmp = lat_rc[idx]
      yyc = total(yy_ttmp, /cumulative, /nan)
      mx = max(yyc, /nan)

      q0875 = interpol(lat_ttmp, yyc, 0.875*mx)
      q075 = interpol(lat_ttmp, yyc, 0.75*mx)
      q0625 = interpol(lat_ttmp, yyc, 0.625*mx)
      q05 = interpol(lat_ttmp, yyc, 0.5*mx)
      q0375 = interpol(lat_ttmp, yyc, 0.375*mx)
      q025 = interpol(lat_ttmp, yyc, 0.25*mx)
      q0125 = interpol(lat_ttmp, yyc, 0.125*mx)

      kurt_moors = (q0875-q0625 + q0375-q0125)/(q075-q025) - 1.233d
      if abs(kurt_moors) gt 10 then kurt_moors = !values.d_nan
      ; moors' kurtosis

      Skew_Bowley = (q075-2*q05+q025)/(q075-q025)
      if abs(Skew_Bowley) gt 10 then Skew_Bowley = !values.d_nan


      ;      mom2_4[*, jj, map_idx] = [PEAK, FWHM, (M1 - PEAK)/M2, (W2/W1)]
      mom2_4[*, jj, map_idx] = [PEAK, FWHM, Skew_Bowley, kurt_moors]

      ; peak and average flux
      flux[0, jj, map_idx] = interpol(YY, LAT_RC, peak)
      flux[1, jj, map_idx] = mean(YY[IDX_TMP], /nan)
      ; peak and average flux

      cnt += 1
    endfor ;jj lon
  endfor ; map draws

  ; Average, Stddev
  if n_sample gt 1 then begin
    NUM_MOM_ERROR = stddev(num_mom, dim = 3, /nan)
    num_mom_tmp = mean(num_mom, dim = 3, /nan)

    MOM2_4_ERROR = stddev(MOM2_4, dim = 3, /nan)
    MOM2_4_tmp = mean(MOM2_4, dim = 3, /nan)

    flux_ERROR = stddev(flux, dim = 3, /nan)
    flux_tmp = mean(flux, dim = 3, /nan)
  endif

  if n_sample eq 1 then begin
    NUM_MOM_ERROR = fltarr(4, 180)
    num_mom_tmp = num_mom

    MOM2_4_ERROR = fltarr(4, 180)
    MOM2_4_tmp = MOM2_4

    flux_ERROR = fltarr(2, 180)
    flux_tmp = flux
  endif
  ; Average, Stddev

  if n_sample gt 1 then RETURN, $
    {num_mom:num_mom_tmp, NUM_MOM_ERROR:NUM_MOM_ERROR, MOM2_4:MOM2_4_tmp, MOM2_4_error:MOM2_4_ERROR, flux:flux_tmp, flux_error:flux_error, $
    peak_rand_res:reform(MOM2_4[0, *, *])}

  if n_sample eq 1 then RETURN, $
    {num_mom:num_mom_tmp, NUM_MOM_ERROR:NUM_MOM_ERROR, MOM2_4:MOM2_4_tmp, MOM2_4_error:MOM2_4_ERROR, flux:flux_tmp, flux_error:flux_error, $
    peak_rand_res:reform(MOM2_4[0, *])}
  ;    peak_rand_res:reform(num_mom[0, *, *])}


end