pro helio_to_ecliptic

  
  l = 180
  m = 90
  
  t_lm = l*m
  lon_arr = [1:359:2]
  lat_arr = [-89:89:2]
  
  xp = fltarr(l, m)
  yp = fltarr(l, m)
  zp = fltarr(l, m)
  
  for j = 0, 90-1 do begin
    for i = 0, 180-1 do begin
      xp[i,j] = cos(lat_arr(j)*!pi/180.)*cos(lon_arr(i)*!pi/180.)
      yp[i,j] = cos(lat_arr(j)*!pi/180.)*sin(lon_arr(i)*!pi/180.)
      zp[i,j] = sin(lat_arr(j)*!pi/180.)
      
    endfor
   endfor
   
   
 phi = 255.76*!pi/180.
 theta = -7.25*!pi/180.
 psi = -0.70*!pi/180.
 
 x = (cos(psi)*cos(phi)-cos(theta)*sin(phi)*sin(psi))*xp-(sin(psi)*cos(phi)+cos(theta)*sin(phi)*cos(psi))*yp+sin(theta)*sin(phi)*zp
 y = (cos(psi)*sin(phi)+cos(theta)*cos(phi)*sin(psi))*xp+(-sin(psi)*sin(phi)+cos(theta)*cos(phi)*cos(psi))*yp-sin(theta)*cos(phi)*zp
 z = sin(theta)*sin(psi)*xp+sin(theta)*cos(psi)*yp+cos(theta)*zp 

 lat_ec = round(asin(z)*(180/!PI))
 lon_ec = round(abs(atan(y,x)*(180/!PI)-180))
   
   save, filename='helio_to_ecliptic.sav'
 stop
 
 end
 
      
      