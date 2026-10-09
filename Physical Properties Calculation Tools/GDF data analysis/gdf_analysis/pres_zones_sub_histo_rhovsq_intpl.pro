pro pres_zones_sub_histo_rhovsq_intpl
  ;can also use to calculate density

  ;restore, 'speed_intpl_et.sav'
  ;restore, 'density_intpl_et.sav'
  ;restore, 'RS_2Aug23ESA_intpl_wNAN.sav'
  ;restore, 'RS_2Aug23all_pres_intpl_wNan.sav'
  ;restore, 'factor_speed_intpl_et.sav'
  ;restore, 'factor_density_intpl_et.sav'
  ;restore, 'pr_factor_density_intpl_et.sav'
  ;restore, 'pr_factor_speed_intpl_et.sav'
  ;restore, 'RS_8Aug23ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
  restore, 'hte_pr_factor_density_intpl_et_new.sav'
  restore, 'hte_pr_factor_speed_intpl_et_new.sav'
  restore, 'p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

  all_ESA6= []
  l=180
  m=90
  ii=6
  pf = 0.6 ;0.5 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)
 

  lat_orig = [-90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90]

  
  mid_arr = ['A_20']
  last_arr = ['B_ram']
 

  restarri = 0
  
  for yo = 15, 22 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
  endfor


  for b = 15, 22 do begin

    year = STRTRIM(b, 2)

    oyn = 15
    oynn= oyn + 1
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(oynn-16, 1)

    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    void = execute('pos_arr_'+ynn+'= intarr(l, m)')


   
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

    void = execute('speed_'+year+'_'+zone+'=[]')
    void = execute('speed_'+year+'_'+zone+'_avg=[]')
    void = execute('speed_'+year+'_'+zone+'_sd=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then speed_'+year+'_'+zone+' = [speed_'+year+'_'+zone+',1.67*density_ts_ally_intpl[b-2,i,j]*speed_ts_ally_intpl[b-2,i,j]*speed_ts_ally_intpl[b-2,i,j]/(2*10000.0)]')

      endfor

    endfor


    void = execute('speed_'+year+'_'+zone+'_avg = mean(speed_'+year+'_'+zone+', /nan)')
    void = execute('speed_'+year+'_'+zone+'_sd = stddev(speed_'+year+'_'+zone+', /nan)/sqrt(n_elements(speed_'+year+'_'+zone+'))')


    



    ;for oyn = 18, 20 do begin
    for oyn = 16, 20 do begin
      oynn= oyn + 1
      yn = STRTRIM(oyn, 1)
      ynn = STRTRIM(oynn, 1)
      zone = STRTRIM(oynn-16, 1)

      void = execute('pos_arr_'+yn+'= intarr(l, m)')
      void = execute('pos_arr_'+ynn+'= intarr(l, m)')

      for lati = 0, m-1 do begin
        for loni = 0, l-1 do begin

          void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')

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

      void = execute('speed_'+year+'_'+zone+'=[]')
      void = execute('speed_'+year+'_'+zone+'_avg=[]')
      void = execute('speed_'+year+'_'+zone+'_sd=[]')

      for j = 0, 90-1 do begin
        for i = 0, 180-1 do begin

          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then speed_'+year+'_'+zone+' = [speed_'+year+'_'+zone+',1.67*density_ts_ally_intpl[b-2,i,j]*speed_ts_ally_intpl[b-2,i,j]*speed_ts_ally_intpl[b-2,i,j]/(2*10000.0)]')

        endfor

      endfor

      void = execute('speed_'+year+'_'+zone+'_avg = mean(speed_'+year+'_'+zone+', /nan)')
      void = execute('speed_'+year+'_'+zone+'_sd = stddev(speed_'+year+'_'+zone+', /nan)/sqrt(n_elements(speed_'+year+'_'+zone+'))')


    endfor



  endfor

  save, filename='ips_pressure.sav'
  stop

  all_ESA6= []

  ;save, filename='zones.sav'

  time1 = [2016, 2017, 2018, 2019, 2020, 2021, 2022]
  time2 = [2017, 2018, 2019, 2020, 2021, 2022]
  time3 = [2018, 2019, 2020, 2021, 2022]
  time4 = [2019, 2020, 2021, 2022]
  time5 = [2020, 2021, 2022]
  time6 = [2021, 2022]
  time7 = [2016]
  time8 = [2017]
  time9 = [2018]
  time10= [2019]
  time11= [2020]
  time12= [2021]
  time13= [2015]
  time14= [2015,2016]
  time15= [2016,2017]
  time16= [2017,2018]

  speed_1 = [speed_16_0_avg, speed_17_0_avg, speed_18_0_avg, speed_19_0_avg, speed_20_0_avg];, speed_21_0_avg, speed_22_0_avg]
  speed_2 = [speed_17_1_avg, speed_18_1_avg, speed_19_1_avg, speed_20_1_avg];, speed_21_1_avg, speed_22_1_avg]
  speed_3 = [speed_18_2_avg, speed_19_2_avg, speed_20_2_avg];, speed_21_2_avg, speed_22_2_avg]
  speed_4 = [speed_19_3_avg, speed_20_3_avg];, speed_21_3_avg, speed_22_3_avg]
  speed_5 = [speed_20_4_avg];, speed_21_4_avg, speed_22_4_avg]
  ;speed_6 = [speed_21_5_avg, speed_22_5_avg]
  speed_7 = [speed_16_1_avg]
  speed_8 = [speed_17_2_avg]
  speed_9 = [speed_18_3_avg]
  speed_10 =[speed_19_4_avg]
  speed_11 =[speed_20_5_avg]
  ;speed_12 =[speed_21_5_avg]
  speed_13 =[speed_15_0_avg]
  speed_14 = [speed_15_0_avg, speed_16_0_avg]
  speed_15 = [speed_16_1_avg, speed_17_1_avg]
  speed_16 = [speed_17_2_avg, speed_18_2_avg]
  
  speed_er1 = [speed_16_0_sd, speed_17_0_sd, speed_18_0_sd, speed_19_0_sd, speed_20_0_sd];, speed_21_0_sd, speed_22_0_sd]
  speed_er2 = [speed_17_1_sd, speed_18_1_sd, speed_19_1_sd, speed_20_1_sd];, speed_21_1_sd, speed_22_1_sd]
  speed_er3 = [speed_18_2_sd, speed_19_2_sd, speed_20_2_sd];, speed_21_2_sd, speed_22_2_sd]
  speed_er4 = [speed_19_3_sd, speed_20_3_sd];, speed_21_3_sd, speed_22_3_sd]
  speed_er5 = [speed_20_4_sd];, speed_21_4_sd, speed_22_4_sd]
  ;speed_er6 = [speed_21_5_sd, speed_22_5_sd]
  speed_er7 = [speed_16_1_sd]
  speed_er8 = [speed_17_2_sd]
  speed_er9 = [speed_18_3_sd]
  speed_er10 =[speed_19_4_sd]
  ;speed_er11 =[speed_20_5_sd]
  ;speed_er12 =[speed_21_5_sd]
  speed_er13 =[speed_15_0_sd]
  speed_er14 = [speed_15_0_sd, speed_16_0_sd]
  speed_er15 = [speed_16_1_sd, speed_17_1_sd]
  speed_er16 = [speed_17_2_sd, speed_18_2_sd]

  g1a = errorplot(time1, speed_1, speed_er1, xrange=[2014, 2022], yrange=[70, 130], xminor=0,XTITLE="Year in HS", YTITLE="IPS SW dynamic pressure (pdynes cm^-2)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  g2a = errorplot(time2, speed_2, speed_er2, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.COLOR ="blue"
  g2a.ERRORBAR_COLOR="blue"
  
  g3a = errorplot(time3, speed_3, speed_er3, /overplot)
  g3a.symbol= 'o'
  g3a.SYM_SIZE= 1
  g3a.SYM_FILLED=1
  g3a.FONT_SIZE=15
  g3a.COLOR ="green"
  g3a.ERRORBAR_COLOR="green"

  g6 = errorplot(time13, speed_13, speed_er13, /overplot)
  g6.symbol= 'X'
  g6.SYM_SIZE= 1
  g6.SYM_FILLED=1
  g6.FONT_SIZE=15

  g7 = errorplot(time7, speed_7, speed_er7, /overplot)
  g7.symbol= 'X'
  g7.SYM_SIZE= 1
  g7.SYM_FILLED=1
  g7.FONT_SIZE=15
  g7.COLOR ="blue"
  g7.ERRORBAR_COLOR="blue"

  g8 = errorplot(time8, speed_8, speed_er8, /overplot)
  g8.symbol= 'X'
  g8.SYM_SIZE= 1
  g8.SYM_FILLED=1
  g8.FONT_SIZE=15
  g8.COLOR ="green"
  g8.ERRORBAR_COLOR="green"

  ;g9 = errorplot(time9, speed_9, speed_er9, /overplot)
  ;g9.symbol= 'X'
  ;g9.SYM_SIZE= 1
  ;g9.SYM_FILLED=1
  ;g9.FONT_SIZE=15
  ;g9.COLOR ="orange"
  ;g9.ERRORBAR_COLOR="orange"
  g14 = errorplot(time14, speed_14, speed_er14, /overplot)
  ;g10.symbol= '.'
  ;g10.SYM_SIZE= 1
  ;g10.SYM_FILLED=1
  g14.FONT_SIZE=15
  g14.COLOR ="black"
  g14.ERRORBAR_COLOR="black"
  g14.LINESTYLE='--'

  g15 = errorplot(time15, speed_15, speed_er15, /overplot)
  g15.FONT_SIZE=15
  g15.COLOR ="blue"
  g15.ERRORBAR_COLOR="blue"
  g15.LINESTYLE='--'

  g16 = errorplot(time16, speed_16, speed_er16, /overplot)
  g16.FONT_SIZE=15
  g16.COLOR ="green"
  g16.ERRORBAR_COLOR="green"
  g16.LINESTYLE='--'


  g16.save, 'p_rhovsq_hsm.png'

stop
  SET_PLOT, 'PS'

  time1 = [16, 17, 18, 19, 20, 21, 22]
  time2 = [17, 18, 19, 20, 21, 22]
  time3 = [18, 19, 20, 21, 22]
  time4 = [19, 20, 21, 22]
  time5 = [20, 21, 22]
  time6 = [21, 22]
  time7 = [16]
  time8 = [17]
  time9 = [18]
  time10= [19]
  time11= [20]
  time12= [21]
  time13= [15]

  speed_1 = [speed_16_0_avg, speed_17_0_avg, speed_18_0_avg, speed_19_0_avg, speed_20_0_avg, speed_21_0_avg, speed_22_0_avg]
  speed_2 = [speed_17_1_avg, speed_18_1_avg, speed_19_1_avg, speed_20_1_avg, speed_21_1_avg, speed_22_1_avg]
  speed_3 = [speed_18_2_avg, speed_19_2_avg, speed_20_2_avg, speed_21_2_avg, speed_22_2_avg]
  speed_4 = [speed_19_3_avg, speed_20_3_avg, speed_21_3_avg, speed_22_3_avg]
  speed_5 = [speed_20_4_avg, speed_21_4_avg, speed_22_4_avg]
  speed_6 = [speed_21_5_avg, speed_22_5_avg]
  speed_7 = [speed_16_1_avg]
  speed_8 = [speed_17_2_avg]
  speed_9 = [speed_18_3_avg]
  speed_10 =[speed_19_4_avg]
  speed_11 =[speed_20_5_avg]
  speed_12 =[speed_21_5_avg]
  speed_13 =[speed_15_0_avg]
  

  
  ;DEVICE, Bits_per_Pixel=8, Color=1, FILENAME='Pres_time_intpl_sub_zone_100TStHS_mid.ps'
  DEVICE, Bits_per_Pixel=8, Color=1, FILENAME='IPS_Pres.ps'
  plot, time1, speed_1, color = fsc_color('black'), thick = 4, psym = 5, yrange = [60, 140], xrange = [15, 22], xtitle ='Year', ytitle='IPS Solar wind dynamic pressure (pdynes cm^-2) ', xminor = 2, xthick = 4, ythick = 4, charthick = 4, charsize = 1.2
  oplot, time1, speed_1 ,color = fsc_color('black'), thick = 2
  oplot, time2, speed_2 ,color = fsc_color('blue'), psym = 5, thick = 4
  oplot, time2, speed_2 ,color = fsc_color('blue'), thick = 2
  oplot, time3, speed_3 , color = fsc_color('green'), psym = 5, thick = 4
  oplot, time3, speed_3 , color = fsc_color('green'), thick = 2
  oplot, time4, speed_4 , color = fsc_color('orange'), psym = 5, thick = 4
  oplot, time4, speed_4 , color = fsc_color('orange'), thick = 2
  ;oplot, time5, speed_5 , color = fsc_color('red'), psym = 2, thick = 4
  ;oplot, time5, speed_5 , color = fsc_color('red'), thick = 2
  ;oplot, time6, speed_6 , color = fsc_color('hot pink'), psym = 2, thick = 4
  ;oplot, time6, speed_6 , color = fsc_color('hot pink'), thick = 2
  oplot, time7, speed_7, color = fsc_color('blue'), psym = 4, thick = 4
  oplot, time8, speed_8, color = fsc_color('green'), psym = 4, thick = 4
  oplot, time9, speed_9, color = fsc_color('orange'), psym = 4, thick = 4
  ;oplot, time10, speed_10, color = fsc_color('red'), psym = 1, thick = 4
  ;oplot, time11, speed_11, color = fsc_color('hot pink'), psym = 1, thick = 4
  ;oplot, time12, speed_12, color = fsc_color('pink'), psym = 1, thick = 4
  oplot, time13, speed_13, color = fsc_color('black'), psym = 4, thick = 4
  DEVICE, /CLOSE

end
