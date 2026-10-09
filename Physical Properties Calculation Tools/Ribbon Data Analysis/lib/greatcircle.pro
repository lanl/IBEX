function phi2mlt, phi

  phi1 = phi
  phi1 mod= 360.

  phi1 -= 180.
  con = where(phi1 lt 0, cnt)
  if cnt ne 0 then phi1[con] += 360.
  return, phi1/15.

end

pro sph_rect, D1, D2, D3, $
  magnitude = magnitude, $
  theta = theta, $
  phi = phi, $
  colat = colat, $
  X = x, $
  Y = y, $
  Z = z, $
  to_rect = to_rect, $
  mlt = mlt



  if ~keyword_set(to_rect) then begin ; rectangular ->> spherical

    if n_params() eq 3 then begin
      x = D1
      y = D2
      z = D3
    endif else if n_params() eq 1 then begin
      x = D1[*, 0]
      y = D1[*, 1]
      z = D1[*, 2]
    endif

    xy = x*x+y*y

    if arg_present(magnitude) then magnitude = sqrt(xy + z*z)

    ty = typename(D1)
    if ty eq 'DOUBLE' then fac = 180d/!dpi else fac = 180/!pi

    if arg_present(theta) then begin
      theta = fac*atan(z , sqrt(xy))
      if keyword_set(colat) then theta = 90 - theta
    endif

    if arg_present(phi) then begin
      phi   = fac*atan(y, x) + 360
      phi mod= 360
    endif

    if arg_present(mlt) then begin
      mlt = fac*atan(-y, -x) + 360 ; in degree
      mlt mod= 360
      mlt /= 15  ; hour
    endif

  endif else begin ; spherical ->> rectangular

    ty = typename(D1)

    if ty eq 'DOUBLE' then fac = !dpi/180d else fac = !pi/180
    if n_params() eq 3 then begin
      r = D1
      if keyword_set(colat) then co_lat = D2*fac else co_lat = (90 - D2)*fac
      phi = D3*fac

    endif else if n_params() eq 1 then begin
      r = D1[*, 0]
      if keyword_set(colat) then co_lat = d1[*, 1]*fac else co_lat = (90 - D1[*, 1])*fac
      phi = D1[*, 2]*fac
    endif

    if arg_present(x) then x = r*sin(co_lat)*cos(phi)
    if arg_present(y) then y = r*sin(co_lat)*sin(phi)
    if arg_present(z) then z = r*cos(co_lat)

    if arg_present(mlt) then mlt = phi2mlt(phi/fac)
  endelse

end

function crosspro, A, B
  ; A =  N X 3
  ; B =  N X 3
  ; A version of CROSSP for efficient vector cross products


  szA = size(A, /DIM)
  szb = size(B, /DIM)

  if (szA[1] ne 3) or (szB[1] ne 3) then $
    message, 'ERROR: number of vectors must match'

  Res = make_array(szA, $
    VALUE = 0.*A[0]*B[0], /nozero)

  xa = a[*, 0]
  ya = a[*, 1]
  za = a[*, 2]


  xb = b[*, 0]
  yb = b[*, 1]
  zb = b[*, 2]


  Res[0, 0] = a[*, 1]*b[*, 2] - a[*, 2]*b[*, 1]
  Res[0, 1] = a[*, 2]*b[*, 0] - a[*, 0]*b[*, 2]
  Res[0, 2] = a[*, 0]*b[*, 1] - a[*, 1]*b[*, 0]

  return, Res
end

function norm_tmp, val
  return, reform(val)/sqrt(total(reform(val^2)))
end

; This code draw a line of a complete great circle (GC) connecting two dots (p0 and p11) on a spherical surface.
; input formats
; p0 and p11 :[Lon, Lat], Lon from 0 to 360, Lat from -90, 90
; npath: number of data point for GC, default = 100

function GreatCircle, p0, p11, npath = npath, midpoint = midpoint

  if ~keyword_set(npath) then npath = 100

  sph_rect, 1d, p0[1], p0[0], x = x0, y = y0, z = z0, /to_rect
  sph_rect, 1d, p11[1], p11[0], x = x1, y = y1, z = z1, /to_rect

  if ~keyword_set(midpoint) then begin
    w = crosspro(transpose([x0, y0, z0]), transpose([x1, y1, z1]))
    w = norm_tmp(w)
  endif else begin
    sph_rect, 1d, midpoint[1], midpoint[0], x = x2, y = y2, z = z2, /to_rect
    w = crosspro(transpose([x0, y0, z0]), transpose([x2, y2, z2]))
    w = norm_tmp(w)
  endelse

  v = crosspro(transpose([x1, y1, z1]), transpose(w))
  v = norm_tmp(v)
  sph_rect, v[0], v[1], v[2], magnitude = r, theta = t, phi = p

  v1 = crosspro(transpose(v), transpose(w))
  v1 = norm_tmp(v1)
  sph_rect, v1[0], v1[1], v1[2], magnitude = r1, theta = t1, phi = p1

  v2 = crosspro(transpose(v1), transpose(w))
  v2 = norm_tmp(v2)
  sph_rect, v2[0], v2[1], v2[2], magnitude = r2, theta = t2, phi = p2

  v3 = crosspro(transpose(v2), transpose(w))
  v3 = norm_tmp(v3)
  sph_rect, v3[0], v3[1], v3[2], magnitude = r3, theta = t3, phi = p3

  res1 = map_2points(p, t, p1, t1, npath = npath)
  res2 = map_2points(p1, t1, p2, t2, npath = npath)
  res3 = map_2points(p2, t2, p3, t3, npath = npath)
  res4 = map_2points(p3, t3, p, t, npath = npath)

  res = [[res1], [res2[*, 1:-1]], [res3[*, 1:-1]], [res4[*, 1:-2]]]

  ;  sidx = uniq(res[0, *], sort(res[0, *]))
  ;  res = res[*, sidx]
  return, res
end