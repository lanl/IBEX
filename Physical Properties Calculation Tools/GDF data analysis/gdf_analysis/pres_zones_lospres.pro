pro pres_zones_lospres

  all_ESA6= []
  l=180
  m=90
  zl=6
  num = STRTRIM(zl, 1)
  ;restore, 'RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
  ;restore, 'RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
  ;restore, 'p_RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
  restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  

  mid_arr = ['A_20']
  last_arr = ['B_ram']
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/asurv_map_04-05-2023/surv_map.sav
  ;sp = surv_struct.YEARLY_SURV_SC_RAM

  restarri = 0

for yo = 15, 20 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
  endfor



  ;for b = 16, 21 do begin
  for b = 15, 21 do begin

    year = STRTRIM(b, 2)

    ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/LRS_Jun27/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'

    oyn = 15
    oynn= oyn + 1
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(oynn-16, 1)

    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')


    for lati = 0, m-1 do begin
      for loni = 0, l-1 do begin

        void = execute('if (Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+')) and (loni gt 70)  then pos_arr_'+ynn+'[loni, lati] = 1')
        void = execute('if (Pres_all_'+ynn+'[loni, lati] lt pf*max(Pres_all_'+ynn+')) then pos_arr_'+ynn+'[loni, lati] = -1')

      endfor
    endfor

    d=[]
    d_o=[]
    dd=[]
    e=[]
    indices=[]


    void = execute('Pres_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_intpl[b-9,i,j])]')

      endfor

    endfor

    void = execute('Pres_'+year+'_'+zone+'_ESA2_avg = mean(Pres_'+year+'_'+zone+'_full_ESA2, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA3_avg = mean(Pres_'+year+'_'+zone+'_full_ESA3, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA4_avg = mean(Pres_'+year+'_'+zone+'_full_ESA4, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA5_avg = mean(Pres_'+year+'_'+zone+'_full_ESA5, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA6_avg = mean(Pres_'+year+'_'+zone+'_full_ESA6, /nan)')
    ;void = execute('Pres_'+year+'_'+zone+'_ESAall_ck = total([[Pres_16_1_full_ESA2],[Pres_16_1_full_ESA3], [Pres_16_1_full_ESA4], [Pres_16_1_full_ESA5], [Pres_16_1_full_ESA6]] , 2, /nan)')
    ;void = execute('Pres_'+year+'_'+zone+'_ESAall_ck2 = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
    void = execute('nan_rep'+year+'_'+zone+'=where (Pres_'+year+'_'+zone+'_ESAall eq 0.00000)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = mean(Pres_'+year+'_'+zone+'_ESAall, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = stddev(Pres_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Pres_'+year+'_'+zone+'_ESAall))')

    for oyn = 16, 19 do begin
      oynn= oyn + 1
      yn = STRTRIM(oyn, 1)
      ynn = STRTRIM(oynn, 1)
      zone = STRTRIM(oynn-16, 1)

      void = execute('pos_arr_'+yn+'= intarr(l, m)')
      void = execute('pos_arr_'+ynn+'= intarr(l, m)')
      void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')

      for lati = 0, m-1 do begin
        for loni = 0, l-1 do begin

          void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')

        endfor
      endfor

      for lati = 0, m-1 do begin
        for loni = 0, l-1 do begin

          void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

        endfor
      endfor

      d=[]
      dd=[]
      e=[]
      indices=[]

      void = execute('Pres_'+year+'_'+zone+'_full_ESA2=[]')
      void = execute('Pres_'+year+'_'+zone+'_full_ESA3=[]')
      void = execute('Pres_'+year+'_'+zone+'_full_ESA4=[]')
      void = execute('Pres_'+year+'_'+zone+'_full_ESA5=[]')
      void = execute('Pres_'+year+'_'+zone+'_full_ESA6=[]')

      for j = 0, 90-1 do begin
        for i = 0, 180-1 do begin

          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_intpl[b-9,i,j])]')
        endfor

      endfor
      void = execute('Pres_'+year+'_'+zone+'_ESA2_avg = mean(Pres_'+year+'_'+zone+'_full_ESA2, /nan)')
      void = execute('Pres_'+year+'_'+zone+'_ESA3_avg = mean(Pres_'+year+'_'+zone+'_full_ESA3, /nan)')
      void = execute('Pres_'+year+'_'+zone+'_ESA4_avg = mean(Pres_'+year+'_'+zone+'_full_ESA4, /nan)')
      void = execute('Pres_'+year+'_'+zone+'_ESA5_avg = mean(Pres_'+year+'_'+zone+'_full_ESA5, /nan)')
      void = execute('Pres_'+year+'_'+zone+'_ESA6_avg = mean(Pres_'+year+'_'+zone+'_full_ESA6, /nan)')
      void = execute('Pres_'+year+'_'+zone+'_ESAall = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
      void = execute('nan_rep'+year+'_'+zone+'=where (Pres_'+year+'_'+zone+'_ESAall eq 0.00000)')
      void = execute('Pres_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
      void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = mean(Pres_'+year+'_'+zone+'_ESAall, /nan)')
      void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = stddev(Pres_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Pres_'+year+'_'+zone+'_ESAall))')




    endfor

    ;stop

  endfor
  
stop

  all_ESA6= []
  
  
  time1 = [2016, 2017, 2018, 2019, 2020]
  time1a = [2016, 2017, 2018, 2019]
  time1b = [2019, 2020]
  time2 = [2017, 2018, 2019, 2020]
  time2a = [2017, 2018, 2019]
  time2b = [2019, 2020]
  time3 = [2018, 2019, 2020]
  time3a = [2018, 2019]
  time3b = [2019, 2020]
  time4 = [2019, 2020]
  time7 = [2016]
  time8 = [2017]
  time9 = [2018]
  time13= [2015]
  time14= [2015,2016]
  time15 = [2016,2017]
  time16 = [2017,2018]

  Pres_1 = [Pres_16_0_ESAall_avg, Pres_17_0_ESAall_avg, Pres_18_0_ESAall_avg, Pres_19_0_ESAall_avg, Pres_20_0_ESAall_avg]
  Pres_1a = [Pres_16_0_ESAall_avg, Pres_17_0_ESAall_avg, Pres_18_0_ESAall_avg, Pres_19_0_ESAall_avg]
  Pres_1b = [Pres_19_0_ESAall_avg, Pres_20_0_ESAall_avg]
  Pres_2 = [Pres_17_1_ESAall_avg, Pres_18_1_ESAall_avg, Pres_19_1_ESAall_avg, Pres_20_1_ESAall_avg]
  Pres_2a = [Pres_17_1_ESAall_avg, Pres_18_1_ESAall_avg, Pres_19_1_ESAall_avg]
  Pres_2b = [Pres_19_1_ESAall_avg, Pres_20_1_ESAall_avg]
  Pres_3 = [Pres_18_2_ESAall_avg, Pres_19_2_ESAall_avg, Pres_20_2_ESAall_avg]
  Pres_3a = [Pres_18_2_ESAall_avg, Pres_19_2_ESAall_avg]
  Pres_3b = [Pres_19_2_ESAall_avg, Pres_20_2_ESAall_avg]
  Pres_4 = [Pres_19_3_ESAall_avg, Pres_20_3_ESAall_avg]
  Pres_7 =  [Pres_16_1_ESAall_avg]
  Pres_8 =  [Pres_17_2_ESAall_avg]
  Pres_9 = [Pres_18_3_ESAall_avg]
  Pres_13 = [Pres_15_0_ESAall_avg]
  Pres_14 = [ Pres_15_0_ESAall_avg, Pres_16_0_ESAall_avg]
  Pres_15 = [ Pres_16_1_ESAall_avg, Pres_17_1_ESAall_avg]
  Pres_16 = [ Pres_17_2_ESAall_avg, Pres_18_2_ESAall_avg]

  Pres_er1 = [Pres_16_0_ESAall_sd, Pres_17_0_ESAall_sd, Pres_18_0_ESAall_sd, Pres_19_0_ESAall_sd, Pres_20_0_ESAall_sd]
  Pres_er1a = [Pres_16_0_ESAall_sd, Pres_17_0_ESAall_sd, Pres_18_0_ESAall_sd, Pres_19_0_ESAall_sd]
  Pres_er1b = [Pres_19_0_ESAall_sd, Pres_20_0_ESAall_sd]
  Pres_er2 = [Pres_17_1_ESAall_sd, Pres_18_1_ESAall_sd, Pres_19_1_ESAall_sd, Pres_20_1_ESAall_sd]
  Pres_er2a = [Pres_17_1_ESAall_sd, Pres_18_1_ESAall_sd, Pres_19_1_ESAall_sd]
  Pres_er2b = [Pres_19_1_ESAall_sd, Pres_20_1_ESAall_sd]
  Pres_er3 = [Pres_18_2_ESAall_sd, Pres_19_2_ESAall_sd, Pres_20_2_ESAall_sd]
  Pres_er3a = [Pres_18_2_ESAall_sd, Pres_19_2_ESAall_sd]
  Pres_er3b = [Pres_19_2_ESAall_sd, Pres_20_2_ESAall_sd]
  Pres_er4 = [Pres_19_3_ESAall_sd, Pres_20_3_ESAall_sd]
  Pres_er7 =  [Pres_16_1_ESAall_sd]
  Pres_er8 =  [Pres_17_2_ESAall_sd]
  Pres_er9 = [Pres_18_3_ESAall_sd]
  Pres_er13 = [Pres_15_0_ESAall_sd]
  Pres_er14 = [Pres_15_0_ESAall_sd, Pres_16_0_ESAall_sd]
  Pres_er15 = [Pres_16_1_ESAall_sd, Pres_17_1_ESAall_sd]
  Pres_er16 = [Pres_17_2_ESAall_sd, Pres_18_2_ESAall_sd]

  g1a = errorplot(time1, Pres_1a, Pres_er1a, xrange=[2014, 2021], yrange=[10, 40], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  g1b = errorplot(time1b, Pres_1b, Pres_er1b, /overplot)
  g1b.symbol= 'o'
  g1b.SYM_SIZE= 1
  g1b.SYM_FILLED=1
  g1b.FONT_SIZE=15
  g1b.LINESTYLE='-.'

  g2a = errorplot(time2a, Pres_2a, Pres_er2a, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.COLOR ="blue"
  g2a.ERRORBAR_COLOR="blue"

  g2b = errorplot(time2b, Pres_2b, Pres_er2b, /overplot)
  g2b.symbol= 'o'
  g2b.SYM_SIZE= 1
  g2b.SYM_FILLED=1
  g2b.FONT_SIZE=15
  g2b.COLOR ="blue"
  g2b.ERRORBAR_COLOR="blue"
  g2b.LINESTYLE='-.'

  g3a = errorplot(time3a, Pres_3a, Pres_er3a, /overplot)
  g3a.symbol= 'o'
  g3a.SYM_SIZE= 1
  g3a.SYM_FILLED=1
  g3a.FONT_SIZE=15
  g3a.COLOR ="green"
  g3a.ERRORBAR_COLOR="green"

  g3b = errorplot(time3b, Pres_3b, Pres_er3b, /overplot)
  g3b.symbol= 'o'
  g3b.SYM_SIZE= 1
  g3b.SYM_FILLED=1
  g3b.FONT_SIZE=15
  g3b.COLOR ="green"
  g3b.ERRORBAR_COLOR="green"
  g3b.LINESTYLE='-.'

  ;g4 = errorplot(time4, Pres_4, Pres_er4, /overplot)
  ;g4.symbol= 'o'
  ;g4.SYM_SIZE= 1
  ;g4.SYM_FILLED=1
  ;g4.FONT_SIZE=15
  ;g4.COLOR ="orange"
  ;g4.ERRORBAR_COLOR="orange"
  ;g4.LINESTYLE='--'


  g6 = errorplot(time13, Pres_13, Pres_er13, /overplot)
  g6.symbol= 'X'
  g6.SYM_SIZE= 1
  g6.SYM_FILLED=1
  g6.FONT_SIZE=15

  g7 = errorplot(time7, Pres_7, Pres_er7, /overplot)
  g7.symbol= 'X'
  g7.SYM_SIZE= 1
  g7.SYM_FILLED=1
  g7.FONT_SIZE=15
  g7.COLOR ="blue"
  g7.ERRORBAR_COLOR="blue"

  g8 = errorplot(time8, Pres_8, Pres_er8, /overplot)
  g8.symbol= 'X'
  g8.SYM_SIZE= 1
  g8.SYM_FILLED=1
  g8.FONT_SIZE=15
  g8.COLOR ="green"
  g8.ERRORBAR_COLOR="green"

  ;g9 = errorplot(time9, Pres_9, Pres_er9, /overplot)
  ;g9.symbol= 'X'
  ;g9.SYM_SIZE= 1
  ;g9.SYM_FILLED=1
  ;g9.FONT_SIZE=15
  ;g9.COLOR ="orange"
  ;g9.ERRORBAR_COLOR="orange"
  
  g14 = errorplot(time14, Pres_14, Pres_er14, /overplot)
  ;g10.symbol= '.'
  ;g10.SYM_SIZE= 1
  ;g10.SYM_FILLED=1
  g14.FONT_SIZE=15
  g14.COLOR ="black"
  g14.ERRORBAR_COLOR="black"
  g14.LINESTYLE='--'

  g15 = errorplot(time15, Pres_15, Pres_er15, /overplot)
  g15.FONT_SIZE=15
  g15.COLOR ="blue"
  g15.ERRORBAR_COLOR="blue"
  g15.LINESTYLE='--'

  g16 = errorplot(time16, Pres_16, Pres_er16, /overplot)
  g16.FONT_SIZE=15
  g16.COLOR ="green"
  g16.ERRORBAR_COLOR="green"
  g16.LINESTYLE='--'


  g16.save, 'p_pres_hsm.png'
  
  
  stop
  
  mx = 15.0
  mn = -5.0

  zone1 = Pres_16_0_ESAall - Pres_15_0_ESAall

  pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1,  MAX= mx, MIN= mn,binsize = 0.5)

  graphic = BARPLOT(xbin1, pdf1, XTITLE='Pressure 2016-2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = [0, 300], transparency=80, histogram =0 )


  mx = 15.0
  mn = -5.0

  zone1 = Pres_17_0_ESAall - Pres_16_0_ESAall
  zone2 = Pres_17_1_ESAall - Pres_16_1_ESAall

  pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1,  MAX= mx, MIN= mn,binsize = 0.5)
  pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2,  MAX= mx, MIN= mn,binsize = 0.5)

  graphic = BARPLOT(xbin1, pdf1, XTITLE='Pressure 2017-2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = [0, 300], transparency=80, histogram =0 )
  graphic = BARPLOT(xbin2, pdf2, /overplot, $
    AXIS_STYLE=1, COLOR='blue', fill_color = 'blue', transparency=60, histogram =0)


  mx = 15.0
  mn = -5.0

  zone1 = Pres_18_0_ESAall - Pres_17_0_ESAall
  zone2 = Pres_18_1_ESAall - Pres_17_1_ESAall
  zone3 = Pres_18_2_ESAall - Pres_17_2_ESAall

  pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1,  MAX= mx, MIN= mn,binsize = 0.5)
  pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2,  MAX= mx, MIN= mn,binsize = 0.5)
  pdf3 = HISTOGRAM(zone3, LOCATIONS=xbin3,  MAX= mx, MIN= mn,binsize = 0.5)

  graphic = BARPLOT(xbin1, pdf1, XTITLE='Pressure 2018-2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = [0, 300], transparency=80, histogram =0 )
  graphic = BARPLOT(xbin2, pdf2, /overplot, $
    AXIS_STYLE=1, COLOR='blue', fill_color = 'blue', transparency=60, histogram =0)
  graphic = BARPLOT(xbin3, pdf3, /overplot, $
    AXIS_STYLE=1, COLOR='green', fill_color = 'green', transparency=0, histogram =0)
    
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mx = 40.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 250]

  pdf15 = HISTOGRAM(Pres_15_0_ESAall, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin15[5:12], pdf15[5:12], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[13:20], pdf15[13:20], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[21:28], pdf15[21:28], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[29:36], pdf15[29:36], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[37:44], pdf15[37:44], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[45:52], pdf15[45:52], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[53:60], pdf15[53:60], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf16 = HISTOGRAM(Pres_16_0_ESAall, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16[0:4], pdf16[0:4], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin16[5:12], pdf16[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[13:20], pdf16[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[21:28], pdf16[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[29:36], pdf16[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[37:44], pdf16[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[45:52], pdf16[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[53:60], pdf16[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf17 = HISTOGRAM(Pres_17_0_ESAall, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17[0:4], pdf17[0:4], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin17[5:12], pdf17[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[13:20], pdf17[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[21:28], pdf17[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[29:36], pdf17[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[37:44], pdf17[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[45:52], pdf17[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[53:60], pdf17[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf18 = HISTOGRAM(Pres_18_0_ESAall, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18[0:4], pdf18[0:4], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin18[5:12], pdf18[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[13:20], pdf18[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[21:28], pdf18[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[29:36], pdf18[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[37:44], pdf18[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[45:52], pdf18[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[53:60], pdf18[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf19 = HISTOGRAM(Pres_19_0_ESAall, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19[0:4], pdf19[0:4], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin19[5:12], pdf19[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[13:20], pdf19[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[21:28], pdf19[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[29:36], pdf19[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[37:44], pdf19[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[45:52], pdf19[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[53:60], pdf19[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Zone 2;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mx = 40.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 250]

  pdf15 = HISTOGRAM(Pres_15_1_ESAall, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin15[5:12], pdf15[5:12], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[13:20], pdf15[13:20], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[21:28], pdf15[21:28], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[29:36], pdf15[29:36], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[37:44], pdf15[37:44], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[45:52], pdf15[45:52], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[53:60], pdf15[53:60], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf16 = HISTOGRAM(Pres_16_1_ESAall, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16[0:4], pdf16[0:4], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin16[5:12], pdf16[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[13:20], pdf16[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[21:28], pdf16[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[29:36], pdf16[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[37:44], pdf16[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[45:52], pdf16[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[53:60], pdf16[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf17 = HISTOGRAM(Pres_17_1_ESAall, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17[0:4], pdf17[0:4], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin17[5:12], pdf17[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[13:20], pdf17[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[21:28], pdf17[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[29:36], pdf17[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[37:44], pdf17[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[45:52], pdf17[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[53:60], pdf17[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf18 = HISTOGRAM(Pres_18_1_ESAall, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18[0:4], pdf18[0:4], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin18[5:12], pdf18[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[13:20], pdf18[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[21:28], pdf18[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[29:36], pdf18[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[37:44], pdf18[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[45:52], pdf18[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[53:60], pdf18[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf19 = HISTOGRAM(Pres_19_1_ESAall, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19[0:4], pdf19[0:4], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin19[5:12], pdf19[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[13:20], pdf19[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[21:28], pdf19[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[29:36], pdf19[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[37:44], pdf19[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[45:52], pdf19[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[53:60], pdf19[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mx = 40.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 250]

  pdf15 = HISTOGRAM(Pres_15_0_ESAall, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15, pdf15, XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf16 = HISTOGRAM(Pres_16_0_ESAall, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16, pdf16, XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf17 = HISTOGRAM(Pres_17_0_ESAall, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17, pdf17, XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf18 = HISTOGRAM(Pres_18_0_ESAall, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18, pdf18, XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf19 = HISTOGRAM(Pres_19_0_ESAall, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19, pdf19, XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf20 = HISTOGRAM(Pres_20_0_ESAall, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin20, pdf20, XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mx = 35.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 200]

  pdf15 = HISTOGRAM(Pres_15_1_ESAall, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15, pdf15, XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf16 = HISTOGRAM(Pres_16_1_ESAall, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16, pdf16, XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf17 = HISTOGRAM(Pres_17_1_ESAall, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17, pdf17, XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf18 = HISTOGRAM(Pres_18_1_ESAall, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18, pdf18, XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf19 = HISTOGRAM(Pres_19_1_ESAall, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19, pdf19, XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf20 = HISTOGRAM(Pres_20_1_ESAall, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin20, pdf20, XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  zy= 0
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)
  zone1 = Pres_16_0_ESAall - Pres_15_0_ESAall

  bin_size = 0.5
  xrange = [-10.0, 10.0]
  yrange = [0, 300]
  void = execute('xtitle = "LOS Integrated Pressure 2016-2015"')
  void = execute ('pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1, binsize = bin_size)')



  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_z.png"')

  zy= 1
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)
  zone1 = Pres_17_0_ESAall - Pres_16_0_ESAall
  zone2 = Pres_17_1_ESAall - Pres_16_1_ESAall

  bin_size = 0.5
  xrange = [-10.0, 10.0]
  yrange = [0, 300]
  void = execute('xtitle = "LOS Integrated Pressure 2017-2016"')
  void = execute ('pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2, binsize = bin_size)')


  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_z.png"')

  zy= 2
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)
  zone1 = Pres_18_0_ESAall - Pres_17_0_ESAall
  zone2 = Pres_18_1_ESAall - Pres_17_1_ESAall
  zone3 = Pres_18_2_ESAall - Pres_17_2_ESAall

  bin_size = 0.5
  xrange = [-10.0, 10.0]
  yrange = [0, 300]
  void = execute('xtitle = "LOS Integrated Pressure 2018-2017"')
  void = execute ('pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2, binsize = bin_size)')
  void = execute ('pdf3 = HISTOGRAM(zone3, LOCATIONS=xbin3, binsize = bin_size)')


  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_z.png"')
  
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  zy= 0
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)

  bin_size = 1
  xrange = [10.0, 50.0]
  yrange = [0, 500]
  void = execute('xtitle = "zone'+zys+'"')
  void = execute ('pdf1 = HISTOGRAM(Pres_15_'+zyo+'_ESAall, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(Pres_16_'+zyo+'_ESAall, LOCATIONS=xbin2, binsize = bin_size)')
  void = execute ('pdf3 = HISTOGRAM(Pres_17_'+zyo+'_ESAall, LOCATIONS=xbin3, binsize = bin_size)')
  void = execute ('pdf4 = HISTOGRAM(Pres_18_'+zyo+'_ESAall, LOCATIONS=xbin4, binsize = bin_size)')
  void = execute ('pdf5 = HISTOGRAM(Pres_19_'+zyo+'_ESAall, LOCATIONS=xbin5, binsize = bin_size)')
  void = execute ('pdf6 = HISTOGRAM(Pres_20_'+zyo+'_ESAall, LOCATIONS=xbin6, binsize = bin_size)')


  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)

  void = execute('phisto.save, "pres'+zys+'_a.png"')

  phisto = PLOT(xbin4, pdf4, thick = 2, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)

  void = execute('phisto.save, "pres'+zys+'_b.png"')

  zy= 1
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)

  bin_size = 1
  xrange = [10.0, 50.0]
  yrange = [0, 300]
  void = execute('xtitle = "zone'+zys+'"')

  void = execute('xtitle = "zone'+zys+'"')
  void = execute ('pdf1 = HISTOGRAM(Pres_15_'+zyo+'_ESAall, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(Pres_16_'+zyo+'_ESAall, LOCATIONS=xbin2, binsize = bin_size)')
  void = execute ('pdf3 = HISTOGRAM(Pres_17_'+zyo+'_ESAall, LOCATIONS=xbin3, binsize = bin_size)')
  void = execute ('pdf4 = HISTOGRAM(Pres_18_'+zyo+'_ESAall, LOCATIONS=xbin4, binsize = bin_size)')
  void = execute ('pdf5 = HISTOGRAM(Pres_19_'+zyo+'_ESAall, LOCATIONS=xbin5, binsize = bin_size)')
  void = execute ('pdf6 = HISTOGRAM(Pres_20_'+zyo+'_ESAall, LOCATIONS=xbin6, binsize = bin_size)')


  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)

  void = execute('phisto.save, "pres'+zys+'_a.png"')

  phisto = PLOT(xbin4, pdf4, thick = 2, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)

  void = execute('phisto.save, "pres'+zys+'_b.png"')


  zy= 2
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)

  bin_size = 1
  xrange = [10.0, 50.0]
  yrange = [0, 200]
  void = execute('xtitle = "zone'+zys+'"')

  void = execute ('pdf1 = HISTOGRAM(Pres_15_'+zyo+'_ESAall, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(Pres_16_'+zyo+'_ESAall, LOCATIONS=xbin2, binsize = bin_size)')
  void = execute ('pdf3 = HISTOGRAM(Pres_17_'+zyo+'_ESAall, LOCATIONS=xbin3, binsize = bin_size)')
  void = execute ('pdf4 = HISTOGRAM(Pres_18_'+zyo+'_ESAall, LOCATIONS=xbin4, binsize = bin_size)')
  void = execute ('pdf5 = HISTOGRAM(Pres_19_'+zyo+'_ESAall, LOCATIONS=xbin5, binsize = bin_size)')
  void = execute ('pdf6 = HISTOGRAM(Pres_20_'+zyo+'_ESAall, LOCATIONS=xbin6, binsize = bin_size)')

  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)

  void = execute('phisto.save, "pres'+zys+'_a.png"')

  phisto = PLOT(xbin4, pdf4, thick = 2, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)

  phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)

  void = execute('phisto.save, "pres'+zys+'_b.png"')
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  zy= 0
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)

  bin_size = 1
  xrange = [10.0, 50.0]
  yrange = [0, 500]
  void = execute('xtitle = "zone'+zys+'"')
  void = execute ('pdf1 = HISTOGRAM(Pres_15_'+zyo+'_ESAall, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(Pres_16_'+zyo+'_ESAall, LOCATIONS=xbin2, binsize = bin_size)')



  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_opz.png"')

  zy= 1
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)

  bin_size = 1
  xrange = [10.0, 50.0]
  yrange = [0, 300]
  void = execute('xtitle = "zone'+zys+'"')
  void = execute ('pdf1 = HISTOGRAM(Pres_16_'+zyo+'_ESAall, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(Pres_17_'+zyo+'_ESAall, LOCATIONS=xbin2, binsize = bin_size)')



  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_opz.png"')

  zy= 2
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)

  bin_size = 1
  xrange = [10.0, 50.0]
  yrange = [0, 200]
  void = execute('xtitle = "zone'+zys+'"')
  void = execute ('pdf1 = HISTOGRAM(Pres_17_'+zyo+'_ESAall, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(Pres_18_'+zyo+'_ESAall, LOCATIONS=xbin2, binsize = bin_size)')



  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

  phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_opz.png"')
  
  
  
  

end