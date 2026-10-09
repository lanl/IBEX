pro mir_zone_lospres_nomir_years

  all_ESA6= []
  l=180
  m=90
  zl=6
  num = STRTRIM(zl, 1)
  restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  restarri = 0

  for yo = 9, 20 do begin
    yos = STRTRIM(yo, 1)
    ;void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Pres_ESA2_'+yos+' = reverse(reform(Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA3_'+yos+' = reverse(reform(Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA4_'+yos+' = reverse(reform(Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA5_'+yos+' = reverse(reform(Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA6_'+yos+' = reverse(reform(Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]))')


  endfor

  ;stop

  for b = 9, 20 do begin

    year = STRTRIM(b, 2)

    oyn = 11
    oynn= oyn+3
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(0, 1)

    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')


    for lati = 0, m-1 do begin
      for loni = 0, l-1 do begin

        ; void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 209) and (lon_arr[loni] le 359) then pos_arr_'+ynn+'[loni, lati] = -1')
        ; void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 209) or (lon_arr[loni] gt 359) then pos_arr_'+ynn+'[loni, lati] = +1')
        ;void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 179) and (lon_arr[loni] le 329) then pos_arr_'+ynn+'[loni, lati] = 1')
        ;void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 179) or (lon_arr[loni] gt 329) then pos_arr_'+ynn+'[loni, lati] = -1')
        void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') and (loni lt 110) then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')


      endfor
    endfor

    d=[]
    d_o=[]
    dd=[]
    e=[]
    indices=[]

    ;    for j = 0, m-1 do begin
    ;      for i = 0, l-1 do begin
    ;        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then d = [d,i]')
    ;      endfor
    ;
    ;      if n_elements(d) gt 0 then dd= [dd, d]
    ;      if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
    ;      d=[]
    ;    endfor
    ;
    ;    void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = mean(Pres_all_'+year+'[dd,e], /nan)')
    ;    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = stddev(Pres_all_'+year+'[dd,e], /nan)/sqrt(n_elements(Pres_all_'+ynn+'[dd,e]))')



    void = execute('Pres_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_'+year+'[i,j])]')

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
    ;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    ;      void = execute('Pres_'+year+'_'+zone+'_full_ESA2=[]')
    ;      void = execute('Pres_'+year+'_'+zone+'_full_ESA3=[]')
    ;      void = execute('Pres_'+year+'_'+zone+'_full_ESA4=[]')
    ;      void = execute('Pres_'+year+'_'+zone+'_full_ESA5=[]')
    ;      void = execute('Pres_'+year+'_'+zone+'_full_ESA6=[]')
    ;
    ;      for j = 0, 90-1 do begin
    ;        for i = 0, 180-1 do begin
    ;
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_intpl[b-9,i,j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_intpl[b-9,i,j])]')
    ;        endfor
    ;
    ;      endfor
    ;      void = execute('Pres_'+year+'_'+zone+'_ESA2_avg = mean(Pres_'+year+'_'+zone+'_full_ESA2, /nan)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESA3_avg = mean(Pres_'+year+'_'+zone+'_full_ESA3, /nan)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESA4_avg = mean(Pres_'+year+'_'+zone+'_full_ESA4, /nan)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESA5_avg = mean(Pres_'+year+'_'+zone+'_full_ESA5, /nan)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESA6_avg = mean(Pres_'+year+'_'+zone+'_full_ESA6, /nan)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESAall = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
    ;      void = execute('nan_rep'+year+'_'+zone+'=where (Pres_'+year+'_'+zone+'_ESAall eq 0.00000)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = mean(Pres_'+year+'_'+zone+'_ESAall, /nan)')
    ;      void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = stddev(Pres_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Pres_'+year+'_'+zone+'_ESAall))')
    ;
    ;
    ;
    ;
    ;    endfor

    ;stop

  endfor

  ;fp4 = spec_plot(ESA6_INTPL[11-9,*,*], LON_ARR, LAT_ARR)

  stop

  time_1 = [2011, 2012, 2013, 2014, 2015]
  Pres_1 = [Pres_11_0_ESAall_avg, Pres_12_0_ESAall_avg, Pres_13_0_ESAall_avg, Pres_14_0_ESAall_avg, Pres_15_0_ESAall_avg]
  Pres_er1 = [Pres_11_0_ESAall_sd, Pres_12_0_ESAall_sd, Pres_13_0_ESAall_sd, Pres_14_0_ESAall_sd, Pres_15_0_ESAall_sd]

  g1a = errorplot(time_1, Pres_1, Pres_er1, xrange=[2010, 2016], yrange=[20, 26], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  ;g1a = errorplot(time_1, Pres_1, Pres_er1, xrange=[2010, 2016], yrange=[10, 30], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  ;stop
  ;ram_LOSPres_11

  ;;;;;;;;;;;;Aram;;;;;;;;;;;;;

  ;restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  restarri = 0

  for yo = 11, 15 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Pres_ESA2_'+yos+' = reverse(reform(Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA3_'+yos+' = reverse(reform(Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA4_'+yos+' = reverse(reform(Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA5_'+yos+' = reverse(reform(Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA6_'+yos+' = reverse(reform(Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]))')
  endfor

  ;stop

  for b = 11, 15 do begin

    year = STRTRIM(b, 2)

    oyn = 11
    oynn= oyn + 3
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(0, 1)

    ;    void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = mean(Pres_all_'+year+'[dd,e], /nan)')
    ;    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = stddev(Pres_all_'+year+'[dd,e], /nan)/sqrt(n_elements(Pres_all_'+ynn+'[dd,e]))')

    ;    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    ;    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    ;    void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')


    ;    for lati = 0, m-1 do begin
    ;      for loni = 0, l-1 do begin
    ;
    ;        ; void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 209) and (lon_arr[loni] le 359) then pos_arr_'+ynn+'[loni, lati] = -1')
    ;        ; void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 209) or (lon_arr[loni] gt 359) then pos_arr_'+ynn+'[loni, lati] = +1')
    ;        ;void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 179) and (lon_arr[loni] le 329) then pos_arr_'+ynn+'[loni, lati] = 1')
    ;        ;void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 179) or (lon_arr[loni] gt 329) then pos_arr_'+ynn+'[loni, lati] = -1')
    ;        void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') and (loni lt 110) then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')
    ;
    ;
    ;      endfor
    ;    endfor
    ;
    ;    d=[]
    ;    d_o=[]
    ;    dd=[]
    ;    e=[]
    ;    indices=[]


    void = execute('Pres_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Pres_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_'+year+'[i,j])]')

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
    ;          void = execute('Pres_'+year+'_'+zone+'_full_ESA2=[]')
    ;          void = execute('Pres_'+year+'_'+zone+'_full_ESA3=[]')
    ;          void = execute('Pres_'+year+'_'+zone+'_full_ESA4=[]')
    ;          void = execute('Pres_'+year+'_'+zone+'_full_ESA5=[]')
    ;          void = execute('Pres_'+year+'_'+zone+'_full_ESA6=[]')
    ;
    ;          for j = 0, 90-1 do begin
    ;            for i = 0, 180-1 do begin
    ;
    ;              void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_intpl[b-9,i,j])]')
    ;              void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_intpl[b-9,i,j])]')
    ;              void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_intpl[b-9,i,j])]')
    ;              void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_intpl[b-9,i,j])]')
    ;              void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_intpl[b-9,i,j])]')
    ;            endfor
    ;
    ;          endfor
    ;          void = execute('Pres_'+year+'_'+zone+'_ESA2_avg = mean(Pres_'+year+'_'+zone+'_full_ESA2, /nan)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESA3_avg = mean(Pres_'+year+'_'+zone+'_full_ESA3, /nan)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESA4_avg = mean(Pres_'+year+'_'+zone+'_full_ESA4, /nan)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESA5_avg = mean(Pres_'+year+'_'+zone+'_full_ESA5, /nan)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESA6_avg = mean(Pres_'+year+'_'+zone+'_full_ESA6, /nan)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESAall = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
    ;          void = execute('nan_rep'+year+'_'+zone+'=where (Pres_'+year+'_'+zone+'_ESAall eq 0.00000)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = mean(Pres_'+year+'_'+zone+'_ESAall, /nan)')
    ;          void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = stddev(Pres_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Pres_'+year+'_'+zone+'_ESAall))')
    ;
    ;
    ;
    ;
    ;    endfor

    ;stop

  endfor

  ;fp4 = spec_plot(ESA6_INTPL[11-9,*,*], LON_ARR, LAT_ARR)

  ;stop

  time_1 = [2011, 2012, 2013, 2014, 2015]
  Pres_1 = [Pres_11_0_ESAall_avg, Pres_12_0_ESAall_avg, Pres_13_0_ESAall_avg, Pres_14_0_ESAall_avg, Pres_15_0_ESAall_avg]
  Pres_er1 = [Pres_11_0_ESAall_sd, Pres_12_0_ESAall_sd, Pres_13_0_ESAall_sd, Pres_14_0_ESAall_sd, Pres_15_0_ESAall_sd]

  ;g1a = errorplot(time_1, Pres_1, Pres_er1, xrange=[2010, 2016], yrange=[19, 22], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  g2a = errorplot(time_1, Pres_1, Pres_er1, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'

  g2a.save, 'mir_lospres_hsm.png'


  stop

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mx = 40.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 250]
  
  pdf9 = HISTOGRAM(Pres_9_0_ESAall, LOCATIONS=xbin9,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin9[0:4], pdf9[0:4], XTITLE='2009', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin9[5:12], pdf9[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin9[13:20], pdf9[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin9[21:28], pdf9[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin9[29:36], pdf9[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin9[37:44], pdf9[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin9[45:52], pdf9[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin9[53:60], pdf9[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    pdf10 = HISTOGRAM(Pres_10_0_ESAall, LOCATIONS=xbin10,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin10[0:4], pdf10[0:4], XTITLE='2010', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin10[5:12], pdf10[5:12], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin10[13:20], pdf10[13:20], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin10[21:28], pdf10[21:28],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin10[29:36], pdf10[29:36], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin10[37:44], pdf10[37:44],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin10[45:52], pdf10[45:52], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin10[53:60], pdf10[53:60], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  pdf11 = HISTOGRAM(Pres_11_0_ESAall, LOCATIONS=xbin11,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin11[0:4], pdf11[0:4], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin11[5:12], pdf11[5:12], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[13:20], pdf11[13:20], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[21:28], pdf11[21:28], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[29:36], pdf11[29:36], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[37:44], pdf11[37:44], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[45:52], pdf11[45:52], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[53:60], pdf11[53:60], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf12 = HISTOGRAM(Pres_12_0_ESAall, LOCATIONS=xbin12,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin12[0:4], pdf12[0:4], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin12[5:12], pdf12[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin12[13:20], pdf12[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin12[21:28], pdf12[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin12[29:36], pdf12[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin12[37:44], pdf12[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin12[45:52], pdf12[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin12[53:60], pdf12[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf13 = HISTOGRAM(Pres_13_0_ESAall, LOCATIONS=xbin13,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin13[0:4], pdf13[0:4], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin13[5:12], pdf13[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin13[13:20], pdf13[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin13[21:28], pdf13[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin13[29:36], pdf13[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin13[37:44], pdf13[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin13[45:52], pdf13[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin13[53:60], pdf13[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf14 = HISTOGRAM(Pres_14_0_ESAall, LOCATIONS=xbin14,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin14[0:4], pdf14[0:4], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin14[5:12], pdf14[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[13:20], pdf14[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[21:28], pdf14[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[29:36], pdf14[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[37:44], pdf14[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[45:52], pdf18[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[53:60], pdf14[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  pdf20 = HISTOGRAM(Pres_20_0_ESAall, LOCATIONS=xbin20,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin20[0:4], pdf20[0:4], XTITLE='2020', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin20[5:12], pdf20[5:12], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin20[13:20], pdf20[13:20], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin20[21:28], pdf20[21:28],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin20[29:36], pdf20[29:36], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin20[37:44], pdf20[37:44],  $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin20[45:52], pdf20[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin20[53:60], pdf20[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )



end
