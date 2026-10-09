pro pres_zones_speci
  ;28Jun
  
  ;restore, 'RS_8Aug23ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'RS_8Aug23all_pres_intpl_wNan_fract_new.sav'
  
  ;restore, 'p_RS_15Mar24ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'p_RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
  
  restore, 'p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  
  
  ; not using these: ;restore, 'RS_15Mar24ESA_intpl_wNAN_fract_new.sav'
  ;restore, 'RS_15Mar24all_pres_intpl_wNan_fract_new.sav'
  all_ESA6= []
  ;all_ESA5= []
  l=180
  m=90
  zl=6
  ;zl=5
  num = STRTRIM(zl, 1)
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)


  mid_arr = ['A_20']
  last_arr = ['B_ram']

  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/asurv_map_04-05-2023/surv_map.sav
  ;sp = surv_struct.YEARLY_SURV_SC_RAM

  restarri = 0


  ;for a = 15, 21 do begin
  ;for a = 15, 22 do begin

  ;y = STRTRIM(a, 2)


  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
  ;restore, '/Users/nwalia/data/LRS_Jun27/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'
  ;restore, '/Users/nwalia/data/RS_25Jul23/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+y+mid_arr[restarri]+y+last_arr[restarri]+'.sav'


  ;all_ESA6 = [all_ESA6, ESA6_GDF_MAP/sp[a-9,*,*,5]]
  ;all_ESA6 = [all_ESA6, ESA6_GDF_MAP]
  ;all_ESA5 = [all_ESA5, ESA5_GDF_MAP]

  ;endfor
  for yo = 15, 20 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
    ;void = execute('Pres_all_'+yos+' = reform((Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
  endfor

  ;void = execute('ESA'+num+'_15 = reform(ESA'+num+'_intpl[15-9, 0:l-1, 0:m-1], 180, 90)') ; not difference, just ESA6
  ;void = execute('ESA'+num+'_16 = reform(ESA'+num+'_intpl[16-9, 0:l-1, 0:m-1], 180, 90)')
  ;void = execute('ESA'+num+'_17 = reform(ESA'+num+'_intpl[17-9, 0:l-1, 0:m-1], 180, 90)')
  ;void = execute('ESA'+num+'_18 = reform(ESA'+num+'_intpl[18-9, 0:l-1, 0:m-1], 180, 90)')
  ;void = execute('ESA'+num+'_19 = reform(ESA'+num+'_intpl[19-9, 0:l-1, 0:m-1], 180, 90)')
  ;void = execute('ESA'+num+'_20 = reform(ESA'+num+'_intpl[20-9, 0:l-1, 0:m-1], 180, 90)')
  ;void = execute('ESA'+num+'_21 = reform(ESA'+num+'_intpl[21-9, 0:l-1, 0:m-1], 180, 90)')
  ;void = execute('ESA'+num+'_22 = reform(ESA'+num+'_intpl[22-9, 0:l-1, 0:m-1], 180, 90)')

  ;for b = 16, 21 do begin
  for b = 15, 21 do begin


    year = STRTRIM(b, 2)

    ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/LRS_Jun27/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/RS_25Jul23/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'


    oyn = 15
    oynn= oyn + 1
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(oynn-16, 1)

    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    ;void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
    void = execute('gamma_'+year+'_'+zone+'= fltarr(l, m)')


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

    void = execute('Flux_'+year+'_'+zone+'=[]')
    void = execute('f_'+year+'_'+zone+'=[]')
    void = execute('gamma_'+year+'_'+zone+'_full=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        ;void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1]), (ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2]), (ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3]), (ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4]), (ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]), (ESA3_intpl[b-9, i, j]), (ESA4_intpl[b-9, i, j]), (ESA5_intpl[b-9, i, j]), (ESA6_intpl[b-9, i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j])]')
        Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then fin_arr'+year+'_'+zone+'=where(finite(Flux_'+year+'_'+zone+'))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then f_'+year+'_'+zone+' = LINFIT(alog(Energy[fin_arr'+year+'_'+zone+']), alog(Flux_'+year+'_'+zone+'[fin_arr'+year+'_'+zone+']))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
      endfor

    endfor


    void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full, /nan)')
    void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full, /nan)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
    void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')


    ;for oyn = 18, 20 do begin
    for oyn = 16, 19 do begin
      oynn= oyn + 1
      yn = STRTRIM(oyn, 1)
      ynn = STRTRIM(oynn, 1)
      zone = STRTRIM(oynn-16, 1)

      void = execute('pos_arr_'+yn+'= intarr(l, m)')
      void = execute('pos_arr_'+ynn+'= intarr(l, m)')
      ;void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
      void = execute('gamma_'+year+'_'+zone+'= fltarr(l, m)')

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

      void = execute('Flux_'+year+'_'+zone+'=[]')
      void = execute('f_'+year+'_'+zone+'=[]')
      void = execute('gamma_'+year+'_'+zone+'_full=[]')
      void = execute('Flux_'+year+'_'+zone+'_full_ESA2=[]')
      void = execute('Flux_'+year+'_'+zone+'_full_ESA3=[]')
      void = execute('Flux_'+year+'_'+zone+'_full_ESA4=[]')
      void = execute('Flux_'+year+'_'+zone+'_full_ESA5=[]')
      void = execute('Flux_'+year+'_'+zone+'_full_ESA6=[]')

      for j = 0, 90-1 do begin
        for i = 0, 180-1 do begin

          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1]), (ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2]), (ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3]), (ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4]), (ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]), (ESA3_intpl[b-9, i, j]), (ESA4_intpl[b-9, i, j]), (ESA5_intpl[b-9, i, j]), (ESA6_intpl[b-9, i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j])]')
          Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then fin_arr'+year+'_'+zone+'=where(finite(Flux_'+year+'_'+zone+'))')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy[fin_arr'+year+'_'+zone+']), alog(Flux_'+year+'_'+zone+'[fin_arr'+year+'_'+zone+']))')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy), alog(Flux_'+year+'_'+zone+'))')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')

        endfor

      endfor

      void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full, /nan)')
      void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full, /nan)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
      void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')


    endfor

    ;stop

  endfor
  
  stop

  all_ESA6= []
  ;all_ESA5= []

  ;save, filename='zones.sav'

