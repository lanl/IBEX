; read_ibex_skymap_kim_theseus.pro
; 
; Author: Dan Reisenfeld (1/24/2021)
; Reads IBEX map data from Theseus map files provided by Dave Osthus and modified by Thomas Kim.
; Headers are stored as strings.
; 
;
function read_ibex_skymap_kim_theseus, filename, res
; Open data file for reading
;print, 'Now reading map file: ', filename
;;read_asc_file, filename, data, str_arr=mapname;, nskip = 1;commented by nehpreet

; Data is in a single column running through latitude then longitude.
nesa = 5
lat_step = double(res)
long_step = double(res)
nlat = 180./lat_step 
nlong = 360./long_step
map_data = dblarr(nlat,nlong,nesa)
s = size(data)
npix = s[2]
for i = 0, npix-1 do begin
  ilat = (data[1,i] + 89)/2
  ilong = (data[0,i] - 1)/2
  for j = 0, nesa-1 do begin
    map_data[ilat,ilong,j] = double(data[12+2*j,i])
  endfor
endfor
;stop

map = dblarr(nlong,nlat,nesa)
for k = 0, nesa-1 do begin
  mapa = rotate(reform(map_data[*,*,k]),1)
  map[*,*,k] = mapa
endfor
Return, map
END
