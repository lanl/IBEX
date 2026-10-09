pro test_SE_COV
  n_sample = 100000

  sig_draws = covmat_randsample(2013, 5, 0, n_sample = N_SAMPLE) ; map draws in EC


  RESTORE, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\SAV\Theseus-L_RBN_SEP_2013_Ram.sav'
  esa_rc_map = randomn(seed, lon_arr.length, lat_arr.length, n_sample) $
    *rebin(ESA5_RBN_STDDEV_MAP, lon_arr.length, lat_arr.length, n_sample)

  sp = spec_plot(mean(sig_draws, dim = 3, /nan), xtitle = 'Lon', ytitle = 'Lat', font_size = 13, data_min = -0.05, data_max = 0.05, rgb_table = 70, title = 'Mean, COV')
  cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]')
  sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230705\MV1000_AVG_'+strcompress(n_sample, /rem)+'.png'
  sp.close

  sp = spec_plot(mean(esa_rc_map, dim = 3, /nan), xtitle = 'Lon', ytitle = 'Lat', font_size = 13, data_min = -0.05, data_max = 0.05, rgb_table = 70, title = 'Mean, SE')
  cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]')
  sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230705\SE_AVG_'+strcompress(n_sample, /rem)+'.png'
  sp.close

  std_avg = mean(esa_rc_map, dim = 3, /nan)
  sp = spec_plot(smooth(std_avg, [4, 2], /edge_truncate), xtitle = 'Lon', ytitle = 'Lat', font_size = 13, data_min = -0.05, data_max = 0.05, rgb_table = 70, title = 'Mean, SE')
  cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]')
  sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230705\SE_AVG_smooth_'+strcompress(n_sample, /rem)+'.png'
  sp.close



  sp = spec_plot(STDDEV(sig_draws, dim = 3, /nan), xtitle = 'Lon', ytitle = 'Lat', font_size = 13, data_min = 0, data_max = 1, rgb_table = 13, title = 'STDDEV, COV')
  cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]')
  sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230705\MV1000_stddev_'+strcompress(n_sample, /rem)+'.png'
  sp.close

  sp = spec_plot(STDDEV(esa_rc_map, dim = 3, /nan), xtitle = 'Lon', ytitle = 'Lat', font_size = 13, data_min = 0, data_max = 1, rgb_table = 13, title = 'STDDEV, SE')
  cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]')
  sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230705\SE_stddev_'+strcompress(n_sample, /rem)+'.png'
  sp.close

  std_std = STDDEV(esa_rc_map, dim = 3, /nan)
  sp = spec_plot(smooth(std_std, [4, 2], /edge_truncate), xtitle = 'Lon', ytitle = 'Lat', font_size = 13, data_min = 0, data_max = 1, rgb_table = 13, title = 'STDDEV, SE')
  cb = color_bar(sp, ytitle = 'Flux [#/cm2/s/sr/keV]')
  sp.save, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230705\SE_stddev_smooth_'+strcompress(n_sample, /rem)+'.png'
  sp.close

  stop
end