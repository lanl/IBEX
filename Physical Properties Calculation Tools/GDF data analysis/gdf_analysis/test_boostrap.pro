pro test_boostrap

  val = findgen(180, 90) ; flux

  sig = sqrt(val) ; uncertainty (sigma)

  nbootstrap = 2000 ; number of bootstrap samples

  map_bootstrap = fltarr(180, 90, nbootstrap)
  for lonidx = 0, 180-1 do begin
    for latidx = 0, 90-1 do begin
      x_samples = randomn(seed, nbootstrap) ; normal sampling with, mean=0 and sig=1
      map_bootstrap[lonidx, latidx, *] = x_samples*sig[lonidx, latidx] + val[lonidx, latidx]
    endfor
  endfor
  
  
  print, stddev(map_bootstrap[100, 50, *]), sig[100, 50] ; testing results by comparing sig
  print, mean(map_bootstrap[100, 50, *]), val[100, 50] ; testing results by comparing sig

  stop
end