pro time_shift_speed_et
  ;26-05-23

  data = read_csv('/Users/nwalia/data/HPmodel_A&D.csv', HEADER=SedHeader, N_TABLE_HEADER=1, count = 7, TABLE_HEADER=SedTableHeader)
  header = STRSPLIT(SedTableHeader, ',', /EXTRACT)
  for ii = 0, header.length-1 do !null = execute(header[ii]+' = data.field'+strcompress(ii+1, /rem))

  lon = data.field2
  lat = data.field3
  ts = data.field4
  hs = data.field5
  hs_minus = data.field6
  hs_plus =  data.field7
  hp = ts + hs
  hs_mid = ts + hs/2



  lon_arr = [1:359:2]
  lat_arr = [-89:89:2]
  TRIANGULATE, lon, lat, tr
  ts_dis = griddata(lon, lat, ts, /grid, /nearest, triangles = tr, xout = lon_arr, yout = lat_arr)
  hp_dis = griddata(lon, lat, hp, /grid, /nearest, triangles = tr, xout = lon_arr, yout = lat_arr)
  hs_thick = griddata(lon, lat, hs, /grid, /nearest, triangles = tr, xout = lon_arr, yout = lat_arr)
  hs_mid_dis = griddata(lon, lat, hs_mid, /grid, /nearest, triangles = tr, xout = lon_arr, yout = lat_arr) ;distance is in AU
  ;hs_thick_minus = griddata(lon, lat, hs_minus, /grid, /nearest, triangles = tr, xout = lon_arr, yout = lat_arr)
  ;hs_thick_plus = griddata(lon, lat, hs_plus, /grid, /nearest, triangles = tr, xout = lon_arr, yout = lat_arr)


  mid_arr = ['A_20']
  last_arr = ['B_ram']
  ty = 21
  l = 180
  m = 90
  speed_ts_ally=fltarr(ty, l, m)
  lat_orig = [-90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90]


  for b = 2, 22 do begin

    year = STRTRIM(b, 2)

    ;if b lt 10 then restore, '/Users/nwalia/data/Sokol_solar_wind/SAV/speed200'+year+'.sav' $
    ;else restore, '/Users/nwalia/data/Sokol_solar_wind/SAV/speed20'+year+'.sav'
    
    if b lt 10 then restore, '/Users/nwalia/data/Porowski_model_Nov_2023/SAV/speed200'+year+'.sav' $
    else restore, '/Users/nwalia/data/Porowski_model_Nov_2023/SAV/speed20'+year+'.sav'


    speed_intpl = interpol(lat, lat_orig, lat_arr)
    speed = fltarr(l, m)

    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin
        speed[i,j] = speed_intpl[j]
      endfor
    endfor




    ;speed_t = hs_mid_dis*1.496*100000000.0/speed ; 1AU to km = 1.496*10^8; very old one, not to be used
    ;speed_t = 1.496*100000000.0*(ts_dis/(0.9*speed) + hs_thick/(2*100)) ; speed_t = time-shifted speed (10^8); hs_thick traversed with a speed of 100 km/s; factor of 2 HS mid-point
    ;speed_t = 1.496*100000000.0*(ts_dis/(0.9*speed) + hs_thick/(2*0.4*speed)) ; speed decreases by a factor of 0.4 after TS
    ;speed_t = 1.496*100000000.0*(ts_dis/(((1+0.8)/2)*speed) + hs_thick/(2*0.8*0.4*((1+0.8)/2)*speed)) ;dec2_equ4
    ;speed_t = 1.496*100000000.0*(ts_dis/(((1+0.8)/2)*speed) + hs_thick/(2*0.8*0.4*((1+0.0)/2)*speed)) ;feb20_equ4
    speed_t = 1.496*100000000.0*(ts_dis/(((1+0.8)/2)*speed) + hs_thick/(2*0.8*0.4*((1+0.5)/2)*speed)) ;feb20_equ4_ag
    
    
    ycf = 0.0000000317;1 sec to year
    speed_t_y = speed_t*ycf

    speed_ts_ally[b-2, 0:l-1, 0:m-1] = speed_t_y

  endfor


  ;save, FILENAME = 'time_shift_speed_new_et.sav'
  ;save, FILENAME = 'pr_time_shift_speed_new_et.sav'
  ;save, FILENAME = 'factor_time_shift_speed_new_et.sav'
  ;save, FILENAME = 'pr_factor_time_shift_speed_new_et.sav'
  ;save, FILENAME = 'Dec2_equ4.sav'
  save, FILENAME = 'Feb20_equ4_ag.sav'

  stop

end
