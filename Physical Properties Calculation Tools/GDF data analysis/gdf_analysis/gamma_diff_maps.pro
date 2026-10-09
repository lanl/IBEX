pro gamma_diff_maps

  ;restore, 'RS_2Aug23all_pres_intpl_wNan.sav'
  ;restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  ;restore, 'all_pres_7May_ag.sav'
  restore,'/Users/nwalia/IDLWorkspace/all_pres_7May_ag.sav'


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
  ;loadct, 70
  cgLoadCT, 71, /reverse


  ;load_ibex_color_table

  latmin = -90
  latmax = 90
  lonmin = 0
  lonmax =  360
  p0lon = nose_lon
  p0lat = nose_lat

  cbmax = [1200,800,200,140,60,18]

  pf = 0.5 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  mid_arr = ['A_20', 'A_20', 'B_20', 'B_20']
  ;last_arr = ['B_aram.sav', 'B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  last_arr = ['B_ram.sav', 'A_antiram.sav', 'A_ram.sav']
  names = [ 'AB_ram', 'BA_antiram', 'BA_ram']
  ;names = ['AB_antiram', 'AB_ram', 'BA_antiram', 'BA_ram']

  restarri = 0

  l=180
  m=90
  ii=6
  ;ii=5

  ;for yo = 15, 22 do begin
  ;  yos = STRTRIM(yo, 1)
  ;  void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2[yo-9,0:l-1, 0:m-1]+Pres_ESA3[yo-9,0:l-1, 0:m-1]+Pres_ESA4[yo-9,0:l-1, 0:m-1]+Pres_ESA5[yo-9,0:l-1, 0:m-1]+Pres_ESA6[yo-9,0:l-1, 0:m-1]), 180, 90))')
  ;endfor
  
  for yo = 15, 22 do begin
    yos = STRTRIM(yo, 1)
    ;void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2[yo-9,0:l-1, 0:m-1]+Pres_ESA3[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('gamma_'+yos+'= fltarr(l, m)')


    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin
        ;void = execute('Flux_'+yos+' = [reverse(ESA2_GDF_MAP[yo-9, i,j]), reverse(ESA3_GDF_MAP[yo-9, i,j]), reverse(ESA4_GDF_MAP[yo-9, i,j]), reverse(ESA5_GDF_MAP[yo-9, i,j]), reverse(ESA6_GDF_MAP[yo-9, i,j])]')
        void = execute('fin_arr'+yos+'= where(finite(reverse(Flux[yo-9, j,i])))')
        Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
        void = execute('f_'+yos+' = LINFIT(alog(Energy[fin_arr'+yos+']), alog(Flux_'+yos+'[fin_arr'+yos+']))')
        void = execute('gamma_'+yos+'[i,j] =  abs(f_'+yos+'[1])')

      endfor
    endfor

    void = execute('gamma_rev'+yos+'= fltarr(l, m)')
    void = execute('gamma_rev'+yos+' =  reverse(gamma_'+yos+')')

  endfor


  ca= [100, 50, 22, 10, 5]

  cl = -0.5
  cm = 0.5

  ozn = 17
  oznn= ozn + 1
  zn = STRTRIM(ozn, 1)
  znn = STRTRIM(oznn, 1)
  fsc_colorbar, charsize=6,charthick=15.,position=[.1, .76, .9, .8], range=[cl, cm], format='(F0.1)', $;, minrange = 1.0, maxrange = 3.0, $
    color=fsc_color('white'),/horizontal
  !p.multi = 0
  device, retain=3

  WRITE_PNG, 'cl_diff_Pres.png', TVRD(/TRUE)

  stop

  for ozn = 15, 22 do begin
    oznn= ozn + 1
    zn = STRTRIM(ozn, 1)
    znn = STRTRIM(oznn, 1)

    ;Pres_all = fltarr(l, m)
    ;for j = 0, m-1 do begin
    ;for i = 0, l-1 do begin
    ;Pres_all[i,j] = Pres_ESA2_intpl[ozn-9,i,j]+Pres_ESA3_intpl[ozn-9,i,j]+Pres_ESA4_intpl[ozn-9,i,j]+Pres_ESA5_intpl[ozn-9,i,j]+Pres_ESA6_intpl[ozn-9,i,j]
    ;endfor
    ;endfor

    void = execute('ascii_map = (gamma_rev_'+znn+'-gamma_rev_'+zn+')/gamma_rev_'+zn+'')
    colorbar_title = 'Pres_'+znn+'-'+zn+names[restarri]
    imSize=SIZE(ascii_map)
    magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])
    this_map = bytscl(magnifiedImg,  min = cl,  max = cm );, top=255)
    MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ', position=[0.05,0.12,0.95,0.99], color = 255, /noborder,/ISOTROPIC,limit=map_limits,/MOLLWEIDE
    remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
    pos = fltarr(4)
    pos[0] = Startx / float(!d.x_vsize)
    pos[1] = Starty / float(!d.y_vsize)
    pos[2] = (Startx + xsize) / float(!d.x_vsize)
    pos[3] = (Starty + ysize) / float(!d.y_vsize)
    imdisp, remap, pos=pos, /usepos, /noscale

    ;void = execute('oplot, reverse(lon_b'+num+'_'+ynn+'), reverse(lat_b'+num+'_'+ynn+'), psym = 1')
    ;void = execute('oplot, LON_ARR[dd], LAT_ARR[e], psym = 1, color = fsc_color("brown")')


    MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('black'),/horizon,$
      lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
      lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
      latlab=0,glinestyle=0, glinethick=1, charthick=15, charsize=6
    !p.multi = 0
    device, retain=2

    stop
    WRITE_PNG, 'diff_Pres_'+znn+'-'+zn+'_'+names[restarri]+'.png', TVRD(/TRUE)
  endfor










  ; reverse
  ;endfor


  all_ESA2= []
  all_ESA3= []
  all_ESA4= []
  all_ESA5= []
  all_ESA6= []



end
