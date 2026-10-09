pro test_GC

  p0 = [259, 5]
  p11 = [220, 40]

  sph_rect, 1d, p0[1], p0[0], x = x0, y = y0, z = z0, /to_rect
  sph_rect, 1d, p11[1], p11[0], x = x1, y = y1, z = z1, /to_rect

  w = crosspro(transpose([x0, y0, z0]), transpose([x1, y1, z1]))
  w = reform(w/norm(w))
  v = crosspro(transpose([x0, y0, z0]), transpose(w))
  v = reform(v/norm(v))
  sph_rect, v[0], v[1], v[2], magnitude = r, theta = t, phi = p

  v1 = crosspro(transpose(v), transpose(w))
  v1 = reform(v1/norm(v1))
  sph_rect, v1[0], v1[1], v1[2], magnitude = r1, theta = t1, phi = p1

  v2 = crosspro(transpose(v1), transpose(w))
  v2 = reform(v2/norm(v2))
  sph_rect, v2[0], v2[1], v2[2], magnitude = r2, theta = t2, phi = p2

  v3 = crosspro(transpose(v2), transpose(w))
  v3 = reform(v3/norm(v3))
  sph_rect, v3[0], v3[1], v3[2], magnitude = r3, theta = t3, phi = p3

  res1 = map_2points(p, t, p1, t1, npath = 100)
  res2 = map_2points(p1, t1, p2, t2, npath = 100)
  res3 = map_2points(p2, t2, p3, t3, npath = 100)
  res4 = map_2points(p3, t3, p, t, npath = 100)

  res = [[res1], [res2], [res3], [res4]]

  sidx = uniq(res[0, *], sort(res[0, *]))
  res = res[*, sidx]
  p = plot(res[0, *], res[1, *], xr = [200, 240], yr = [25, 55], thick = 3)
  
  br = map_2points(p0[0], p0[1], p11[0], p11[1], npath = 1000)
  p = plot(br[0, *], br[1, *], over = p, co = 'red')
 stop





  npath = 100

  lon0 = p0[0] & lat0 = p0[1]
  lon1 = p1[0] & lat1 = p1[1]

  stop
end