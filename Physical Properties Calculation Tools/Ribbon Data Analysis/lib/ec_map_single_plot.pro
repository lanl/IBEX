;Plots multiple Theseus flux unit maps created by Thomas Kim, located in a user-defined directory
; Note to user:
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro ec_map_single_plot, esa, flux_map, flux_idx, map_str, data_range = data_range, cb_title = cb_title, title = title, RT = RT, mollweide = mollweide
  !quiet = 1
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]
  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  nose_lat = +5.1
  char_color = 255

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

  if flux_idx eq 1 then begin
    IF STRUPCASE(MAP_STR) EQ 'GDF' THEN cbmax = [1200,400,300,100,40,15]
    IF STRUPCASE(MAP_STR) EQ 'RBN' THEN cbmax = [1200,400,300,100,40,15];[1200,250,120,55,17,4];
    IF STRUPCASE(MAP_STR) EQ 'TOT' THEN cbmax = [1200,800,300,140,60,20]

    ;    cbmax = [1200,400,250,140,40,15]
    ;    cbmax = [1200,400,250,200,40,15]
    unit = 'Diff. Flux [#/keV-cm2-sr-s]'
  endif
  


  if flux_idx eq 0 then begin
    cbmax = [1, 0.20,0.30,0.35,0.35,0.32]
    unit = 'Count Rate [#/s]'
  endif

  if flux_idx eq 2 then begin
    cbmax = [-5, 0]
    unit = 'Spectral Index'
  endif
  
  if flux_idx eq 3 then begin
    cbmax = [1200,400,250,100,40,15]/10d
    unit = 'Standard Error'
  endif
  
  if flux_idx eq 4 then begin
    cbmax = [1, 1, 1, 1, 1, 1]
    unit = 'Fractional Error'
  endif

  load_ibex_color_table

  pos_arr = [0.05, 0.15, 0.95, 0.95]

  window, 0, xsize=1200/2*3/2,ysize=600;700/2*3
  WSHOW, 0, 0
  ;  WSHOW, 0
  ie = esa-1
  esa = ie+1
  e_value = e_step[ie] ;keV

  if keyword_set(data_range) then $
    colorbar_range = data_range else $
    colorbar_range=[0,cbmax[ie]]

  if keyword_set(cb_title) then $
    colorbar_title = cb_title else $
    colorbar_title = unit

  if keyword_set(title) then $
    title = title else $
    title = ''

  ;  colorbar_title = unit
  ;;;+ Reading different energies for the same map
  ;    print, esa+1, max(flux_map[*,*,ie])
  ascii_map=reverse(flux_map,1)
  ;  colorbar_title = 'ESA'+strcompress(esa+1,/remove_all)+' ~'+strtrim(string(e_value, format='(F10.2)'),2)+' keV!C'+unit

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

  if keyword_set(RT) then loadct, rt else load_ibex_color_table

  imdisp, remap, /noscale, /usepos, pos=pos, CHARSIZE = 5;[*, ie]
  ;    MAP_GRID, latdel=30, londel=30,/LABEL, color=fsc_color('white'), /horizon, $
  ;      lats = [-90,-60,-30,0,30,60,90], latnames=['-90','-60','-30','0','30','60',' '], $
  ;      lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0], lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'], $
  ;      latlab=0, glinestyle=1, glinethick=0.5, charthick=1.5, charsize=2.0

  LAT_MARK = [-90,-60,-30,0,30,60,90]
  LAT_MARK_STR = STRING((LAT_MARK), FORMAT = '(I3)')

  LON_MARK = [-180:180:30.]
  LON_MARK_STR = STRING(-(LON_MARK), FORMAT = '(I4)')

  MAP_GRID, latdel=30, londel=30,/LABEL, color=fsc_color('white'), /horizon, $
    lats = LAT_MARK, latnames=LAT_MARK_STR, $
    lons = LON_MARK, lonnames=STRCOMPRESS(LON_MARK_STR, /REM), $
    latlab=0, glinestyle=1, glinethick=0.5, charthick=1.5, charsize=3

  gap = 0.06

  if keyword_set(RT) then loadct, rt else load_ibex_color_table
  fsc_colorbar, range=colorbar_range,/overplot,position=[pos[0], pos[1]-gap-0.02, pos[2], pos[1]-gap], charsize=5, charthick=2.5,$
    divisions=colorbar_divisions,/horizontal,title=colorbar_title, format = '(f7.2)', color = char_color
  ;position=[.1, .06, .9, .1]

  ;  XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+5, 'ESA '+strcompress(esa+1,/remove_all), charsize=4.0, charthick=2.0, ALIGNMENT = 0.5, /DEVICE
  ;  XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+5, 'Ribbon Only, Theseus-D', charsize=4.0, charthick=2.0, ALIGNMENT = 0.5, /DEVICE
  XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+5, title, charsize=5, charthick=2.0, ALIGNMENT = 0.5, color = char_color, /DEVICE


  ; Write out flux and variance to files
  flux_mapr = rotate(ascii_map,5)
  s = size(flux_mapr)
  nlat = s[2]
  nlong = s[1]
  fmt_str = '('+strcompress(nlong,/remove_all)+'f11.2)'


  !p.multi = 0
  device, retain=2


end
