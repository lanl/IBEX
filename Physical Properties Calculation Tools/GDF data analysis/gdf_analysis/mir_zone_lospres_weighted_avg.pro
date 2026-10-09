pro mir_zone_lospres_weighted_avg

  all_ESA6= []
  l=180
  m=90
  zl=6
  num = STRTRIM(zl, 1)
  ;restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

  restore, '/Users/nwalia/IDLWorkspace/ram_pres_fract_Mar.sav'

  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  restarri = 0

  for yo = 11, 16 do begin
    yos = STRTRIM(yo, 1)

    ;void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Pres_ESA2_'+yos+' = reverse(reform(Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA3_'+yos+' = reverse(reform(Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA4_'+yos+' = reverse(reform(Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA5_'+yos+' = reverse(reform(Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA6_'+yos+' = reverse(reform(Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA2_stdev_'+yos+' = reverse(reform(Pres_ESA2_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA3_stdev_'+yos+' = reverse(reform(Pres_ESA3_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA4_stdev_'+yos+' = reverse(reform(Pres_ESA4_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA5_stdev_'+yos+' = reverse(reform(Pres_ESA5_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA6_stdev_'+yos+' = reverse(reform(Pres_ESA6_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    
    void = execute('time_ESA2_'+yos+' = reverse(reform(2000.25+yos+ESA2_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA3_'+yos+' = reverse(reform(2000.25+yos+ESA3_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA4_'+yos+' = reverse(reform(2000.25+yos+ESA4_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA5_'+yos+' = reverse(reform(2000.25+yos+ESA5_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA6_'+yos+' = reverse(reform(2000.25+yos+ESA6_t_y[0:l-1, 0:m-1]))')


  endfor

  
  for b = 11, 16 do begin

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
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA2=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA3=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA4=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA5=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA6=[]')
    
    void = execute('time_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_stdev_ESA2 = [Pres_'+year+'_'+zone+'_stdev_ESA2,(Pres_ESA2_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_stdev_ESA3 = [Pres_'+year+'_'+zone+'_stdev_ESA3,(Pres_ESA3_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_stdev_ESA4 = [Pres_'+year+'_'+zone+'_stdev_ESA4,(Pres_ESA4_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_stdev_ESA5 = [Pres_'+year+'_'+zone+'_stdev_ESA5,(Pres_ESA5_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_stdev_ESA6 = [Pres_'+year+'_'+zone+'_stdev_ESA6,(Pres_ESA6_stdev_'+year+'[i,j])]')
        
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then time_'+year+'_'+zone+'_full_ESA2 = [time_'+year+'_'+zone+'_full_ESA2,(time_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then time_'+year+'_'+zone+'_full_ESA3 = [time_'+year+'_'+zone+'_full_ESA3,(time_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then time_'+year+'_'+zone+'_full_ESA4 = [time_'+year+'_'+zone+'_full_ESA4,(time_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then time_'+year+'_'+zone+'_full_ESA5 = [time_'+year+'_'+zone+'_full_ESA5,(time_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then time_'+year+'_'+zone+'_full_ESA6 = [time_'+year+'_'+zone+'_full_ESA6,(time_ESA6_'+year+'[i,j])]')

      endfor

    endfor

    void = execute('Pres_'+year+'_'+zone+'_ESA2_avg = total(Pres_'+year+'_'+zone+'_full_ESA2/(Pres_'+year+'_'+zone+'_stdev_ESA2)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA2)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA3_avg = total(Pres_'+year+'_'+zone+'_full_ESA3/(Pres_'+year+'_'+zone+'_stdev_ESA3)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA3)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA4_avg = total(Pres_'+year+'_'+zone+'_full_ESA4/(Pres_'+year+'_'+zone+'_stdev_ESA4)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA4)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA5_avg = total(Pres_'+year+'_'+zone+'_full_ESA5/(Pres_'+year+'_'+zone+'_stdev_ESA5)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA5)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA6_avg = total(Pres_'+year+'_'+zone+'_full_ESA6/(Pres_'+year+'_'+zone+'_stdev_ESA6)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA6)^(-2), /nan)')
    
    void = execute('Pres_'+year+'_'+zone+'_ESAall = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESAall = sqrt(total([[Pres_'+year+'_'+zone+'_stdev_ESA2^2],[Pres_'+year+'_'+zone+'_stdev_ESA3^2], [Pres_'+year+'_'+zone+'_stdev_ESA4^2], [Pres_'+year+'_'+zone+'_stdev_ESA5^2], [Pres_'+year+'_'+zone+'_stdev_ESA6^2]] , 2, /nan))')
    void = execute('nan_rep'+year+'_'+zone+'=where (Pres_'+year+'_'+zone+'_ESAall eq 0.00000)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    ;avg calculated from total pres of all ESAs as in 13-10-25 pres
    void = execute('Pres_'+year+'_'+zone+'_ESAall_avg_o = total(Pres_'+year+'_'+zone+'_ESAall/(Pres_'+year+'_'+zone+'_stdev_ESAall)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd_o = stddev(Pres_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Pres_'+year+'_'+zone+'_ESAall))')
    ;void = execute('Pres_'+year+'_'+zone+'_ESAall_sd_map = sqrt(1/(total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2))))')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = sqrt((1/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan))+(((stddev(Pres_'+year+'_'+zone+'_ESAall, /nan))^2)/n_elements(Pres_'+year+'_'+zone+'_ESAall)))')
    ;standard deviation without divison by n
    ;void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = sqrt((1/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan))+(stddev(Pres_'+year+'_'+zone+'_ESAall, /nan))^2)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = total([Pres_'+year+'_'+zone+'_ESA2_avg]+[Pres_'+year+'_'+zone+'_ESA3_avg]+[Pres_'+year+'_'+zone+'_ESA4_avg]+[Pres_'+year+'_'+zone+'_ESA5_avg]+[Pres_'+year+'_'+zone+'_ESA6_avg])')
    
    void = execute('time_'+year+'_'+zone+'_ESA2_avg = mean(time_'+year+'_'+zone+'_full_ESA2, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA3_avg = mean(time_'+year+'_'+zone+'_full_ESA3, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA4_avg = mean(time_'+year+'_'+zone+'_full_ESA4, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA5_avg = mean(time_'+year+'_'+zone+'_full_ESA5, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA6_avg = mean(time_'+year+'_'+zone+'_full_ESA6, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA2_sd = stddev(time_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA2))')
    void = execute('time_'+year+'_'+zone+'_ESA3_sd = stddev(time_'+year+'_'+zone+'_full_ESA3, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA3))')
    void = execute('time_'+year+'_'+zone+'_ESA4_sd = stddev(time_'+year+'_'+zone+'_full_ESA4, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA4))')
    void = execute('time_'+year+'_'+zone+'_ESA5_sd = stddev(time_'+year+'_'+zone+'_full_ESA5, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA5))')
    void = execute('time_'+year+'_'+zone+'_ESA6_sd = stddev(time_'+year+'_'+zone+'_full_ESA6, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA6))')
    
;stop
  endfor

;time plots for HS data to 1 AU IBEX data
  time_1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  au_time_esa2 = [time_11_0_ESA2_avg, time_12_0_ESA2_avg, time_13_0_ESA2_avg, time_14_0_ESA2_avg, time_15_0_ESA2_avg]
  au_time_er_esa2 = [time_11_0_ESA2_sd, time_12_0_ESA2_sd, time_13_0_ESA2_sd, time_14_0_ESA2_sd, time_15_0_ESA2_sd]
  g1a = errorplot(time_1, au_time_esa2, au_time_er_esa2, xrange=[2011, 2016], yrange=[2009, 2016], xminor=0,XTITLE="Year in HS", YTITLE="ESA2 Year in AU")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  time_1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  au_time_esa3 = [time_11_0_ESA3_avg, time_12_0_ESA3_avg, time_13_0_ESA3_avg, time_14_0_ESA3_avg, time_15_0_ESA3_avg]
  au_time_er_esa3 = [time_11_0_ESA3_sd, time_12_0_ESA3_sd, time_13_0_ESA3_sd, time_14_0_ESA3_sd, time_15_0_ESA3_sd]
  g1a = errorplot(time_1, au_time_esa3, au_time_er_esa3, xrange=[2011, 2016], yrange=[2009, 2016], xminor=0,XTITLE="Year in HS", YTITLE="ESA3 Year in AU")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  time_1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  au_time_esa4 = [time_11_0_ESA4_avg, time_12_0_ESA4_avg, time_13_0_ESA4_avg, time_14_0_ESA4_avg, time_15_0_ESA4_avg]
  au_time_er_esa4 = [time_11_0_ESA4_sd, time_12_0_ESA4_sd, time_13_0_ESA4_sd, time_14_0_ESA4_sd, time_15_0_ESA4_sd]
  g1a = errorplot(time_1, au_time_esa4, au_time_er_esa4, xrange=[2011, 2016], yrange=[2009, 2016], xminor=0,XTITLE="Year in HS", YTITLE="ESA4 Year in AU")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  time_1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  au_time_esa5 = [time_11_0_ESA5_avg, time_12_0_ESA5_avg, time_13_0_ESA5_avg, time_14_0_ESA5_avg, time_15_0_ESA5_avg]
  au_time_er_esa5 = [time_11_0_ESA5_sd, time_12_0_ESA5_sd, time_13_0_ESA5_sd, time_14_0_ESA5_sd, time_15_0_ESA5_sd]
  g1a = errorplot(time_1, au_time_esa5, au_time_er_esa5, xrange=[2011, 2016], yrange=[2009, 2016], xminor=0,XTITLE="Year in HS", YTITLE="ESA5 Year in AU")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  time_1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  au_time_esa6 = [time_11_0_ESA6_avg, time_12_0_ESA6_avg, time_13_0_ESA6_avg, time_14_0_ESA6_avg, time_15_0_ESA6_avg]
  au_time_er_esa6 = [time_11_0_ESA6_sd, time_12_0_ESA6_sd, time_13_0_ESA6_sd, time_14_0_ESA6_sd, time_15_0_ESA6_sd]
  g1a = errorplot(time_1, au_time_esa6, au_time_er_esa6, xrange=[2011, 2016], yrange=[2009, 2016], xminor=0,XTITLE="Year in HS", YTITLE="ESA6 Year in AU")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

  time_1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  Pres_1 = [Pres_11_0_ESAall_avg, Pres_12_0_ESAall_avg, Pres_13_0_ESAall_avg, Pres_14_0_ESAall_avg, Pres_15_0_ESAall_avg]
  Pres_er1 = [Pres_11_0_ESAall_sd, Pres_12_0_ESAall_sd, Pres_13_0_ESAall_sd, Pres_14_0_ESAall_sd, Pres_15_0_ESAall_sd]

  g1a = errorplot(time_1, Pres_1, Pres_er1, xrange=[2011, 2016], yrange=[19, 22], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  ;g1a = errorplot(time_1, Pres_1, Pres_er1, xrange=[2010, 2016], yrange=[10, 30], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15

; wrong scaling -> only use ESA scaling not Pres_scaling
;  Pres_1_avg_ram = (Pres_11_0_ESAall_avg+Pres_12_0_ESAall_avg+Pres_13_0_ESAall_avg+Pres_14_0_ESAall_avg+Pres_15_0_ESAall_avg)/6
;  Pres_ram_scal = [(Pres_11_0_ESAall_avg+Pres_12_0_ESAall_avg)/2, (Pres_12_0_ESAall_avg+Pres_13_0_ESAall_avg)/2, (Pres_13_0_ESAall_avg+Pres_14_0_ESAall_avg)/2, (Pres_14_0_ESAall_avg+Pres_15_0_ESAall_avg)/2, (Pres_15_0_ESAall_avg+Pres_16_0_ESAall_avg)/2]
stop
  mx = 40.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 250]

    pdf11 = HISTOGRAM(Pres_11_0_ESAall, LOCATIONS=xbin11,  MAX= mx, MIN= mn, binsize = binsize)
  
    graphic = BARPLOT(xbin11[0:3], pdf11[0:3], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
  
    graphic = BARPLOT(xbin11[4:11], pdf11[4:11], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin11[12:19], pdf11[12:19], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin11[20:27], pdf11[20:27], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin11[28:35], pdf11[28:35], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin11[36:43], pdf11[36:43], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin11[45:52], pdf11[45:52], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin11[53:60], pdf11[53:60], XTITLE='2011.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    ;-------------
  
    pdf12 = HISTOGRAM(Pres_12_0_ESAall, LOCATIONS=xbin12,  MAX= mx, MIN= mn, binsize = binsize)
  
    graphic = BARPLOT(xbin12[0:3], pdf12[0:3], XTITLE='2012.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
  
    graphic = BARPLOT(xbin12[4:11], pdf12[4:11], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin12[13:19], pdf12[13:19], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin12[20:27], pdf12[20:27],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin12[28:35], pdf12[28:35], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin12[36:43], pdf12[36:43],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin12[45:52], pdf12[45:52], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin12[53:60], pdf12[53:60], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
  
    ;-------------
  
    pdf13 = HISTOGRAM(Pres_13_0_ESAall, LOCATIONS=xbin13,  MAX= mx, MIN= mn, binsize = binsize)
  
    graphic = BARPLOT(xbin13[0:3], pdf13[0:3], XTITLE='2013.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
  
    graphic = BARPLOT(xbin13[4:11], pdf13[4:11], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin13[13:19], pdf13[13:19], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin13[20:27], pdf13[20:27],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin13[28:35], pdf13[28:35], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin13[36:43], pdf13[36:43],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin13[45:52], pdf13[45:52], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin13[53:60], pdf13[53:60], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
  
    ;-------------
  
    pdf14 = HISTOGRAM(Pres_14_0_ESAall, LOCATIONS=xbin14,  MAX= mx, MIN= mn, binsize = binsize)
  
    graphic = BARPLOT(xbin14[0:3], pdf14[0:3], XTITLE='2014.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
  
    graphic = BARPLOT(xbin14[4:11], pdf14[4:11], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin14[13:19], pdf14[13:19], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin14[20:27], pdf14[20:27],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin14[28:35], pdf14[28:35], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin14[36:43], pdf14[36:43],  $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin14[45:52], pdf14[45:52], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin14[53:60], pdf14[53:60], $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
  
    ;-------------
  
    pdf15 = HISTOGRAM(Pres_15_0_ESAall, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)
  
    graphic = BARPLOT(xbin15[0:3], pdf15[0:3], XTITLE='2015.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
  
    graphic = BARPLOT(xbin15[4:11], pdf15[4:11], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin15[13:19], pdf15[13:19], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin15[20:27], pdf15[20:27], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin15[28:35], pdf15[28:35], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin15[36:43], pdf15[36:43], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin15[45:52], pdf15[45:52], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
    graphic = BARPLOT(xbin15[53:60], pdf15[53:60], XTITLE='2015.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;stop
  ;ram_LOSPres_11

  ;;;;;;;;;;;;Aram;;;;;;;;;;;;;

  ;restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

  ;restore, '/Users/nwalia/IDLWorkspace/Aram_pres_fract_Sep.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_pres_scal.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_pres_scal_new_wa.sav'
  restore, '/Users/nwalia/IDLWorkspace/Aram_pres_scal_new_wa_rem_lp.sav'


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
    void = execute('Pres_ESA2_stdev_'+yos+' = reverse(reform(Pres_ESA2_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA3_stdev_'+yos+' = reverse(reform(Pres_ESA3_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA4_stdev_'+yos+' = reverse(reform(Pres_ESA4_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA5_stdev_'+yos+' = reverse(reform(Pres_ESA5_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Pres_ESA6_stdev_'+yos+' = reverse(reform(Pres_ESA6_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    
    void = execute('time_ESA2_'+yos+' = reverse(reform(2000.75+yos+ESA2_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA3_'+yos+' = reverse(reform(2000.75+yos+ESA3_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA4_'+yos+' = reverse(reform(2000.75+yos+ESA4_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA5_'+yos+' = reverse(reform(2000.75+yos+ESA5_t_y[0:l-1, 0:m-1]))')
    void = execute('time_ESA6_'+yos+' = reverse(reform(2000.75+yos+ESA6_t_y[0:l-1, 0:m-1]))')
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
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA2=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA3=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA4=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA5=[]')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESA6=[]')
    
    void = execute('time_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('time_'+year+'_'+zone+'_full_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA2 = [Pres_'+year+'_'+zone+'_full_ESA2,(Pres_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA3 = [Pres_'+year+'_'+zone+'_full_ESA3,(Pres_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_full_ESA4 = [Pres_'+year+'_'+zone+'_full_ESA4,(Pres_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA5 = [Pres_'+year+'_'+zone+'_full_ESA5,(Pres_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_full_ESA6 = [Pres_'+year+'_'+zone+'_full_ESA6,(Pres_ESA6_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_stdev_ESA2 = [Pres_'+year+'_'+zone+'_stdev_ESA2,(Pres_ESA2_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_stdev_ESA3 = [Pres_'+year+'_'+zone+'_stdev_ESA3,(Pres_ESA3_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Pres_'+year+'_'+zone+'_stdev_ESA4 = [Pres_'+year+'_'+zone+'_stdev_ESA4,(Pres_ESA4_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_stdev_ESA5 = [Pres_'+year+'_'+zone+'_stdev_ESA5,(Pres_ESA5_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Pres_'+year+'_'+zone+'_stdev_ESA6 = [Pres_'+year+'_'+zone+'_stdev_ESA6,(Pres_ESA6_stdev_'+year+'[i,j])]')
        
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then time_'+year+'_'+zone+'_full_ESA2 = [time_'+year+'_'+zone+'_full_ESA2,(time_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then time_'+year+'_'+zone+'_full_ESA3 = [time_'+year+'_'+zone+'_full_ESA3,(time_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then time_'+year+'_'+zone+'_full_ESA4 = [time_'+year+'_'+zone+'_full_ESA4,(time_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then time_'+year+'_'+zone+'_full_ESA5 = [time_'+year+'_'+zone+'_full_ESA5,(time_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then time_'+year+'_'+zone+'_full_ESA6 = [time_'+year+'_'+zone+'_full_ESA6,(time_ESA6_'+year+'[i,j])]')

      endfor

    endfor

    void = execute('Pres_'+year+'_'+zone+'_ESA2_avg = total(Pres_'+year+'_'+zone+'_full_ESA2/(Pres_'+year+'_'+zone+'_stdev_ESA2)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA2)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA3_avg = total(Pres_'+year+'_'+zone+'_full_ESA3/(Pres_'+year+'_'+zone+'_stdev_ESA3)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA3)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA4_avg = total(Pres_'+year+'_'+zone+'_full_ESA4/(Pres_'+year+'_'+zone+'_stdev_ESA4)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA4)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA5_avg = total(Pres_'+year+'_'+zone+'_full_ESA5/(Pres_'+year+'_'+zone+'_stdev_ESA5)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA5)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESA6_avg = total(Pres_'+year+'_'+zone+'_full_ESA6/(Pres_'+year+'_'+zone+'_stdev_ESA6)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESA6)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall = total([[Pres_'+year+'_'+zone+'_full_ESA2],[Pres_'+year+'_'+zone+'_full_ESA3], [Pres_'+year+'_'+zone+'_full_ESA4], [Pres_'+year+'_'+zone+'_full_ESA5], [Pres_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
    void = execute('Pres_'+year+'_'+zone+'_stdev_ESAall = sqrt(total([[Pres_'+year+'_'+zone+'_stdev_ESA2^2],[Pres_'+year+'_'+zone+'_stdev_ESA3^2], [Pres_'+year+'_'+zone+'_stdev_ESA4^2], [Pres_'+year+'_'+zone+'_stdev_ESA5^2], [Pres_'+year+'_'+zone+'_stdev_ESA6^2]] , 2, /nan))')
    void = execute('nan_rep'+year+'_'+zone+'=where (Pres_'+year+'_'+zone+'_ESAall eq 0.00000)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_avg = total(Pres_'+year+'_'+zone+'_ESAall/(Pres_'+year+'_'+zone+'_stdev_ESAall)^2, /nan)/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan)')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd_o = stddev(Pres_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Pres_'+year+'_'+zone+'_ESAall))')
    void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = sqrt((1/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan))+(((stddev(Pres_'+year+'_'+zone+'_ESAall, /nan))^2)/n_elements(Pres_'+year+'_'+zone+'_ESAall)))')
    ;standard deviation without divison by n
    ;void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = sqrt((1/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan))+(stddev(Pres_'+year+'_'+zone+'_ESAall, /nan))^2)')
    
    void = execute('time_'+year+'_'+zone+'_ESA2_avg = mean(time_'+year+'_'+zone+'_full_ESA2, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA3_avg = mean(time_'+year+'_'+zone+'_full_ESA3, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA4_avg = mean(time_'+year+'_'+zone+'_full_ESA4, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA5_avg = mean(time_'+year+'_'+zone+'_full_ESA5, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA6_avg = mean(time_'+year+'_'+zone+'_full_ESA6, /nan)')
    void = execute('time_'+year+'_'+zone+'_ESA2_sd = stddev(time_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA2))')
    void = execute('time_'+year+'_'+zone+'_ESA3_sd = stddev(time_'+year+'_'+zone+'_full_ESA3, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA3))')
    void = execute('time_'+year+'_'+zone+'_ESA4_sd = stddev(time_'+year+'_'+zone+'_full_ESA4, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA4))')
    void = execute('time_'+year+'_'+zone+'_ESA5_sd = stddev(time_'+year+'_'+zone+'_full_ESA5, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA5))')
    void = execute('time_'+year+'_'+zone+'_ESA6_sd = stddev(time_'+year+'_'+zone+'_full_ESA6, /nan)/sqrt(n_elements(time_'+year+'_'+zone+'_full_ESA6))')

   

  endfor

  ;fp4 = spec_plot(ESA6_INTPL[11-9,*,*], LON_ARR, LAT_ARR)

  ;stop

  time_1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  au_time_esa2 = [time_11_0_ESA2_avg, time_12_0_ESA2_avg, time_13_0_ESA2_avg, time_14_0_ESA2_avg, time_15_0_ESA2_avg]
  au_time_er_esa2 = [time_11_0_ESA2_sd, time_12_0_ESA2_sd, time_13_0_ESA2_sd, time_14_0_ESA2_sd, time_15_0_ESA2_sd]
  g2a = errorplot(time_1, au_time_esa2, au_time_er_esa2, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'

  time_1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  au_time_esa3 = [time_11_0_ESA3_avg, time_12_0_ESA3_avg, time_13_0_ESA3_avg, time_14_0_ESA3_avg, time_15_0_ESA3_avg]
  au_time_er_esa3 = [time_11_0_ESA3_sd, time_12_0_ESA3_sd, time_13_0_ESA3_sd, time_14_0_ESA3_sd, time_15_0_ESA3_sd]
  g2a = errorplot(time_1, au_time_esa3, au_time_er_esa3, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'

  time_1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  au_time_esa4 = [time_11_0_ESA4_avg, time_12_0_ESA4_avg, time_13_0_ESA4_avg, time_14_0_ESA4_avg, time_15_0_ESA4_avg]
  au_time_er_esa4 = [time_11_0_ESA4_sd, time_12_0_ESA4_sd, time_13_0_ESA4_sd, time_14_0_ESA4_sd, time_15_0_ESA4_sd]
  g2a = errorplot(time_1, au_time_esa4, au_time_er_esa4, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'

  time_1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  au_time_esa5 = [time_11_0_ESA5_avg, time_12_0_ESA5_avg, time_13_0_ESA5_avg, time_14_0_ESA5_avg, time_15_0_ESA5_avg]
  au_time_er_esa5 = [time_11_0_ESA5_sd, time_12_0_ESA5_sd, time_13_0_ESA5_sd, time_14_0_ESA5_sd, time_15_0_ESA5_sd]
  g2a = errorplot(time_1, au_time_esa5, au_time_er_esa5, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'

  time_1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  au_time_esa6 = [time_11_0_ESA6_avg, time_12_0_ESA6_avg, time_13_0_ESA6_avg, time_14_0_ESA6_avg, time_15_0_ESA6_avg]
  au_time_er_esa6 = [time_11_0_ESA6_sd, time_12_0_ESA6_sd, time_13_0_ESA6_sd, time_14_0_ESA6_sd, time_15_0_ESA6_sd]
  g2a = errorplot(time_1, au_time_esa6, au_time_er_esa6, /overplot)
  g1a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'

  time_1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  Pres_1 = [Pres_11_0_ESAall_avg, Pres_12_0_ESAall_avg, Pres_13_0_ESAall_avg, Pres_14_0_ESAall_avg, Pres_15_0_ESAall_avg]
  Pres_er1 = [Pres_11_0_ESAall_sd, Pres_12_0_ESAall_sd, Pres_13_0_ESAall_sd, Pres_14_0_ESAall_sd, Pres_15_0_ESAall_sd]
  
  ;last point removed scaling
;  time_1 = [2011.75, 2012.75, 2013.75, 2014.75]
;  Pres_1 = [Pres_11_0_ESAall_avg, Pres_12_0_ESAall_avg, Pres_13_0_ESAall_avg, Pres_14_0_ESAall_avg]
;  Pres_er1 = [Pres_11_0_ESAall_sd, Pres_12_0_ESAall_sd, Pres_13_0_ESAall_sd, Pres_14_0_ESAall_sd]

  ;g1a = errorplot(time_1, Pres_1, Pres_er1, xrange=[2010, 2016], yrange=[19, 22], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")


  Pres_1_avg_Aram = (Pres_11_0_ESAall_avg+Pres_12_0_ESAall_avg+Pres_13_0_ESAall_avg+Pres_14_0_ESAall_avg+Pres_15_0_ESAall_avg)/6
  ;Pres_1_ratio = Pres_1_avg_Aram/Pres_1_avg_ram

;  wrong scaling
  ;Pres_aram_scal = Pres_1/Pres_ram_scal
  ;Pres_ratio = (Pres_aram_scal[0]+Pres_aram_scal[1]+Pres_aram_scal[2]+Pres_aram_scal[3]+Pres_aram_scal[4])/5
;  wrong scaling

  ; stop

  ;g2a = errorplot(time_1, Pres_1/Pres_ratio, Pres_er1, /overplot)
  ;g2a = errorplot(time_1, Pres_1/Pres_aram_scal, Pres_er1, /overplot)
  g2a = errorplot(time_1, Pres_1, Pres_er1, /overplot)
  g2a.symbol= 'o'
  g2a.SYM_SIZE= 1
  g2a.SYM_FILLED=1
  g2a.FONT_SIZE=15
  g2a.LINESTYLE='-.'
  ;g2a.save, 'mir_lospres_hsm.png'


  stop

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mx = 40.0
  mn = 10.0
  binsize = 0.5
  yrange = [0, 250]

  pdf11 = HISTOGRAM(Pres_11_0_ESAall/Pres_aram_scal[0], LOCATIONS=xbin11,  MAX= mx, MIN= mn, binsize = binsize)

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

  graphic = BARPLOT(xbin11[53:60], pdf11[53:60], XTITLE='2011.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;-------------

  pdf12 = HISTOGRAM(Pres_12_0_ESAall/Pres_aram_scal[1], LOCATIONS=xbin12,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin12[0:4], pdf12[0:4], XTITLE='2012.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
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

  pdf13 = HISTOGRAM(Pres_13_0_ESAall/Pres_aram_scal[2], LOCATIONS=xbin13,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin13[0:4], pdf13[0:4], XTITLE='2013.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
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

  pdf14 = HISTOGRAM(Pres_14_0_ESAall/Pres_aram_scal[3], LOCATIONS=xbin14,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin14[0:4], pdf14[0:4], XTITLE='2014.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
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

  graphic = BARPLOT(xbin14[45:52], pdf14[45:52], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin14[53:60], pdf14[53:60], $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )


  ;-------------

  pdf15 = HISTOGRAM(Pres_15_0_ESAall/Pres_aram_scal[4], LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

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

  graphic = BARPLOT(xbin15[53:60], pdf15[53:60], XTITLE='2015.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  ;  all_ESA6= []
  ;
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
  ;  time4 = [2019, 2020]
  ;  time7 = [2016]
  ;  time8 = [2017]
  ;  time9 = [2018]
  ;  time13= [2015]
  ;  time14= [2015,2016]
  ;  time15 = [2016,2017]
  ;  time16 = [2017,2018]
  ;
  ;  Pres_1 = [Pres_16_0_ESAall_avg, Pres_17_0_ESAall_avg, Pres_18_0_ESAall_avg, Pres_19_0_ESAall_avg, Pres_20_0_ESAall_avg]
  ;  Pres_1a = [Pres_16_0_ESAall_avg, Pres_17_0_ESAall_avg, Pres_18_0_ESAall_avg, Pres_19_0_ESAall_avg]
  ;  Pres_1b = [Pres_19_0_ESAall_avg, Pres_20_0_ESAall_avg]
  ;  Pres_2 = [Pres_17_1_ESAall_avg, Pres_18_1_ESAall_avg, Pres_19_1_ESAall_avg, Pres_20_1_ESAall_avg]
  ;  Pres_2a = [Pres_17_1_ESAall_avg, Pres_18_1_ESAall_avg, Pres_19_1_ESAall_avg]
  ;  Pres_2b = [Pres_19_1_ESAall_avg, Pres_20_1_ESAall_avg]
  ;  Pres_3 = [Pres_18_2_ESAall_avg, Pres_19_2_ESAall_avg, Pres_20_2_ESAall_avg]
  ;  Pres_3a = [Pres_18_2_ESAall_avg, Pres_19_2_ESAall_avg]
  ;  Pres_3b = [Pres_19_2_ESAall_avg, Pres_20_2_ESAall_avg]
  ;  Pres_4 = [Pres_19_3_ESAall_avg, Pres_20_3_ESAall_avg]
  ;  Pres_7 =  [Pres_16_1_ESAall_avg]
  ;  Pres_8 =  [Pres_17_2_ESAall_avg]
  ;  Pres_9 = [Pres_18_3_ESAall_avg]
  ;  Pres_13 = [Pres_15_0_ESAall_avg]
  ;  Pres_14 = [ Pres_15_0_ESAall_avg, Pres_16_0_ESAall_avg]
  ;  Pres_15 = [ Pres_16_1_ESAall_avg, Pres_17_1_ESAall_avg]
  ;  Pres_16 = [ Pres_17_2_ESAall_avg, Pres_18_2_ESAall_avg]
  ;
  ;  Pres_er1 = [Pres_16_0_ESAall_sd, Pres_17_0_ESAall_sd, Pres_18_0_ESAall_sd, Pres_19_0_ESAall_sd, Pres_20_0_ESAall_sd]
  ;  Pres_er1a = [Pres_16_0_ESAall_sd, Pres_17_0_ESAall_sd, Pres_18_0_ESAall_sd, Pres_19_0_ESAall_sd]
  ;  Pres_er1b = [Pres_19_0_ESAall_sd, Pres_20_0_ESAall_sd]
  ;  Pres_er2 = [Pres_17_1_ESAall_sd, Pres_18_1_ESAall_sd, Pres_19_1_ESAall_sd, Pres_20_1_ESAall_sd]
  ;  Pres_er2a = [Pres_17_1_ESAall_sd, Pres_18_1_ESAall_sd, Pres_19_1_ESAall_sd]
  ;  Pres_er2b = [Pres_19_1_ESAall_sd, Pres_20_1_ESAall_sd]
  ;  Pres_er3 = [Pres_18_2_ESAall_sd, Pres_19_2_ESAall_sd, Pres_20_2_ESAall_sd]
  ;  Pres_er3a = [Pres_18_2_ESAall_sd, Pres_19_2_ESAall_sd]
  ;  Pres_er3b = [Pres_19_2_ESAall_sd, Pres_20_2_ESAall_sd]
  ;  Pres_er4 = [Pres_19_3_ESAall_sd, Pres_20_3_ESAall_sd]
  ;  Pres_er7 =  [Pres_16_1_ESAall_sd]
  ;  Pres_er8 =  [Pres_17_2_ESAall_sd]
  ;  Pres_er9 = [Pres_18_3_ESAall_sd]
  ;  Pres_er13 = [Pres_15_0_ESAall_sd]
  ;  Pres_er14 = [Pres_15_0_ESAall_sd, Pres_16_0_ESAall_sd]
  ;  Pres_er15 = [Pres_16_1_ESAall_sd, Pres_17_1_ESAall_sd]
  ;  Pres_er16 = [Pres_17_2_ESAall_sd, Pres_18_2_ESAall_sd]
  ;
  ;  g1a = errorplot(time1, Pres_1a, Pres_er1a, xrange=[2014, 2021], yrange=[10, 40], xminor=0,XTITLE="Year in HS", YTITLE="LOS integrated Pressure (pdynes cm^-2 AU)")
  ;  g1a.symbol= 'o'
  ;  g1a.SYM_SIZE= 1
  ;  g1a.SYM_FILLED=1
  ;  g1a.FONT_SIZE=15
  ;
  ;  g1b = errorplot(time1b, Pres_1b, Pres_er1b, /overplot)
  ;  g1b.symbol= 'o'
  ;  g1b.SYM_SIZE= 1
  ;  g1b.SYM_FILLED=1
  ;  g1b.FONT_SIZE=15
  ;  g1b.LINESTYLE='-.'
  ;
  ;  g2a = errorplot(time2a, Pres_2a, Pres_er2a, /overplot)
  ;  g2a.symbol= 'o'
  ;  g2a.SYM_SIZE= 1
  ;  g2a.SYM_FILLED=1
  ;  g2a.FONT_SIZE=15
  ;  g2a.COLOR ="blue"
  ;  g2a.ERRORBAR_COLOR="blue"
  ;
  ;  g2b = errorplot(time2b, Pres_2b, Pres_er2b, /overplot)
  ;  g2b.symbol= 'o'
  ;  g2b.SYM_SIZE= 1
  ;  g2b.SYM_FILLED=1
  ;  g2b.FONT_SIZE=15
  ;  g2b.COLOR ="blue"
  ;  g2b.ERRORBAR_COLOR="blue"
  ;  g2b.LINESTYLE='-.'
  ;
  ;  g3a = errorplot(time3a, Pres_3a, Pres_er3a, /overplot)
  ;  g3a.symbol= 'o'
  ;  g3a.SYM_SIZE= 1
  ;  g3a.SYM_FILLED=1
  ;  g3a.FONT_SIZE=15
  ;  g3a.COLOR ="green"
  ;  g3a.ERRORBAR_COLOR="green"
  ;
  ;  g3b = errorplot(time3b, Pres_3b, Pres_er3b, /overplot)
  ;  g3b.symbol= 'o'
  ;  g3b.SYM_SIZE= 1
  ;  g3b.SYM_FILLED=1
  ;  g3b.FONT_SIZE=15
  ;  g3b.COLOR ="green"
  ;  g3b.ERRORBAR_COLOR="green"
  ;  g3b.LINESTYLE='-.'
  ;
  ;  ;g4 = errorplot(time4, Pres_4, Pres_er4, /overplot)
  ;  ;g4.symbol= 'o'
  ;  ;g4.SYM_SIZE= 1
  ;  ;g4.SYM_FILLED=1
  ;  ;g4.FONT_SIZE=15
  ;  ;g4.COLOR ="orange"
  ;  ;g4.ERRORBAR_COLOR="orange"
  ;  ;g4.LINESTYLE='--'
  ;
  ;
  ;  g6 = errorplot(time13, Pres_13, Pres_er13, /overplot)
  ;  g6.symbol= 'X'
  ;  g6.SYM_SIZE= 1
  ;  g6.SYM_FILLED=1
  ;  g6.FONT_SIZE=15
  ;
  ;  g7 = errorplot(time7, Pres_7, Pres_er7, /overplot)
  ;  g7.symbol= 'X'
  ;  g7.SYM_SIZE= 1
  ;  g7.SYM_FILLED=1
  ;  g7.FONT_SIZE=15
  ;  g7.COLOR ="blue"
  ;  g7.ERRORBAR_COLOR="blue"
  ;
  ;  g8 = errorplot(time8, Pres_8, Pres_er8, /overplot)
  ;  g8.symbol= 'X'
  ;  g8.SYM_SIZE= 1
  ;  g8.SYM_FILLED=1
  ;  g8.FONT_SIZE=15
  ;  g8.COLOR ="green"
  ;  g8.ERRORBAR_COLOR="green"
  ;
  ;  ;g9 = errorplot(time9, Pres_9, Pres_er9, /overplot)
  ;  ;g9.symbol= 'X'
  ;  ;g9.SYM_SIZE= 1
  ;  ;g9.SYM_FILLED=1
  ;  ;g9.FONT_SIZE=15
  ;  ;g9.COLOR ="orange"
  ;  ;g9.ERRORBAR_COLOR="orange"
  ;
  ;  g14 = errorplot(time14, Pres_14, Pres_er14, /overplot)
  ;  ;g10.symbol= '.'
  ;  ;g10.SYM_SIZE= 1
  ;  ;g10.SYM_FILLED=1
  ;  g14.FONT_SIZE=15
  ;  g14.COLOR ="black"
  ;  g14.ERRORBAR_COLOR="black"
  ;  g14.LINESTYLE='--'
  ;
  ;  g15 = errorplot(time15, Pres_15, Pres_er15, /overplot)
  ;  g15.FONT_SIZE=15
  ;  g15.COLOR ="blue"
  ;  g15.ERRORBAR_COLOR="blue"
  ;  g15.LINESTYLE='--'
  ;
  ;  g16 = errorplot(time16, Pres_16, Pres_er16, /overplot)
  ;  g16.FONT_SIZE=15
  ;  g16.COLOR ="green"
  ;  g16.ERRORBAR_COLOR="green"
  ;  g16.LINESTYLE='--'
  ;
  ;
  ;  g16.save, 'p_pres_hsm.png'


end
