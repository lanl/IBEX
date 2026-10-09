pro mir_zone_temp_weighted_avg

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
    void = execute('Temp_ESA2_stdev_'+yos+' = reverse(reform(Temp_ESA2_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA3_stdev_'+yos+' = reverse(reform(Temp_ESA3_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA4_stdev_'+yos+' = reverse(reform(Temp_ESA4_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA5_stdev_'+yos+' = reverse(reform(Temp_ESA5_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Temp_ESA6_stdev_'+yos+' = reverse(reform(Temp_ESA6_stddev_intpl[yo-9,0:l-1, 0:m-1]))')
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
    void = execute('Temp_'+year+'_'+zone+'_stdev_ESA2=[]')
    void = execute('Temp_'+year+'_'+zone+'_stdev_ESA3=[]')
    void = execute('Temp_'+year+'_'+zone+'_stdev_ESA4=[]')
    void = execute('Temp_'+year+'_'+zone+'_stdev_ESA5=[]')
    void = execute('Temp_'+year+'_'+zone+'_stdev_ESA6=[]')



    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

       void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA2 = [Temp_'+year+'_'+zone+'_full_ESA2,(Temp_ESA2_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA3 = [Temp_'+year+'_'+zone+'_full_ESA3,(Temp_ESA3_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_full_ESA4 = [Temp_'+year+'_'+zone+'_full_ESA4,(Temp_ESA4_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Temp_'+year+'_'+zone+'_full_ESA5 = [Temp_'+year+'_'+zone+'_full_ESA5,(Temp_ESA5_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Temp_'+year+'_'+zone+'_full_ESA6 = [Temp_'+year+'_'+zone+'_full_ESA6,(Temp_ESA6_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_stdev_ESA2 = [Temp_'+year+'_'+zone+'_stdev_ESA2,(Temp_ESA2_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_stdev_ESA3 = [Temp_'+year+'_'+zone+'_stdev_ESA3,(Temp_ESA3_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Temp_'+year+'_'+zone+'_stdev_ESA4 = [Temp_'+year+'_'+zone+'_stdev_ESA4,(Temp_ESA4_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Temp_'+year+'_'+zone+'_stdev_ESA5 = [Temp_'+year+'_'+zone+'_stdev_ESA5,(Temp_ESA5_stdev_'+year+'[i,j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Temp_'+year+'_'+zone+'_stdev_ESA6 = [Temp_'+year+'_'+zone+'_stdev_ESA6,(Temp_ESA6_stdev_'+year+'[i,j])]')

      endfor

    endfor
;    void = execute('Temp_'+year+'_'+zone+'_ESA2_avg = mean(Temp_'+year+'_'+zone+'_full_ESA2)')
;    void = execute('Temp_'+year+'_'+zone+'_ESA3_avg = mean(Temp_'+year+'_'+zone+'_full_ESA3)')
;    void = execute('Temp_'+year+'_'+zone+'_ESA4_avg = mean(Temp_'+year+'_'+zone+'_full_ESA4)')
;    void = execute('Temp_'+year+'_'+zone+'_ESA5_avg = mean(Temp_'+year+'_'+zone+'_full_ESA5)')
;    void = execute('Temp_'+year+'_'+zone+'_ESA6_avg = mean(Temp_'+year+'_'+zone+'_full_ESA6)')
;    void = execute('Temp_'+year+'_'+zone+'_ESAall = (Temp_'+year+'_'+zone+'_full_ESA2+Temp_'+year+'_'+zone+'_full_ESA3+Temp_'+year+'_'+zone+'_full_ESA4+Temp_'+year+'_'+zone+'_full_ESA5+Temp_'+year+'_'+zone+'_full_ESA6)/6')
;    void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall)')
;    void = execute('Temp_'+year+'_'+zone+'_ESAall_sd = stddev(Temp_'+year+'_'+zone+'_full_ESA2, /nan)/sqrt(n_elements(Temp_'+year+'_'+zone+'_full_ESA2))')
;    void = execute('nan_rep'+year+'_'+zone+'=where (Temp_'+year+'_'+zone+'_ESAall eq 0.00000)')
;    void = execute('Temp_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
;    void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = mean(Temp_'+year+'_'+zone+'_ESAall, /nan)')
;    void = execute('Temp_'+year+'_'+zone+'_sd = [stddev(Temp_'+year+'_'+zone+'_full_ESA2), stddev(Temp_'+year+'_'+zone+'_full_ESA3), stddev(Temp_'+year+'_'+zone+'_full_ESA4), stddev(Temp_'+year+'_'+zone+'_full_ESA5), stddev(Temp_'+year+'_'+zone+'_full_ESA6)]')
;


void = execute('Temp_'+year+'_'+zone+'_ESA2_avg = total(Temp_'+year+'_'+zone+'_full_ESA2/(Temp_'+year+'_'+zone+'_stdev_ESA2)^2, /nan)/total((Temp_'+year+'_'+zone+'_stdev_ESA2)^(-2), /nan)')
void = execute('Temp_'+year+'_'+zone+'_ESA3_avg = total(Temp_'+year+'_'+zone+'_full_ESA3/(Temp_'+year+'_'+zone+'_stdev_ESA3)^2, /nan)/total((Temp_'+year+'_'+zone+'_stdev_ESA3)^(-2), /nan)')
void = execute('Temp_'+year+'_'+zone+'_ESA4_avg = total(Temp_'+year+'_'+zone+'_full_ESA4/(Temp_'+year+'_'+zone+'_stdev_ESA4)^2, /nan)/total((Temp_'+year+'_'+zone+'_stdev_ESA4)^(-2), /nan)')
void = execute('Temp_'+year+'_'+zone+'_ESA5_avg = total(Temp_'+year+'_'+zone+'_full_ESA5/(Temp_'+year+'_'+zone+'_stdev_ESA5)^2, /nan)/total((Temp_'+year+'_'+zone+'_stdev_ESA5)^(-2), /nan)')
void = execute('Temp_'+year+'_'+zone+'_ESA6_avg = total(Temp_'+year+'_'+zone+'_full_ESA6/(Temp_'+year+'_'+zone+'_stdev_ESA6)^2, /nan)/total((Temp_'+year+'_'+zone+'_stdev_ESA6)^(-2), /nan)')

void = execute('Temp_'+year+'_'+zone+'_ESAall = total([[Temp_'+year+'_'+zone+'_full_ESA2],[Temp_'+year+'_'+zone+'_full_ESA3], [Temp_'+year+'_'+zone+'_full_ESA4], [Temp_'+year+'_'+zone+'_full_ESA5], [Temp_'+year+'_'+zone+'_full_ESA6]] , 2, /nan)')
void = execute('Temp_'+year+'_'+zone+'_stdev_ESAall = sqrt(total([[Temp_'+year+'_'+zone+'_stdev_ESA2^2],[Temp_'+year+'_'+zone+'_stdev_ESA3^2], [Temp_'+year+'_'+zone+'_stdev_ESA4^2], [Temp_'+year+'_'+zone+'_stdev_ESA5^2], [Temp_'+year+'_'+zone+'_stdev_ESA6^2]] , 2, /nan))')
void = execute('nan_rep'+year+'_'+zone+'=where (Temp_'+year+'_'+zone+'_ESAall eq 0.00000)')
void = execute('Temp_'+year+'_'+zone+'_ESAall[nan_rep'+year+'_'+zone+']=!VALUES.F_NAN')
;avg calculated from total pres of all ESAs as in 13-10-25 pres
void = execute('Temp_'+year+'_'+zone+'_ESAall_avg_o = total(Temp_'+year+'_'+zone+'_ESAall/(Temp_'+year+'_'+zone+'_stdev_ESAall)^2, /nan)/total((Temp_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan)')
void = execute('Temp_'+year+'_'+zone+'_ESAall_sd_o = stddev(Temp_'+year+'_'+zone+'_ESAall, /nan)/sqrt(n_elements(Temp_'+year+'_'+zone+'_ESAall))')
;void = execute('Pres_'+year+'_'+zone+'_ESAall_sd_map = sqrt(1/(total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2))))')
void = execute('Temp_'+year+'_'+zone+'_ESAall_sd = sqrt((1/total((Temp_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan))+(((stddev(Temp_'+year+'_'+zone+'_ESAall, /nan))^2)/n_elements(Temp_'+year+'_'+zone+'_ESAall)))')
;standard deviation without divison by n
;void = execute('Pres_'+year+'_'+zone+'_ESAall_sd = sqrt((1/total((Pres_'+year+'_'+zone+'_stdev_ESAall)^(-2), /nan))+(stddev(Pres_'+year+'_'+zone+'_ESAall, /nan))^2)')
void = execute('Temp_'+year+'_'+zone+'_ESAall_avg = total([Temp_'+year+'_'+zone+'_ESA2_avg]+[Temp_'+year+'_'+zone+'_ESA3_avg]+[Temp_'+year+'_'+zone+'_ESA4_avg]+[Temp_'+year+'_'+zone+'_ESA5_avg]+[Temp_'+year+'_'+zone+'_ESA6_avg])')
  endfor



  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  Temp_1 = [Temp_11_0_ESAall_avg, Temp_12_0_ESAall_avg, Temp_13_0_ESAall_avg, Temp_14_0_ESAall_avg, Temp_15_0_ESAall_avg]
  Temp_er1 = [Temp_11_0_ESAall_sd, Temp_12_0_ESAall_sd, Temp_13_0_ESAall_sd, Temp_14_0_ESAall_sd, Temp_15_0_ESAall_sd]
  g1a = errorplot(time1, Temp_1/6, Temp_er1, xrange=[2011, 2016], yrange=[3700000, 3950000], xminor=0,XTITLE="Year in HS", YTITLE="Temperature (K)")
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15
stop
  
  end