pro lrs_8feb_sub_zones_esa6_new_maxflux

  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []



  ;Upwind center (Ref: McComas et al. 2015)
  nose_lon = 180.+75.7
  ;nose_lon = +75.7
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

  b_lon = 226.99
  b_lat = 34.82 ; Eric's 2016 paper B field direction
  b_lon_ii = 360-b_lon

  load_ibex_color_table

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat

  cbmax = [1200,800,200,140,60,18]
  
  pf = 0.55 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  mid_arr = ['A_20', 'A_20', 'B_20', 'B_20']
  ;last_arr = ['B_aram.sav', 'B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  last_arr = ['B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  names = [ 'AB_ram', 'BA_antiram', 'BA_ram']
  ;names = ['AB_antiram', 'AB_ram', 'BA_antiram', 'BA_ram']

  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/asurv_map_04-05-2023/surv_map.sav
  ;sp = surv_struct.YEARLY_SURV_SC_RAM

  for restarri = 0, 1 do begin

    for a = 11, 22 do begin
      y = STRTRIM(a, 2)
      z = STRTRIM(a+1, 2)


      
      ;restore, '/Users/nwalia/data/RS_8Aug23/cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]
      ;restore, '/Users/nwalia/data/Data&RS_15Mar24/data/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]
      ;restore, '/Users/nwalia/data/Data&RS_15Mar24/data_post/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]
      restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]
      ;restore, '/Users/nwalia/data/svgp_tot_and_gdf/ribbon_cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]


      ;all_ESA6 = [all_ESA6, ESA6_GDF_MAP+ESA6_RBN_MAP]
      ;all_ESA5 = [all_ESA5, ESA5_GDF_MAP+ESA5_RBN_MAP]
      all_ESA6 = [all_ESA6, ESA6_GDF_MAP]
      ;all_ESA4 = [all_ESA4, ESA4_GDF_MAP]
      ;all_ESA5 = [all_ESA5, ESA5_GDF_MAP]

    endfor



    l=180
    m=90
    ii=6
    ;ii=5
    ;ii=4
    
    



    ;for i = 2, 6 do begin
    ;for ii = 6, 7 do begin
    ;for ii = 5, 6 do begin
    
    
      num = STRTRIM(ii, 1)
      void = execute('ESA'+num+'_11 = reverse(all_ESA'+num+'[0:l-1, 0:m-1])') ; not difference, just ESA6
      void = execute('ESA'+num+'_12 = reverse(all_ESA'+num+'[l:l*2-1, 0:m-1])')
      void = execute('ESA'+num+'_13 = reverse(all_ESA'+num+'[l*2:l*3-1, 0:m-1])')
      void = execute('ESA'+num+'_14 = reverse(all_ESA'+num+'[l*3:l*4-1, 0:m-1])')
      void = execute('ESA'+num+'_15 = reverse(all_ESA'+num+'[l*4:l*5-1, 0:m-1])')
      void = execute('ESA'+num+'_16 = reverse(all_ESA'+num+'[l*5:l*6-1, 0:m-1])')
      void = execute('ESA'+num+'_21 = reverse(all_ESA'+num+'[l*6:l*7-1, 0:m-1])')
      void = execute('ESA'+num+'_22 = reverse(all_ESA'+num+'[l*7:l*8-1, 0:m-1])')
      ;void = execute('ESA'+num+'_15 = reverse(all_ESA'+num+'[0:l-1, 0:m-1])') ; not difference, just ESA6
      ;void = execute('ESA'+num+'_16 = reverse(all_ESA'+num+'[l:l*2-1, 0:m-1])')
      ;void = execute('ESA'+num+'_17 = reverse(all_ESA'+num+'[l*2:l*3-1, 0:m-1])')
      ;void = execute('ESA'+num+'_18 = reverse(all_ESA'+num+'[l*3:l*4-1, 0:m-1])')
      ;void = execute('ESA'+num+'_19 = reverse(all_ESA'+num+'[l*4:l*5-1, 0:m-1])')
      ;void = execute('ESA'+num+'_20 = reverse(all_ESA'+num+'[l*5:l*6-1, 0:m-1])')
     ; void = execute('ESA'+num+'_21 = reverse(all_ESA'+num+'[l*6:l*7-1, 0:m-1])')
      ;void = execute('ESA'+num+'_22 = reverse(all_ESA'+num+'[l*7:l*8-1, 0:m-1])')

      ;ca= [100, 50, 22, 10, 5]
      ;ca= [100, 50, 22, 10, 4]
      ;ca= [100, 50, 22, 10, 3]
      ca= [100, 50, 22, 10, 5]

      ;cm = 100
      ;cm = 45
      cm = 15


