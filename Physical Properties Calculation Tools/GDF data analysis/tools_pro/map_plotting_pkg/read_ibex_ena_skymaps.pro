;MAD 12/08/2013
; Reads IBEX standard ISOC maps
; Headers are stored as strings.
function read_ibex_ena_skymaps, filename
; Open data file for reading
;print, 'Now reading map file: ', filename
close,10
OPENR, unit, filename, /get_lun
line = ''
index=0
d_index=0
headers_0=strarr(100000)
data_0=strarr(100000)
WHILE ~ EOF(unit) DO BEGIN
	readf, unit, line
	if STRCMP(line, '#', 1, /FOLD_CASE) eq 1 then begin
		headers_0[index] = line
		index = index+1
	endif else begin
		data_0[d_index]= line
		d_index=d_index+1
	endelse
ENDWHILE
FREE_LUN, unit
Header=headers_0[0:index-1]
data=data_0[0:d_index-1]
Lat_num = n_elements(data)
Lon_num = n_elements(strsplit(data[0],/extract))
Map_data=dblarr(Lat_num, Lon_num)
for i=0L, Lat_num-1 do begin
	for j=0L, Lon_num-1 do begin
	this_lat = strsplit(data[i],/extract)
	map_data[i,j] = double(this_lat[j])
	endfor
endfor
map = rotate(map_data, 1)
Return, map
END
