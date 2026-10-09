pro mir_zone_temp

  ;restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/p_RS_7May24all_temp_intpl_wNan_fract_new.sav'
  
  restore, '/Users/nwalia/IDLWorkspace/ram_temp_fract_Mar.sav'
  restore, '/Users/nwalia/IDLWorkspace/ram_pres_fract_Mar.sav'

  all_ESA6= []
  l=180
  m=90
  zl=5
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)


  for yo = 11, 15 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Temp_all_'+yos+' = reverse(reform((Temp_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Temp_ESA2_'+yos+' = reverse(reform(Temp_ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA3_'+yos+' = reverse(reform(Temp_ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA4_'+yos+' = reverse(reform(Temp_ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA5_'+yos+' = reverse(reform(Temp_ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA6_'+yos+' = reverse(reform(Temp_ESA6_intpl[yo-9,0:l-1, 0:m-1]))')
  endfor

  for b = 11, 15 do begin

    year = STRTRIM(b, 2)


    oyn = 11
    oynn= oyn + 3
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(0, 1)

    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')


    for lati = 0, m-1 do begin
      for loni = 0, l-1 do begin

        ;void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 179) and (lon_arr[loni] le 329)  then pos_arr_'+ynn+'[loni, lati] = 1')
        ;void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 179) or (lon_arr[loni] gt 329) then pos_arr_'+ynn+'[loni, lati] = -1')
        void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') and (loni lt 110) then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

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

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_'+year+'[i,j])]')

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



;    ;for oyn = 18, 20 do begin
;    for oyn = 16, 19 do begin
;      oynn= oyn + 1
;      yn = STRTRIM(oyn, 1)
;      ynn = STRTRIM(oynn, 1)
;      zone = STRTRIM(oynn-16, 1)
;
;      void = execute('pos_arr_'+yn+'= intarr(l, m)')
;      void = execute('pos_arr_'+ynn+'= intarr(l, m)')
;      void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
;
;      for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
;
;        endfor
;      endfor
;
;      for lati = 0, m-1 do begin
;        for loni = 0, l-1 do begin
;
;          void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')
;
;        endfor
;      endfor
;
;      d=[]
;      dd=[]
;      e=[]
;      indices=[]
;
;      void = execute('Temp_'+year+'_'+zone+'_full_ESA2=[]')
;      void = execute('Temp_'+year+'_'+zone+'_full_ESA3=[]')
;      void = execute('Temp_'+year+'_'+zone+'_full_ESA4=[]')
;      void = execute('Temp_'+year+'_'+zone+'_full_ESA5=[]')
;      void = execute('Temp_'+year+'_'+zone+'_full_ESA6=[]')
;
;      for j = 0, 90-1 do begin
;        for i = 0, 180-1 do begin
;
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_intpl[b-9,i,j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_intpl[b-9,i,j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_intpl[b-9,i,j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_intpl[b-9,i,j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_intpl[b-9,i,j])]')
;        endfor
;
;      endfor
;      void = execute('Temp_'+year+'_'+zone+'_ESA2_avg = mean(Temp_'+year+'_'+zone+'_full_ESA2)')
;      void = execute('Temp_'+year+'_'+zone+'_ESA3_avg = mean(Temp_'+year+'_'+zone+'_full_ESA3)')
;      void = execute('Temp_'+year+'_'+zone+'_ESA4_avg = mean(Temp_'+year+'_'+zone+'_full_ESA4)')
;      void = execute('Temp_'+year+'_'+zone+'_ESA5_avg = mean(Temp_'+year+'_'+zone+'_full_ESA5)')
;      void = execute('Temp_'+year+'_'+zone+'_ESA6_avg = mean(Temp_'+year+'_'+zone+'_full_ESA6)')
;      void = execute('Temp_'+year+'_'+zone+'_ESAall = (Temp_'+year+'_'+zone+'_full_ESA2+Temp_'+year+'_'+zone+'_full_ESA3+Temp_'+year+'_'+zone+'_full_ESA4+Temp_'+year+'_'+zone+'_full_ESA5+Temp_'+year+'_'+zone+'_full_ESA6)/6')
;      void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall)')
;      void = execute('Temp_'+year+'_'+zone+'_ESAall_sd = stddev(Temp_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(Temp_'+year+'_'+zone+'_full_ESA2))')
;      void = execute('nan_rep'+year+'_'+zone+'=where (Temp_'+year+'_'+zone+'_ESAall eq 0.00000)')
;      void = execute('Temp_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
;      void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall, /nan)')
;      void = execute('Temp_'+year+'_'+zone+'_sd = [stddev(Temp_'+year+'_'+zone+'_full_ESA2), stddev(Temp_'+year+'_'+zone+'_full_ESA3), stddev(Temp_'+year+'_'+zone+'_full_ESA4), stddev(Temp_'+year+'_'+zone+'_full_ESA5), stddev(Temp_'+year+'_'+zone+'_full_ESA6)]')
;
;
;
;
;    endfor

    ;stop

  endfor

  ;stop

  ;all_ESA6= []
  
  
  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  Temp_1 = [Temp_11_0_ESAall_avg, Temp_12_0_ESAall_avg, Temp_13_0_ESAall_avg, Temp_14_0_ESAall_avg, Temp_15_0_ESAall_avg]
  Temp_er1 = [Temp_11_0_ESAall_sd, Temp_12_0_ESAall_sd, Temp_13_0_ESAall_sd, Temp_14_0_ESAall_sd, Temp_15_0_ESAall_sd]
  g1a = errorplot(time1, Temp_1, Temp_er1, xrange=[2011, 2016], yrange=[3700000, 4000000], xminor=0,XTITLE="Year in HS", YTITLE="Temperature (K)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15
  temp_avg_ram = (Temp_11_0_ESAall_avg+Temp_12_0_ESAall_avg+Temp_13_0_ESAall_avg+Temp_14_0_ESAall_avg+Temp_15_0_ESAall_avg)/6

  
  ;;;;;;;;;;;;
  
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7May24all_temp_intpl_wNan_fract_new.sav'
  
  restore, '/Users/nwalia/IDLWorkspace/Aram_temp_fract_Sep.sav'
  restore, '/Users/nwalia/IDLWorkspace/Aram_pres_fract_Sep.sav'

  all_ESA6= []
  l=180
  m=90
  zl=5
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)


  for yo = 11, 15 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
    void = execute('Temp_all_'+yos+' = reverse(reform((Temp_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Temp_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Temp_ESA2_'+yos+' = reverse(reform(Temp_ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA3_'+yos+' = reverse(reform(Temp_ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA4_'+yos+' = reverse(reform(Temp_ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA5_'+yos+' = reverse(reform(Temp_ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA6_'+yos+' = reverse(reform(Temp_ESA6_intpl[yo-9,0:l-1, 0:m-1]))')
  endfor

  for b = 11, 15 do begin

    year = STRTRIM(b, 2)


    oyn = 11
    oynn= oyn + 3
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(0, 1)

;    void = execute('pos_arr_'+yn+'= intarr(l, m)')
;    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
;    void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
;
;
;    for lati = 0, m-1 do begin
;      for loni = 0, l-1 do begin
;
;        ;void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 179) and (lon_arr[loni] le 329)  then pos_arr_'+ynn+'[loni, lati] = 1')
;        ;void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 179) or (lon_arr[loni] gt 329) then pos_arr_'+ynn+'[loni, lati] = -1')
;        void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') and (loni lt 110) then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')
;
;      endfor
;    endfor
;
;    d=[]
;    d_o=[]
;    dd=[]
;    e=[]
;    indices=[]


    void = execute('Temp_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Temp_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

       void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_'+year+'[i,j])]')

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



    ;    ;for oyn = 18, 20 do begin
    ;    for oyn = 16, 19 do begin
    ;      oynn= oyn + 1
    ;      yn = STRTRIM(oyn, 1)
    ;      ynn = STRTRIM(oynn, 1)
    ;      zone = STRTRIM(oynn-16, 1)
    ;
    ;      void = execute('pos_arr_'+yn+'= intarr(l, m)')
    ;      void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    ;      void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
    ;
    ;      for lati = 0, m-1 do begin
    ;        for loni = 0, l-1 do begin
    ;
    ;          void = execute('if Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+yn+'[loni, lati] = 1 else pos_arr_'+yn+'[loni, lati] = -1')
    ;
    ;        endfor
    ;      endfor
    ;
    ;      for lati = 0, m-1 do begin
    ;        for loni = 0, l-1 do begin
    ;
    ;          void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')
    ;
    ;        endfor
    ;      endfor
    ;
    ;      d=[]
    ;      dd=[]
    ;      e=[]
    ;      indices=[]
    ;
    ;      void = execute('Temp_'+year+'_'+zone+'_full_ESA2=[]')
    ;      void = execute('Temp_'+year+'_'+zone+'_full_ESA3=[]')
    ;      void = execute('Temp_'+year+'_'+zone+'_full_ESA4=[]')
    ;      void = execute('Temp_'+year+'_'+zone+'_full_ESA5=[]')
    ;      void = execute('Temp_'+year+'_'+zone+'_full_ESA6=[]')
    ;
    ;      for j = 0, 90-1 do begin
    ;        for i = 0, 180-1 do begin
    ;
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_intpl[b-9,i,j])]')
    ;        endfor
    ;
    ;      endfor
    ;      void = execute('Temp_'+year+'_'+zone+'_ESA2_avg = mean(Temp_'+year+'_'+zone+'_full_ESA2)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESA3_avg = mean(Temp_'+year+'_'+zone+'_full_ESA3)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESA4_avg = mean(Temp_'+year+'_'+zone+'_full_ESA4)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESA5_avg = mean(Temp_'+year+'_'+zone+'_full_ESA5)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESA6_avg = mean(Temp_'+year+'_'+zone+'_full_ESA6)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESAall = (Temp_'+year+'_'+zone+'_full_ESA2+Temp_'+year+'_'+zone+'_full_ESA3+Temp_'+year+'_'+zone+'_full_ESA4+Temp_'+year+'_'+zone+'_full_ESA5+Temp_'+year+'_'+zone+'_full_ESA6)/6')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESAall_sd = stddev(Temp_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(Temp_'+year+'_'+zone+'_full_ESA2))')
    ;      void = execute('nan_rep'+year+'_'+zone+'=where (Temp_'+year+'_'+zone+'_ESAall eq 0.00000)')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    ;      void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall, /nan)')
    ;      void = execute('Temp_'+year+'_'+zone+'_sd = [stddev(Temp_'+year+'_'+zone+'_full_ESA2), stddev(Temp_'+year+'_'+zone+'_full_ESA3), stddev(Temp_'+year+'_'+zone+'_full_ESA4), stddev(Temp_'+year+'_'+zone+'_full_ESA5), stddev(Temp_'+year+'_'+zone+'_full_ESA6)]')
    ;
    ;
    ;
    ;
    ;    endfor

    ;stop

  endfor
  
  
  temp_avg_Aram = (Temp_11_0_ESAall_avg+Temp_12_0_ESAall_avg+Temp_13_0_ESAall_avg+Temp_14_0_ESAall_avg+Temp_15_0_ESAall_avg)/6
  temp_ratio = temp_avg_Aram/temp_avg_ram
  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  Temp_1 = [Temp_11_0_ESAall_avg/temp_ratio, Temp_12_0_ESAall_avg, Temp_13_0_ESAall_avg, Temp_14_0_ESAall_avg, Temp_15_0_ESAall_avg]
  Temp_er1 = [Temp_11_0_ESAall_sd, Temp_12_0_ESAall_sd, Temp_13_0_ESAall_sd, Temp_14_0_ESAall_sd, Temp_15_0_ESAall_sd]
  g2a = errorplot(time1, Temp_1, Temp_er1, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'
  
  g2a.save, 'mir_temp_hsm.png'

  stop
  
;
;  time1 = [2016, 2017, 2018, 2019, 2020]
;  time1a = [2016, 2017, 2018, 2019]
;  time1b = [2019, 2020]
;  time2 = [2017, 2018, 2019, 2020]
;  time2a = [2017, 2018, 2019]
;  time2b = [2019, 2020]
;  time3 = [2018, 2019, 2020]
;  time3a = [2018, 2019]
;  time3b = [2019, 2020]
;  time4 = [2018, 2019, 2020]
;  time7 = [2016]
;  time8 = [2017]
;  time9 = [2018]
;  time13= [2015]
;  time14= [2015,2016]
;  time15 = [2016,2017]
;  time16 = [2017,2018]
;
;  Temp_1 = [Temp_16_0_ESAall_avg, Temp_17_0_ESAall_avg, Temp_18_0_ESAall_avg, Temp_19_0_ESAall_avg, Temp_20_0_ESAall_avg]
;  Temp_1a = [Temp_16_0_ESAall_avg, Temp_17_0_ESAall_avg, Temp_18_0_ESAall_avg, Temp_19_0_ESAall_avg]
;  Temp_1b = [Temp_19_0_ESAall_avg, Temp_20_0_ESAall_avg]
;  Temp_2 = [Temp_17_1_ESAall_avg, Temp_18_1_ESAall_avg, Temp_19_1_ESAall_avg, Temp_20_1_ESAall_avg]
;  Temp_2a = [Temp_17_1_ESAall_avg, Temp_18_1_ESAall_avg, Temp_19_1_ESAall_avg]
;  Temp_2b = [Temp_19_1_ESAall_avg, Temp_20_1_ESAall_avg]
;  Temp_3 = [Temp_18_2_ESAall_avg, Temp_19_2_ESAall_avg, Temp_20_2_ESAall_avg]
;  Temp_3a = [Temp_18_2_ESAall_avg, Temp_19_2_ESAall_avg]
;  Temp_3b = [Temp_19_2_ESAall_avg, Temp_20_2_ESAall_avg]
;  Temp_4 = [Temp_18_3_ESAall_avg, Temp_19_3_ESAall_avg, Temp_20_3_ESAall_avg]
;  Temp_7 =  [Temp_16_1_ESAall_avg]
;  Temp_8 =  [Temp_17_2_ESAall_avg]
;  Temp_9 = [Temp_18_3_ESAall_avg]
;  Temp_13 = [Temp_15_0_ESAall_avg]
;  Temp_14 = [ Temp_15_0_ESAall_avg, Temp_16_0_ESAall_avg]
;  Temp_15 = [ Temp_16_1_ESAall_avg, Temp_17_1_ESAall_avg]
;  Temp_16 = [ Temp_17_2_ESAall_avg, Temp_18_2_ESAall_avg]
;
;  Temp_er1 = [Temp_16_0_ESAall_sd, Temp_17_0_ESAall_sd, Temp_18_0_ESAall_sd, Temp_19_0_ESAall_sd, Temp_20_0_ESAall_sd]
;  Temp_er1a = [Temp_16_0_ESAall_sd, Temp_17_0_ESAall_sd, Temp_18_0_ESAall_sd, Temp_19_0_ESAall_sd]
;  Temp_er1b = [Temp_19_0_ESAall_sd, Temp_20_0_ESAall_sd]
;  Temp_er2 = [Temp_17_1_ESAall_sd, Temp_18_1_ESAall_sd, Temp_19_1_ESAall_sd, Temp_20_1_ESAall_sd]
;  Temp_er2a = [Temp_17_1_ESAall_sd, Temp_18_1_ESAall_sd, Temp_19_1_ESAall_sd]
;  Temp_er2b = [Temp_19_1_ESAall_sd, Temp_20_1_ESAall_sd]
;  Temp_er3 = [Temp_18_2_ESAall_sd, Temp_19_2_ESAall_sd, Temp_20_2_ESAall_sd]
;  Temp_er3a = [Temp_18_2_ESAall_sd, Temp_19_2_ESAall_sd]
;  Temp_er3b = [Temp_19_2_ESAall_sd, Temp_20_2_ESAall_sd]
;  Temp_er4 = [Temp_18_3_ESAall_sd, Temp_19_3_ESAall_sd, Temp_20_3_ESAall_sd]
;  Temp_er7 =  [Temp_16_1_ESAall_sd]
;  Temp_er8 =  [Temp_17_2_ESAall_sd]
;  Temp_er9 = [Temp_18_3_ESAall_sd]
;  Temp_er13 = [Temp_15_0_ESAall_sd]
;  Temp_er14 = [Temp_15_0_ESAall_sd, Temp_16_0_ESAall_sd]
;  Temp_er15 = [Temp_16_1_ESAall_sd, Temp_17_1_ESAall_sd]
;  Temp_er16 = [Temp_17_2_ESAall_sd, Temp_18_2_ESAall_sd]
;
;  g1a = errorplot(time1a, Temp_1a, Temp_er1a, xrange=[2014, 2021], yrange=[3500000, 4500000], xminor=0,XTITLE="Year in HS", YTITLE="Temperature (K)")
;  g1a.symbol= 'o'
;  g1a.SYM_SIZE= 1
;  g1a.SYM_FILLED=1
;  g1a.FONT_SIZE=15
;
;  g1b = errorplot(time1b, Temp_1b, Temp_er1b, /overplot)
;  g1b.symbol= 'o'
;  g1b.SYM_SIZE= 1
;  g1b.SYM_FILLED=1
;  g1b.FONT_SIZE=15
;  g1b.LINESTYLE='-.'
;
;  g2a = errorplot(time2a, Temp_2a, Temp_er2a, /overplot)
;  g2a.symbol= 'o'
;  g2a.SYM_SIZE= 1
;  g2a.SYM_FILLED=1
;  g2a.FONT_SIZE=15
;  g2a.COLOR ="blue"
;  g2a.ERRORBAR_COLOR="blue"
;
;  g2b = errorplot(time2b, Temp_2b, Temp_er2b, /overplot)
;  g2b.symbol= 'o'
;  g2b.SYM_SIZE= 1
;  g2b.SYM_FILLED=1
;  g2b.FONT_SIZE=15
;  g2b.COLOR ="blue"
;  g2b.ERRORBAR_COLOR="blue"
;  g2b.LINESTYLE='-.'
;
;  g3a = errorplot(time3a, Temp_3a, Temp_er3a, /overplot)
;  g3a.symbol= 'o'
;  g3a.SYM_SIZE= 1
;  g3a.SYM_FILLED=1
;  g3a.FONT_SIZE=15
;  g3a.COLOR ="green"
;  g3a.ERRORBAR_COLOR="green"
;
;  g3b = errorplot(time3b, Temp_3b, Temp_er3b, /overplot)
;  g3b.symbol= 'o'
;  g3b.SYM_SIZE= 1
;  g3b.SYM_FILLED=1
;  g3b.FONT_SIZE=15
;  g3b.COLOR ="green"
;  g3b.ERRORBAR_COLOR="green"
;  g3b.LINESTYLE='-.'
;
;  ;g4 = errorplot(time4, Temp_4, Temp_er4, /overplot)
;  ;g4.symbol= 'o'
;  ;g4.SYM_SIZE= 1
;  ;g4.SYM_FILLED=1
;  ;g4.FONT_SIZE=15
;  ;g4.COLOR ="orange"
;  ;g4.ERRORBAR_COLOR="orange"
;  ;g4.LINESTYLE='--'
;
;
;  g6 = errorplot(time13, Temp_13, Temp_er13, /overplot)
;  g6.symbol= 'X'
;  g6.SYM_SIZE= 2
;  g6.SYM_FILLED=1
;  g6.FONT_SIZE=15
;
;  g7 = errorplot(time7, Temp_7, Temp_er7, /overplot)
;  g7.symbol= 'X'
;  g7.SYM_SIZE= 2
;  g7.SYM_FILLED=1
;  g7.FONT_SIZE=15
;  g7.COLOR ="blue"
;  g7.ERRORBAR_COLOR="blue"
;
;  g8 = errorplot(time8, Temp_8, Temp_er8, /overplot)
;  g8.symbol= 'X'
;  g8.SYM_SIZE= 2
;  g8.SYM_FILLED=1
;  g8.FONT_SIZE=15
;  g8.COLOR ="green"
;  g8.ERRORBAR_COLOR="green"
;
;  ;g9 = errorplot(time9, Temp_9, Temp_er9, /overplot)
;  ;g9.symbol= 'X'
;  ;g9.SYM_SIZE= 1
;  ;g9.SYM_FILLED=1
;  ;g9.FONT_SIZE=15
;  ;g9.COLOR ="orange"
;  ;g9.ERRORBAR_COLOR="orange"
;
;  g14 = errorplot(time14, Temp_14, Temp_er14, /overplot)
;  ;g10.symbol= '.'
;  ;g10.SYM_SIZE= 1
;  ;g10.SYM_FILLED=1
;  g14.FONT_SIZE=15
;  g14.COLOR ="black"
;  g14.ERRORBAR_COLOR="black"
;  g14.LINESTYLE='--'
;
;  g15 = errorplot(time15, Temp_15, Temp_er15, /overplot)
;  g15.FONT_SIZE=15
;  g15.COLOR ="blue"
;  g15.ERRORBAR_COLOR="blue"
;  g15.LINESTYLE='--'
;
;  g16 = errorplot(time16, Temp_16, Temp_er16, /overplot)
;  g16.FONT_SIZE=15
;  g16.COLOR ="green"
;  g16.ERRORBAR_COLOR="green"
;  g16.LINESTYLE='--'
;
;
;  g16.save, 'temp_hsm.png'

  end