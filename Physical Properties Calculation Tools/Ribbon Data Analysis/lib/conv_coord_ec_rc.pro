pro conv_fac_normalize, data

  mag_data = sqrt(total(data^2, 2))
  for j = 0, 2 do data[*, j] /= mag_data

end



; lon, lat: ecliptic longitude and latitude that user wants to transform into the ribbon center coordinate system
; rc_lon, rc_lat: Ribbon center location in the Ecliptic Coordinate system
; nose_pos: Nose location in the Ecliptic Coordinate system. To determine starting axis (x axis in Cartesian). Default = [259, 5]

Function conv_coord_EC_RC, lon, lat, rc_lon, rc_lat, $
  nose_POS = nose_POS, $
  reverse = reverse

  ; parameter handle
  ;          r = p[0] ; radius in degree
  t0 = rc_lat ; ecliptic latitude in degree (not colat or polar angle)
  p0 = rc_lon ; ecliptic longitude in degree
  ; parameter handle

  ;********************** BASIS SETTING **********************
  ;1111111  ribbon center basis in EC coordinates, BASIS FOR EC --> RC
  ; nose location in ecliptic coordinates
  if keyword_set(nose_POS) then  nose = transpose([1d*sin((90-nose_POS[1])*!dtor)*cos(nose_POS[0]*!dtor), $
    1d*sin((90-nose_POS[1])*!dtor)*sin(nose_POS[0]*!dtor), $
    1d*cos((90-nose_POS[1])*!dtor)]) $
  else nose = transpose([1d*sin((90-5.14d)*!dtor)*cos(255.6*!dtor), $
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

  if ~keyword_set(reverse) then begin
    ;3333333 ribbon location, transform from EC spherical to EC cartesian
    R_MAT = lon
    R_MAT[*] = 1D
    sph_rect, R_MAT, lat, lon, x = x, y = y, z = z, /to_rect
    ;3333333 ribbon location, transform from EC spherical to EC cartesian

    ;4444444 ribbon location, transform from EC cartesian to RC cartesian
    xx = unit_x[0]*x+unit_x[1]*y+unit_x[2]*z
    yy = unit_y[0]*x+unit_y[1]*y+unit_y[2]*z
    zz = unit_z[0]*x+unit_z[1]*y+unit_z[2]*z
    ;4444444 ribbon location, transform from EC cartesian to RC cartesian

    ;5555555 ribbon location, transform from RC cartesian to RC spherical
    sph_rect, xx, yy, zz, magnitude = m1, theta = t1, phi = p1, /COLAT
    ;5555555 ribbon location, transform from RC cartesian to RC spherical

  endif

  if keyword_set(reverse) then begin
    ;6666666 fitted location w/ input, transform from RC spherical to RC cartesian
    lon1 = lon
    lat1 = lat
    R_MAT = lon
    R_MAT[*] = 1D

    sph_rect, r_mat, 90-lat1, lon1, x = x1, y = y1, z = z1, /to_rect
    ;6666666 fitted location w/ input, transform from RC spherical to RC cartesian

    ;7777777 fitted location w/ input, transform from RC cartesian to EC cartesian
    xx2 = unit_x1[0]*x1+unit_x1[1]*y1+unit_x1[2]*z1
    yy2 = unit_y1[0]*x1+unit_y1[1]*y1+unit_y1[2]*z1
    zz2 = unit_z1[0]*x1+unit_z1[1]*y1+unit_z1[2]*z1
    ;7777777 fitted location w/ input, transform from RC cartesian to EC cartesian

    ;8888888 fitted location w/ input, transform from EC cartesian to EC spherical
    sph_rect, xx2, yy2, zz2, magnitude = m2, theta = t1, phi = p1
    ;8888888 fitted location w/ input, transform from EC cartesian to EC spherical
  endif



  return, {lon:p1, lat:t1}

END