;      oyn = 16
;      oynn= oyn + 1
;      yn = STRTRIM(oyn, 1)
;      ynn = STRTRIM(oynn, 1)
;
;      void = execute('pos_arr'+num+'_'+yn+'= intarr(l, m)')
;      void = execute('pos_arr'+num+'_'+ynn+'= intarr(l, m)')
;
;      for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+yn+')) and (loni lt 120) or (loni gt 155) then pos_arr'+num+'_'+yn+'[loni, lati] = 1')
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+yn+')) and (loni gt 120) and (loni lt 155) and (lati lt 15) then pos_arr'+num+'_'+yn+'[loni, lati] = 1')
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] lt pf*max(ESA'+num+'_'+yn+')) then pos_arr'+num+'_'+yn+'[loni, lati] = -1')
;
;        endfor
;      endfor
;
;      for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if (ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni lt 120) or (loni gt 155) then pos_arr'+num+'_'+ynn+'[loni, lati] = 1')
;          void = execute('if (ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni gt 120) and (loni lt 155) and (lati lt 15) then pos_arr'+num+'_'+ynn+'[loni, lati] = 1')
;          void = execute('if (ESA'+num+'_'+ynn+'[loni, lati] lt pf*max(ESA'+num+'_'+ynn+')) then pos_arr'+num+'_'+ynn+'[loni, lati] = -1')
;
;        endfor
;      endfor
;
;      d=[]
;      d_o=[]
;      dd=[]
;      e=[]
;
;      for j = 0, m-1 do begin
;        for i = 0, l-1 do begin
;
;
;          ;void = execute('if (pos_arr'+num+'_'+ynn+'[i,j] eq 1) and (pos_arr'+num+'_'+yn+'[i,j] eq -1)  then d = [d,i]')
;          void = execute('if (pos_arr'+num+'_'+ynn+'[i,j] eq 1) then d = [d,i]')
;        endfor
;
;        if n_elements(d) gt 0 then dd= [dd, d]
;        if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;        d=[]
;        d_o=[]
;      endfor


        ozn = 22
      oznn= ozn + 1
      zn = STRTRIM(ozn, 1)
      znn = STRTRIM(oznn, 1)
      fsc_colorbar, charsize=6,charthick=15.,position=[.1, .76, .9, .8], range=[0, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
        color=fsc_color('white'),/horizontal
      !p.multi = 0
      device, retain=3

      WRITE_PNG, 'cl_bv_mf_sub_ESA'+num+'.png', TVRD(/TRUE)

      
      
        ;ozn = 22
       ; oznn= ozn + 1
        ;zn = STRTRIM(ozn, 1)
        ;znn = STRTRIM(oznn, 1)

        ;void = execute('ascii_map=ESA'+num+'_'+zn)
        ;imSize=SIZE(ascii_map)
        ;magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
        ;this_map = bytscl(magnifiedImg,  min = 0, max = cm );, top=255)
        ;MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.2,0.95,0.95],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
        
        ;remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
       ; pos = fltarr(4)
        ;pos[0] = Startx / float(!d.x_vsize)
       ; pos[1] = Starty / float(!d.y_vsize)
       ; pos[2] = (Startx + xsize) / float(!d.x_vsize)
       ; pos[3] = (Starty + ysize) / float(!d.y_vsize)
       ; imdisp, remap, pos=pos, /usepos, /noscale
       ; MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
       ;   lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
       ;   lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
       ;   latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6

       ; !p.multi = 0
       ; device, retain=2


    



       ; bv = GreatCircle([nose_lon, nose_lat], [b_lon,b_lat])
       ; oplot, 360-bv[0,*], bv[1,*], color = fsc_color("black"), thick=2
       ; oplot, [360.-nose_lon, 360.-b_lon], [nose_lat, b_lat], color = fsc_color("black"), psym = 1, thick = 10
       
        ;WRITE_PNG, 'bv_mf_sub_ESA'+num+'_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
        
        
      ;stop

      ;for ozn = 16, 22 do begin
          ;ozn = 22 
      ;  oznn= ozn + 1
       ; zn = STRTRIM(ozn, 1)
      ;  znn = STRTRIM(oznn, 1)

      ;  void = execute('ascii_map=ESA'+num+'_'+zn)
       ; colorbar_title = 'ESA'+num+'_'+zn+names[restarri]
      ;  imSize=SIZE(ascii_map)
      ;  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
       ; this_map = bytscl(magnifiedImg,  min = 0, max = cm );, top=255)
      ;  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.2,0.95,0.95],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE;MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.00,0.95,1.00],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
       ; remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
       ; pos = fltarr(4)
       ; pos[0] = Startx / float(!d.x_vsize)
       ; pos[1] = Starty / float(!d.y_vsize)
       ; pos[2] = (Startx + xsize) / float(!d.x_vsize)
       ; pos[3] = (Starty + ysize) / float(!d.y_vsize)
       ; imdisp, remap, pos=pos, /usepos, /noscale
       ; MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
       ;   lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
        ;  lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
        ;  latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
       
       ; !p.multi = 0
       ; device, retain=2
        
        
        

        
        ;bv = GreatCircle([nose_lon, nose_lat], [b_lon,b_lat])
        ;void = execute('oplot, 360-bv[0,*], bv[1,*], color = fsc_color("black")')
        ;void = execute('oplot, [nose_lon, nose_lon], [nose_lat, nose_lat], psym = 1, color = fsc_color("red")')
