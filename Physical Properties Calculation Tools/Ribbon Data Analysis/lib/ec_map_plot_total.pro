;Plots multiple Theseus flux unit maps created by Thomas Kim, located in a user-defined directory
; Note to user:
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro ec_map_plot_total, flux_map, flux_idx, MAP_STR, map_dir, mollweide = mollweide, row_style = row_style, STD = STD
  !quiet = 1
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]
  sz = size(flux_map)
  char_color = 255
  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  nose_lat = +5.1

  !P.BACKGROUND = 0
  !P.COLOR = 0
  resolution = 2.0 ;degrees
  mag_factor=5.
  !p.position=0
  !p.font=1
  plots_across=5
  plots_down=1*sz[4]
  !p.multi=[0,plots_across,plots_down,0,0]
  device, retain=2

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat;nose_lat

  if flux_idx eq 1 then begin
    cbmax = [1200,250,150,60,30,7]
    if STRUPCASE(MAP_DIR) EQ 'RAM' THEN BEGIN
      IF STRUPCASE(MAP_STR) EQ 'GDF' THEN cbmax = [1200,400,200,100,40,15]
      IF STRUPCASE(MAP_STR) EQ 'RBN' THEN cbmax = [1200,400,200,100,40,15]
      IF STRUPCASE(MAP_STR) EQ 'TOT' THEN cbmax = [1200,800,400,140,60,18]
    ENDIF
    if STRUPCASE(MAP_DIR) EQ '6MO' THEN BEGIN
      IF STRUPCASE(MAP_STR) EQ 'GDF' THEN cbmax = [1200,250,150,60,30,12]
      IF STRUPCASE(MAP_STR) EQ 'RBN' THEN cbmax = [1200,250,150,60,30,7]
      IF STRUPCASE(MAP_STR) EQ 'TOT' THEN cbmax = [1200,400,250,100,40,15]
    ENDIF

    if STRUPCASE(MAP_DIR) EQ 'ARAM' THEN BEGIN
      IF STRUPCASE(MAP_STR) EQ 'GDF' THEN cbmax = [1200,300,150,60,30,12]
      IF STRUPCASE(MAP_STR) EQ 'RBN' THEN cbmax = [1200,270,140,70,25,6]
      IF STRUPCASE(MAP_STR) EQ 'TOT' THEN cbmax = [1200,500,250,120,45,13]
    ENDIF

    unit = 'Differential Flux [#/keV-cm2-sr-s]'
  endif else begin
    cbmax = [1, 0.20,0.30,0.35,0.35,0.32]
    unit = 'Count Rate [#/s]'
  endelse


  IF KEYWORD_SET(STD) THEN BEGIN
    CBMAX = REPLICATE(1., 6)
    UNIT = 'Fractional Uncertainty'
  ENDIF
  load_ibex_color_table

  if keyword_set(row_style) then begin
    hight = 0.95-0.05
    hight_tmp = hight/(sz[4]-1)*0.95
    pos_arr = []

    for yy = 0, sz[4]-1 do pos_arr = [[[pos_arr]], [[make_plot_pos(0.06, 0.05+hight_tmp*yy, 0.98, 0.05+hight_tmp*(yy+1), 5, /row, gap = 0.005)]]]
    pos_arr = reverse(pos_arr, 3)
    window, 0, xsize=750*5,ysize=400*sz[4];700/2*3
  endif else begin
    pos1 = make_plot_pos(0.05, 0.50, 0.95, 0.95, 3, /row, gap = 0.01)
    pos2 = make_plot_pos(0.05, 0.030, 0.95, 0.500, 3, /row, gap = 0.01)
    pos_arr = [[pos1], [pos2]]
    window, 0, xsize=600*3,ysize=450*1;700/2*3
  endelse

  WSHOW, 0, 0

  ;  WSHOW, 0, SHOW = 0
  for yidx = 0, sz[4]-1 do begin
    for ie = 0,4 do begin
      esa = ie+1
      e_value = e_step[esa] ;keV
      colorbar_range=[0,cbmax[esa]]
      out_map = 'esa'+ strcompress(esa+1,/remove_all)
      ;  window, imap, xsize=1200,ysize=700

      ;;;+ Reading different energies for the same map
      ;    print, esa+1, max(flux_map[*,*,ie])
      ascii_map=reverse(flux_map[*,*,ie,yidx],1)
      colorbar_title = unit
      imSize=SIZE(ascii_map)
      magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
      this_map = bytscl(magnifiedImg, min = colorbar_range[0], max = colorbar_range[1], top=255)
      if keyword_set(mollweide) then $
        MAP_SET, p0lat,360.-p0lon,0, /advance,position=pos_arr[*, ie, yidx],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE, color = 250 $
      else $
        MAP_SET, 0,360.-p0lon,0, /advance,position=pos_arr[*, ie, yidx],/ISOTROPIC,/noborder,limit=map_limits,/cylindrical


      remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
      pos = fltarr(4)
      pos[0] = Startx / float(!d.x_vsize)
      pos[1] = Starty / float(!d.y_vsize)
      pos[2] = (Startx + xsize) / float(!d.x_vsize)
      pos[3] = (Starty + ysize) / float(!d.y_vsize)

      load_ibex_color_table
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
        latlab=0, glinestyle=1, glinethick=1., charthick=1.5, charsize=2.0

      gap = 0.05/sz[4]
      ;    device, decomposed=0
      ;    loadct, 13, /SILENT
      load_ibex_color_table
      if yidx eq sz[4]-1 then fsc_colorbar, range=colorbar_range,/overplot,position=[pos[0]+0.02, pos[1]-gap-0.04/sz[4], pos[2]-0.02, pos[1]-gap], charsize=10, charthick=2.5,$
        divisions=colorbar_divisions,/horizontal, format = '(I3)', color = 255
      ;        if yidx eq sz[4]-1 then fsc_colorbar, range=colorbar_range,/overplot,position=[pos[0], pos[1]-gap-0.04/sz[4], pos[2], pos[1]-gap], charsize=3.4, charthick=2.5,$
      ;        divisions=colorbar_divisions,/horizontal,title=colorbar_title, format = '(I3)', color = 255

      if yidx eq 0 then XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+100, 'ESA '+strcompress(esa+1,/remove_all)+'!C'+strtrim(string(e_value, format='(F10.2)'),2)+' keV!C', charsize=8, charthick=2.0, ALIGNMENT = 0.5, /DEVICE, color = char_color
      if ie eq 0 then XYOUTS, Startx-70, StartY + float(Ysize)/2, string(2009+yidx, format = '(I4)'), charsize=9, charthick=2.0, ALIGNMENT = 0.5, orientation = 90, /DEVICE, color = char_color


      ; Write out flux and variance to files
      flux_mapr = rotate(ascii_map,5)
      s = size(flux_mapr)
      nlat = s[2]
      nlong = s[1]
      fmt_str = '('+strcompress(nlong,/remove_all)+'f11.2)'

      if ie eq 2 and yidx eq sz[4]-1 then $
        XYOUTS, Startx+float(xsize)/2, StartY-200, Unit, charsize=7, charthick=2.0, ALIGNMENT = 0.5, color = char_color, /device

    endfor
  endfor

  !p.multi = 0
  device, retain=2


end
