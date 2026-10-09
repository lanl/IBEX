pro zone2_sep_speci

  ;restore, 'RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
  ;restore, 'p_RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
  restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'



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
  ;loadct, 20
  loadct, 0



  b_lon = 226.99
  b_lat = 34.82

  ;load_ibex_color_table

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat

  cbmax = [1200,800,200,140,60,18]

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


  for yo = 15, 22 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('gamma_'+yos+'= fltarr(l, m)')
    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin
        void = execute('Flux_'+yos+' = [(ESA2_intpl[yo-9, i,j]), (ESA3_intpl[yo-9, i,j]), (ESA4_intpl[yo-9, i,j]), (ESA5_intpl[yo-9, i,j]), (ESA6_intpl[yo-9, i,j])]')
        void = execute('fin_arr'+yos+'= where(finite(Flux_'+yos+'))')
        Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
        void = execute('f_'+yos+' = LINFIT(alog(Energy[fin_arr'+yos+']), alog(Flux_'+yos+'[fin_arr'+yos+']))')
        void = execute('gamma_'+yos+'[i,j] =  abs(f_'+yos+'[1])')
      endfor
    endfor
    
    void = execute('gamma_rev'+yos+'= fltarr(l, m)')
    void = execute('gamma_rev'+yos+' =  reverse(gamma_'+yos+')')

  endfor


  ;stop

  ca= [100, 50, 22, 10, 5]

  cm = 45
  
  
  
  oyn = 16 ; zone 2 behavior in the year before pressure pulse hits
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)
  ny = 15
  nys = STRTRIM(ny, 1)

  void = execute('pos_arr_'+yn+'= intarr(l, m)')
  void = execute('pos_arr_'+ynn+'= intarr(l, m)')

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
      void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')



    endfor
  endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    endfor
  endfor
  
  d=[]
  d1 = []
  d2 = []
  d3 = []
  d4 = []
  d5 = []
  d6 = []
  d7 = []
  d8 = []
  d_o=[]
  dd=[]
  dd1=[]
  dd2=[]
  dd3=[]
  dd4=[]
  dd5=[]
  dd6=[]
  dd7=[]
  dd8=[]
  e=[]
  e1=[]
  e2=[]
  e3=[]
  e4=[]
  e5=[]
  e6=[]
  e7=[]
  e8=[]
  si1 = 1.25
  si2 = 1.5
  si3 = 1.75
  si4 = 2.0
  si5 = 2.25
  si6 = 2.5
  si7 = 2.75

  for j = 0, m-1 do begin
    for i = 0, l-1 do begin

      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si7) then d1 = [d1,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si6) and (gamma_rev'+nys+'[i,j] lt si7) then d2 = [d2,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si5) and (gamma_rev'+nys+'[i,j] lt si6) then d3 = [d3,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si4) and (gamma_rev'+nys+'[i,j] lt si5) then d4 = [d4,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si3) and (gamma_rev'+nys+'[i,j] lt si4) then d5 = [d5,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) and (gamma_rev'+nys+'[i,j] lt si3) then d6 = [d6,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d7 = [d7,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d8 = [d8,i]')
    endfor



    if n_elements(d) gt 0 then dd= [dd, d]
    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor

    d=[]
    d_o=[]


    if n_elements(d1) gt 0 then dd1= [dd1, d1]
    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor

    d1=[]

    if n_elements(d2) gt 0 then dd2= [dd2, d2]
    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor

    d2=[]

    if n_elements(d3) gt 0 then dd3= [dd3, d3]
    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor

    d3=[]

    if n_elements(d4) gt 0 then dd4= [dd4, d4]
    if n_elements(d4) gt 0 then for x = 0, n_elements(d4)-1 do begin e4 = [e4, j] & endfor

    d4=[]

    if n_elements(d5) gt 0 then dd5= [dd5, d5]
    if n_elements(d5) gt 0 then for x = 0, n_elements(d5)-1 do begin e5 = [e5, j] & endfor

    d5=[]

    if n_elements(d6) gt 0 then dd6= [dd6, d6]
    if n_elements(d6) gt 0 then for x = 0, n_elements(d6)-1 do begin e6 = [e6, j] & endfor

    d6=[]

    if n_elements(d7) gt 0 then dd7= [dd7, d7]
    if n_elements(d7) gt 0 then for x = 0, n_elements(d7)-1 do begin e7 = [e7, j] & endfor

    d7=[]

    if n_elements(d8) gt 0 then dd8= [dd8, d8]
    if n_elements(d8) gt 0 then for x = 0, n_elements(d8)-1 do begin e8 = [e8, j] & endfor

    d8=[]
  endfor

;  d=[]
;  d1 = []
;  d2 = []
;  d3 = []
;  d_o=[]
;  dd=[]
;  dd1=[]
;  dd2=[]
;  dd3=[]
;  e=[]
;  e1=[]
;  e2=[]
;  e3=[]
;  si1 = 2.0
;  si2 = 2.3
;
;  for j = 0, m-1 do begin
;    for i = 0, l-1 do begin
;
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) then d1 = [d1,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d2 = [d2,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d3 = [d3,i]')
;    endfor
;
;
;
;    if n_elements(d) gt 0 then dd= [dd, d]
;    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;
;    d=[]
;    d_o=[]
;
;
;    if n_elements(d1) gt 0 then dd1= [dd1, d1]
;    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor
;
;    d1=[]
;
;    if n_elements(d2) gt 0 then dd2= [dd2, d2]
;    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor
;
;    d2=[]
;
;    if n_elements(d3) gt 0 then dd3= [dd3, d3]
;    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor
;
;    d3=[]
;  endfor

  ozn = 15
  ;for ozn = 15, 22 do begin
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)

  void = execute('ascii_map = Pres_all_'+nys+'')
  colorbar_title = 'Pres_'+zn+names[restarri]
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale

  
  ;void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 1.9,  color = fsc_color("green")')
  ;void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("orange")')
  ;void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("olive")')
  void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 2.1, color = fsc_color("black")')
  void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("blue")')
  void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("cyan")')
  void = execute('oplot, LON_ARR[dd4], LAT_ARR[e4], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("green")')
  void = execute('oplot, LON_ARR[dd5], LAT_ARR[e5], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("yellow")')
  void = execute('oplot, LON_ARR[dd6], LAT_ARR[e6], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd7], LAT_ARR[e7], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("red")')
  void = execute('oplot, LON_ARR[dd8], LAT_ARR[e8], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("violet red")')
  


  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
  !p.multi = 0
  device, retain=2


  WRITE_PNG, 'dd_p_mp0.6_sub_Pres_'+yn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)

  
  oyn = 16 ; zone 2 behavior in the year before pressure pulse hits
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)

  void = execute('pos_arr_'+yn+'= intarr(l, m)')
  void = execute('pos_arr_'+ynn+'= intarr(l, m)')

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
      void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')



    endfor
  endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    endfor
  endfor
  
  d=[]
  d1 = []
  d2 = []
  d3 = []
  d4 = []
  d5 = []
  d6 = []
  d7 = []
  d8 = []
  d_o=[]
  dd=[]
  dd1=[]
  dd2=[]
  dd3=[]
  dd4=[]
  dd5=[]
  dd6=[]
  dd7=[]
  dd8=[]
  e=[]
  e1=[]
  e2=[]
  e3=[]
  e4=[]
  e5=[]
  e6=[]
  e7=[]
  e8=[]
  si1 = 1.25
  si2 = 1.5
  si3 = 1.75
  si4 = 2.0
  si5 = 2.25
  si6 = 2.5
  si7 = 2.75

  for j = 0, m-1 do begin
    for i = 0, l-1 do begin

      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si7) then d1 = [d1,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si6) and (gamma_rev'+yn+'[i,j] lt si7) then d2 = [d2,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si5) and (gamma_rev'+yn+'[i,j] lt si6) then d3 = [d3,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si4) and (gamma_rev'+yn+'[i,j] lt si5) then d4 = [d4,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si3) and (gamma_rev'+yn+'[i,j] lt si4) then d5 = [d5,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si2) and (gamma_rev'+yn+'[i,j] lt si3) then d6 = [d6,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si1) and (gamma_rev'+yn+'[i,j] lt si2) then d7 = [d7,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] lt si1) then d8 = [d8,i]')
    endfor



    if n_elements(d) gt 0 then dd= [dd, d]
    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor

    d=[]
    d_o=[]


    if n_elements(d1) gt 0 then dd1= [dd1, d1]
    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor

    d1=[]

    if n_elements(d2) gt 0 then dd2= [dd2, d2]
    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor

    d2=[]

    if n_elements(d3) gt 0 then dd3= [dd3, d3]
    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor

    d3=[]

    if n_elements(d4) gt 0 then dd4= [dd4, d4]
    if n_elements(d4) gt 0 then for x = 0, n_elements(d4)-1 do begin e4 = [e4, j] & endfor

    d4=[]

    if n_elements(d5) gt 0 then dd5= [dd5, d5]
    if n_elements(d5) gt 0 then for x = 0, n_elements(d5)-1 do begin e5 = [e5, j] & endfor

    d5=[]

    if n_elements(d6) gt 0 then dd6= [dd6, d6]
    if n_elements(d6) gt 0 then for x = 0, n_elements(d6)-1 do begin e6 = [e6, j] & endfor

    d6=[]

    if n_elements(d7) gt 0 then dd7= [dd7, d7]
    if n_elements(d7) gt 0 then for x = 0, n_elements(d7)-1 do begin e7 = [e7, j] & endfor

    d7=[]

    if n_elements(d8) gt 0 then dd8= [dd8, d8]
    if n_elements(d8) gt 0 then for x = 0, n_elements(d8)-1 do begin e8 = [e8, j] & endfor

    d8=[]
  endfor

