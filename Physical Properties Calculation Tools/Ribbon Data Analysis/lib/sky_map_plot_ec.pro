; Note to user:
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro sky_map_plot_EC, flux_map, data_range = data_range, CB_title = CB_title, Title = Title, Color_Table = Color_Table, Mollweide = Mollweide
  !quiet = 1

  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  nose_lat = +5.1
  char_color = fsc_color('white')

  !P.BACKGROUND = 0
  !P.COLOR = 0
  resolution = 2.0 ;degrees
  mag_factor=5.
  !p.position=0
  !p.font=1
  plots_across=3
  plots_down=2
  !p.multi=[0,plots_across,plots_down,0,0]
  device, retain=2

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat

  pos_arr = [0.05, 0.15, 0.95, 0.95]

  if keyword_set(data_range) then $
    colorbar_range = data_range else $
    colorbar_range=[min(flux_map, /nan), max(flux_map, /nan)]

  if keyword_set(cb_title) then $
    colorbar_title = cb_title else $
    colorbar_title = ''

  if keyword_set(title) then $
    title = title else $
    title = ''

  ;;;+ Reading different energies for the same map
  ascii_map=reverse(flux_map,1)

  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])

  this_map = bytscl(magnifiedImg, min = colorbar_range[0], max = colorbar_range[1], top=255)
  if keyword_set(mollweide) then $
    MAP_SET, p0lat,360.-p0lon,0, /advance,position=pos_arr,/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE, color = char_color $ ; mollweide
  else $
    MAP_SET, 0,360.-p0lon,0, /advance,position=pos_arr,/ISOTROPIC,/noborder,limit=map_limits,/cylindrical, color = char_color ; mollweide

  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)

  if keyword_set(Color_Table) then tvlct,Color_Table[*, 0], Color_Table[*, 1], Color_Table[*, 2]

  imdisp, remap, /noscale, /usepos, pos=pos, CHARSIZE = 3;[*, ie]

  LAT_MARK = [-90,-60,-30, 0,30,60,90]
  LAT_MARK_STR = STRING((LAT_MARK), FORMAT = '(I3)')
  LAT_MARK_STR[where(lat_mark eq 0), /null] = ''

  LON_MARK = [-180:180:30.]
  LON_MARK_STR = STRING(-(LON_MARK), FORMAT = '(I4)')

  MAP_GRID, latdel=30, londel=30,/LABEL, color=fsc_color('white'), /horizon, $
    lats = LAT_MARK, latnames=LAT_MARK_STR, $
    lons = LON_MARK, lonnames=STRCOMPRESS(LON_MARK_STR, /REM), $
    latlab=0, glinestyle=1, glinethick=0.5, charthick=1.5, charsize=3

  gap = 0.08
  fsc_colorbar, range=colorbar_range,/overplot,position=[pos[0], pos[1]-gap-0.02, pos[2], pos[1]-gap], charsize=5, charthick=2.5,$
    divisions=colorbar_divisions,/horizontal,title=colorbar_title, format = '(f7.2)', color = char_color
  ;position=[.1, .06, .9, .1]

  XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+10, title, charsize=5, charthick=2.0, ALIGNMENT = 0.5, color = char_color, /DEVICE


  !p.multi = 0
  device, retain=2

end
