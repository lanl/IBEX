pro lrs_8feb_diff_maps_wdiv_esa

  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []
 
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

 
  ;load_ibex_color_table
  cgLoadCT, 71, /reverse

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat

  cbmax = [1200,800,200,140,60,18]


  mid_arr = ['A_20', 'A_20', 'B_20', 'B_20']
  ;last_arr = ['B_antiram.sav', 'B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  last_arr = ['B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  names = [ 'AB_ram', 'BA_antiram', 'BA_ram']
  ;names = ['AB_antiram', 'AB_ram', 'BA_antiram', 'BA_ram']

 for restarri = 0, 1 do begin
  
  for a = 12, 20 do begin
    y = STRTRIM(a, 2)
    z = STRTRIM(a+1, 2)
    
   
    restore, '/Users/nwalia/data/Flux Corrected Ribbon Separated Maps 02-08-2023 V1/SAV/20'+y+mid_arr[restarri]+y+last_arr[restarri]
      
  
    all_ESA2 = [all_ESA2, ESA2_GDF_MAP]
    all_ESA3 = [all_ESA3, ESA3_GDF_MAP]
    all_ESA4 = [all_ESA4, ESA4_GDF_MAP]
    all_ESA5 = [all_ESA5, ESA5_GDF_MAP]
    all_ESA6 = [all_ESA6, ESA6_GDF_MAP]

  endfor
  


  l=180
  m=89
  
  
  
 ;for i = 2, 6 do begin
  for i = 6, 7 do begin
  num = STRTRIM(i, 1)
 void = execute('diff_map12_13_ESA'+num+' = (- all_ESA'+num+'[0:l-1, 0:m] + all_ESA'+num+'[l:l*2-1, 0:m])/all_ESA'+num+'[0:l-1, 0:m]')
 void = execute('diff_map12_13_ESA'+num+'notdiv = (- all_ESA'+num+'[0:l-1, 0:m] + all_ESA'+num+'[l:l*2-1, 0:m])')
 void = execute('diff_map13_14_ESA'+num+' = (- all_ESA'+num+'[l:l*2-1, 0:m] + all_ESA'+num+'[l*2:l*3-1, 0:m])/all_ESA'+num+'[l:l*2-1, 0:m]')
 void = execute('diff_map13_14_ESA'+num+'notdiv = (- all_ESA'+num+'[l:l*2-1, 0:m] + all_ESA'+num+'[l*2:l*3-1, 0:m])')
 void = execute('diff_map17_18_ESA'+num+' = (- all_ESA'+num+'[l*2:l*3-1, 0:m] + all_ESA'+num+'[l*3:l*4-1, 0:m])/all_ESA'+num+'[l*2:l*3-1, 0:m]')
 void = execute('diff_map18_19_ESA'+num+' = (- all_ESA'+num+'[l*3:l*4-1, 0:m] + all_ESA'+num+'[l*4:l*5-1, 0:m])/all_ESA'+num+'[l*3:l*4-1, 0:m]')
 void = execute('diff_map19_20_ESA'+num+' = (- all_ESA'+num+'[l*4:l*5-1, 0:m] + all_ESA'+num+'[l*5:l*6-1, 0:m])/all_ESA'+num+'[l*4:l*5-1, 0:m]')
 void = execute('diff_map15_20_ESA'+num+' = (- all_ESA'+num+'[0:l-1, 0:m] + all_ESA'+num+'[l*5:l*6-1, 0:m])/all_ESA'+num+'[0:l-1, 0:m]')
 

;lon_b=[]
;lat_b=[]
 ;for lati = 0, m do begin
  ; ESA6_16b =  where(reverse(all_ESA6[l:l*2-1, lati]) ge 4)
  ; if n_elements(ESA6_16b) gt 1 then lon_b= [lon_b, LON_ARR[ESA6_16b]]
  ; if n_elements(ESA6_16b) gt 1 then for v = 0, n_elements(ESA6_16b)-1 do begin 
  ; lat_b = [lat_b, LAT_ARR[lati]]
  ; endfor
 ; endfor
 
 cl = -0.7
 cm = 0.7
 
ca= [100, 50, 22, 10, 4]

 oyn = 13
  ;for oyn = 16, 19 do begin
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)
  
  void = execute('lon_b'+num+'_'+ynn+'=[]')
  void = execute('lat_b'+num+'_'+ynn+'=[]')
  for lati = 0, m do begin
      ;ESA_LON =[]
      ;HVAL_LON=[]
      ;PRES_LON=[]
    ;void = execute('ESA_LON = reverse(all_ESA'+num+'[l*(oynn - 15) :l*(oynn - 14)-1, lati])')
    
    void = execute('ESA'+num+'_'+ynn+'b_o =  where((reverse(all_ESA'+num+'[l*(oynn - 15) :l*(oynn - 14)-1, lati]) ge ca[i - 2]))')
    void = execute('d = where((ESA'+num+'_'+ynn+'b_o lt 120) or  (ESA'+num+'_'+ynn+'b_o gt 160))')
    void = execute('if ((lati gt 5) and (lati lt 70)) then ESA'+num+'_'+ynn+'b = ESA'+num+'_'+ynn+'b_o[d] else ESA'+num+'_'+ynn+'b = ESA'+num+'_'+ynn+'b_o')
    ;HVAL_LON = where( ESA_LON ge ca[i - 2])
    ;void = execute('if n_elements(HVAL_LON) eq n_elements (ESA_LON) then ESA'+num+'_'+ynn+'b = HVAL_LON ')
    ;if n_elements(HVAL_LON)lt n_elements(ESA_LON) then begin
      ;lc = n_elements(HVAL_LON)-1
      ;if c gt 0 then begin
      ;d = where((HVAL_LON[1:c]-HVAL_LON[0:c-1]) ge 2) 
      ;if d[0] ge 0 then PRES_LON = [HVAL_LON[d[0]+1]:HVAL_LON[c]] else PRES_LON = [HVAL_LON]
      ;endif else begin
        ;if HVAL_LON gt -1 then PRES_LON = [HVAL_LON]
      ;endelse
    ;endif
    
    ;void = execute('if n_elements(HVAL_LON) lt n_elements (ESA_LON) then ESA'+num+'_'+ynn+'b = PRES_LON')
    void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then lon_b'+num+'_'+ynn+'= [lon_b'+num+'_'+ynn+', LON_ARR[ESA'+num+'_'+ynn+'b]]')
    void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then for v = 0, n_elements(ESA'+num+'_'+ynn+'b)-1 do begin lat_b'+num+'_'+ynn+' = [lat_b'+num+'_'+ynn+', LAT_ARR[lati]] & endfor')
    ;void = execute('print, "LON =", lon_b'+num+'_'+ynn+', "LAT =", lat_b'+num+'_'+ynn+', ESA'+num+'_'+ynn+'b')
    ;stop
    endfor
  
  
 
 void = execute('ascii_map=reverse(diff_map'+yn+'_'+ynn+'_ESA'+num+')')
    colorbar_title = 'ESA'+num+'diff_map_'+yn+'_'+ynn+'/'+yn+names[restarri]
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
    
     ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
     ;void = execute('oplot, lon_b'+num+'_'+ynn+', lat_b'+num+'_'+ynn+', psym = 1')
     ;void = execute('oplot, 75.7, 5.1, psym = 1')
     
      
    MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
    fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[cl, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
    !p.multi = 0
    device, retain=2
   
    WRITE_PNG, 'b_ESA'+num+'diff_map_'+yn+'_'+ynn+names[restarri], TVRD(/TRUE)
    stop
    
    cl = -2
    cm = 2
    
    void = execute('ascii_map=reverse(diff_map'+yn+'_'+ynn+'_ESA'+num+'notdiv)')
    colorbar_title = 'ESA'+num+'diff_map_'+yn+'_'+ynn
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

    ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
    ;void = execute('oplot, lon_b'+num+'_'+ynn+', lat_b'+num+'_'+ynn+', psym = 1')
    ;void = execute('oplot, 75.7, 5.1, psym = 1')


    MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
      lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
      lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
      latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
    fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[cl, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
      color=fsc_color('white'),/horizontal,title=colorbar_title
    !p.multi = 0
    device, retain=2

    WRITE_PNG, 'b_ESA'+num+'diff_map_'+yn+'_'+ynn+names[restarri], TVRD(/TRUE)
    
    stop
    
   oyn = 16
     ;for oyn = 16, 19 do begin
     oynn= oyn + 1
     yn = STRTRIM(oyn, 1)
     ynn = STRTRIM(oynn, 1)

     void = execute('lon_b'+num+'_'+ynn+'=[]')
     void = execute('lat_b'+num+'_'+ynn+'=[]')
     for lati = 0, m do begin
       ;ESA_LON =[]
       ;HVAL_LON=[]
       ;PRES_LON=[]
       ;void = execute('ESA_LON = reverse(all_ESA'+num+'[l*(oynn - 15) :l*(oynn - 14)-1, lati])')

       void = execute('ESA'+num+'_'+ynn+'b_o =  where((reverse(all_ESA'+num+'[l*(oynn - 15) :l*(oynn - 14)-1, lati]) ge ca[i - 2]))')
       void = execute('d = where((ESA'+num+'_'+ynn+'b_o lt 120) or  (ESA'+num+'_'+ynn+'b_o gt 155))')
       void = execute('if ((lati gt 15) and (lati lt 70)) then ESA'+num+'_'+ynn+'b = ESA'+num+'_'+ynn+'b_o[d] else ESA'+num+'_'+ynn+'b = ESA'+num+'_'+ynn+'b_o')
       ;HVAL_LON = where( ESA_LON ge ca[i - 2])
       ;void = execute('if n_elements(HVAL_LON) eq n_elements (ESA_LON) then ESA'+num+'_'+ynn+'b = HVAL_LON ')
       ;if n_elements(HVAL_LON)lt n_elements(ESA_LON) then begin
       ;lc = n_elements(HVAL_LON)-1
       ;if c gt 0 then begin
       ;d = where((HVAL_LON[1:c]-HVAL_LON[0:c-1]) ge 2)
       ;if d[0] ge 0 then PRES_LON = [HVAL_LON[d[0]+1]:HVAL_LON[c]] else PRES_LON = [HVAL_LON]
       ;endif else begin
       ;if HVAL_LON gt -1 then PRES_LON = [HVAL_LON]
       ;endelse
       ;endif

       ;void = execute('if n_elements(HVAL_LON) lt n_elements (ESA_LON) then ESA'+num+'_'+ynn+'b = PRES_LON')
       void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then lon_b'+num+'_'+ynn+'= [lon_b'+num+'_'+ynn+', LON_ARR[ESA'+num+'_'+ynn+'b]]')
       void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then for v = 0, n_elements(ESA'+num+'_'+ynn+'b)-1 do begin lat_b'+num+'_'+ynn+' = [lat_b'+num+'_'+ynn+', LAT_ARR[lati]] & endfor')
       ;void = execute('print, "LON =", lon_b'+num+'_'+ynn+', "LAT =", lat_b'+num+'_'+ynn+', ESA'+num+'_'+ynn+'b')
       ;stop
     endfor
     
     void = execute('ascii_map=reverse(diff_map'+yn+'_'+ynn+'_ESA'+num+')')
     colorbar_title = 'ESA'+num+'diff_map_'+yn+'_'+ynn+'/'+yn+names[restarri]
     imSize=SIZE(ascii_map)
     magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
     this_map = bytscl(magnifiedImg,  min = -2, max = 2 );, top=255)
     MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
     remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
     pos = fltarr(4)
     pos[0] = Startx / float(!d.x_vsize)
     pos[1] = Starty / float(!d.y_vsize)
     pos[2] = (Startx + xsize) / float(!d.x_vsize)
     pos[3] = (Starty + ysize) / float(!d.y_vsize)
     imdisp, remap, pos=pos, /usepos, /noscale

     ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
     void = execute('oplot, lon_b'+num+'_'+ynn+', lat_b'+num+'_'+ynn+', psym = 1')


     MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
       lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
       lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
       latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
     fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-2, 2], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
       color=fsc_color('white'),/horizontal,title=colorbar_title
     !p.multi = 0
     device, retain=2
    
     WRITE_PNG, 'b_ESA'+num+'diff_map_'+yn+'_'+ynn+names[restarri], TVRD(/TRUE)

   
   for oyn = 17, 19 do begin
     oynn= oyn + 1
     yn = STRTRIM(oyn, 1)
     ynn = STRTRIM(oynn, 1)

     void = execute('lon_b'+num+'_'+ynn+'=[]')
     void = execute('lat_b'+num+'_'+ynn+'=[]')
     for lati = 0, m do begin
       void = execute('ESA'+num+'_'+ynn+'b =  where(reverse(all_ESA'+num+'[l*(oynn - 15) :l*(oynn - 14)-1, lati]) ge ca[i - 2])')
       void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then lon_b'+num+'_'+ynn+'= [lon_b'+num+'_'+ynn+', LON_ARR[ESA'+num+'_'+ynn+'b]]')
       void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then for v = 0, n_elements(ESA'+num+'_'+ynn+'b)-1 do begin lat_b'+num+'_'+ynn+' = [lat_b'+num+'_'+ynn+', LAT_ARR[lati]] & endfor')
     endfor
     
     void = execute('ascii_map=reverse(diff_map'+yn+'_'+ynn+'_ESA'+num+')')
     colorbar_title = 'ESA'+num+'diff_map_'+yn+'_'+ynn+'/'+yn+names[restarri]
     imSize=SIZE(ascii_map)
     magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
     this_map = bytscl(magnifiedImg,  min = -2, max = 2 );, top=255)
     MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
     remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
     pos = fltarr(4)
     pos[0] = Startx / float(!d.x_vsize)
     pos[1] = Starty / float(!d.y_vsize)
     pos[2] = (Startx + xsize) / float(!d.x_vsize)
     pos[3] = (Starty + ysize) / float(!d.y_vsize)
     imdisp, remap, pos=pos, /usepos, /noscale

     ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
     void = execute('oplot, lon_b'+num+'_'+ynn+', lat_b'+num+'_'+ynn+', psym = 1')


     MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
       lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
       lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
       latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
     fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-2, 2], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
       color=fsc_color('white'),/horizontal,title=colorbar_title
     !p.multi = 0
     device, retain=2

     WRITE_PNG, 'b_ESA'+num+'diff_map_'+yn+'_'+ynn+names[restarri], TVRD(/TRUE)



   endfor
   
   stop
   
   
   

   ;commenting 15_20 for the moment;;;;;;;;;;;;;;;;
   ; void = execute('ascii_map=reverse(diff_map15_20_ESA'+num+')')
   ; caf = ['ESA'+num+'diff_map_15_20/15_AB_antiram', 'ESA'+num+'diff_map_15_20/15_AB_ram', 'ESA'+num+'diff_map_15_20/15_BA_antiram', 'ESA'+num+'diff_map_15_20/15_BA_ram']
   ; capngf = ['ESA'+num+'diff_map_15_20_AB_antiram', 'ESA'+num+'diff_map_15_20_AB_ram', 'ESA'+num+'diff_map_15_20_BA_antiram', 'ESA'+num+'diff_map_15_20_BA_ram']


   ;   colorbar_title = 'ESA'+num+'diff_map_15_20/15'+names[restarri]
   ;   imSize=SIZE(ascii_map)
   ;   magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
   ;   this_map = bytscl(magnifiedImg,  min = -2, max = 2  );, top=255)
   ;   MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
   ;   remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
   ;   pos = fltarr(4)
   ;  pos[0] = Startx / float(!d.x_vsize)
   ;  pos[1] = Starty / float(!d.y_vsize)
   ;  pos[2] = (Startx + xsize) / float(!d.x_vsize)
   ;  pos[3] = (Starty + ysize) / float(!d.y_vsize)
   ;  imdisp, remap, pos=pos, /usepos, /noscale
   ;  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
   ;    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
   ;    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
   ;    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
   ;  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-2, 2], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
   ;    color=fsc_color('white'),/horizontal,title=colorbar_title
   ;  !p.multi = 0
   ;  device, retain=2
   ;  WRITE_PNG, 'ESA'+num+'diff_map_15_20'+names[restarri], TVRD(/TRUE)
  
    
  
  
  
  endfor
  
  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []
  
  
  endfor
  
  
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []
  
  for restarri = 2, 3 do begin
  
  for a = 15, 20 do begin
    y = STRTRIM(a, 2)
    z = STRTRIM(a+1, 2)
    
   
    restore, '/Users/nwalia/data/Flux Corrected Ribbon Separated Maps 02-08-2023 V1/SAV/20'+y+mid_arr[restarri]+z+last_arr[restarri]
      
  
    all_ESA2 = [all_ESA2, ESA2_GDF_MAP]
    all_ESA3 = [all_ESA3, ESA3_GDF_MAP]
    all_ESA4 = [all_ESA4, ESA4_GDF_MAP]
    all_ESA5 = [all_ESA5, ESA5_GDF_MAP]
    all_ESA6 = [all_ESA6, ESA6_GDF_MAP]

  endfor
  


  l=180
  m=89
  
 for i = 2, 6 do begin
  num = STRTRIM(i, 1)
 void = execute('diff_map15_16_ESA'+num+' = (- all_ESA'+num+'[0:l-1, 0:m] + all_ESA'+num+'[l:l*2-1, 0:m])/all_ESA'+num+'[0:l-1, 0:m]')
 void = execute('diff_map16_17_ESA'+num+' = (- all_ESA'+num+'[l:l*2-1, 0:m] + all_ESA'+num+'[l*2:l*3-1, 0:m])/all_ESA'+num+'[l:l*2-1, 0:m]')
 void = execute('diff_map17_18_ESA'+num+' = (- all_ESA'+num+'[l*2:l*3-1, 0:m] + all_ESA'+num+'[l*3:l*4-1, 0:m])/all_ESA'+num+'[l*2:l*3-1, 0:m]')
 void = execute('diff_map18_19_ESA'+num+' = (- all_ESA'+num+'[l*3:l*4-1, 0:m] + all_ESA'+num+'[l*4:l*5-1, 0:m])/all_ESA'+num+'[l*3:l*4-1, 0:m]')
 void = execute('diff_map19_20_ESA'+num+' = (- all_ESA'+num+'[l*4:l*5-1, 0:m] + all_ESA'+num+'[l*5:l*6-1, 0:m])/all_ESA'+num+'[l*4:l*5-1, 0:m]')
 void = execute('diff_map15_20_ESA'+num+' = (- all_ESA'+num+'[0:l-1, 0:m] + all_ESA'+num+'[l*5:l*6-1, 0:m])/all_ESA'+num+'[0:l-1, 0:m]')
 
 ca= [100, 50, 22, 10, 4]
 
 for oyn = 15, 19 do begin
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)
  
  void = execute('lon_b'+num+'_'+ynn+'=[]')
  void = execute('lat_b'+num+'_'+ynn+'=[]')
  for lati = 0, m do begin
    void = execute('ESA'+num+'_'+ynn+'b =  where(reverse(all_ESA'+num+'[l*(oynn - 15) :l*(oynn - 14)-1, lati]) ge ca[i - 2])')
    void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then lon_b'+num+'_'+ynn+'= [lon_b'+num+'_'+ynn+', LON_ARR[ESA'+num+'_'+ynn+'b]]')
    void = execute('if n_elements(ESA'+num+'_'+ynn+'b) gt 1 then for v = 0, n_elements(ESA'+num+'_'+ynn+'b)-1 do begin lat_b'+num+'_'+ynn+' = [lat_b'+num+'_'+ynn+', LAT_ARR[lati]] & endfor')
  endfor
 
 void = execute('ascii_map=reverse(diff_map'+yn+'_'+ynn+'_ESA'+num+')')
    colorbar_title = 'ESA'+num+'diff_map_'+yn+'_'+ynn+'/'+yn+names[restarri]
    imSize=SIZE(ascii_map)
    magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
    this_map = bytscl(magnifiedImg,  min = -2, max = 2  );, top=255)
    MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
    remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
    pos = fltarr(4)
    pos[0] = Startx / float(!d.x_vsize)
    pos[1] = Starty / float(!d.y_vsize)
    pos[2] = (Startx + xsize) / float(!d.x_vsize)
    pos[3] = (Starty + ysize) / float(!d.y_vsize)
    imdisp, remap, pos=pos, /usepos, /noscale
    
    void = execute('oplot, lon_b'+num+'_'+ynn+', lat_b'+num+'_'+ynn+', psym = 1')
    
    MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
    fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-2, 2], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal,title=colorbar_title
    !p.multi = 0
    device, retain=2
    WRITE_PNG, 'b_ESA'+num+'diff_map_'+yn+'_'+ynn+names[restarri], TVRD(/TRUE)
    

 
   endfor
    ;commenting 15_20 for the moment;;;;;;;;;;;;;;;;
    ;void = execute('ascii_map=reverse(diff_map15_20_ESA'+num+')')
    ;caf = ['ESA'+num+'diff_map_15_20/15_AB_antiram', 'ESA'+num+'diff_map_15_20/15_AB_ram', 'ESA'+num+'diff_map_15_20/15_BA_antiram', 'ESA'+num+'diff_map_15_20/15_BA_ram']
    ;capngf = ['ESA'+num+'diff_map_15_20_AB_antiram', 'ESA'+num+'diff_map_15_20_AB_ram', 'ESA'+num+'diff_map_15_20_BA_antiram', 'ESA'+num+'diff_map_15_20_BA_ram']


    ;  colorbar_title = 'ESA'+num+'diff_map_15_20/15'+names[restarri]
    ;  imSize=SIZE(ascii_map)
    ;  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
    ;  this_map = bytscl(magnifiedImg,  min = -2, max = 2  );, top=255)
    ;  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
    ;  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
    ;  pos = fltarr(4)
    ;  pos[0] = Startx / float(!d.x_vsize)
    ; pos[1] = Starty / float(!d.y_vsize)
    ;  pos[2] = (Startx + xsize) / float(!d.x_vsize)
    ;  pos[3] = (Starty + ysize) / float(!d.y_vsize)
    ;  imdisp, remap, pos=pos, /usepos, /noscale
    ;  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
    ;    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    ;    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    ;    latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
    ;  fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[-2, 2], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    ;    color=fsc_color('white'),/horizontal,title=colorbar_title
    ;  !p.multi = 0
    ;  device, retain=2
    ;  WRITE_PNG, 'ESA'+num+'diff_map_15_20'+names[restarri], TVRD(/TRUE)
  
    
  
  
  
  endfor


 all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []

    endfor
  
 

  







end
