function covmat_randsample, year, esa, ram, ver, n_sample = n_sample

  if keyword_set(n_sample) then nmap = n_sample else nmap = 1000

  if ram eq 0 then str = 'ram'
  if ram eq 1 then str = 'antiram'
  rstr = 'ribbon'

  ; load COVariance 1
  res = read_csv('D:\Data\IBEX_skymaps\Theseus_skymaps_'+ver+'\separated_maps\'+rstr+'_cg\'+str+'\covariances\spatial\'+rstr+'_cg_'+str+'_'+strcompress(year, /rem)+'AB_'+strcompress(esa, /rem)+'_sepcov1')
  mat = []
  for ii = 1, 50 do $ ; change iter # according to the # of column
    !null = execute('mat = [[mat], [res.field'+string(ii, format = '(I2.2)')+']]')

  full_mat1 = mat#transpose(mat)

  ; load COV 2
  res = read_csv('D:\Data\IBEX_skymaps\Theseus_skymaps_'+ver+'\separated_maps\'+rstr+'_cg\'+str+'\covariances\spatial\'+rstr+'_cg_'+str+'_'+strcompress(year, /rem)+'AB_'+strcompress(esa, /rem)+'_inputcov')
  mat = []
  for ii = 1, 303 do $
    !null = execute('mat = [[mat], [res.field'+string(ii, format = '(I3.3)')+']]')

  full_mat2 = mat#transpose(mat)


  ; 3rd COV is added, July 25, 2023
  res = read_csv('D:\Data\IBEX_skymaps\Theseus_skymaps_'+ver+'\separated_maps\'+rstr+'_cg\'+str+'\covariances\spatial\'+rstr+'_cg_'+str+'_'+strcompress(year, /rem)+'AB_'+strcompress(esa, /rem)+'_sepcov2')
  mat = []
  if n_elements(res.field01) gt 16200 then begin
    for ii = 1, 50 do begin; change iter # according to the # of column
      !null = execute('res.field'+string(ii, format = '(I2.2)')+'[where(res.field'+string(ii, format = '(I2.2)')+' eq "NA")] = "0"')
      !null = execute('field'+string(ii, format = '(I2.2)')+' = double(res.field'+string(ii, format = '(I2.2)')+'[1:-1])')
    endfor
    mat = []
    for ii = 1, 50 do $; change iter # according to the # of column
      !null = execute('mat = [[mat], [field'+string(ii, format = '(I2.2)')+']]')
  endif else begin
    mat = []
    for ii = 1, 50 do $; change iter # according to the # of column
      !null = execute('mat = [[mat], [double(res.field'+string(ii, format = '(I2.2)')+')]]')
  endelse

  full_mat3 = mat#transpose(mat)
  ; 3rd COV is added, July 25, 2023

  full_mat = full_mat1+full_mat2 + full_mat3 ; combining all COVs

  undefine, full_mat1, full_mat2, full_mat3, mat ; remove COVs to save memory

  mr = mrandomn(seed, full_mat, nmap, status = status) ; multivariate normal sampling

  n = 0
  while status gt 0 do begin
    
    aa = abs(full_mat[findgen(180*90), findgen(180*90)])
    aa = min(aa[where(aa ne 0)])
    print, 'Adding a small positive val to diag term until COV becomes positive definite'+string(n)
    print, 'Value added ='+string(0.01d*aa)
    full_mat[findgen(180*90), findgen(180*90)] = full_mat[findgen(180*90), findgen(180*90)]+0.01d*aa
    mr = mrandomn(seed, full_mat, nmap, status = status)
    n = n+1
  endwhile
  ;  if status gt 0 then begin
  ;    print, 'Adding positive vals to diag term, #1'
  ;    aa = abs(full_mat[findgen(180*90), findgen(180*90)])
  ;    aa = min(aa[where(aa ne 0)])
  ;    full_mat[findgen(180*90), findgen(180*90)] = full_mat[findgen(180*90), findgen(180*90)]+0.01d*aa
  ;    mr = mrandomn(seed, full_mat, nmap, status = status)
  ;  endif
  ;
  ;  if status gt 0 then begin
  ;    print, 'Adding positive vals to diag term, #2'
  ;    full_mat[findgen(180*90), findgen(180*90)] = full_mat[findgen(180*90), findgen(180*90)]+0.01d*aa
  ;    mr = mrandomn(seed, full_mat, nmap, status = status)
  ;  endif

  map_draw = make_array(180, 90, nmap, value = !values.d_nan)
  for nm = 0, nmap-1 do begin
    kk = 0

    for lonidx = 0, 179 do begin
      for latidx = 0, 89 do begin
        map_draw[lonidx, latidx, nm] = mr[nm, kk]
        kk = kk+1
      endfor
    endfor

  endfor ; # of maps

  return, map_draw

end