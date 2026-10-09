pro conv_fac_normalize, data

  mag_data = sqrt(total(data^2, 2))
  for j = 0, 2 do data[*, j] /= mag_data

end


function circ_fit_from_rc, peak_pos, p, $
  all = all, $
  _EXTRA=extra


  peak_pos_tmp = peak_pos

  ; parameter handle
  r = p[0] ; radius in degree
  t0 = p[1] ; ecliptic latitude in degree (not colat or polar angle)
  p0 = p[2] ; ecliptic longitude in degree
  T00 = p[3] ; ecliptic latitude in degree (not colat or polar angle)
  P00 = p[4] ; ecliptic longitude in degree
  ; parameter handle

  ;  lon for fitting output
  lon_tmp = linspace(0, 360, 1000)
  ;  lon for fitting output

  ; -1-1-1-1-1-1 rc --> ec
  res = conv_coord_ec_rc(peak_pos_tmp[*, 0], peak_pos_tmp[*, 1], P00, T00, /reverse)
  peak_pos_tmp[*, 0] = RES.LON
  peak_pos_tmp[*, 1] = RES.LAT
  ; -1-1-1-1-1-1 rc --> ec


  ;0000000000 peak lon sort
  idx = sort(peak_pos_tmp[*, 0])
  peak_pos_tmp = peak_pos_tmp[idx, *]
  ;0000000000 peak lon sort


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
  r1 = replicate(r, p1.length)
  sph_rect, replicate(1d, n_elements(peak_pos_tmp[*, 0])), 90-r1, p1, x = x1, y = y1, z = z1, /to_rect
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
  r1 = replicate(r, lon_tmp.length)
  sph_rect, replicate(1d, n_elements(lon_tmp)), 90-r1, lon_tmp, x = x1, y = y1, z = z1, /to_rect
  ;9999999 fitted location w/ 0-360, transform from RC spherical to RC cartesian

  ;10101010 fitted location w/ 0-360, transform from RC cartesian to EC cartesian
  xx2 = unit_x1[0]*x1+unit_x1[1]*y1+unit_x1[2]*z1
  yy2 = unit_y1[0]*x1+unit_y1[1]*y1+unit_y1[2]*z1
  zz2 = unit_z1[0]*x1+unit_z1[1]*y1+unit_z1[2]*z1
  ;10101010 fitted location w/ 0-360, transform from RC cartesian to EC cartesian

  ;11111111 fitted location w/ 0-360, transform from EC cartesian to EC spherical
  sph_rect, xx2, yy2, zz2, magnitude = m3, theta = t3, phi = p3
  ;11111111 fitted location w/ 0-360, transform from EC cartesian to EC spherical

  ; 12121212 ec --> original rc
  res = conv_coord_ec_rc(p3, t3, P00, T00)
  p3 = RES.LON
  t3 = RES.LAT
  ; 12121212 ec --> original rc

  ;13131313 ascending order
  idx = sort(p3)
  p3 = p3[idx]
  t3 = t3[idx]
  ;13131313 ascending order

  ;14141414 interpolate fitted location to input longitude

  t3_tmp = [t3[-10:-1], t3, t3[0:9]]
  p3_tmp = [p3[-10:-1]-360, p3, p3[0:9]+360]

  lat_int = interpol(t3_tmp, p3_tmp, peak_pos[*, 0])
  ;14141414 interpolate fitted location to input longitude

  ;  if total(peak_pos[*, 0] eq peak_pos_tmp[*, 0]) ne n_elements(peak_pos[*, 0]) then stop
  
  if keyword_set(all) then return, {lon:p2, lat:t2, lon_cont:p3, lat_cont:t3, lat_match:lat_int}
  if ~keyword_set(all) then return, lat_int

end
