PRO RIBBON_FIT_SUMMARY

  fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\svGP_v20240413\Gauss_Fit\'
  file_mkdir, fpath
  RESTORE, 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Data\Theseus-L\TheseusRibbonSep_RC_Peak_Moment_svGP_v20240413\Gauss_Fit\Fit_Result.sav'

  tic
  for yidx = 2009, 2022 do begin
    for esa = 2, 6 do begin
      par_tmp = reform(PAR_SAVE[*, yidx-2009, esa-2, *])
      no_good_tmp = reform(no_good_fit_res[*, yidx-2009, esa-2])
      n_pop_tmp = reform(N_POP_RES[*, yidx-2009, esa-2])

      nidx = where(no_good_tmp eq 1,tmp)
      if tmp eq 0 then continue
      par_tmp[nidx, *] = !values.f_nan
      n_pop_tmp[nidx] = !values.f_nan

      PAR_SAVE[*, yidx-2009, esa-2, *] = par_tmp
      N_POP_RES[*, yidx-2009, esa-2] = n_pop_tmp
    endfor
  endfor
  toc

  year = [2009:2022]

  ;  for esa = 2, 6 do begin
  ;    sp = spec_plot(no_good_fit_res[*, *, esa-2], lon_arr, year, xtitle = 'Lon_RC', ytitle = 'Year', title = 'Fit Flag, ESA'+strcompress(esa, /rem), font_size = 15)
  ;    sp.save, fpath+'Fit_Flag_ESA'+strcompress(esa, /rem)+'.png'
  ;    sp.close
  ;
  ;    sp = spec_plot(N_POP_RES[*, *, esa-2], lon_arr, year, xtitle = 'Lon_RC', ytitle = 'Year', title = '# of populations 1, ESA'+strcompress(esa, /rem), font_size = 15)
  ;    sp.save, fpath+'NoPopultions_ESA'+strcompress(esa, /rem)+'.png'
  ;    sp.close
  ;
  ;    sp = spec_plot(PAR_SAVE[*, *, esa-2, 0], lon_arr, year, xtitle = 'Lon_RC', ytitle = 'Year', title = '# of populations 2, ESA'+strcompress(esa, /rem), font_size = 15)
  ;    sp.save, fpath+'NoPopultions2_ESA'+strcompress(esa, /rem)+'.png'
  ;    sp.close
  ;
  ;    print, 'ESA'+strcompress(esa, /rem)
  ;    print, '1 pop', total(N_POP_RES[*, *, esa-2] eq 1)
  ;    print, '2 pop', total(N_POP_RES[*, *, esa-2] eq 1)
  ;    print, '3 pop', total(N_POP_RES[*, *, esa-2] eq 1)
  ;  endfor


  for esa = 2, 6 do begin
    sp = spec_plot(no_good_fit_res[*, *, esa-2], lon_arr, year, xtitle = 'Lon_RC', ytitle = 'Year', title = 'Fit Flag, ESA'+strcompress(esa, /rem), font_size = 15)
    sp.save, fpath+'Fit_Flag_ESA'+strcompress(esa, /rem)+'.png'
    sp.close

    sp = spec_plot(N_POP_RES[*, *, esa-2], lon_arr, year, xtitle = 'Lon_RC', ytitle = 'Year', title = '# of populations 1, ESA'+strcompress(esa, /rem), font_size = 15)
    sp.save, fpath+'NoPopultions_ESA'+strcompress(esa, /rem)+'.png'
    sp.close

    sp = spec_plot(PAR_SAVE[*, *, esa-2, 0], lon_arr, year, xtitle = 'Lon_RC', ytitle = 'Year', title = '# of populations 2, ESA'+strcompress(esa, /rem), font_size = 15)
    sp.save, fpath+'NoPopultions2_ESA'+strcompress(esa, /rem)+'.png'
    sp.close

    print, 'ESA'+strcompress(esa, /rem)
    print, '1 pop', total(N_POP_RES[*, *, esa-2] eq 1), n_elements(N_POP_RES[*, *, esa-2])
    print, '2 pop', total(N_POP_RES[*, *, esa-2] eq 2), n_elements(N_POP_RES[*, *, esa-2])
    print, '3 pop', total(N_POP_RES[*, *, esa-2] eq 3), n_elements(N_POP_RES[*, *, esa-2])
  endfor


  stop
END