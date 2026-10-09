pro f_pres_zones_temp_interpol

  ;restore, 'RS_8Aug23all_temp_intpl_wNan_fract_new.sav'

  ;restore, 'RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
  
  restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  restore, 'p_RS_7May24all_temp_intpl_wNan_fract_new.sav'
  
  all_ESA6= []
  l=180
  m=90
  zl=5
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)


  mid_arr = ['A_20']
  last_arr = ['B_ram']

  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/asurv_map_04-05-2023/surv_map.sav
  ;sp = surv_struct.YEARLY_SURV_SC_RAM

  restarri = 0


  for yo = 15, 21 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
  endfor


  ;for b = 16, 21 do begin
  for b = 15, 21 do begin

    year = STRTRIM(b, 2)


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


    void = execute('Temp_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_intpl[b-9,i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_intpl[b-9,i,j])]')

      endfor

    endfor
    void = execute('Temp_'+year+'_'+zone+'_ESA2_avg = mean(Temp_'+year+'_'+zone+'_full_ESA2)')
    void = execute('Temp_'+year+'_'+zone+'_ESA3_avg = mean(Temp_'+year+'_'+zone+'_full_ESA3)')
    void = execute('Temp_'+year+'_'+zone+'_ESA4_avg = mean(Temp_'+year+'_'+zone+'_full_ESA4)')
    void = execute('Temp_'+year+'_'+zone+'_ESA5_avg = mean(Temp_'+year+'_'+zone+'_full_ESA5)')
    void = execute('Temp_'+year+'_'+zone+'_ESA6_avg = mean(Temp_'+year+'_'+zone+'_full_ESA6)')
    void = execute('Temp_'+year+'_'+zone+'_ESAall = (Temp_'+year+'_'+zone+'_full_ESA2+Temp_'+year+'_'+zone+'_full_ESA3+Temp_'+year+'_'+zone+'_full_ESA4+Temp_'+year+'_'+zone+'_full_ESA5+Temp_'+year+'_'+zone+'_full_ESA6)/6')
    void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall)')
    void = execute('Temp_'+year+'_'+zone+'_ESAall_sd = stddev(Temp_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(Temp_'+year+'_'+zone+'_full_ESA2))')
    void = execute('nan_rep'+year+'_'+zone+'=where (Temp_'+year+'_'+zone+'_ESAall eq 0.00000)')
    void = execute('Temp_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall, /nan)')
    void = execute('Temp_'+year+'_'+zone+'_sd = [stddev(Temp_'+year+'_'+zone+'_full_ESA2), stddev(Temp_'+year+'_'+zone+'_full_ESA3), stddev(Temp_'+year+'_'+zone+'_full_ESA4), stddev(Temp_'+year+'_'+zone+'_full_ESA5), stddev(Temp_'+year+'_'+zone+'_full_ESA6)]')



    ;for oyn = 18, 20 do begin
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

      void = execute('Temp_'+year+'_'+zone+'_full_ESA2=[]')
      void = execute('Temp_'+year+'_'+zone+'_full_ESA3=[]')
      void = execute('Temp_'+year+'_'+zone+'_full_ESA4=[]')
      void = execute('Temp_'+year+'_'+zone+'_full_ESA5=[]')
      void = execute('Temp_'+year+'_'+zone+'_full_ESA6=[]')

      for j = 0, 90-1 do begin
        for i = 0, 180-1 do begin

          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_intpl[b-9,i,j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_intpl[b-9,i,j])]')
        endfor

      endfor
      void = execute('Temp_'+year+'_'+zone+'_ESA2_avg = mean(Temp_'+year+'_'+zone+'_full_ESA2)')
      void = execute('Temp_'+year+'_'+zone+'_ESA3_avg = mean(Temp_'+year+'_'+zone+'_full_ESA3)')
      void = execute('Temp_'+year+'_'+zone+'_ESA4_avg = mean(Temp_'+year+'_'+zone+'_full_ESA4)')
      void = execute('Temp_'+year+'_'+zone+'_ESA5_avg = mean(Temp_'+year+'_'+zone+'_full_ESA5)')
      void = execute('Temp_'+year+'_'+zone+'_ESA6_avg = mean(Temp_'+year+'_'+zone+'_full_ESA6)')
      void = execute('Temp_'+year+'_'+zone+'_ESAall = (Temp_'+year+'_'+zone+'_full_ESA2+Temp_'+year+'_'+zone+'_full_ESA3+Temp_'+year+'_'+zone+'_full_ESA4+Temp_'+year+'_'+zone+'_full_ESA5+Temp_'+year+'_'+zone+'_full_ESA6)/6')
      void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall)')
      void = execute('Temp_'+year+'_'+zone+'_ESAall_sd = stddev(Temp_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(Temp_'+year+'_'+zone+'_full_ESA2))')
      void = execute('nan_rep'+year+'_'+zone+'=where (Temp_'+year+'_'+zone+'_ESAall eq 0.00000)')
      void = execute('Temp_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
      void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall, /nan)')
      void = execute('Temp_'+year+'_'+zone+'_sd = [stddev(Temp_'+year+'_'+zone+'_full_ESA2), stddev(Temp_'+year+'_'+zone+'_full_ESA3), stddev(Temp_'+year+'_'+zone+'_full_ESA4), stddev(Temp_'+year+'_'+zone+'_full_ESA5), stddev(Temp_'+year+'_'+zone+'_full_ESA6)]')




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
  time4 = [2018, 2019, 2020]
  time7 = [2016]
  time8 = [2017]
  time9 = [2018]
  time13= [2015]
  time14= [2015,2016]
  time15 = [2016,2017]
  time16 = [2017,2018]

  Temp_1 = [Temp_16_0_ESAall_avg, Temp_17_0_ESAall_avg, Temp_18_0_ESAall_avg, Temp_19_0_ESAall_avg, Temp_20_0_ESAall_avg]
  Temp_1a = [Temp_16_0_ESAall_avg, Temp_17_0_ESAall_avg, Temp_18_0_ESAall_avg, Temp_19_0_ESAall_avg]
  Temp_1b = [Temp_19_0_ESAall_avg, Temp_20_0_ESAall_avg]
  Temp_2 = [Temp_17_1_ESAall_avg, Temp_18_1_ESAall_avg, Temp_19_1_ESAall_avg, Temp_20_1_ESAall_avg]
  Temp_2a = [Temp_17_1_ESAall_avg, Temp_18_1_ESAall_avg, Temp_19_1_ESAall_avg]
  Temp_2b = [Temp_19_1_ESAall_avg, Temp_20_1_ESAall_avg]
  Temp_3 = [Temp_18_2_ESAall_avg, Temp_19_2_ESAall_avg, Temp_20_2_ESAall_avg]
  Temp_3a = [Temp_18_2_ESAall_avg, Temp_19_2_ESAall_avg]
  Temp_3b = [Temp_19_2_ESAall_avg, Temp_20_2_ESAall_avg]
  Temp_4 = [Temp_18_3_ESAall_avg, Temp_19_3_ESAall_avg, Temp_20_3_ESAall_avg]
  Temp_7 =  [Temp_16_1_ESAall_avg]
  Temp_8 =  [Temp_17_2_ESAall_avg]
  Temp_9 = [Temp_18_3_ESAall_avg]
  Temp_13 = [Temp_15_0_ESAall_avg]
   Temp_14 = [ Temp_15_0_ESAall_avg, Temp_16_0_ESAall_avg]
   Temp_15 = [ Temp_16_1_ESAall_avg, Temp_17_1_ESAall_avg]
   Temp_16 = [ Temp_17_2_ESAall_avg, Temp_18_2_ESAall_avg]

  Temp_er1 = [Temp_16_0_ESAall_sd, Temp_17_0_ESAall_sd, Temp_18_0_ESAall_sd, Temp_19_0_ESAall_sd, Temp_20_0_ESAall_sd]
  Temp_er1a = [Temp_16_0_ESAall_sd, Temp_17_0_ESAall_sd, Temp_18_0_ESAall_sd, Temp_19_0_ESAall_sd]
  Temp_er1b = [Temp_19_0_ESAall_sd, Temp_20_0_ESAall_sd]
  Temp_er2 = [Temp_17_1_ESAall_sd, Temp_18_1_ESAall_sd, Temp_19_1_ESAall_sd, Temp_20_1_ESAall_sd]
  Temp_er2a = [Temp_17_1_ESAall_sd, Temp_18_1_ESAall_sd, Temp_19_1_ESAall_sd]
  Temp_er2b = [Temp_19_1_ESAall_sd, Temp_20_1_ESAall_sd]
  Temp_er3 = [Temp_18_2_ESAall_sd, Temp_19_2_ESAall_sd, Temp_20_2_ESAall_sd]
  Temp_er3a = [Temp_18_2_ESAall_sd, Temp_19_2_ESAall_sd]
  Temp_er3b = [Temp_19_2_ESAall_sd, Temp_20_2_ESAall_sd]
  Temp_er4 = [Temp_18_3_ESAall_sd, Temp_19_3_ESAall_sd, Temp_20_3_ESAall_sd]
  Temp_er7 =  [Temp_16_1_ESAall_sd]
  Temp_er8 =  [Temp_17_2_ESAall_sd]
  Temp_er9 = [Temp_18_3_ESAall_sd]
  Temp_er13 = [Temp_15_0_ESAall_sd]
  Temp_er14 = [Temp_15_0_ESAall_sd, Temp_16_0_ESAall_sd]
  Temp_er15 = [Temp_16_1_ESAall_sd, Temp_17_1_ESAall_sd]
  Temp_er16 = [Temp_17_2_ESAall_sd, Temp_18_2_ESAall_sd]

  g1a = errorplot(time1a, Temp_1a, Temp_er1a, xrange=[2014, 2021], yrange=[3500000, 4500000], xminor=0,XTITLE="Year in HS", YTITLE="Temperature (K)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  g1b = errorplot(time1b, Temp_1b, Temp_er1b, /overplot)
  g1b.symbol= 'o'
  g1b.SYM_SIZE= 1
  g1b.SYM_FILLED=1
  g1b.FONT_SIZE=15
  g1b.LINESTYLE='-.'

  g2a = errorplot(time2a, Temp_2a, Temp_er2a, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.COLOR ="blue"
  g2a.ERRORBAR_COLOR="blue"

  g2b = errorplot(time2b, Temp_2b, Temp_er2b, /overplot)
  g2b.symbol= 'o'
  g2b.SYM_SIZE= 1
  g2b.SYM_FILLED=1
  g2b.FONT_SIZE=15
  g2b.COLOR ="blue"
  g2b.ERRORBAR_COLOR="blue"
  g2b.LINESTYLE='-.'

  g3a = errorplot(time3a, Temp_3a, Temp_er3a, /overplot)
  g3a.symbol= 'o'
  g3a.SYM_SIZE= 1
  g3a.SYM_FILLED=1
  g3a.FONT_SIZE=15
  g3a.COLOR ="green"
  g3a.ERRORBAR_COLOR="green"

  g3b = errorplot(time3b, Temp_3b, Temp_er3b, /overplot)
  g3b.symbol= 'o'
  g3b.SYM_SIZE= 1
  g3b.SYM_FILLED=1
  g3b.FONT_SIZE=15
  g3b.COLOR ="green"
  g3b.ERRORBAR_COLOR="green"
  g3b.LINESTYLE='-.'

  ;g4 = errorplot(time4, Temp_4, Temp_er4, /overplot)
  ;g4.symbol= 'o'
  ;g4.SYM_SIZE= 1
  ;g4.SYM_FILLED=1
  ;g4.FONT_SIZE=15
  ;g4.COLOR ="orange"
  ;g4.ERRORBAR_COLOR="orange"
  ;g4.LINESTYLE='--'


  g6 = errorplot(time13, Temp_13, Temp_er13, /overplot)
  g6.symbol= 'X'
  g6.SYM_SIZE= 2
  g6.SYM_FILLED=1
  g6.FONT_SIZE=15

  g7 = errorplot(time7, Temp_7, Temp_er7, /overplot)
  g7.symbol= 'X'
  g7.SYM_SIZE= 2
  g7.SYM_FILLED=1
  g7.FONT_SIZE=15
  g7.COLOR ="blue"
  g7.ERRORBAR_COLOR="blue"

  g8 = errorplot(time8, Temp_8, Temp_er8, /overplot)
  g8.symbol= 'X'
  g8.SYM_SIZE= 2
  g8.SYM_FILLED=1
  g8.FONT_SIZE=15
  g8.COLOR ="green"
  g8.ERRORBAR_COLOR="green"

  ;g9 = errorplot(time9, Temp_9, Temp_er9, /overplot)
  ;g9.symbol= 'X'
  ;g9.SYM_SIZE= 1
  ;g9.SYM_FILLED=1
  ;g9.FONT_SIZE=15
  ;g9.COLOR ="orange"
  ;g9.ERRORBAR_COLOR="orange"
  
  g14 = errorplot(time14, Temp_14, Temp_er14, /overplot)
  ;g10.symbol= '.'
  ;g10.SYM_SIZE= 1
  ;g10.SYM_FILLED=1
  g14.FONT_SIZE=15
  g14.COLOR ="black"
  g14.ERRORBAR_COLOR="black"
  g14.LINESTYLE='--'

  g15 = errorplot(time15, Temp_15, Temp_er15, /overplot)
  g15.FONT_SIZE=15
  g15.COLOR ="blue"
  g15.ERRORBAR_COLOR="blue"
  g15.LINESTYLE='--'

  g16 = errorplot(time16, Temp_16, Temp_er16, /overplot)
  g16.FONT_SIZE=15
  g16.COLOR ="green"
  g16.ERRORBAR_COLOR="green"
  g16.LINESTYLE='--'


  g16.save, 'temp_hsm.png'
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mx = 50
  mn = 35
  binsize = 0.2
  yrange = [0, 700]
  
  pdf15 = HISTOGRAM(Temp_15_0_ESAall/100000, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin15[5:9], pdf15[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[10:14], pdf15[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[15:19], pdf15[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[20:24], pdf15[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[25:29], pdf15[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[30:34], pdf15[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[35:39], pdf15[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[40:44], pdf15[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[45:49], pdf15[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[50:54], pdf15[50:54], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf16 = HISTOGRAM(Temp_16_0_ESAall/100000, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16[0:4], pdf16[0:4], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin16[5:9], pdf16[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[10:14], pdf16[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[15:19], pdf16[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[20:24], pdf16[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[25:29], pdf16[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[30:34], pdf16[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[35:39], pdf16[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin16[40:44], pdf16[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin16[45:49], pdf16[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin16[50:54], pdf16[50:54], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf17 = HISTOGRAM(Temp_17_0_ESAall/100000, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17[0:4], pdf17[0:4], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin17[5:9], pdf17[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[10:14], pdf17[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[15:19], pdf17[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[20:24], pdf17[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[25:29], pdf17[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[30:34], pdf17[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[35:39], pdf17[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin17[40:44], pdf17[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin17[45:49], pdf17[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin17[50:54], pdf17[50:54], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

;-----------------------------------------

  pdf18 = HISTOGRAM(Temp_18_0_ESAall/100000, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18[0:4], pdf18[0:4], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin18[5:9], pdf18[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[10:14], pdf18[10:14], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[15:19], pdf18[15:19], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[20:24], pdf18[20:24], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[25:29], pdf18[25:29], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[30:34], pdf18[30:34], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[35:39], pdf18[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin18[40:44], pdf18[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin18[45:49], pdf18[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin18[50:54], pdf18[50:54], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf19 = HISTOGRAM(Temp_19_0_ESAall/100000, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19[0:4], pdf19[0:4], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin19[5:9], pdf19[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[10:14], pdf19[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[15:19], pdf19[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[20:24], pdf19[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[25:29], pdf19[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[30:34], pdf19[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[35:39], pdf19[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin19[40:44], pdf19[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin19[45:49], pdf19[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin19[50:54], pdf19[50:54], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Zone 2;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mx = 50
  mn = 35
  binsize = 0.2
  yrange = [0, 300]

  pdf15 = HISTOGRAM(Temp_15_1_ESAall/100000, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin15[5:9], pdf15[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[10:14], pdf15[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[15:19], pdf15[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[20:24], pdf15[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[25:29], pdf15[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[30:34], pdf15[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[35:39], pdf15[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[40:44], pdf15[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[45:49], pdf15[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[50:75], pdf15[50:75], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf16 = HISTOGRAM(Temp_16_1_ESAall/100000, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16[0:4], pdf16[0:4], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin16[5:9], pdf16[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[10:14], pdf16[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[15:19], pdf16[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[20:24], pdf16[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[25:29], pdf16[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[30:34], pdf16[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[35:39], pdf16[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin16[40:44], pdf16[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin16[45:49], pdf16[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin16[50:75], pdf16[50:75], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf17 = HISTOGRAM(Temp_17_1_ESAall/100000, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17[0:4], pdf17[0:4], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin17[5:9], pdf17[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[10:14], pdf17[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[15:19], pdf17[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[20:24], pdf17[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[25:29], pdf17[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[30:34], pdf17[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[35:39], pdf17[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin17[40:44], pdf17[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin17[45:49], pdf17[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin17[50:75], pdf17[50:75], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-----------------------------------------

  pdf18 = HISTOGRAM(Temp_18_1_ESAall/100000, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18[0:4], pdf18[0:4], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin18[5:9], pdf18[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[10:14], pdf18[10:14], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[15:19], pdf18[15:19], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[20:24], pdf18[20:24], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[25:29], pdf18[25:29], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[30:34], pdf18[30:34], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[35:39], pdf18[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin18[40:44], pdf18[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin18[45:49], pdf18[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin18[50:75], pdf18[50:75], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf19 = HISTOGRAM(Temp_19_1_ESAall/100000, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19[0:4], pdf19[0:4], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin19[5:9], pdf19[5:9], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[10:14], pdf19[10:14], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[15:19], pdf19[15:19], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[20:24], pdf19[20:24], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[25:29], pdf19[25:29], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[30:34], pdf19[30:34], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[35:39], pdf19[35:39], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin19[40:44], pdf19[40:44], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin19[45:49], pdf19[45:49], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin19[50:75], pdf19[50:75], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'light pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mx = 50
  mn = 35
  binsize = 0.2
  yrange = [0, 700]

  pdf15 = HISTOGRAM(Temp_15_0_ESAall/100000, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15[0:5], pdf15[0:5], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin15[6:11], pdf15[6:11], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[12:17], pdf15[12:17], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[18:23], pdf15[18:23], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[24:29], pdf15[24:29], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[30:35], pdf15[30:35], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[36:41], pdf15[36:41], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin15[42:50], pdf15[42:50], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
  graphic = BARPLOT(xbin15[42:50], pdf15[42:50], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf16 = HISTOGRAM(Temp_16_0_ESAall/100000, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16[0:5], pdf16[0:5], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin16[6:11], pdf16[6:11], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[12:17], pdf16[12:17], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[18:23], pdf16[18:23], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[24:29], pdf16[24:29], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[30:35], pdf16[30:35], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[36:41], pdf16[36:41], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin16[42:50], pdf16[42:50], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf17 = HISTOGRAM(Temp_17_0_ESAall/100000, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17[0:5], pdf17[0:5], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin17[6:11], pdf17[6:11], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[12:17], pdf17[12:17], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[18:23], pdf17[18:23], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[24:29], pdf17[24:29], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[30:35], pdf17[30:35], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[36:41], pdf17[36:41], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin17[42:50], pdf17[42:50], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf18 = HISTOGRAM(Temp_18_0_ESAall/100000, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18[0:5], pdf18[0:5], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin18[6:11], pdf18[6:11], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[12:17], pdf18[12:17], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[18:23], pdf18[18:23], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[24:29], pdf18[24:29], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[30:35], pdf18[30:35], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[36:41], pdf18[36:41], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin18[42:50], pdf18[42:50], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf19 = HISTOGRAM(Temp_19_0_ESAall/100000, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19[0:5], pdf19[0:5], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin19[6:11], pdf19[6:11], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[12:17], pdf19[12:17], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[18:23], pdf19[18:23], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[24:29], pdf19[24:29], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[30:35], pdf19[30:35], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[36:41], pdf19[36:41], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin19[42:50], pdf19[42:50], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'hot pink', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;mx = 4500000
  ;mn = 3500000
  ;binsize = 50000
  mx = 45
  mn = 35
  binsize = 0.2
  yrange = [0, 700]

  pdf15 = HISTOGRAM(Temp_15_0_ESAall/100000, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15, pdf15, XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf16 = HISTOGRAM(Temp_16_0_ESAall/100000, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16, pdf16, XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf17 = HISTOGRAM(Temp_17_0_ESAall/100000, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17, pdf17, XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf18 = HISTOGRAM(Temp_18_0_ESAall/100000, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18, pdf18, XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf19 = HISTOGRAM(Temp_19_0_ESAall/100000, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19, pdf19, XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf20 = HISTOGRAM(Temp_20_0_ESAall/100000, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin20, pdf20, XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  mx = 52
  mn = 36
  binsize = 0.2
  yrange = [0, 300]
  
  pdf15 = HISTOGRAM(Temp_15_1_ESAall/100000, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15, pdf15, XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf16 = HISTOGRAM(Temp_16_1_ESAall/100000, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin16, pdf16, XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf17 = HISTOGRAM(Temp_17_1_ESAall/100000, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin17, pdf17, XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf18 = HISTOGRAM(Temp_18_1_ESAall/100000, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin18, pdf18, XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf19 = HISTOGRAM(Temp_19_1_ESAall/100000, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin19, pdf19, XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

  pdf20 = HISTOGRAM(Temp_20_1_ESAall/100000, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin20, pdf20, XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
  
  
  
  
  
 stop
  DEVICE, Color=1, Bits_per_Pixel=8, FILENAME="pres_zone_temp_intpl.ps"
  plot, time1, Temp_ESAall_1_opz, color = fsc_color("black"), thick = 4, psym = 2, xtitle ='Year', ytitle='Temperature', yrange = [0.0000000099, 0.000000011], xrange = [15, 21], xminor = 2, xthick = 4, ythick = 4, charsize = 1.5, charthick = 4
  oplot, time1a, Temp_ESAall_1_opza, color = fsc_color("black"), thick = 2
  oplot, time1b, Temp_ESAall_1_opzb, color = fsc_color("black"), thick = 2, linestyle=2
  oplot, time2, Temp_ESAall_2_opz ,color = fsc_color("blue"), psym = 2, thick = 4
  oplot, time2a, Temp_ESAall_2_opza ,color = fsc_color("blue"), thick = 2
  oplot, time2b, Temp_ESAall_2_opzb ,color = fsc_color("blue"), thick = 2, linestyle=2
  oplot, time3, Temp_ESAall_3_opz , color = fsc_color("green"), psym = 2, thick = 4
  oplot, time3a, Temp_ESAall_3_opza , color = fsc_color("green"),thick = 2
  oplot, time3b, Temp_ESAall_3_opzb , color = fsc_color("green"),thick = 2, linestyle=2
  oplot, time4, Temp_ESAall_4_opz , color = fsc_color("orange"), psym = 2, thick = 4
  oplot, time4, Temp_ESAall_4_opz , color = fsc_color("orange"), thick = 2, linestyle=2
  oplot, time7, Temp_ESAall_7_opz, color = fsc_color('blue'), psym = 1, thick = 4
  oplot, time8, Temp_ESAall_8_opz, color = fsc_color('green'), psym = 1, thick = 4
  oplot, time9, Temp_ESAall_9_opz, color = fsc_color('orange'), psym = 1, thick = 4
  oplot, time13, Temp_ESAall_13_opz, color = fsc_color('black'), psym = 1, thick = 4
  DEVICE, /CLOSE

end