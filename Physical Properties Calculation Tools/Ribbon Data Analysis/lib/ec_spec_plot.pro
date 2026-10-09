;Function ec_spec_plot, img, lon_Arr, lat_arr, win = win, ext = ext
;  Load_IBEX_color_table
;  tvlct,red,green,blue,/get
;  co = [[red], [green], [blue]]
;
;  nose = [256, 5]
;
;  lon_tmp = lon_arr
;  lat_tmp = lat_arr
;
;  mn = min(lon_tmp-76, /abs, mnidx)
;  if mn lt 0 then begin
;    idx1 = [mnidx+1:lon_tmp.length-1]
;    idx2 = [0:mnidx]
;  endif
;  if mn ge 0 then begin
;    idx1 = [mnidx:lon_tmp.length-1]
;    idx2 = [0:mnidx-1]
;  endif
;  
;  idx = [idx1, idx2]
;  idx = reverse(idx)
;  
;  lon_tmp = lon_tmp[idx]
;  img = img[idx, *]
;
;lon_tmp[where(lon_tmp gt 180)] = lon_tmp[where(lon_tmp gt 180)]-360
;
;  ;  lon_tmp[where(lon_tmp gt 180, /null)] = lon_tmp[[where(lon_tmp gt 180, /null)]]-360
;
;  SP = SPEC_PLOT(esa_map, findgen(lon_tmp.length), lat_tmp, _extra = ext)
;  CB = COLOR_BAR(SP, YTITLE = 'Flux', gap = 0.01, width = 0.01)
;
;  return, sp
;
;end