;  d=[]
;  d1 = []
;  d2 = []
;  d3 = []
;  d_o=[]
;  dd=[]
;  dd1=[]
;  dd2=[]
;  dd3=[]
;  e=[]
;  e1=[]
;  e2=[]
;  e3=[]
;  si1 = 1.8
;  si2 = 2.05
;
;  for j = 0, m-1 do begin
;    for i = 0, l-1 do begin
;
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si2) then d1 = [d1,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] ge si1) and (gamma_rev'+yn+'[i,j] lt si2) then d2 = [d2,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+yn+'[i,j] lt si1) then d3 = [d3,i]')
;    endfor
;
;
;
;    if n_elements(d) gt 0 then dd= [dd, d]
;    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;
;    d=[]
;    d_o=[]
;
;
;    if n_elements(d1) gt 0 then dd1= [dd1, d1]
;    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor
;
;    d1=[]
;
;    if n_elements(d2) gt 0 then dd2= [dd2, d2]
;    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor
;
;    d2=[]
;
;    if n_elements(d3) gt 0 then dd3= [dd3, d3]
;    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor
;
;    d3=[]
;  endfor

  ozn = 16
  ;for ozn = 15, 22 do begin
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)

  void = execute('ascii_map = Pres_all_'+zn+'')
  colorbar_title = 'Pres_'+zn+names[restarri]
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale

  
  ;void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("green")')
  ;void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("yellow")')
  ;void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 2.1, color = fsc_color("black")')
  void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("blue")')
  void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("cyan")')
  void = execute('oplot, LON_ARR[dd4], LAT_ARR[e4], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("green")')
  void = execute('oplot, LON_ARR[dd5], LAT_ARR[e5], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("yellow")')
  void = execute('oplot, LON_ARR[dd6], LAT_ARR[e6], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd7], LAT_ARR[e7], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("red")')
  void = execute('oplot, LON_ARR[dd8], LAT_ARR[e8], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("violet red")')
  


  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
  !p.multi = 0
  device, retain=2


  WRITE_PNG, 'dd_p_mp0.6_sub_Pres_'+yn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
  
 
  oyn = 16
  ;for oyn = 16, 21 do begin
  ;for oyn = 16, 17 do begin
  ;for oyn = 17, 18 do begin
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)

  void = execute('pos_arr_'+yn+'= intarr(l, m)')
  void = execute('pos_arr_'+ynn+'= intarr(l, m)')

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
      void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')



    endfor
  endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    endfor
  endfor
  
  d=[]
  d1 = []
  d2 = []
  d3 = []
  d4 = []
  d5 = []
  d6 = []
  d7 = []
  d8 = []
  d_o=[]
  dd=[]
  dd1=[]
  dd2=[]
  dd3=[]
  dd4=[]
  dd5=[]
  dd6=[]
  dd7=[]
  dd8=[]
  e=[]
  e1=[]
  e2=[]
  e3=[]
  e4=[]
  e5=[]
  e6=[]
  e7=[]
  e8=[]
  si1 = 1.25
  si2 = 1.5
  si3 = 1.75
  si4 = 2.0
  si5 = 2.25
  si6 = 2.5
  si7 = 2.75

  for j = 0, m-1 do begin
    for i = 0, l-1 do begin

      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si7) then d1 = [d1,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si6) and (gamma_rev'+ynn+'[i,j] lt si7) then d2 = [d2,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si5) and (gamma_rev'+ynn+'[i,j] lt si6) then d3 = [d3,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si4) and (gamma_rev'+ynn+'[i,j] lt si5) then d4 = [d4,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si3) and (gamma_rev'+ynn+'[i,j] lt si4) then d5 = [d5,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si2) and (gamma_rev'+ynn+'[i,j] lt si3) then d6 = [d6,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si1) and (gamma_rev'+ynn+'[i,j] lt si2) then d7 = [d7,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] lt si1) then d8 = [d8,i]')
    endfor

    if n_elements(d) gt 0 then dd= [dd, d]
    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor

    d=[]
    d_o=[]


    if n_elements(d1) gt 0 then dd1= [dd1, d1]
    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor

    d1=[]

    if n_elements(d2) gt 0 then dd2= [dd2, d2]
    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor

    d2=[]

    if n_elements(d3) gt 0 then dd3= [dd3, d3]
    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor

    d3=[]

    if n_elements(d4) gt 0 then dd4= [dd4, d4]
    if n_elements(d4) gt 0 then for x = 0, n_elements(d4)-1 do begin e4 = [e4, j] & endfor

    d4=[]

    if n_elements(d5) gt 0 then dd5= [dd5, d5]
    if n_elements(d5) gt 0 then for x = 0, n_elements(d5)-1 do begin e5 = [e5, j] & endfor

    d5=[]

    if n_elements(d6) gt 0 then dd6= [dd6, d6]
    if n_elements(d6) gt 0 then for x = 0, n_elements(d6)-1 do begin e6 = [e6, j] & endfor

    d6=[]

    if n_elements(d7) gt 0 then dd7= [dd7, d7]
    if n_elements(d7) gt 0 then for x = 0, n_elements(d7)-1 do begin e7 = [e7, j] & endfor

    d7=[]

    if n_elements(d8) gt 0 then dd8= [dd8, d8]
    if n_elements(d8) gt 0 then for x = 0, n_elements(d8)-1 do begin e8 = [e8, j] & endfor

    d8=[]
  endfor

