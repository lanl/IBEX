PRO Ribbon_Separation_Peak_Center_MULTI_RUN

  ;  ver = '230511' ; 230511 --> 1000 samples, no longitude cut, no flux weighted, ellipse, 10 iter with threshold, New RS and SP, R80_20 is corrected to be linearly scaled--> normalized by stddev
  ; 230512 --> 1000 samples, no longitude cut, no flux weighted, ellipse, 10 iter with threshold, New RS and SP, Bowley skewness and Moors kurtosis

  ; 230523a --> 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS and SP, Bowley skewness and Moors kurtosis, Median
  ; 230523b --> 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS and SP, Median
  ; 230530 --> 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS and SP, Bowley skewness and Moors kurtosis, RC fit with mean
  ; 230531 --> 1000 samples, no longitude cut, no fl  ux weighted, circle, 10 iter with threshold, New RS and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230531 --> 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230609 --> 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity

  ; 230629 --> THESEUS V2, 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230705 --> Weighted average of moments, Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230725 & 230725a --> New Separation with removed wiggles, Weighted average of moments, Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, no flux weighted, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230725b -->mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments, Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230801 --> NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments, Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230803 --> separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments, Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230809 --> Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments, Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 230809a --> No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 240308 --> Separation uncertainty correction, No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; 240313_svGP --> svGP, Separation uncertainty correction, No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; svGP_v20240413 --> new svGP, Separation uncertainty correction, No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; svGP_v20240612 --> representing metrics average --> parent map, new svGP, Separation uncertainty correction, No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; svGP_v20240730 --> smooth peak as isoc, representing metrics average --> parent map, new svGP, Separation uncertainty correction, No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity
  ; svGP_v20250323_patialfit --> partial fit WO s-t, new svGP, Separation uncertainty correction, No weighted average, Nose corrected to [255.6, 5.14], Covariance correction, separation version 080223, NEW MEAN STDDEV CALC METHOD FOR ROTATION ANGLE, mean distance for ribbon fit, flux weighted RC fit, New Separation with removed wiggles, Weighted average of moments (lifted 230809), Covariance Matrix and Multivariate Sampling, Theseus only, THESEUS V2, 1000 samples, no longitude cut, circle, 10 iter with threshold, New RS(May 17) and SP, Bowley skewness and Moors kurtosis, Compression ratio --> eccentricity, partial fit

  for runs = 1, 1 do begin
    if runs eq 0 then ver = 'GAM_v20240413'
    if runs eq 1 then ver = 'svGP_v20240413'; 'svGP_v20250323_patialfit' ;'svGP_v20240413'

    cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
    cd, cpath
    ;    if runs eq 2 then begin
    ;        ENA_MAP_PLOT_FROM_CSV, ver
    ;stop

    ;    print, '111111 Map Separation & Properties Calculation 111111'
    ;    bris = build_bridges(14)
    ;    tic
    ;    FOR SIDX = 1, 1 DO BEGIN
    ;      if SIDX eq 1 then SS = 'L'
    ;      if SIDX eq 0 then SS = 'D'
    ;      for midx = 1, 1 do begin
    ;        if midx eq 1 then mm = 'Theseus'
    ;        if midx eq 0 then mm = 'ISOC'
    ;        if mm eq 'Theseus' then ymax = 2022
    ;        if mm eq 'ISOC' then if ss eq 'L' then ymax = 2022 else ymax = 2019
    ;        for j = 2009, ymax do begin
    ;          ;        if mm eq 'ISOC' and SS eq 'D' then continue
    ;          bri = get_idle_bridge(bris)
    ;          bri.setvar, 'YIDX', J
    ;          bri.setvar, 'MAPS', mm
    ;          bri.setvar, 'SEPS', SS
    ;          bri.setvar, 'ver', ver
    ;          bri.setvar, 'cpath', cpath
    ;          bri.setvar, 'N_SAMPLE', 1000
    ;          bri.execute, 'cd, cpath'
    ;          bri.execute, 'Ribbon_Separation_Peak_Center_Cov_MULTI, YIDX, MAPS, SEPS, ver, cpath, N_SAMPLE', /nowait
    ;          print, midx, j
    ;          wait, 20
    ;        endfor
    ;        print, systime()
    ;      endfor
    ;    ENDFOR
    ;    barrier_bridges, bris
    ;    burn_bridges, bris
    ;    toc
    ;    print, '111111 Map Separation & Properties Calculation 111111'

    ;  endif
    ;  --------------------------------------------------------------------------------------------------------------------

    ;    print, '222222 Map Plot 222222'
    ;    tic
    ;    FOR SIDX = 1, 1 DO BEGIN
    ;      if SIDX eq 1 then SEPNAME = 'L'
    ;      if SIDX eq 0 then SEPNAME = 'D'
    ;      for midx = 1, 1 do begin
    ;        if midx eq 1 then MAPNAME = 'Theseus'
    ;        if midx eq 0 then MAPNAME = 'ISOC'
    ;        if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
    ;        ;      IBEX_DATA_RAM_ANTIRAM_FLX_PLOT_pro, MAPNAME, SEPNAME, VER, cpath
    ;        ;        IBEX_DATA_RAM_ANTIRAM_flx_PLOT_pro_mollweide, MAPNAME, SEPNAME, VER, cpath
    ;        Example_RCframe_skymap, MAPNAME, SEPNAME, VER, cpath ; EXAMPLE SKYMAP 2012 ram
    ;
    ;      endfor ; map
    ;    endfor ; sep
    ;    toc

    ;    Ribbon_Slice_Profile_Draw, ver, cpath
    ;    print, '222222 Map Plot 222222'
    ;    stop
    ;    stop


    ;    print, '333333 RC Propeties Draw 333333'
    ;    tic
    ;    FOR SIDX = 1, 1 DO BEGIN
    ;      if SIDX eq 1 then SEPNAME = 'L'
    ;      if SIDX eq 0 then SEPNAME = 'D'
    ;      for midx = 1, 1 do begin
    ;        if midx eq 1 then MAPNAME = 'Theseus'
    ;        if midx eq 0 then MAPNAME = 'ISOC'
    ;        if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
    ;        rc_polar_plot_skewness_rand, MAPNAME, SEPNAME, VER, cpath
    ;      ENDFOR
    ;    ENDFOR;
    ;    toc
    ;
    ;    print, '333333 RC Propeties Draw 333333'
    ;    stop

    print, '444444 RC Summary Plots Draw 444444'
    tic
    FOR SIDX = 1, 1 DO BEGIN
      if SIDX eq 1 then SEPNAME = 'L'
      if SIDX eq 0 then SEPNAME = 'D'
      for midx = 1, 1 do begin
        if midx eq 1 then MAPNAME = 'Theseus'
        if midx eq 0 then MAPNAME = 'ISOC'
        if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
        RC_SUMMARY_PLOT_rand, MAPNAME, SEPNAME, VER, cpath
      ENDFOR
    ENDFOR;
    toc
    print, '444444 RC Summary Plots Draw 444444'
    stop
    ;    stop
    ;  ;
    ;  print, '555555 RC Summary Plots Draw ESA2-5 555555'
    ;  tic
    ;  FOR SIDX = 1, 1 DO BEGIN
    ;    if SIDX eq 1 then SEPNAME = 'L'
    ;    if SIDX eq 0 then SEPNAME = 'D'
    ;    for midx = 1, 1 do begin
    ;      if midx eq 1 then MAPNAME = 'Theseus'
    ;      if midx eq 0 then MAPNAME = 'ISOC'
    ;      if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
    ;      RC_SUMMARY_PLOT_rand_esa25, MAPNAME, SEPNAME, VER, cpath
    ;    ENDFOR
    ;  ENDFOR;
    ;  toc
    ;  print, '555555 RC Summary Plots Draw ESA2-5 555555'

    print, '666666 RC Summary Average Plots Draw 666666'
    tic
    FOR SIDX = 1, 1 DO BEGIN
      if SIDX eq 1 then SEPNAME = 'L'
      if SIDX eq 0 then SEPNAME = 'D'
      for midx = 1, 1 do begin
        if midx eq 1 then MAPNAME = 'Theseus'
        if midx eq 0 then MAPNAME = 'ISOC'
        ;      if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
        RC_SUMMARY_average_plot, MAPNAME, SEPNAME, VER, cpath

      endfor ; map
    endfor ; sep
    toc
    print, '666666 RC Summary Average Plots Draw 666666'
    ;
    ;  print, '777777 RC Properties Sector/Time Variation  777777'
    ;  tic
    ;  ; only for Theseus-L
    ;  ;  ENA_response_Comp_IPS, ver, cpath
    ;  ENA_flux_response_Comp_IPS_inout_sep, ver, cpath
    ;  toc
    ;  print, '777777 RC Properties Sector/Time Variation  777777'
    ;  ;


    ;  print, '888888 RC Temporal Variation Plots Draw 888888'
    ;  tic
    ;  FOR SIDX = 1, 1 DO BEGIN
    ;    if SIDX eq 1 then SEPNAME = 'L'
    ;    if SIDX eq 0 then SEPNAME = 'D'
    ;    for midx = 1, 1 do begin
    ;      if midx eq 1 then MAPNAME = 'Theseus'
    ;      if midx eq 0 then MAPNAME = 'ISOC'
    ;      if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
    ;      ribbon_temporal_variation, ver, cpath
    ;    ENDFOR
    ;  ENDFOR;
    ;  toc
    ;  print, '888888 RC Temporal Variation Plots Draw 888888'


    print, '999999 RC Temporal Variation Plots Draw 999999'
    tic
    FOR SIDX = 1, 1 DO BEGIN
      if SIDX eq 1 then SEPNAME = 'L'
      if SIDX eq 0 then SEPNAME = 'D'
      for midx = 1, 1 do begin
        if midx eq 1 then MAPNAME = 'Theseus'
        if midx eq 0 then MAPNAME = 'ISOC'
        if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
        ribbon_temporal_variation_total, ver, cpath
      ENDFOR
    ENDFOR;
    toc
    print, '999999 RC Temporal Variation Plots Draw 999999'


    ;

    print, '101010 Moments Histogram 101010'
    tic
    FOR SIDX = 1, 1 DO BEGIN
      if SIDX eq 1 then SEPNAME = 'L'
      if SIDX eq 0 then SEPNAME = 'D'
      for midx = 1, 1 do begin
        if midx eq 1 then MAPNAME = 'Theseus'
        if midx eq 0 then MAPNAME = 'ISOC'
        if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
        RC_SUMMARY_histogram, MAPNAME, SEPNAME, VER, cpath
      ENDFOR
    ENDFOR;
    toc
    print, '101010 Moments Histogram 101010'

    stop
    ;    ;
    ;    print, '111111 Profile Line Plot 111111'
    ;    tic
    ;    FOR SIDX = 1, 1 DO BEGIN
    ;      if SIDX eq 1 then SEPNAME = 'L'
    ;      if SIDX eq 0 then SEPNAME = 'D'
    ;      for midx = 1, 1 do begin
    ;        if midx eq 1 then MAPNAME = 'Theseus'
    ;        if midx eq 0 then MAPNAME = 'ISOC'
    ;        if MAPNAME eq 'ISOC' and SEPNAME eq 'D' then continue
    ;        IBEX_DATA_RAM_ANTIRAM_flx_LinePlot, MAPNAME, SEPNAME, VER, cpath
    ;      ENDFOR
    ;    ENDFOR;
    ;    toc
    ;    print, '111111 Profile Line Plot 111111'
  endfor ; runs


  ; --------------------------------------------------------------------------------------------------------------------
END