pro lrs_8feb_diff_maps_speci

  all_spec_in= []

  for a = 12, 20 do begin
    y = STRTRIM(a, 2)
     z = STRTRIM(a+1, 2)
    ;restore, '/Users/nwalia/data/Flux Corrected Ribbon Separated Maps 02-08-2023 V1/SAV/20'+y+'A_20'+y+'B_antiram.sav'
    restore, '/Users/nwalia/data/Flux Corrected Ribbon Separated Maps 02-08-2023 V1/SAV/20'+y+'A_20'+y+'B_ram.sav'
    ;restore, '/Users/nwalia/data/Flux Corrected Ribbon Separated Maps 02-08-2023 V1/SAV/20'+y+'B_20'+z+'A_antiram.sav'
    ;restore, '/Users/nwalia/data/Flux Corrected Ribbon Separated Maps 02-08-2023 V1/SAV/20'+y+'B_20'+z+'A_ram.sav'


    ;xp = spec_plot(ESA5_TOT_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(xp, range= [0,20])

    indices = make_array(180, 90)

    for i = 0, 179 do begin
      for j = 0, 89 do begin

        Flux = [ESA2_GDF_MAP[i, j], ESA3_GDF_MAP[i, j], ESA4_GDF_MAP[i, j], ESA5_GDF_MAP[i, j], ESA6_GDF_MAP[i, j]]
        Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
        f = LINFIT(alog(Energy), alog(flux))
        indices(i,j)=f[1]




      endfor
    endfor


    all_spec_in = [all_spec_in, indices]
  
  endfor

  ;help, all_spec_in
  l=180
  m=89
  diff_map15_16= (-all_spec_in[0:l-1, 0:m] + all_spec_in[l:l*2-1, 0:m]);/all_spec_in[0:l-1, 0:m]
  diff_map16_17= (-all_spec_in[l:l*2-1, 0:m] + all_spec_in[l*2:l*3-1, 0:m]);/all_spec_in[l:l*2-1, 0:m]
  diff_map17_18= all_spec_in[l*2:l*3-1, 0:m] - all_spec_in[l*3:l*4-1, 0:m]
  diff_map18_19= all_spec_in[l*3:l*4-1, 0:m] - all_spec_in[l*4:l*5-1, 0:m]
  diff_map19_20= all_spec_in[l*4:l*5-1, 0:m] - all_spec_in[l*5:l*6-1, 0:m]
  diff_map15_20= all_spec_in[0:l-1, 0:m] - all_spec_in[l*5:l*6-1, 0:m]

  ;print, diff_map15_16
  ;help, diff_map15_16

  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  nose_lat = +5.1

  resolution = 2.0 ;degrees
  mag_factor=5.
  !p.position=0
  !p.font=1
  plots_across=1
  plots_down=1
  !p.multi=[0,plots_across,plots_down,0,0]
  device, retain=2
  ;loadct, 33
cgLoadCT, 71, /reverse
  ;load_ibex_color_table

  ;latmin = -90
  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat
  
  cl = -0.5
  cm = 0.5

  cbmax = [1200,800,200,140,60,18]

  ascii_map=reverse(diff_map15_16)
  ;colorbar_title = 'diff_map_15_16_AB_antiram'
  colorbar_title = 'diff_map_12_13_AB_ram'
  ;colorbar_title = 'diff_map_15_16_BA_antiram'
  ;colorbar_title = 'diff_map_15_16_BA_ram'
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = cl, max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale
  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[cl, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
  !p.multi = 0
  device, retain=2
  ;WRITE_PNG, 'diff_map_15_16_AB_antiram.png', TVRD(/TRUE)
  WRITE_PNG, 'diff_map_15_16_AB_ram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_15_16_BA_antiram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_15_16_BA_ram.png', TVRD(/TRUE)
 
  ascii_map=reverse(diff_map16_17)
  ;colorbar_title = 'diff_map_16_17_AB_antiram'
  colorbar_title = 'diff_map_13_14_AB_ram'
  ;colorbar_title = 'diff_map_16_17_BA_antiram'
  ;colorbar_title = 'diff_map_16_17_BA_ram'
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = cl, max = cm  );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale
  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[cl, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
  !p.multi = 0
  device, retain=2
  ;WRITE_PNG, 'diff_map_16_17_AB_antiram.png', TVRD(/TRUE)
  WRITE_PNG, 'diff_map_16_17_AB_ram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_16_17_BA_antiram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_16_17_BA_ram.png', TVRD(/TRUE)
  stop
  
  ascii_map=reverse(diff_map17_18)
  ;colorbar_title = 'diff_map_17_18_AB_antiram'
  colorbar_title = 'diff_map_17_18_AB_ram'
  ;colorbar_title = 'diff_map_17_18_BA_antiram'
  ;colorbar_title = 'diff_map_17_18_BA_ram'
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = -1.0, max = 1.0  );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale
  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-1.0, 1.0], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
  !p.multi = 0
  device, retain=2
  ;WRITE_PNG, 'diff_map_17_18_AB_antiram.png', TVRD(/TRUE)
  WRITE_PNG, 'diff_map_17_18_AB_ram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_17_18_BA_antiram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_17_18_BA_ram.png', TVRD(/TRUE)
  
  
  ascii_map=reverse(diff_map18_19)
  ;colorbar_title = 'diff_map_18_19_AB_antiram'
  colorbar_title = 'diff_map_18_19_AB_ram'
  ;colorbar_title = 'diff_map_18_19_BA_antiram'
  ;colorbar_title = 'diff_map_18_19_BA_ram'
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = -1.0, max = 1.0  );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale
  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-1.0, 1.0], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
  !p.multi = 0
  device, retain=2
  ;WRITE_PNG, 'diff_map_18_19_AB_antiram.png', TVRD(/TRUE)
  WRITE_PNG, 'diff_map_18_19_AB_ram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_18_19_BA_antiram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_18_19_BA_ram.png', TVRD(/TRUE)
  
  
  ascii_map=reverse(diff_map19_20)
  ;colorbar_title = 'diff_map_19_20_AB_antiram'
  colorbar_title = 'diff_map_19_20_AB_ram'
  ;colorbar_title = 'diff_map_19_20_BA_antiram'
  ;colorbar_title = 'diff_map_19_20_BA_ram'
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = -1.0, max = 1.0  );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale
  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-1.0, 1.0], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
  !p.multi = 0
  device, retain=2
  ;WRITE_PNG, 'diff_map_19_20_AB_antiram.png', TVRD(/TRUE)
  WRITE_PNG, 'diff_map_19_20_AB_ram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_19_20_BA_antiram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_19_20_BA_ram.png', TVRD(/TRUE)
  
  
  ascii_map=reverse(diff_map15_20)
  ;colorbar_title = 'diff_map_15_20_AB_antiram'
  colorbar_title = 'diff_map_15_20_AB_ram'
  ;colorbar_title = 'diff_map_15_20_BA_antiram'
  ;colorbar_title = 'diff_map_15_20_BA_ram'
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = -1.0, max = 1.0  );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale
  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-1.0, 1.0], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
  !p.multi = 0
  device, retain=2
  ;WRITE_PNG, 'diff_map_15_20_AB_antiram.png', TVRD(/TRUE)
  WRITE_PNG, 'diff_map_15_20_AB_ram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_15_20_BA_antiram.png', TVRD(/TRUE)
  ;WRITE_PNG, 'diff_map_15_20_BA_ram.png', TVRD(/TRUE)

  






end