;  d=[]
;  d1 = []
;  d2 = []
;  d3 = []
;  d_o=[]
;  dd=[]
;  dd1=[]
;  dd2=[]
;  dd3=[]
;  e=[]
;  e1=[]
;  e2=[]
;  e3=[]
;  si1 = 1.75
;  si2 = 1.95
;
;  for j = 0, m-1 do begin
;    for i = 0, l-1 do begin
;
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si2) then d1 = [d1,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] ge si1) and (gamma_rev'+ynn+'[i,j] lt si2) then d2 = [d2,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+ynn+'[i,j] lt si1) then d3 = [d3,i]')
;    endfor
;
;
;
;    if n_elements(d) gt 0 then dd= [dd, d]
;    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;
;    d=[]
;    d_o=[]
;
;
;    if n_elements(d1) gt 0 then dd1= [dd1, d1]
;    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor
;
;    d1=[]
;
;    if n_elements(d2) gt 0 then dd2= [dd2, d2]
;    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor
;
;    d2=[]
;
;    if n_elements(d3) gt 0 then dd3= [dd3, d3]
;    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor
;
;    d3=[]
;  endfor

  ozn = 16
  ;for ozn = 15, 22 do begin
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)

  void = execute('ascii_map = Pres_all_'+ynn+'')
  colorbar_title = 'Pres_'+zn+names[restarri]
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale

  
   ;void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("green")')
  ;void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("yellow")')
  ;void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 2.1, color = fsc_color("black")')
  void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("blue")')
  void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("cyan")')
  void = execute('oplot, LON_ARR[dd4], LAT_ARR[e4], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("green")')
  void = execute('oplot, LON_ARR[dd5], LAT_ARR[e5], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("yellow")')
  void = execute('oplot, LON_ARR[dd6], LAT_ARR[e6], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd7], LAT_ARR[e7], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("red")')
  void = execute('oplot, LON_ARR[dd8], LAT_ARR[e8], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("violet red")')


  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
  !p.multi = 0
  device, retain=2


  WRITE_PNG, 'dd_p_mp0.6_sub_Pres_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)


  ;!!!!!!!!!next year!!!!!!!!!!
  oyn = 16
  ;for oyn = 16, 21 do begin
  ;for oyn = 16, 17 do begin
  ;for oyn = 17, 18 do begin
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)
  ny = oyn +2 ; next year
  nys = STRTRIM(ny, 1)

  void = execute('pos_arr_'+yn+'= intarr(l, m)')
  void = execute('pos_arr_'+ynn+'= intarr(l, m)')

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
      void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')



    endfor
  endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    endfor
  endfor
  
  d=[]
  d1 = []
  d2 = []
  d3 = []
  d4 = []
  d5 = []
  d6 = []
  d7 = []
  d8 = []
  d_o=[]
  dd=[]
  dd1=[]
  dd2=[]
  dd3=[]
  dd4=[]
  dd5=[]
  dd6=[]
  dd7=[]
  dd8=[]
  e=[]
  e1=[]
  e2=[]
  e3=[]
  e4=[]
  e5=[]
  e6=[]
  e7=[]
  e8=[]
  si1 = 1.25
  si2 = 1.5
  si3 = 1.75
  si4 = 2.0
  si5 = 2.25
  si6 = 2.5
  si7 = 2.75

  for j = 0, m-1 do begin
    for i = 0, l-1 do begin

      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si7) then d1 = [d1,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si6) and (gamma_rev'+nys+'[i,j] lt si7) then d2 = [d2,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si5) and (gamma_rev'+nys+'[i,j] lt si6) then d3 = [d3,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si4) and (gamma_rev'+nys+'[i,j] lt si5) then d4 = [d4,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si3) and (gamma_rev'+nys+'[i,j] lt si4) then d5 = [d5,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) and (gamma_rev'+nys+'[i,j] lt si3) then d6 = [d6,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d7 = [d7,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d8 = [d8,i]')
    endfor



    if n_elements(d) gt 0 then dd= [dd, d]
    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor

    d=[]
    d_o=[]


    if n_elements(d1) gt 0 then dd1= [dd1, d1]
    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor

    d1=[]

    if n_elements(d2) gt 0 then dd2= [dd2, d2]
    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor

    d2=[]

    if n_elements(d3) gt 0 then dd3= [dd3, d3]
    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor

    d3=[]

    if n_elements(d4) gt 0 then dd4= [dd4, d4]
    if n_elements(d4) gt 0 then for x = 0, n_elements(d4)-1 do begin e4 = [e4, j] & endfor

    d4=[]

    if n_elements(d5) gt 0 then dd5= [dd5, d5]
    if n_elements(d5) gt 0 then for x = 0, n_elements(d5)-1 do begin e5 = [e5, j] & endfor

    d5=[]

    if n_elements(d6) gt 0 then dd6= [dd6, d6]
    if n_elements(d6) gt 0 then for x = 0, n_elements(d6)-1 do begin e6 = [e6, j] & endfor

    d6=[]

    if n_elements(d7) gt 0 then dd7= [dd7, d7]
    if n_elements(d7) gt 0 then for x = 0, n_elements(d7)-1 do begin e7 = [e7, j] & endfor

    d7=[]

    if n_elements(d8) gt 0 then dd8= [dd8, d8]
    if n_elements(d8) gt 0 then for x = 0, n_elements(d8)-1 do begin e8 = [e8, j] & endfor

    d8=[]
  endfor

;  d=[]
;  d1 = []
;  d2 = []
;  d3 = []
;  d_o=[]
;  dd=[]
;  dd1=[]
;  dd2=[]
;  dd3=[]
;  e=[]
;  e1=[]
;  e2=[]
;  e3=[]
;  si1 = 1.6
;  si2 = 1.8
;
;  for j = 0, m-1 do begin
;    for i = 0, l-1 do begin
;
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) then d1 = [d1,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d2 = [d2,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d3 = [d3,i]')
;    endfor
;
;
;
;    if n_elements(d) gt 0 then dd= [dd, d]
;    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;
;    d=[]
;    d_o=[]
;
;
;    if n_elements(d1) gt 0 then dd1= [dd1, d1]
;    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor
;
;    d1=[]
;
;    if n_elements(d2) gt 0 then dd2= [dd2, d2]
;    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor
;
;    d2=[]
;
;    if n_elements(d3) gt 0 then dd3= [dd3, d3]
;    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor
;
;    d3=[]
;  endfor

  ozn = 16
  ;for ozn = 15, 22 do begin
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)

  void = execute('ascii_map = Pres_all_'+nys+'')
  colorbar_title = 'Pres_'+zn+names[restarri]
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale

  
   ;void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("green")')
  ;void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("yellow")')
  ;void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 2.1, color = fsc_color("black")')
  void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("blue")')
  void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("cyan")')
  void = execute('oplot, LON_ARR[dd4], LAT_ARR[e4], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("green")')
  void = execute('oplot, LON_ARR[dd5], LAT_ARR[e5], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("yellow")')
  void = execute('oplot, LON_ARR[dd6], LAT_ARR[e6], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd7], LAT_ARR[e7], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("red")')
  void = execute('oplot, LON_ARR[dd8], LAT_ARR[e8], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("violet red")')


  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
  !p.multi = 0
  device, retain=2


  WRITE_PNG, 'next'+nys+'_dd_p_mp0.6_sub_Pres_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
  
  ;!!!!!!!!!next year!!!!!!!!!!
  oyn = 16
  ;for oyn = 16, 21 do begin
  ;for oyn = 16, 17 do begin
  ;for oyn = 17, 18 do begin
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)
  ny = oyn +3 ; next to next year
  nys = STRTRIM(ny, 1)

  void = execute('pos_arr_'+yn+'= intarr(l, m)')
  void = execute('pos_arr_'+ynn+'= intarr(l, m)')

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
      void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')



    endfor
  endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    endfor
  endfor
  
  d=[]
  d1 = []
  d2 = []
  d3 = []
  d4 = []
  d5 = []
  d6 = []
  d7 = []
  d8 = []
  d_o=[]
  dd=[]
  dd1=[]
  dd2=[]
  dd3=[]
  dd4=[]
  dd5=[]
  dd6=[]
  dd7=[]
  dd8=[]
  e=[]
  e1=[]
  e2=[]
  e3=[]
  e4=[]
  e5=[]
  e6=[]
  e7=[]
  e8=[]
  si1 = 1.25
  si2 = 1.5
  si3 = 1.75
  si4 = 2.0
  si5 = 2.25
  si6 = 2.5
  si7 = 2.75

  for j = 0, m-1 do begin
    for i = 0, l-1 do begin

      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si7) then d1 = [d1,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si6) and (gamma_rev'+nys+'[i,j] lt si7) then d2 = [d2,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si5) and (gamma_rev'+nys+'[i,j] lt si6) then d3 = [d3,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si4) and (gamma_rev'+nys+'[i,j] lt si5) then d4 = [d4,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si3) and (gamma_rev'+nys+'[i,j] lt si4) then d5 = [d5,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) and (gamma_rev'+nys+'[i,j] lt si3) then d6 = [d6,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d7 = [d7,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d8 = [d8,i]')
    endfor



    if n_elements(d) gt 0 then dd= [dd, d]
    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor

    d=[]
    d_o=[]


    if n_elements(d1) gt 0 then dd1= [dd1, d1]
    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor

    d1=[]

    if n_elements(d2) gt 0 then dd2= [dd2, d2]
    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor

    d2=[]

    if n_elements(d3) gt 0 then dd3= [dd3, d3]
    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor

    d3=[]

    if n_elements(d4) gt 0 then dd4= [dd4, d4]
    if n_elements(d4) gt 0 then for x = 0, n_elements(d4)-1 do begin e4 = [e4, j] & endfor

    d4=[]

    if n_elements(d5) gt 0 then dd5= [dd5, d5]
    if n_elements(d5) gt 0 then for x = 0, n_elements(d5)-1 do begin e5 = [e5, j] & endfor

    d5=[]

    if n_elements(d6) gt 0 then dd6= [dd6, d6]
    if n_elements(d6) gt 0 then for x = 0, n_elements(d6)-1 do begin e6 = [e6, j] & endfor

    d6=[]

    if n_elements(d7) gt 0 then dd7= [dd7, d7]
    if n_elements(d7) gt 0 then for x = 0, n_elements(d7)-1 do begin e7 = [e7, j] & endfor

    d7=[]

    if n_elements(d8) gt 0 then dd8= [dd8, d8]
    if n_elements(d8) gt 0 then for x = 0, n_elements(d8)-1 do begin e8 = [e8, j] & endfor

    d8=[]
  endfor

;  d=[]
;  d1 = []
;  d2 = []
;  d3 = []
;  d_o=[]
;  dd=[]
;  dd1=[]
;  dd2=[]
;  dd3=[]
;  e=[]
;  e1=[]
;  e2=[]
;  e3=[]
;  si1 = 1.6
;  si2 = 1.85
;
;  for j = 0, m-1 do begin
;    for i = 0, l-1 do begin
;
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) then d1 = [d1,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d2 = [d2,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d3 = [d3,i]')
;    endfor
;
;
;
;    if n_elements(d) gt 0 then dd= [dd, d]
;    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;
;    d=[]
;    d_o=[]
;
;
;    if n_elements(d1) gt 0 then dd1= [dd1, d1]
;    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor
;
;    d1=[]
;
;    if n_elements(d2) gt 0 then dd2= [dd2, d2]
;    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor
;
;    d2=[]
;
;    if n_elements(d3) gt 0 then dd3= [dd3, d3]
;    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor
;
;    d3=[]
;  endfor

  ozn = 16
  ;for ozn = 15, 22 do begin
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)

  void = execute('ascii_map = Pres_all_'+nys+'')
  colorbar_title = 'Pres_'+zn+names[restarri]
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale

 
  ; void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("green")')
  ;void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("yellow")')
  ;void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 2.1, color = fsc_color("black")')
  void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("blue")')
  void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("cyan")')
  void = execute('oplot, LON_ARR[dd4], LAT_ARR[e4], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("green")')
  void = execute('oplot, LON_ARR[dd5], LAT_ARR[e5], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("yellow")')
  void = execute('oplot, LON_ARR[dd6], LAT_ARR[e6], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd7], LAT_ARR[e7], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("red")')
  void = execute('oplot, LON_ARR[dd8], LAT_ARR[e8], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("violet red")')


  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
  !p.multi = 0
  device, retain=2

  WRITE_PNG, 'next'+nys+'_dd_p_mp0.6_sub_Pres_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
  
  ;!!!!!!!!!next year!!!!!!!!!!
  oyn = 16
  ;for oyn = 16, 21 do begin
  ;for oyn = 16, 17 do begin
  ;for oyn = 17, 18 do begin
  oynn= oyn + 1
  yn = STRTRIM(oyn, 1)
  ynn = STRTRIM(oynn, 1)
  ny = oyn +4 ; next to next year
  nys = STRTRIM(ny, 1)

  void = execute('pos_arr_'+yn+'= intarr(l, m)')
  void = execute('pos_arr_'+ynn+'= intarr(l, m)')

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      ;void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
      void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')



    endfor
  endfor

  for lati = 0, m-1 do begin
    for loni = 0, l-1 do begin

      void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    endfor
  endfor
  
  d=[]
  d1 = []
  d2 = []
  d3 = []
  d4 = []
  d5 = []
  d6 = []
  d7 = []
  d8 = []
  d_o=[]
  dd=[]
  dd1=[]
  dd2=[]
  dd3=[]
  dd4=[]
  dd5=[]
  dd6=[]
  dd7=[]
  dd8=[]
  e=[]
  e1=[]
  e2=[]
  e3=[]
  e4=[]
  e5=[]
  e6=[]
  e7=[]
  e8=[]
  si1 = 1.25
  si2 = 1.5
  si3 = 1.75
  si4 = 2.0
  si5 = 2.25
  si6 = 2.5
  si7 = 2.75

  for j = 0, m-1 do begin
    for i = 0, l-1 do begin

      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si7) then d1 = [d1,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si6) and (gamma_rev'+nys+'[i,j] lt si7) then d2 = [d2,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si5) and (gamma_rev'+nys+'[i,j] lt si6) then d3 = [d3,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si4) and (gamma_rev'+nys+'[i,j] lt si5) then d4 = [d4,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si3) and (gamma_rev'+nys+'[i,j] lt si4) then d5 = [d5,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) and (gamma_rev'+nys+'[i,j] lt si3) then d6 = [d6,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d7 = [d7,i]')
      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d8 = [d8,i]')
    endfor



    if n_elements(d) gt 0 then dd= [dd, d]
    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor

    d=[]
    d_o=[]


    if n_elements(d1) gt 0 then dd1= [dd1, d1]
    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor

    d1=[]

    if n_elements(d2) gt 0 then dd2= [dd2, d2]
    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor

    d2=[]

    if n_elements(d3) gt 0 then dd3= [dd3, d3]
    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor

    d3=[]

    if n_elements(d4) gt 0 then dd4= [dd4, d4]
    if n_elements(d4) gt 0 then for x = 0, n_elements(d4)-1 do begin e4 = [e4, j] & endfor

    d4=[]

    if n_elements(d5) gt 0 then dd5= [dd5, d5]
    if n_elements(d5) gt 0 then for x = 0, n_elements(d5)-1 do begin e5 = [e5, j] & endfor

    d5=[]

    if n_elements(d6) gt 0 then dd6= [dd6, d6]
    if n_elements(d6) gt 0 then for x = 0, n_elements(d6)-1 do begin e6 = [e6, j] & endfor

    d6=[]

    if n_elements(d7) gt 0 then dd7= [dd7, d7]
    if n_elements(d7) gt 0 then for x = 0, n_elements(d7)-1 do begin e7 = [e7, j] & endfor

    d7=[]

    if n_elements(d8) gt 0 then dd8= [dd8, d8]
    if n_elements(d8) gt 0 then for x = 0, n_elements(d8)-1 do begin e8 = [e8, j] & endfor

    d8=[]
  endfor
  
  

;  d=[]
;  d1 = []
;  d2 = []
;  d3 = []
;  d_o=[]
;  dd=[]
;  dd1=[]
;  dd2=[]
;  dd3=[]
;  e=[]
;  e1=[]
;  e2=[]
;  e3=[]
;  si1 = 1.5
;  si2 = 1.85
;
;  for j = 0, m-1 do begin
;    for i = 0, l-1 do begin
;
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then d = [d,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si2) then d1 = [d1,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] ge si1) and (gamma_rev'+nys+'[i,j] lt si2) then d2 = [d2,i]')
;      void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) and (gamma_rev'+nys+'[i,j] lt si1) then d3 = [d3,i]')
;    endfor
;
;
;
;    if n_elements(d) gt 0 then dd= [dd, d]
;    if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;
;    d=[]
;    d_o=[]
;
;
;    if n_elements(d1) gt 0 then dd1= [dd1, d1]
;    if n_elements(d1) gt 0 then for w = 0, n_elements(d1)-1 do begin e1 = [e1, j] & endfor
;
;    d1=[]
;
;    if n_elements(d2) gt 0 then dd2= [dd2, d2]
;    if n_elements(d2) gt 0 then for x = 0, n_elements(d2)-1 do begin e2 = [e2, j] & endfor
;
;    d2=[]
;
;    if n_elements(d3) gt 0 then dd3= [dd3, d3]
;    if n_elements(d3) gt 0 then for x = 0, n_elements(d3)-1 do begin e3 = [e3, j] & endfor
;
;    d3=[]
;  endfor

  ozn = 16
  ;for ozn = 15, 22 do begin
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)

  void = execute('ascii_map = Pres_all_'+nys+'')
  colorbar_title = 'Pres_'+zn+names[restarri]
  imSize=SIZE(ascii_map)
  magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
  this_map = bytscl(magnifiedImg,  min = 0,  max = cm );, top=255)
  MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
  remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
  pos = fltarr(4)
  pos[0] = Startx / float(!d.x_vsize)
  pos[1] = Starty / float(!d.y_vsize)
  pos[2] = (Startx + xsize) / float(!d.x_vsize)
  pos[3] = (Starty + ysize) / float(!d.y_vsize)
  imdisp, remap, pos=pos, /usepos, /noscale

 
  ;void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("green")')
  ;void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("yellow")')
  ;void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 1.9, color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd1], LAT_ARR[e1], psym = 1, SymSize=2.0, thick = 2.1, color = fsc_color("black")')
  void = execute('oplot, LON_ARR[dd2], LAT_ARR[e2], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("blue")')
  void = execute('oplot, LON_ARR[dd3], LAT_ARR[e3], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("cyan")')
  void = execute('oplot, LON_ARR[dd4], LAT_ARR[e4], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("green")')
  void = execute('oplot, LON_ARR[dd5], LAT_ARR[e5], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("yellow")')
  void = execute('oplot, LON_ARR[dd6], LAT_ARR[e6], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("orange")')
  void = execute('oplot, LON_ARR[dd7], LAT_ARR[e7], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("red")')
  void = execute('oplot, LON_ARR[dd8], LAT_ARR[e8], psym = 1, SymSize=2.0, thick = 2.1,color = fsc_color("violet red")')


  MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('white'),/horizon,$
    lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
    lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
    latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
  !p.multi = 0
  device, retain=2


  WRITE_PNG, 'next'+nys+'_dd_p_mp0.6_sub_Pres_'+ynn+'_'+zn+names[restarri]+'.png', TVRD(/TRUE)
  
  
  
  end