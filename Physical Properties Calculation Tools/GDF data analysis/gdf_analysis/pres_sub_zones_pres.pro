pro pres_sub_zones_pres

 ;restore, 'RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
 ;restore, 'p_RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
 ;restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
 
 restore, '/Users/nwalia/IDLWorkspace/ram_pres_fract_Mar.sav'
 



  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []



  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  nose_lat = +5.1
 
  ;Tail center (Ref: McComas et al. 2015)
  ;nose_lon = 75.7
  ;nose_lat = +5.1

  resolution = 2.0 ;degrees
  mag_factor=5.
  !p.position=0
  !p.font=1
  plots_across=1
  plots_down=1
  !p.multi=[0,plots_across,plots_down,0,0]
  device, retain=2
  ;loadct, 33



  b_lon = 226.99
  b_lat = 34.82

  load_ibex_color_table

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat

  

  pf = 0.6;0.5 ; percentage factor to be multiplied with max pressure
  pfs = STRTRIM(pf, 2)

  mid_arr = ['A_20', 'A_20', 'B_20', 'B_20']
  ;last_arr = ['B_aram.sav', 'B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  last_arr = ['B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  names = [ 'AB_ram', 'BA_antiram', 'BA_ram']
  ;names = ['AB_antiram', 'AB_ram', 'BA_antiram', 'BA_ram']

;for restarri = 0, 1 do begin

    restarri = 0
    
    l=180
    m=90
    ii=6
    ;ii=5

    for yo = 11, 22 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    endfor
    
    
    ca= [100, 50, 22, 10, 5]

    cm = 40
    
;    
;    oyn = 11
;    oynn= oyn + 1
;    yn = STRTRIM(oyn, 1)
;    ynn = STRTRIM(oynn, 1)
;
;    void = execute('pos_arr_'+yn+'= intarr(l, m)')
;    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
;
;    for lati = 0, m-1 do begin
;      for loni = 0, l-1 do begin
;
;        void = execute('if (Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+')) and (loni lt 110) or (loni gt 160) then pos_arr_'+yn+'[loni, lati] = 1')
;        void = execute('if (Pres_all_'+yn+'[loni, lati] lt pf*max(Pres_all_'+yn+')) then pos_arr_'+yn+'[loni, lati] = -1')
;
;      endfor
;    endfor
;
;    d=[]
;    d_o=[]
;    dd=[]
;    e=[]
;
;    for j = 0, m-1 do begin
;      for i = 0, l-1 do begin
;
;
;        void = execute('if (pos_arr_'+yn+'[i,j] eq 1) then d = [d,i]')
;      endfor
;
;      if n_elements(d) gt 0 then dd= [dd, d]
;      if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;      d=[]
;      d_o=[]
;    endfor
    
    ozn = 22
    oznn= ozn + 1
    zn = STRTRIM(ozn, 1)
    znn = STRTRIM(oznn, 1)
    fsc_colorbar, charsize=6,charthick=15.,position=[.1, .76, .9, .8], range=[0, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
      color=fsc_color('white'),/horizontal
    !p.multi = 0
    device, retain=3

    WRITE_PNG, 'cl_mP0.6_sub_Pres_.png', TVRD(/TRUE)

;    for ozn = 11, 15 do begin
;      oznn= ozn + 1
;      zn = STRTRIM(ozn, 1)
;      znn = STRTRIM(oznn, 1)
;
;      void = execute('ascii_map = Pres_all_'+zn+'')
;      colorbar_title = 'Pres_'+zn+names[restarri]
;      imSize=SIZE(ascii_map)
;      magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
;      this_map = bytscl(magnifiedImg,  min = 0, max = cm );, top=255)
;      MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.2,0.95,0.95],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
;      remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
;      pos = fltarr(4)
;      pos[0] = Startx / float(!d.x_vsize)
;      pos[1] = Starty / float(!d.y_vsize)
;      pos[2] = (Startx + xsize) / float(!d.x_vsize)
;      pos[3] = (Starty + ysize) / float(!d.y_vsize)
;      imdisp, remap, pos=pos, /usepos, /noscale
;
;
;      ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
;      void = execute('oplot, LON_ARR[dd], LAT_ARR[e], psym = 1, color = fsc_color("brown")')
;
;
;
;      MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
;          lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
;          lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
;          latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
;      
;      !p.multi = 0
;      device, retain=2
;      
;  
;      
;      WRITE_PNG, 'p_mP0.6_sub_Pres_'+yn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
;    endfor
;    
;stop

   ;for oyn = 11, 14 do begin
    oyn = 14
     oynn= oyn + 1
      yn = STRTRIM(oyn, 1)
      ynn = STRTRIM(oynn, 1)

      void = execute('pos_arr_'+yn+'= intarr(l, m)')
      void = execute('pos_arr_'+ynn+'= intarr(l, m)')

      for lati = 0, m-1 do begin
        for loni = 0, l-1 do begin

          void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') and (loni lt 110) then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
          ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
         
          

        endfor
      endfor

;     for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')
;
;        endfor
;      endfor

      d=[]
      dd=[]
      e=[]

      for j = 0, m-1 do begin
        for i = 0, l-1 do begin

          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then d = [d,i]')
          void = execute('if (pos_arr_'+yn+'[i,j] eq 1) then d = [d,i]')
        endfor
        if n_elements(d) gt 0 then dd= [dd, d]
        if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
        d=[]
      endfor

      for ozn = 11, 15 do begin
        oznn= ozn + 1
        zn = STRTRIM(ozn, 1)
        znn = STRTRIM(oznn, 1)

        void = execute('ascii_map = Pres_all_'+zn+'')
        colorbar_title = 'Pres_'+zn+names[restarri]
        imSize=SIZE(ascii_map)
        magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
        this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
        MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.2,0.95,0.95],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
        remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
        pos = fltarr(4)
        pos[0] = Startx / float(!d.x_vsize)
        pos[1] = Starty / float(!d.y_vsize)
        pos[2] = (Startx + xsize) / float(!d.x_vsize)
        pos[3] = (Starty + ysize) / float(!d.y_vsize)
        imdisp, remap, pos=pos, /usepos, /noscale

        ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
        ;void = execute('oplot, LON_ARR[dd], LAT_ARR[e], psym = 1, color = fsc_color("brown")')


        MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
          lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
          lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
          latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
        !p.multi = 0
        device, retain=2

;stop
        WRITE_PNG, 'p_mp0.6_sub_Pres_'+yn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
      endfor

    ;endfor


   



    ; reverse
    ;endfor


    all_ESA2= []
    all_ESA3= []
    all_ESA4= []
    all_ESA5= []
    all_ESA6= []

  ;endfor

end

