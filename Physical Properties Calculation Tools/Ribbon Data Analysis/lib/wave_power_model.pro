; IsHp30 --> Power model with Hp30. Default is AL*
FUNCTION wave_power_model, GEOIND, Lval, MLTval, NOS = NOS, SIMPLE = SIMPLE, IsHp30 = IsHp30

  ;  GEOIND = -100d
  ;  Lval = 5.5d
  ;  MLTval = 15d

  if ~keyword_set(NOS) then NOS = 1000

  ;  wave model Bw prep
  AL_LEVEL = [1:3]
  BAND_STR = ['He', 'Hy']
  als_range = [0, -250, -650, -10000]
  if keyword_set(IsHp30) then als_range = [0, 1.6, 3.3, 10]

  ; probabilistic wave model
  bw_prob_model = make_array(5, 8, 1000, AL_LEVEL.length, BAND_STR.length, value = !values.d_nan); L X MLT X POWER BIN X AL X BAND

  FOR AIDX = 0, AL_LEVEL.LENGTH-1 DO BEGIN
    FOR BIDX = 0, BAND_STR.LENGTH-1 DO BEGIN
      file = file_search('D:\Wave\Data\Zhang_EMIC_wave_model\Present_Model_240223a\'+BAND_STR[BIDX]+'Band_AL'+string(AL_LEVEL[aidx]-1, format = '(I1)')+'.sav')
      if keyword_set(IsHp30) then file = file_search('D:\Wave\Data\Present_Model_241205\'+BAND_STR[BIDX]+'Band_Hp30'+string(AIDX, format = '(I1)')+'.sav')
      IF FILE EQ '' THEN STOP
      restore, file

      bw_prob_model[*, *, *, AIDX, BIDX] = bw_pdf_mat
      L_prob = l_loc_hist
      MLT_prob = mlt_loc_hist
      xx_prob = xx
    ENDFOR ; BAND
  ENDFOR ; AL
  dL_prob = L_prob[1]-L_prob[0]
  dMLT_prob = MLT_prob[1]-MLT_prob[0]


  bw_model = make_array(GEOIND.LENGTH, BAND_STR.LENGTH, NOS, value = !values.d_nan) ; time x band x SAMPLE
  bw_model_MED = make_array(GEOIND.LENGTH, BAND_STR.LENGTH, value = !values.d_nan) ; time x band x SAMPLE
  bw_model_025 = make_array(GEOIND.LENGTH, BAND_STR.LENGTH, value = !values.d_nan) ; time x band x SAMPLE
  bw_model_050 = make_array(GEOIND.LENGTH, BAND_STR.LENGTH, value = !values.d_nan) ; time x band x SAMPLE
  bw_model_075 = make_array(GEOIND.LENGTH, BAND_STR.LENGTH, value = !values.d_nan) ; time x band x SAMPLE

  FOR TT = 0, GEOIND.LENGTH-1 DO BEGIN
    LL = WHERE(Lval[TT] GE L_prob AND Lval[TT] LT L_prob+dL_prob, TMPL)
    MM = WHERE(MLTval[TT] GE MLT_prob AND MLTval[TT] LT MLT_prob+dMLT_prob, TMPMLT)
    AA = WHERE(GEOIND[TT] LE als_range[0:-2] AND GEOIND[TT] GT als_range[1:-1], TMPAA)
    if keyword_set(IsHp30) then AA = WHERE(GEOIND[TT] ge als_range[0:-2] AND GEOIND[TT] lt als_range[1:-1], TMPAA)

    if TMPL+TMPMLT+TMPAA ne 3 then continue
    bw_prob_tmp = REFORM(bw_prob_model[LL, MM, *, AA, *]) ; POWER BIN & band
    bw_cumul = total(bw_prob_tmp, 1, /cumul)*(xx_prob[1]-xx_prob[0])

    bw_model[TT, *, *] = sqrt(TRANSPOSE([[10d^interpol(xx_prob, bw_cumul[*, 0], randomu(seed, NOS))], [10d^interpol(xx_prob, bw_cumul[*, 1], randomu(seed, NOS))]])) ; HE, H
    ;    bw_prob_TIMESERIES[TT, *] = [mean(10d^interpol(xx_prob, bw_cumul[*, 0], randomu(seed, 10)), /nan), mean(10d^interpol(xx_prob, bw_cumul[*, 1], randomu(seed, 10)), /nan)]
    bw_model_MED[TT, *] = MEDIAN(REFORM(bw_model[TT, *, *]), DIM = 2)
    bw_model_025[TT, *] = sqrt(TRANSPOSE([[10d^interpol(xx_prob, bw_cumul[*, 0], 0.159)], [10d^interpol(xx_prob, bw_cumul[*, 1], 0.159)]])) ; HE, H
    bw_model_050[TT, *] = sqrt(TRANSPOSE([[10d^interpol(xx_prob, bw_cumul[*, 0], 0.5)], [10d^interpol(xx_prob, bw_cumul[*, 1], 0.5)]])) ; HE, H
    bw_model_075[TT, *] = sqrt(TRANSPOSE([[10d^interpol(xx_prob, bw_cumul[*, 0], 0.841)], [10d^interpol(xx_prob, bw_cumul[*, 1], 0.841)]])) ; HE, H
  ENDFOR

  IF keyword_set(SIMPLE) THEN RETURN, {bw_model:bw_model, ATT:['GEOIND', 'BAND (He, H)', '# OF SAMPLE']}
  IF ~keyword_set(SIMPLE) THEN RETURN, {bw_model:bw_model, bw_model_LOW:bw_model_025, bw_model_MID:bw_model_050, bw_model_HIGH:bw_model_075, ATT:['GEOIND', 'BAND (He, H)', 'MEDIAN', 'LOW [0.159]', 'MID [0.50]', 'HIGH [0.841]']}

end