;stop
       ; WRITE_PNG, 'tail_bv_mf_sub_ESA'+num+'_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
        
     ; endfor
      
     ;stop
        
      

      oyn = 12
      oynn= oyn + 1
      yn = STRTRIM(oyn, 1)
      ynn = STRTRIM(oynn, 1)

      void = execute('pos_arr'+num+'_'+yn+'= intarr(l, m)')
      void = execute('pos_arr'+num+'_'+ynn+'= intarr(l, m)')

;      for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni lt 120) or (loni gt 155) then pos_arr'+num+'_'+yn+'[loni, lati] = 1')
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni gt 120) and (loni lt 155) and (lati lt 15) then pos_arr'+num+'_'+yn+'[loni, lati] = 1')
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni gt 120) and (loni lt 155) and (lati ge 15) then pos_arr'+num+'_'+yn+'[loni, lati] = -1')
;          void = execute('if (ESA'+num+'_'+yn+'[loni, lati] lt pf*max(ESA'+num+'_'+ynn+')) then pos_arr'+num+'_'+yn+'[loni, lati] = -1')
;
;        endfor
;      endfor
;
;      for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+') then pos_arr'+num+'_'+ynn+'[loni, lati] = 1 else pos_arr'+num+'_'+ynn+'[loni, lati] = -1')
;          ;void = execute('if (ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni gt 115) and (loni lt 180) and (lati ge 44) then pos_arr'+num+'_'+ynn+'[loni, lati] = -1')
;          void = execute('if (ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+')) and (loni gt 115) and (loni lt 180) and (lati ge 20) then pos_arr'+num+'_'+ynn+'[loni, lati] = -1')
;
;
;        endfor
;      endfor


      for lati = 0, m-1 do begin
      for loni = 0, l-1 do begin

      void = execute('if ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+') then pos_arr'+num+'_'+yn+'[loni, lati] = 1 else pos_arr'+num+'_'+yn+'[loni, lati] = -1')

    endfor
    endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+') then pos_arr'+num+'_'+ynn+'[loni, lati] = 1 else pos_arr'+num+'_'+ynn+'[loni, lati] = -1')

    endfor
    endfor

      d=[]
      d_o=[]
      dd=[]
      e=[]

      for j = 0, m-1 do begin
        for i = 0, l-1 do begin


          void = execute('if (pos_arr'+num+'_'+ynn+'[i,j] eq 1) and (pos_arr'+num+'_'+yn+'[i,j] eq -1)  then d = [d,i]')
        endfor

        if n_elements(d) gt 0 then dd= [dd, d]
        if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
        d=[]
        d_o=[]
      endfor

      for ozn = 12, 15 do begin
        oznn= ozn + 1
        zn = STRTRIM(ozn, 1)
        znn = STRTRIM(oznn, 1)

        void = execute('ascii_map=ESA'+num+'_'+zn)
        colorbar_title = 'ESA'+num+'_'+zn+names[restarri]
        imSize=SIZE(ascii_map)
        magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
        this_map = bytscl(magnifiedImg,  min = 0, max = cm );, top=255)
        MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
        remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
        pos = fltarr(4)
        pos[0] = Startx / float(!d.x_vsize)
        pos[1] = Starty / float(!d.y_vsize)
        pos[2] = (Startx + xsize) / float(!d.x_vsize)
        pos[3] = (Starty + ysize) / float(!d.y_vsize)
        imdisp, remap, pos=pos, /usepos, /noscale

        
        void = execute('oplot, LON_ARR[dd], LAT_ARR[e], psym = 1, color = fsc_color("brown")')


        MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
          lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
          lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
          latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
        fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[0, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
          color=fsc_color('white'),/horizontal,title=colorbar_title
        !p.multi = 0
        device, retain=2

        WRITE_PNG, 'mesh_ESA'+num+'_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)

      endfor

stop


      for oyn = 18, 22 do begin
        oynn= oyn + 1
        yn = STRTRIM(oyn, 1)
        ynn = STRTRIM(oynn, 1)

        void = execute('pos_arr'+num+'_'+yn+'= intarr(l, m)')
        void = execute('pos_arr'+num+'_'+ynn+'= intarr(l, m)')

        for lati = 0, m-1 do begin
          for loni = 0, l-1 do begin

            void = execute('if ESA'+num+'_'+yn+'[loni, lati] ge pf*max(ESA'+num+'_'+yn+') then pos_arr'+num+'_'+yn+'[loni, lati] = 1 else pos_arr'+num+'_'+yn+'[loni, lati] = -1')

          endfor
        endfor

        for lati = 0, m-1 do begin
          for loni = 0, l-1 do begin

            void = execute('if ESA'+num+'_'+ynn+'[loni, lati] ge pf*max(ESA'+num+'_'+ynn+') then pos_arr'+num+'_'+ynn+'[loni, lati] = 1 else pos_arr'+num+'_'+ynn+'[loni, lati] = -1')

          endfor
        endfor

        d=[]
        dd=[]
        e=[]

        for j = 0, m-1 do begin
          for i = 0, l-1 do begin

            void = execute('if (pos_arr'+num+'_'+ynn+'[i,j] eq 1) and (pos_arr'+num+'_'+yn+'[i,j] eq -1)  then d = [d,i]')
          endfor
          if n_elements(d) gt 0 then dd= [dd, d]
          if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
          d=[]
        endfor

        for ozn = 16, 22 do begin
          oznn= ozn + 1
          zn = STRTRIM(ozn, 1)
          znn = STRTRIM(oznn, 1)

          void = execute('ascii_map=ESA'+num+'_'+zn)
          colorbar_title = 'ESA'+num+'_'+zn+names[restarri]
          imSize=SIZE(ascii_map)
          magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
          this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
          MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
          remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
          pos = fltarr(4)
          pos[0] = Startx / float(!d.x_vsize)
          pos[1] = Starty / float(!d.y_vsize)
          pos[2] = (Startx + xsize) / float(!d.x_vsize)
          pos[3] = (Starty + ysize) / float(!d.y_vsize)
          imdisp, remap, pos=pos, /usepos, /noscale

          ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
          void = execute('oplot, LON_ARR[dd], LAT_ARR[e], psym = 1, color = fsc_color("brown")')


          MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
            lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
            lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
            latlab=0,glinestyle=0, glinethick=1.25, charthick=10, charsize=3.5
          fsc_colorbar,/overplot,position=[.1, .06, .9, .1], charsize=2,charthick=2., range=[0, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
            color=fsc_color('white'),/horizontal,title=colorbar_title
          !p.multi = 0
          device, retain=2


          WRITE_PNG, 'mf_sub_ESA'+num+'_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
        endfor

      endfor

   
   stop



   ; reverse
  ;endfor
  

  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []

endfor

end