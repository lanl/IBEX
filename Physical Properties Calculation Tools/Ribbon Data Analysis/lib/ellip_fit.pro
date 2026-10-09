pro conv_fac_normalize, data

  mag_data = sqrt(total(data^2, 2))
  for j = 0, 2 do data[*, j] /= mag_data

end

FUNCTION ELLIPSE_FUNC, LON, EP

  A = EP[0]
  B = EP[1]
  T_ROT = EP[2]
  T0 = EP[3]
  P0 = EP[4]

  A_ = a^2*sin(t_rot*!dtor)^2 + b^2*cos(t_rot*!dtor)^2
  B_ = 2*(b^2 - a^2)*sin(t_rot*!dtor)*cos(t_rot*!dtor)
  C_ = a^2*cos(t_rot*!dtor)^2 + b^2*sin(t_rot*!dtor)^2
  F_ = - a^2*b^2

  r = sqrt(-F_/ (A_*cos(lon*!DTOR)^2 + B_*cos(lon*!DTOR)*sin(lon*!DTOR) + C_*sin(lon*!DTOR)^2 ))
  LON_SOL = lon
  LAT_SOL = r

  ; ellipse with offset
  ;  x0 = T0*cos(P0*!dtor)
  ;  y0 = T0*sin(P0*!dtor)
  ;  A_ = a^2*sin(t_rot*!dtor)^2 + b^2*cos(t_rot*!dtor)^2
  ;  B_ = 2*(b^2 - a^2)*sin(t_rot*!dtor)*cos(t_rot*!dtor)
  ;  C_ = a^2*cos(t_rot*!dtor)^2 + b^2*sin(t_rot*!dtor)^2
  ;  D_ = -2*A_*x0 - B_*y0
  ;  E_ = -B_*x0 - 2*C_*y0
  ;  F_ = A_*x0^2 + B_*x0*y0 + C_*y0^2 - a^2*b^2;*c^2
  ;  Ap = A_*cos(lon*!DTOR)^2 + B_*cos(lon*!DTOR)*sin(lon*!DTOR) + C_*sin(lon*!DTOR)^2
  ;  Bp = D_*cos(lon*!DTOR) + E_*sin(lon*!DTOR)
  ;  ;coeff
  ;  Lat_sol1 = (-Bp + sqrt(Bp^2 - 4*Ap*F_))/(2*Ap)
  ;  Lat_sol2 = (-Bp - sqrt(Bp^2 - 4*Ap*F_))/(2*Ap)
  ;  idx1 = where(Lat_sol1 gt 0, /null)
  ;  idx2 = where(Lat_sol2 gt 0, /null)
  ;  Lat_sol = [Lat_sol1[idx1], Lat_sol2[idx2]]
  ;  lon_sol = [lon[idx1], lon[idx2]]
  ; ellipse with offset

  RETURN, {LON_SOL:LON_SOL, LAT_SOL:LAT_SOL}
END