;stop



  ;SET_PLOT, 'PS'

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
  time17 = [2018,2019]

  gamma_1 = [gamma_16_0_avg, gamma_17_0_avg, gamma_18_0_avg, gamma_19_0_avg, gamma_20_0_avg]
  gamma_1a = [gamma_16_0_avg, gamma_17_0_avg, gamma_18_0_avg, gamma_19_0_avg]
  gamma_1b = [gamma_19_0_avg, gamma_20_0_avg]
  gamma_2 = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg, gamma_20_1_avg]
  gamma_2a = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg]
  gamma_2b = [gamma_19_1_avg, gamma_20_1_avg]
  gamma_3 = [gamma_18_2_avg, gamma_19_2_avg, gamma_20_2_avg]
  gamma_3a = [gamma_18_2_avg, gamma_19_2_avg]
  gamma_3b = [gamma_19_2_avg, gamma_20_2_avg]
  gamma_4 = [gamma_19_3_avg, gamma_20_3_avg]
  gamma_7 =  [gamma_16_1_avg]
  gamma_8 =  [gamma_17_2_avg]
  gamma_9 = [gamma_18_3_avg]
  gamma_13 = [gamma_15_0_avg]
  gamma_14 = [gamma_15_0_avg, gamma_16_0_avg]
  gamma_15 = [gamma_16_1_avg, gamma_17_1_avg]
  gamma_16 = [gamma_17_2_avg, gamma_18_2_avg]
  gamma_17 = [gamma_18_3_avg, gamma_19_3_avg]
  
  
  gamma_er1 = [gamma_16_0_sd, gamma_17_0_sd, gamma_18_0_sd, gamma_19_0_sd, gamma_20_0_sd]
  gamma_er1a = [gamma_16_0_sd, gamma_17_0_sd, gamma_18_0_sd, gamma_19_0_sd]
  gamma_er1b = [gamma_19_0_sd, gamma_20_0_sd]
  gamma_er2 = [gamma_17_1_sd, gamma_18_1_sd, gamma_19_1_sd, gamma_20_1_sd]
  gamma_er2a = [gamma_17_1_sd, gamma_18_1_sd, gamma_19_1_sd]
  gamma_er2b = [gamma_19_1_sd, gamma_20_1_sd]
  gamma_er3 = [gamma_18_2_sd, gamma_19_2_sd, gamma_20_2_sd]
  gamma_er3a = [gamma_18_2_sd, gamma_19_2_sd]
  gamma_er3b = [gamma_19_2_sd, gamma_20_2_sd]
  gamma_er4 = [gamma_19_3_sd, gamma_20_3_sd]
  gamma_er7 =  [gamma_16_1_sd]
  gamma_er8 =  [gamma_17_2_sd]
  gamma_er9 = [gamma_18_3_sd]
  gamma_er13 = [gamma_15_0_sd]
  gamma_er14 = [gamma_15_0_sd, gamma_16_0_sd]
  gamma_er15 = [gamma_16_1_sd, gamma_17_1_sd]
  gamma_er16 = [gamma_17_2_sd, gamma_18_2_sd]
  gamma_er17 = [gamma_18_3_sd, gamma_19_3_sd]
  
  
  g1a = errorplot(time1, gamma_1a, gamma_er1a, xrange=[2014, 2021], yrange=[1.1, 2.6], xminor=0,XTITLE="Year in HS", YTITLE="Spectral Index")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15
  
  g1b = errorplot(time1b, gamma_1b, gamma_er1b, /overplot)
  g1b.symbol= 'o'
  g1b.SYM_SIZE= 1
  g1b.SYM_FILLED=1
  g1b.FONT_SIZE=15
  g1b.LINESTYLE='-.'

  g2a = errorplot(time2a, gamma_2a, gamma_er2a, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.COLOR ="blue"
  g2a.ERRORBAR_COLOR="blue"
  
  g2b = errorplot(time2b, gamma_2b, gamma_er2b, /overplot)
  g2b.symbol= 'o'
  g2b.SYM_SIZE= 1
  g2b.SYM_FILLED=1
  g2b.FONT_SIZE=15
  g2b.COLOR ="blue"
  g2b.ERRORBAR_COLOR="blue"
  g2b.LINESTYLE='-.'

  g3a = errorplot(time3a, gamma_3a, gamma_er3a, /overplot)
  g3a.symbol= 'o'
  g3a.SYM_SIZE= 1
  g3a.SYM_FILLED=1
  g3a.FONT_SIZE=15
  g3a.COLOR ="green"
  g3a.ERRORBAR_COLOR="green"
  
  g3b = errorplot(time3b, gamma_3b, gamma_er3b, /overplot)
  g3b.symbol= 'o'
  g3b.SYM_SIZE= 1
  g3b.SYM_FILLED=1
  g3b.FONT_SIZE=15
  g3b.COLOR ="green"
  g3b.ERRORBAR_COLOR="green"
  g3b.LINESTYLE='-.'

  ;g4 = errorplot(time4, gamma_4, gamma_er4, /overplot)
  ;g4.symbol= 'o'
  ;g4.SYM_SIZE= 1
  ;g4.SYM_FILLED=1
  ;g4.FONT_SIZE=15
  ;g4.COLOR ="orange"
  ;g4.ERRORBAR_COLOR="orange"
  ;g4.LINESTYLE='-.'


  g6 = errorplot(time13, gamma_13, gamma_er13, /overplot)
  g6.symbol= 'X'
  g6.SYM_SIZE= 1
  g6.SYM_FILLED=1
  g6.FONT_SIZE=15

  g7 = errorplot(time7, gamma_7, gamma_er7, /overplot)
  g7.symbol= 'X'
  g7.SYM_SIZE= 1
  g7.SYM_FILLED=1
  g7.FONT_SIZE=15
  g7.COLOR ="blue"
  g7.ERRORBAR_COLOR="blue"

  g8 = errorplot(time8, gamma_8, gamma_er8, /overplot)
  g8.symbol= 'X'
  g8.SYM_SIZE= 1
  g8.SYM_FILLED=1
  g8.FONT_SIZE=15
  g8.COLOR ="green"
  g8.ERRORBAR_COLOR="green"
  
  ;g9 = errorplot(time9, gamma_9, gamma_er9, /overplot)
  ;g9.symbol= 'X'
  ;g9.SYM_SIZE= 1
  ;g9.SYM_FILLED=1
  ;g9.FONT_SIZE=15
  ;g9.COLOR ="orange"
  ;g9.ERRORBAR_COLOR="orange"

  
  g14 = errorplot(time14, gamma_14, gamma_er14, /overplot)
  ;g10.symbol= '.'
  ;g10.SYM_SIZE= 1
  ;g10.SYM_FILLED=1
  g14.FONT_SIZE=15
  g14.COLOR ="black"
  g14.ERRORBAR_COLOR="black"
  g14.LINESTYLE='--'

  g15 = errorplot(time15, gamma_15, gamma_er15, /overplot)
  g15.FONT_SIZE=15
  g15.COLOR ="blue"
  g15.ERRORBAR_COLOR="blue"
  g15.LINESTYLE='--'

  g16 = errorplot(time16, gamma_16, gamma_er16, /overplot)
  g16.FONT_SIZE=15
  g16.COLOR ="green"
  g16.ERRORBAR_COLOR="green"
  g16.LINESTYLE='--'
  
  ;g17 = errorplot(time17, gamma_17, gamma_er17, /overplot)
  ;g17.FONT_SIZE=15
  ;g17.COLOR ="orange"
  ;g17.ERRORBAR_COLOR="orange"
  ;g17.LINESTYLE='--'

  


  g16.save, 'speci_hsm.png'
  
  stop
  
  mx = 1.0
  mn = -1.0
  
  zone1 = gamma_16_0_full - gamma_15_0_full

  pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1,  MAX= mx, MIN= mn,binsize = 0.05)

  graphic = BARPLOT(xbin1, pdf1, XTITLE='Spectral Index 2016-2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = [0, 700], transparency=80, histogram =0 )
 
  
  mx = 1.0
  mn = -1.0

  zone1 = gamma_17_0_full - gamma_16_0_full
  zone2 = gamma_17_1_full - gamma_16_1_full

  pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1,  MAX= mx, MIN= mn,binsize = 0.05)
  pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2,  MAX= mx, MIN= mn,binsize = 0.05)

  graphic = BARPLOT(xbin1, pdf1, XTITLE='Spectral Index 2017-2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = [0, 700], transparency=80, histogram =0 )
  graphic = BARPLOT(xbin2, pdf2, /overplot, $
    AXIS_STYLE=1, COLOR='blue', fill_color = 'blue', transparency=60, histogram =0)
    
    
  mx = 1.0
  mn = -1.0

  zone1 = gamma_18_0_full - gamma_17_0_full
  zone2 = gamma_18_1_full - gamma_17_1_full
  zone3 = gamma_18_2_full - gamma_17_2_full

  pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1,  MAX= mx, MIN= mn,binsize = 0.05)
  pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2,  MAX= mx, MIN= mn,binsize = 0.05)
  pdf3 = HISTOGRAM(zone3, LOCATIONS=xbin3,  MAX= mx, MIN= mn,binsize = 0.05)

  graphic = BARPLOT(xbin1, pdf1, XTITLE='Spectral Index 2018-2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = [0, 700], transparency=80, histogram =0 )
  graphic = BARPLOT(xbin2, pdf2, /overplot, $
    AXIS_STYLE=1, COLOR='blue', fill_color = 'blue', transparency=60, histogram =0)
  graphic = BARPLOT(xbin3, pdf3, /overplot, $
    AXIS_STYLE=1, COLOR='green', fill_color = 'green', transparency=0, histogram =0)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
  
    mx = 3.0
  mn = 1.0
  binsize = 0.05
  yrange = [0, 700]

  pdf15 = HISTOGRAM(gamma_15_0_full, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )  
    
   graphic = BARPLOT(xbin15[5:9], pdf15[5:9], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
   graphic = BARPLOT(xbin15[10:14], pdf15[10:14], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    graphic = BARPLOT(xbin15[15:19], pdf15[15:19], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    graphic = BARPLOT(xbin15[20:24], pdf15[20:24], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot ) 
    
    graphic = BARPLOT(xbin15[25:29], pdf15[25:29], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    graphic = BARPLOT(xbin15[30:35], pdf15[30:35], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    graphic = BARPLOT(xbin15[35:40], pdf15[35:40], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    ;-------------
    
    pdf16 = HISTOGRAM(gamma_16_0_full, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin16[0:4], pdf16[0:4], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin16[5:9], pdf16[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[10:14], pdf16[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[15:19], pdf16[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[20:24], pdf16[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[25:29], pdf16[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[30:35], pdf16[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[35:40], pdf16[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      
    
    ;-------------

    pdf17 = HISTOGRAM(gamma_17_0_full, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin17[0:4], pdf17[0:4], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin17[5:9], pdf17[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[10:14], pdf17[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[15:19], pdf17[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[20:24], pdf17[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[25:29], pdf17[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[30:35], pdf17[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[35:40], pdf17[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      
    
    ;-------------

    pdf18 = HISTOGRAM(gamma_18_0_full, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin18[0:4], pdf18[0:4], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin18[5:9], pdf18[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[10:14], pdf18[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[15:19], pdf18[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[20:24], pdf18[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[25:29], pdf18[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[30:35], pdf18[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[35:40], pdf18[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      
      
      ;-------------

    pdf19 = HISTOGRAM(gamma_19_0_full, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin19[0:4], pdf19[0:4], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin19[5:9], pdf19[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[10:14], pdf19[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[15:19], pdf19[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[20:24], pdf19[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[25:29], pdf19[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[30:35], pdf19[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[35:40], pdf19[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;Zone 2;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;
    
    mx = 3.0
    mn = 1.0
    binsize = 0.05
    yrange = [0, 350]

    pdf15 = HISTOGRAM(gamma_15_1_full, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin15[5:9], pdf15[5:9], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin15[10:14], pdf15[10:14], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin15[15:19], pdf15[15:19], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin15[20:24], pdf15[20:24], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin15[25:29], pdf15[25:29], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin15[30:35], pdf15[30:35], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin15[35:40], pdf15[35:40], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    ;-------------

    pdf16 = HISTOGRAM(gamma_16_1_full, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin16[0:4], pdf16[0:4], XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin16[5:9], pdf16[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[10:14], pdf16[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[15:19], pdf16[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[20:24], pdf16[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[25:29], pdf16[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[30:35], pdf16[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin16[35:40], pdf16[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


    ;-------------

    pdf17 = HISTOGRAM(gamma_17_1_full, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin17[0:4], pdf17[0:4], XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin17[5:9], pdf17[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[10:14], pdf17[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[15:19], pdf17[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[20:24], pdf17[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[25:29], pdf17[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[30:35], pdf17[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin17[35:40], pdf17[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


    ;-------------

    pdf18 = HISTOGRAM(gamma_18_1_full, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin18[0:4], pdf18[0:4], XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin18[5:9], pdf18[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[10:14], pdf18[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[15:19], pdf18[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[20:24], pdf18[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[25:29], pdf18[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[30:35], pdf18[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin18[35:40], pdf18[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


    ;-------------

    pdf19 = HISTOGRAM(gamma_19_1_full, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin19[0:4], pdf19[0:4], XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin19[5:9], pdf19[5:9], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[10:14], pdf19[10:14], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[15:19], pdf19[15:19], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[20:24], pdf19[20:24], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[25:29], pdf19[25:29], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[30:35], pdf19[30:35], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin19[35:40], pdf19[35:40], FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
   
   
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    mx = 3.0
    mn = 1.0
    binsize = 0.05
    yrange = [0, 600]

    pdf15 = HISTOGRAM(gamma_15_0_full, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin15, pdf15, XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

    pdf16 = HISTOGRAM(gamma_16_0_full, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin16, pdf16, XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

    pdf17 = HISTOGRAM(gamma_17_0_full, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin17, pdf17, XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

    pdf18 = HISTOGRAM(gamma_18_0_full, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin18, pdf18, XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

    pdf19 = HISTOGRAM(gamma_19_0_full, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin19, pdf19, XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

    pdf20 = HISTOGRAM(gamma_20_0_full, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin20, pdf20, XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )

    mx = 3.0
    mn = 1.0
    binsize = 0.05
    yrange = [0, 350]
    
    pdf15 = HISTOGRAM(gamma_15_1_full, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)
    
    graphic = BARPLOT(xbin15, pdf15, XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
      
    pdf16 = HISTOGRAM(gamma_16_1_full, LOCATIONS=xbin16,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin16, pdf16, XTITLE='2016', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
      
    pdf17 = HISTOGRAM(gamma_17_1_full, LOCATIONS=xbin17,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin17, pdf17, XTITLE='2017', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
      
    pdf18 = HISTOGRAM(gamma_18_1_full, LOCATIONS=xbin18,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin18, pdf18, XTITLE='2018', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
      
    pdf19 = HISTOGRAM(gamma_19_1_full, LOCATIONS=xbin19,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin19, pdf19, XTITLE='2019', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
      
    pdf20 = HISTOGRAM(gamma_20_1_full, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin20, pdf20, XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=80, histogram =0 )
      
      
    
      
    
      
      
    
      
      
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    void = execute('xtitle = "zone'+zys+'"')
    void = execute ('pdf1 = HISTOGRAM(gamma_15_'+zyo+'_full, LOCATIONS=xbin1, binsize = bin_size)')
    void = execute ('pdf2 = HISTOGRAM(gamma_16_'+zyo+'_full, LOCATIONS=xbin2, binsize = bin_size)')
    void = execute ('pdf3 = HISTOGRAM(gamma_17_'+zyo+'_full, LOCATIONS=xbin3, binsize = bin_size)')
    void = execute ('pdf4 = HISTOGRAM(gamma_18_'+zyo+'_full, LOCATIONS=xbin4, binsize = bin_size)')
    void = execute ('pdf5 = HISTOGRAM(gamma_19_'+zyo+'_full, LOCATIONS=xbin5, binsize = bin_size)')
    void = execute ('pdf6 = HISTOGRAM(gamma_20_'+zyo+'_full, LOCATIONS=xbin6, binsize = bin_size)')




    phisto = PLOT(xbin1, pdf1, thick = 2,$
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

    phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)

    phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)

    phisto = PLOT(xbin4, pdf4, thick = 2, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)

    phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)

    phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
  
  zy= 0
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)
  zone1 = gamma_16_0_full - gamma_15_0_full

  bin_size = 0.05
  xrange = [-1.0, 1.0]
  yrange = [0, 800]
  void = execute('xtitle = "Spectral Index 2016-2015"')
  void = execute ('pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1, binsize = bin_size)')



  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_opz.png"')
  
  zy= 1
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)
  zone1 = gamma_17_0_full - gamma_16_0_full
  zone2 = gamma_17_1_full - gamma_16_1_full

  bin_size = 0.05
  xrange = [-1.0, 1.0]
  yrange = [0, 800]
  void = execute('xtitle = "Spectral Index 2017-2016"')
  void = execute ('pdf1 = HISTOGRAM(zone1, LOCATIONS=xbin1, binsize = bin_size)')
  void = execute ('pdf2 = HISTOGRAM(zone2, LOCATIONS=xbin2, binsize = bin_size)')
 

  phisto = PLOT(xbin1, pdf1, thick = 2,$
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)
    
    phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    XTITLE=xtitle, YTITLE='Number of pixels', $
    AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)


  void = execute('phisto.save, "speci'+zys+'_opz.png"')
  
  zy= 2
  zyo = STRTRIM(zy, 1)
  zys = STRTRIM(zy+1, 1)
  zone1 = gamma_18_0_full - gamma_17_0_full
  zone2 = gamma_18_1_full - gamma_17_1_full
  zone3 = gamma_18_2_full - gamma_17_2_full

  bin_size = 0.05
  xrange = [-1.0, 1.0]
  yrange = [0, 800]
  void = execute('xtitle = "Spectral Index 2018-2017"')
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


  void = execute('phisto.save, "speci'+zys+'_opz.png"')
  
  

  zy= 0
  zyo = STRTRIM(zy, 1)
    zys = STRTRIM(zy+1, 1)

    bin_size = 0.05
    xrange = [1.0, 3.0]
    yrange = [0, 800]
    void = execute('xtitle = "zone'+zys+'"')
    void = execute ('pdf1 = HISTOGRAM(gamma_15_'+zyo+'_full, LOCATIONS=xbin1, binsize = bin_size)')
    void = execute ('pdf2 = HISTOGRAM(gamma_16_'+zyo+'_full, LOCATIONS=xbin2, binsize = bin_size)')
    void = execute ('pdf3 = HISTOGRAM(gamma_17_'+zyo+'_full, LOCATIONS=xbin3, binsize = bin_size)')
    void = execute ('pdf4 = HISTOGRAM(gamma_18_'+zyo+'_full, LOCATIONS=xbin4, binsize = bin_size)')
    void = execute ('pdf5 = HISTOGRAM(gamma_19_'+zyo+'_full, LOCATIONS=xbin5, binsize = bin_size)')
    void = execute ('pdf6 = HISTOGRAM(gamma_20_'+zyo+'_full, LOCATIONS=xbin6, binsize = bin_size)')




    phisto = PLOT(xbin1, pdf1, thick = 2,$
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

    phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
       void = execute('phisto.save, "old_speci'+zys+'_opz_a.png"')
      
      phisto = PLOT(xbin4, pdf4, thick = 2, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)

    void = execute('phisto.save, "old_speci'+zys+'_opz_b.png"')
    
    zy= 1
    zyo = STRTRIM(zy, 1)
    zys = STRTRIM(zy+1, 1)

    bin_size = 0.05
    xrange = [1.0, 3.0]
    yrange = [0, 300]
    void = execute('xtitle = "zone'+zys+'"')
    
    void = execute('xtitle = "zone'+zys+'"')
    void = execute ('pdf1 = HISTOGRAM(gamma_15_'+zyo+'_full, LOCATIONS=xbin1, binsize = bin_size)')
    void = execute ('pdf2 = HISTOGRAM(gamma_16_'+zyo+'_full, LOCATIONS=xbin2, binsize = bin_size)')
    void = execute ('pdf3 = HISTOGRAM(gamma_17_'+zyo+'_full, LOCATIONS=xbin3, binsize = bin_size)')
    void = execute ('pdf4 = HISTOGRAM(gamma_18_'+zyo+'_full, LOCATIONS=xbin4, binsize = bin_size)')
    void = execute ('pdf5 = HISTOGRAM(gamma_19_'+zyo+'_full, LOCATIONS=xbin5, binsize = bin_size)')
    void = execute ('pdf6 = HISTOGRAM(gamma_20_'+zyo+'_full, LOCATIONS=xbin6, binsize = bin_size)')
    
    ;void = execute ('pdf1 = HISTOGRAM(gamma_16_'+zyo+'_full, LOCATIONS=xbin1, binsize = bin_size)')
    ;void = execute ('pdf2 = HISTOGRAM(gamma_17_'+zyo+'_full, LOCATIONS=xbin2, binsize = bin_size)')

    phisto = PLOT(xbin1, pdf1, thick = 2,$
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

    phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
       void = execute('phisto.save, "old_speci'+zys+'_opz_a.png"')
      
      phisto = PLOT(xbin4, pdf4, thick = 2, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)

    void = execute('phisto.save, "old_speci'+zys+'_opz_b.png"')

    ;phisto = PLOT(xbin1, pdf1, thick = 2,$
    ;  XTITLE=xtitle, YTITLE='Number of pixels', $
    ;  AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

    ;phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    ;  XTITLE=xtitle, YTITLE='Number of pixels', $
    ;  AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)


   
    

    zy= 2
    zyo = STRTRIM(zy, 1)
    zys = STRTRIM(zy+1, 1)

    bin_size = 0.05
    xrange = [1.0, 3.0]
    yrange = [0, 80]
    void = execute('xtitle = "zone'+zys+'"')
    
    void = execute ('pdf1 = HISTOGRAM(gamma_15_'+zyo+'_full, LOCATIONS=xbin1, binsize = bin_size)')
    void = execute ('pdf2 = HISTOGRAM(gamma_16_'+zyo+'_full, LOCATIONS=xbin2, binsize = bin_size)')
    void = execute ('pdf3 = HISTOGRAM(gamma_17_'+zyo+'_full, LOCATIONS=xbin3, binsize = bin_size)')
    void = execute ('pdf4 = HISTOGRAM(gamma_18_'+zyo+'_full, LOCATIONS=xbin4, binsize = bin_size)')
    void = execute ('pdf5 = HISTOGRAM(gamma_19_'+zyo+'_full, LOCATIONS=xbin5, binsize = bin_size)')
    void = execute ('pdf6 = HISTOGRAM(gamma_20_'+zyo+'_full, LOCATIONS=xbin6, binsize = bin_size)')
    
    phisto = PLOT(xbin1, pdf1, thick = 2,$
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='black', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

    phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='blue', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin3, pdf3, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
       void = execute('phisto.save, "old_speci'+zys+'_opz_a.png"')
      
      phisto = PLOT(xbin4, pdf4, thick = 2, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin5, pdf5, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='hot pink', xrange = xrange, yrange = yrange, /STAIRSTEP)
      
      phisto = PLOT(xbin6, pdf6, thick = 2, /overplot, $
      XTITLE=xtitle, YTITLE='Number of pixels', $
      AXIS_STYLE=1, COLOR='red', xrange = xrange, yrange = yrange, /STAIRSTEP)

    void = execute('phisto.save, "old_speci'+zys+'_opz_b.png"')
    
    ;void = execute ('pdf1 = HISTOGRAM(gamma_17_'+zyo+'_full, LOCATIONS=xbin1, binsize = bin_size)')
    ;void = execute ('pdf2 = HISTOGRAM(gamma_18_'+zyo+'_full, LOCATIONS=xbin2, binsize = bin_size)')



    ;phisto = PLOT(xbin1, pdf1, thick = 2,$
    ;  XTITLE=xtitle, YTITLE='Number of pixels', $
     ; AXIS_STYLE=1, COLOR='green', xrange = xrange, yrange = yrange, xthick = 2, ythick = 2, /STAIRSTEP)

    ;phisto = PLOT(xbin2, pdf2, thick = 2, /overplot, $
    ;  XTITLE=xtitle, YTITLE='Number of pixels', $
    ;  AXIS_STYLE=1, COLOR='orange', xrange = xrange, yrange = yrange, /STAIRSTEP)


    

  
  stop

end