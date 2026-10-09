pro omni_sw_pressure

;stime = ['2009-01-01/00:00:00']
;etime = ['2009-12-01/00:00:00']
;etime = ['2024-12-31/00:00:00']

;stime = ['2012-01-01/00:00:00']
;etime = ['2021-12-31/00:00:00']


stime = ['2011-01-01/00:00:00']
etime = ['2016-12-31/00:00:00']

omni_hro_load, trange=[time_double(stime),time_double(etime)], /res5min

get_data, 'OMNI_HRO_5min_Pressure', data=omnip

omp_arr = omnip.y

 ; 3month average
 ;data points in 3months 
; min_m = 30.*24.*60. ; minutes in one month
; fivemin_m = min_m/5. ; five minutes in a month
; fivemin_3m = fivemin_m * 3. ; five minutes in 3 months
; fivemin_1m = fivemin_m * 1 ; five minutes in 0.5 months
; et= long((n_elements(omnip.x)-1)/fivemin_1m)
; time_array = []
; pressure_array = []
; for i = 0, et-1 do begin
;  time = mean(omnip.x[long(fivemin_1m)*i:long(fivemin_1m)*(i+1)])
;  pressure = mean(omnip.y[long(fivemin_1m)*i:long(fivemin_1m)*(i+1)], /nan)
;  append_array, time_array, time
;  append_array, pressure_array, pressure
;  
; endfor
 
 ;sliding window
 
 ;min_m = 30.*24.*60. ; minutes in one month
 ;fivemin_m = min_m/5. ; five minutes in a month
 ;fivemin_3m = fivemin_m * 3. ; five minutes in 3 months
 ;fivemin_1m = fivemin_m * 1 ; five minutes in 0.5 months
 
 min_m = 27.275*24.*60. ; minutes in one carrington rotation
 fivemin_m = min_m/5. ; five minutes in one carrington rotation
 fivemin_2m = fivemin_m * 2. ; five minutes in 2 carrington rotation
 fivemin_3m = fivemin_m * 3. ; five minutes in 3 carrington rotation
 et1 = long(n_elements(omnip.x)-1)
 ;et= long((n_elements(omnip.x)-1)/fivemin_1m)
 time_array = []
 pressure_array = []
 yt5min = 365.*24.*12. ; 5min to year

;3 months
 for i = 0, et1-long(fivemin_3m) do begin
   time = 2011.+i/yt5min
   pressure = mean(omnip.y[i:long(fivemin_3m)+i], /nan)
   append_array, time_array, time
   append_array, pressure_array, pressure
   ;print, time, pressure
   print, time_string(time), pressure
 
 endfor
 
 ; 2months
; for i = 0, et1-long(fivemin_2m) do begin
;   time = 2011.+i/yt5min
;   pressure = mean(omnip.y[i:long(fivemin_2m)+i], /nan)
;   append_array, time_array, time
;   append_array, pressure_array, pressure
;   ;print, time, pressure
;   print, time_string(time), pressure
;
; endfor
 
 ;stop
 time_cn = time_string(time_array)
 ;plot, time_array, pressure_array, color = fsc_color('red'), thick = 4, yrange = [0, 3], xrange = [2012, 2022], xtitle ='Year', ytitle='SW dynamic Pressure [nPa] ', xminor = 2, xthick = 4, ythick = 4, charthick = 4, charsize = 1.2
 ;g1a = errorplot(time_array, pressure_array, color = fsc_color('red'), xrange=[2010, 2014], yrange=[0, 3], xminor=0, XTITLE="Year", YTITLE="SW dynamic Pressure [nPa]")
 a=plot(time_array, pressure_array, color = fsc_color('red'), xrange=[2011.8, 2016], yrange=[1, 3], xminor=0, XTITLE="Year", YTITLE="SW dynamic Pressure [nPa]")
 
 data_press={x:time_array, y:pressure_array}
 store_data, 'SW_dynamic_pressure_1', data=data_press
 options, 'SW_dynamic_pressure_1', xtitle='', ytitle='SW Dynamic Pressure [nPa]', charsize=3, charthick = 2;, 'color', 150
 tplot_options,'region',[.1,.3,.9,.9]
 time_stamp,/off 
 
  ;save, filename='2cr_omni.sav'
  save, filename='3cr_omni.sav'
  stop
  end