function ellip_fit, peak_pos, p, $
  all = all, $
  _EXTRA=extra

  ;0000000000 peak lon sort
  peak_pos_tmp = peak_pos
  idx = sort(peak_pos_tmp[*, 0])
  peak_pos_tmp = peak_pos_tmp[idx, *]
  ;0000000000 peak lon sort

  ; parameter handle
  a = p[0] ; AXIS1 IN DEGREE
  b = p[1] ; AXIS2 IN DEGREE
  t_rot = p[2] ; ROTATION ANGLE IN DEGREE
  T0 = p[3] ; ecliptic latitude in degree (not colat or polar angle)
  P0 = p[4] ; ecliptic longitude in degree
  ; parameter handle

  ;  lon for fitting output
  lon_tmp = linspace(0, 360, 1000)
  ;  lon for fitting output

  ;********************** BASIS SETTING **********************
  ;1111111  ribbon center basis in EC coordinates, BASIS FOR EC --> RC
  ; nose location in ecliptic coordinates
  nose = transpose([1d*sin((90-5d)*!dtor)*cos(259d*!dtor), $
    1d*sin((90-5d)*!dtor)*sin(259d*!dtor), $
    1d*cos((90-5d)*!dtor)])
  ; nose location in ecliptic coordinates

  ; ribbon center to unit z
  unit_z = transpose([1d*sin((90-t0)*!dtor)*cos(p0*!dtor), $
    1d*sin((90-t0)*!dtor)*sin(p0*!dtor), $
    1d*cos((90-t0)*!dtor)])
  conv_fac_normalize, unit_z
  ; ribbon center to unit z

  ; unit y = ribbon center X nose direction
  unit_y = crosspro(unit_z, nose)
  conv_fac_normalize, unit_y
  ; unit y = ribbon center X nose direction

  ; unit x = unit y X ribbon center = at the same lon to the nose
  unit_x = crosspro(unit_y, unit_z)
  conv_fac_normalize, unit_x
  ; unit x = unit y X ribbon center = at the same lon to the nose
  ;1111111  ribbon center basis in EC coordinates


  ;2222222 EC pole in RC coordinates, BASIS FOR RC --> EC
  unit_z1 = transpose([total(unit_x*[0, 0, 1]), total(unit_y*[0, 0, 1]), total(unit_z*[0, 0, 1])])
  conv_fac_normalize, unit_z1
  unit_y1 = transpose([total(unit_x*[0, 1, 0]), total(unit_y*[0, 1, 0]), total(unit_z*[0, 1, 0])])
  conv_fac_normalize, unit_y1
  unit_x1 = transpose([total(unit_x*[1, 0, 0]), total(unit_y*[1, 0, 0]), total(unit_z*[1, 0, 0])])
  conv_fac_normalize, unit_x1
  ;2222222 EC pole in RC coordinates
  ;********************** BASIS SETTING **********************

  ;3333333 ribbon location, transform from EC spherical to EC cartesian
  sph_rect, replicate(1d, n_elements(peak_pos_tmp[*, 0])), peak_pos_tmp[*, 1], peak_pos_tmp[*, 0], x = x, y = y, z = z, /to_rect
  ;3333333 ribbon location, transform from EC spherical to EC cartesian

  ;4444444 ribbon location, transform from EC cartesian to RC cartesian
  xx = unit_x[0]*x+unit_x[1]*y+unit_x[2]*z
  yy = unit_y[0]*x+unit_y[1]*y+unit_y[2]*z
  zz = unit_z[0]*x+unit_z[1]*y+unit_z[2]*z
  ;4444444 ribbon location, transform from EC cartesian to RC cartesian

  ;5555555 ribbon location, transform from RC cartesian to RC spherical
  sph_rect, xx, yy, zz, magnitude = m1, theta = t1, phi = p1, /colat
  ;5555555 ribbon location, transform from RC cartesian to RC spherical

  ;6666666 fitted location w/ input, transform from RC spherical to RC cartesian
  RES = ELLIPSE_FUNC(p1, [A, B, T_ROT, T0, P0])
  LON1 = RES.LON_SOL
  LAT1 = RES.LAT_SOL

  idx = sort(lon1)
  lon1 = lon1[idx]
  lat1 = lat1[idx]

  sph_rect, replicate(1d, n_elements(peak_pos_tmp[*, 0])), 90-lat1, lon1, x = x1, y = y1, z = z1, /to_rect
  ;6666666 fitted location w/ input, transform from RC spherical to RC cartesian

  ;7777777 fitted location w/ input, transform from RC cartesian to EC cartesian
  xx2 = unit_x1[0]*x1+unit_x1[1]*y1+unit_x1[2]*z1
  yy2 = unit_y1[0]*x1+unit_y1[1]*y1+unit_y1[2]*z1
  zz2 = unit_z1[0]*x1+unit_z1[1]*y1+unit_z1[2]*z1
  ;7777777 fitted location w/ input, transform from RC cartesian to EC cartesian

  ;8888888 fitted location w/ input, transform from EC cartesian to EC spherical
  sph_rect, xx2, yy2, zz2, magnitude = m2, theta = t2, phi = p2
  ;8888888 fitted location w/ input, transform from EC cartesian to EC spherical

  ;9999999 fitted location w/ 0-360, transform from RC spherical to RC cartesian
  RES = ELLIPSE_FUNC(lon_tmp, [A, B, T_ROT, T0, P0])
  LON2 = RES.LON_SOL
  LAT2 = RES.LAT_SOL

  idx = sort(lon2)
  lon2 = lon2[idx]
  lat2 = lat2[idx]

  sph_rect, replicate(1d, n_elements(lon2)), 90-lat2, lon2, x = x1, y = y1, z = z1, /to_rect
  ;9999999 fitted location w/ 0-360, transform from RC spherical to RC cartesian

  ;10101010 fitted location w/ 0-360, transform from RC cartesian to EC cartesian
  xx2 = unit_x1[0]*x1+unit_x1[1]*y1+unit_x1[2]*z1
  yy2 = unit_y1[0]*x1+unit_y1[1]*y1+unit_y1[2]*z1
  zz2 = unit_z1[0]*x1+unit_z1[1]*y1+unit_z1[2]*z1
  ;10101010 fitted location w/ 0-360, transform from RC cartesian to EC cartesian

  ;11111111 fitted location w/ 0-360, transform from EC cartesian to EC spherical
  sph_rect, xx2, yy2, zz2, magnitude = m3, theta = t3, phi = p3
  ;11111111 fitted location w/ 0-360, transform from EC cartesian to EC spherical

  ;12121212 ascending order
  idx = sort(p3)
  p3 = p3[idx]
  t3 = t3[idx]
  ;12121212 ascending order

  ;13131313 interpolate fitted location to input longitude
  lat_int = interpol(t3, p3, peak_pos[*, 0])
  ;13131313 interpolate fitted location to input longitude

;  ;14141414 sort to match original
;  idx1 = value_locate(peak_pos[*, 0], peak_pos_tmp[*, 0])
;  peak_pos_t = peak_pos[idx1, *]
;  lat_int = lat_int[idx1]
;  ;14141414 sort to match original
;  if total(peak_pos_t[*, 0] eq peak_pos_tmp[*, 0]) ne n_elements(peak_pos_t[*, 0]) then stop

  if keyword_set(all) then return, {lon:p2, lat:t2, lon_cont:p3, lat_cont:t3, lat_match:lat_int}
  if ~keyword_set(all) then return, lat_int

  ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


  ;  Lat_sol = 90 - Lat_sol
  ;  return, Lat_sol
end