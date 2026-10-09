;Plots multiple Theseus flux unit maps created by Thomas Kim, located in a user-defined directory
; Note to user:
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro ec_map_plot, flux_map, flux_idx, MAP_STR, mollweide = mollweide, row_style = row_style
  !quiet = 1
  e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  nose_lat = +5.1

  !P.BACKGROUND = 255
  !P.COLOR = 0
  resolution = 2.0 ;degrees
  mag_factor=5.
  !p.position=0
  !p.font=1
  plots_across=5
  plots_down=1
  !p.multi=[0,plots_across,plots_down,0,0]
  device, retain=2

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = 0;nose_lat

  if flux_idx eq 1 then begin

    IF STRUPCASE(MAP_STR) EQ 'GDF' THEN cbmax = [1200,240,120,55,23,12]
    IF STRUPCASE(MAP_STR) EQ 'RBN' THEN cbmax = [1200,250,120,70,25,5]
    IF STRUPCASE(MAP_STR) EQ 'TOT' THEN cbmax = [1200,400,180,100,30,12]

    unit = 'Diff. Flux [#/keV-cm2-sr-s]'
  endif else begin
    cbmax = [1, 0.20,0.30,0.35,0.35,0.32]
    unit = 'Count Rate [#/s]'
  endelse

  load_ibex_color_table

if keyword_set(row_style) then begin
  pos_arr = make_plot_pos(0.02, 0.08, 0.98, 0.97, 5, /row, gap = 0.015)
  window, 0, xsize=600*5,ysize=450*1;700/2*3
endif else begin
  pos1 = make_plot_pos(0.05, 0.50, 0.95, 0.95, 3, /row, gap = 0.01)
  pos2 = make_plot_pos(0.05, 0.030, 0.95, 0.500, 3, /row, gap = 0.01)
  pos_arr = [[pos1], [pos2]]
  window, 0, xsize=600*3,ysize=450*1;700/2*3
endelse


  ;  WSHOW, 0, SHOW = 0
  for ie = 0,4 do begin
    esa = ie+1
    e_value = e_step[esa] ;keV
    colorbar_range=[0,cbmax[esa]]
    out_map = 'esa'+ strcompress(esa+1,/remove_all)
    ;  window, imap, xsize=1200,ysize=700

    ;;;+ Reading different energies for the same map
    ;    print, esa+1, max(flux_map[*,*,ie])
    ascii_map=reverse(flux_map[*,*,ie],1)
    colorbar_title = unit
    imSize=SIZE(ascii_map)
    magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
    this_map = bytscl(magnifiedImg, min = colorbar_range[0], max = colorbar_range[1], top=255)
    if keyword_set(mollweide) then $
      MAP_SET, p0lat,360.-p0lon,0, /advance,position=pos_arr[*, ie],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE $
    else $
      MAP_SET, p0lat,360.-p0lon,0, /advance,position=pos_arr[*, ie],/ISOTROPIC,/noborder,limit=map_limits,/cylindrical


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
      latlab=0, glinestyle=1, glinethick=0.5, charthick=1.5, charsize=2.0

    gap = 0.1
    ;    device, decomposed=0
    ;    loadct, 13, /SILENT
    load_ibex_color_table
    fsc_colorbar, range=colorbar_range,/overplot,position=[pos[0], pos[1]-gap-0.02, pos[2], pos[1]-gap], charsize=3.4, charthick=2.5,$
      divisions=colorbar_divisions,/horizontal,title=colorbar_title, format = '(f6.1)'
    ;position=[.1, .06, .9, .1]

    XYOUTS, Startx+float(xsize)/2, StartY+float(Ysize)+15, 'ESA '+strcompress(esa+1,/remove_all)+' ~'+strtrim(string(e_value, format='(F10.2)'),2)+' keV!C', charsize=4.0, charthick=2.0, ALIGNMENT = 0.5, /DEVICE

    ; Write out flux and variance to files
    flux_mapr = rotate(ascii_map,5)
    s = size(flux_mapr)
    nlat = s[2]
    nlong = s[1]
    fmt_str = '('+strcompress(nlong,/remove_all)+'f11.2)'

  endfor

  !p.multi = 0
  device, retain=2


end
