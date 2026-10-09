; quantile --> 0 to 1, default = [0.5-0.341, 0.5, 0.5+0.341] <-- gauusian 1sigma
function quantile_pdf, val, quantile = quantile

  val_tmp = val
  val_tmp = val_tmp[sort(val_tmp)]
  idx = where(finite(val_tmp), tmp)
  if tmp lt 4 then begin
    if ~keyword_set(quantile) then begin
      return, replicate(!values.f_nan, 3)
    endif else begin
      return, replicate(!values.f_nan, quantile.length)
    endelse
  endif
  val_tmp = val_tmp[idx]

  c_dist = replicate(1d, val_tmp.length)
  c_dist = total(c_dist, /cumulative)
  c_dist = c_dist/max(c_dist)

  if ~keyword_set(quantile) then begin
    res = [interpol(val_tmp, c_dist, 0.5-0.341), interpol(val_tmp, c_dist, 0.5), interpol(val_tmp, c_dist, 0.5+0.341)]
  endif else begin
    res = []
    for ii = 0, quantile.length-1 do $
      res = [res, interpol(val_tmp, c_dist, quantile[ii])]
  endelse

  return, res
end