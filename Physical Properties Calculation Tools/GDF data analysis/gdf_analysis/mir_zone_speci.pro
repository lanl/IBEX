pro mir_zone_speci

;  restore, '/Users/nwalia/IDLWorkspace/p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
;  restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
 
 restore, '/Users/nwalia/IDLWorkspace/ram_fract_Mar.sav'
 restore, '/Users/nwalia/IDLWorkspace/ram_pres_fract_Mar.sav'
  
  all_ESA6= []

  l=180
  m=90
  zl=6
  
  num = STRTRIM(zl, 1)
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  for yo = 9, 20 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Flux_ESA2_'+yos+' = reverse(reform(ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA3_'+yos+' = reverse(reform(ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA4_'+yos+' = reverse(reform(ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA5_'+yos+' = reverse(reform(ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA6_'+yos+' = reverse(reform(ESA6_intpl[yo-9,0:l-1, 0:m-1]))')
  endfor

  for b = 9, 20 do begin


    year = STRTRIM(b, 2)


    oyn = 11
    oynn= oyn + 3
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(0, 1)

    void = execute('pos_arr_'+yn+'= intarr(l, m)')
    void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    void = execute('gamma_'+year+'_'+zone+'= fltarr(l, m)')


    for lati = 0, m-1 do begin
      for loni = 0, l-1 do begin

       void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') and (loni lt 110) then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

      endfor
    endfor

;    d=[]
;    d_o=[]
;    dd=[]
;    e=[]
;    indices=[]
;    
;    
;    for j = 0, m-1 do begin
;      for i = 0, l-1 do begin
;        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) then d = [d,i]')
;      endfor
;
;      if n_elements(d) gt 0 then dd= [dd, d]
;      if n_elements(d) gt 0 then for v = 0, n_elements(d)-1 do begin e = [e, j] & endfor
;      d=[]
;    endfor
    
    Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
    
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

        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(Flux_ESA2_'+year+'[i, j]), (Flux_ESA3_'+year+'[i, j]), (Flux_ESA4_'+year+'[i, j]), (Flux_ESA5_'+year+'[i, j]), (Flux_ESA6_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(Flux_ESA2_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(Flux_ESA3_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(Flux_ESA4_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(Flux_ESA5_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(Flux_ESA6_'+year+'[i, j])]')
        
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then fin_arr'+year+'_'+zone+'=where(finite(Flux_'+year+'_'+zone+'))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then f_'+year+'_'+zone+' = LINFIT(alog(Energy[fin_arr'+year+'_'+zone+']), alog(Flux_'+year+'_'+zone+'[fin_arr'+year+'_'+zone+']))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
      endfor

    endfor


    void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full, /nan)')
    void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full, /nan)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
    void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
    void = execute('Flux_'+year+'_'+zone+'_sd = [stddev(Flux_'+year+'_'+zone+'_full_ESA2)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA2)), stddev(Flux_'+year+'_'+zone+'_full_ESA3)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA3)), stddev(Flux_'+year+'_'+zone+'_full_ESA4)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA4)), stddev(Flux_'+year+'_'+zone+'_full_ESA5)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA5)), stddev(Flux_'+year+'_'+zone+'_full_ESA6)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA6))]')


;    ;for oyn = 18, 20 do begin
;    for oyn = 16, 19 do begin
;      oynn= oyn + 1
;      yn = STRTRIM(oyn, 1)
;      ynn = STRTRIM(oynn, 1)
;      zone = STRTRIM(oynn-16, 1)
;
;      void = execute('pos_arr_'+yn+'= intarr(l, m)')
;      void = execute('pos_arr_'+ynn+'= intarr(l, m)')
;      ;void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
;      void = execute('gamma_'+year+'_'+zone+'= fltarr(l, m)')
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
;      void = execute('Flux_'+year+'_'+zone+'=[]')
;      void = execute('f_'+year+'_'+zone+'=[]')
;      void = execute('gamma_'+year+'_'+zone+'_full=[]')
;      void = execute('Flux_'+year+'_'+zone+'_full_ESA2=[]')
;      void = execute('Flux_'+year+'_'+zone+'_full_ESA3=[]')
;      void = execute('Flux_'+year+'_'+zone+'_full_ESA4=[]')
;      void = execute('Flux_'+year+'_'+zone+'_full_ESA5=[]')
;      void = execute('Flux_'+year+'_'+zone+'_full_ESA6=[]')
;
;      for j = 0, 90-1 do begin
;        for i = 0, 180-1 do begin
;
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1]), (ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2]), (ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3]), (ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4]), (ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1])]')
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2])]')
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3])]')
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4])]')
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]), (ESA3_intpl[b-9, i, j]), (ESA4_intpl[b-9, i, j]), (ESA5_intpl[b-9, i, j]), (ESA6_intpl[b-9, i, j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j])]')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j])]')
;          Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then fin_arr'+year+'_'+zone+'=where(finite(Flux_'+year+'_'+zone+'))')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy[fin_arr'+year+'_'+zone+']), alog(Flux_'+year+'_'+zone+'[fin_arr'+year+'_'+zone+']))')
;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy), alog(Flux_'+year+'_'+zone+'))')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
;
;        endfor
;
;      endfor
;
;      void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full, /nan)')
;      void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full, /nan)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
;      void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
;
;
;    endfor

    ;stop

  endfor


;stop
  
;  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
;  gamma_1 = [gamma_11_0_avg, gamma_12_0_avg, gamma_13_0_avg, gamma_14_0_avg, gamma_15_0_avg]
;  gamma_er1 = [gamma_11_0_sd, gamma_12_0_sd, gamma_13_0_sd, gamma_14_0_sd, gamma_15_0_sd]
;  g1a = errorplot(time1, gamma_1, gamma_er1, xrange=[2011, 2016], yrange=[1.8, 2.4], xminor=0,XTITLE="Year in HS", YTITLE="Spectral Index")
;  g1a.symbol= 'o'
;  g1a.SYM_SIZE= 1
;  g1a.SYM_FILLED=1
;  g1a.FONT_SIZE=15
;  gamma_avg_ram = (gamma_11_0_avg+gamma_12_0_avg+gamma_13_0_avg+gamma_14_0_avg+gamma_15_0_avg)/6
;  
;  
;  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
;  gamma_1 = [flux_11_0_avg[0], flux_12_0_avg[0], flux_13_0_avg[0], flux_14_0_avg[0], flux_15_0_avg[0]]
;  gamma_er1 = [flux_11_0_sd[0], flux_12_0_sd[0], flux_13_0_sd[0], flux_14_0_sd[0], flux_15_0_sd[0]]
;  g2a = errorplot(time1, gamma_1, gamma_er1, xrange=[2011, 2016], yrange=[100, 300], xminor=0,XTITLE="Year in HS", YTITLE="ESA2")
;  g2a.symbol= 'o'
;  g2a.SYM_SIZE= 1
;  g2a.SYM_FILLED=1
;  g2a.FONT_SIZE=15
; esa2_avg_ram = (flux_11_0_avg[0]+flux_12_0_avg[0]+flux_13_0_avg[0]+flux_14_0_avg[0]+flux_15_0_avg[0])/6
;  
;  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
;  gamma_1 = [flux_11_0_avg[1], flux_12_0_avg[1], flux_13_0_avg[1], flux_14_0_avg[1], flux_15_0_avg[1]]
;  gamma_er1 = [flux_11_0_sd[1], flux_12_0_sd[1], flux_13_0_sd[1], flux_14_0_sd[1], flux_15_0_sd[1]]
;  g3a = errorplot(time1, gamma_1, gamma_er1, xrange=[2011, 2016], yrange=[80, 110], xminor=0,XTITLE="Year in HS", YTITLE="ESA3")
;  g3a.symbol= 'o'
;  g3a.SYM_SIZE= 1
;  g3a.SYM_FILLED=1
;  g3a.FONT_SIZE=15
;esa3_avg_ram = (flux_11_0_avg[1]+flux_12_0_avg[1]+flux_13_0_avg[1]+flux_14_0_avg[1]+flux_15_0_avg[1])/6
;  
;  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
;  gamma_1 = [flux_11_0_avg[2], flux_12_0_avg[2], flux_13_0_avg[2], flux_14_0_avg[2], flux_15_0_avg[2]]
;  gamma_er1 = [flux_11_0_sd[2], flux_12_0_sd[2], flux_13_0_sd[2], flux_14_0_sd[2], flux_15_0_sd[2]]
;  g4a = errorplot(time1, gamma_1, gamma_er1, xrange=[2011, 2016], yrange=[30, 50], xminor=0,XTITLE="Year in HS", YTITLE="ESA4")
;  g4a.symbol= 'o'
;  g4a.SYM_SIZE= 1
;  g4a.SYM_FILLED=1
;  g4a.FONT_SIZE=15
; esa4_avg_ram = (flux_11_0_avg[2]+flux_12_0_avg[2]+flux_13_0_avg[2]+flux_14_0_avg[2]+flux_15_0_avg[2])/6
;;  
;  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
;  gamma_1 = [flux_11_0_avg[3], flux_12_0_avg[3], flux_13_0_avg[3], flux_14_0_avg[3], flux_15_0_avg[3]]
;  gamma_er1 = [flux_11_0_sd[3], flux_12_0_sd[3], flux_13_0_sd[3], flux_14_0_sd[3], flux_15_0_sd[3]]
;  g5a = errorplot(time1, gamma_1, gamma_er1, xrange=[2011, 2016], yrange=[12, 18], xminor=0,XTITLE="Year in HS", YTITLE="ESA5")
;  g5a.symbol= 'o'
;  g5a.SYM_SIZE= 1
;  g5a.SYM_FILLED=1
;  g5a.FONT_SIZE=15
; esa5_avg_ram = (flux_11_0_avg[3]+flux_12_0_avg[3]+flux_13_0_avg[3]+flux_14_0_avg[3]+flux_15_0_avg[3])/6
;;  
  time1 = [2011.25, 2012.25, 2013.25, 2014.25, 2015.25]
  gamma_1 = [flux_11_0_avg[4], flux_12_0_avg[4], flux_13_0_avg[4], flux_14_0_avg[4], flux_15_0_avg[4]]
  gamma_er1 = [flux_11_0_sd[4], flux_12_0_sd[4], flux_13_0_sd[4], flux_14_0_sd[4], flux_15_0_sd[4]]
  g6a = errorplot(time1, gamma_1, gamma_er1, xrange=[2011, 2016], yrange=[2, 6], xminor=0,XTITLE="Year in HS", YTITLE="ESA6")
  g6a.symbol= 'o'
  g6a.SYM_SIZE= 1
  g6a.SYM_FILLED=1
  g6a.FONT_SIZE=15
 esa6_avg_ram = (flux_11_0_avg[4]+flux_12_0_avg[4]+flux_13_0_avg[4]+flux_14_0_avg[4]+flux_15_0_avg[4])/6
 
 gamma_ram_scal = [(gamma_11_0_avg+gamma_12_0_avg)/2, (gamma_12_0_avg+gamma_13_0_avg)/2, (gamma_13_0_avg+gamma_14_0_avg)/2, (gamma_14_0_avg+gamma_15_0_avg)/2, (gamma_15_0_avg+gamma_16_0_avg)/2]
 esa2_ram_scal = [(flux_11_0_avg[0]+flux_12_0_avg[0])/2, (flux_12_0_avg[0]+flux_13_0_avg[0])/2, (flux_13_0_avg[0]+flux_14_0_avg[0])/2, (flux_14_0_avg[0]+flux_15_0_avg[0])/2, (flux_15_0_avg[0]+flux_16_0_avg[0])/2]
 esa3_ram_scal = [(flux_11_0_avg[1]+flux_12_0_avg[1])/2, (flux_12_0_avg[1]+flux_13_0_avg[1])/2, (flux_13_0_avg[1]+flux_14_0_avg[1])/2, (flux_14_0_avg[1]+flux_15_0_avg[1])/2, (flux_15_0_avg[1]+flux_16_0_avg[1])/2]
 esa4_ram_scal = [(flux_11_0_avg[2]+flux_12_0_avg[2])/2, (flux_12_0_avg[2]+flux_13_0_avg[2])/2, (flux_13_0_avg[2]+flux_14_0_avg[2])/2, (flux_14_0_avg[2]+flux_15_0_avg[2])/2, (flux_15_0_avg[2]+flux_16_0_avg[2])/2]
 esa5_ram_scal = [(flux_11_0_avg[3]+flux_12_0_avg[3])/2, (flux_12_0_avg[3]+flux_13_0_avg[3])/2, (flux_13_0_avg[3]+flux_14_0_avg[3])/2, (flux_14_0_avg[3]+flux_15_0_avg[3])/2, (flux_15_0_avg[3]+flux_16_0_avg[3])/2]
 esa6_ram_scal = [(flux_11_0_avg[4]+flux_12_0_avg[4])/2, (flux_12_0_avg[4]+flux_13_0_avg[4])/2, (flux_13_0_avg[4]+flux_14_0_avg[4])/2, (flux_14_0_avg[4]+flux_15_0_avg[4])/2, (flux_15_0_avg[4]+flux_16_0_avg[4])/2]
  
 
;  mx = 3.0
;  mn = 1.0
;  binsize = 0.05
;  yrange = [0, 800]
;
;  
;  pdf11 = HISTOGRAM(gamma_11_0_full, LOCATIONS=xbin11,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin11[0:4], pdf11[0:4], XTITLE='2011.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin11[5:9], pdf11[5:9], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin11[10:14], pdf11[10:14], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin11[15:19], pdf11[15:19], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin11[20:24], pdf11[20:24], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin11[25:29], pdf11[25:29], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin11[30:35], pdf11[30:35], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin11[35:40], pdf11[35:40], XTITLE='2011.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  ;-------------
;
;  pdf12 = HISTOGRAM(gamma_12_0_full, LOCATIONS=xbin12,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin12[0:4], pdf12[0:4], XTITLE='2012.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin12[5:9], pdf12[5:9], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin12[10:14], pdf12[10:14], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin12[15:19], pdf12[15:19], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin12[20:24], pdf12[20:24], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin12[25:29], pdf12[25:29], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin12[30:35], pdf12[30:35], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin12[35:40], pdf12[35:40], XTITLE='2012.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  ;-------------
;
;  pdf13 = HISTOGRAM(gamma_13_0_full, LOCATIONS=xbin13,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin13[0:4], pdf13[0:4], XTITLE='2013.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin13[5:9], pdf13[5:9], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin13[10:14], pdf13[10:14], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin13[15:19], pdf13[15:19], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin13[20:24], pdf13[20:24], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin13[25:29], pdf13[25:29], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin13[30:35], pdf13[30:35], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin13[35:40], pdf13[35:40], XTITLE='2013.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  ;-------------
;
;  pdf14 = HISTOGRAM(gamma_14_0_full, LOCATIONS=xbin14,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin14[0:4], pdf14[0:4], XTITLE='2014.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin14[5:9], pdf14[5:9], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin14[10:14], pdf14[10:14], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin14[15:19], pdf14[15:19], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin14[20:24], pdf14[20:24], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin14[25:29], pdf14[25:29], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin14[30:35], pdf14[30:35], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin14[35:40], pdf14[35:40], XTITLE='2014.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  ;-------------
;
;  pdf15 = HISTOGRAM(gamma_15_0_full, LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin15[0:4], pdf15[0:4], XTITLE='2015.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin15[5:9], pdf15[5:9], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin15[10:14], pdf15[10:14], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin15[15:19], pdf15[15:19], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin15[20:24], pdf15[20:24], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin15[25:29], pdf15[25:29], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin15[30:35], pdf15[30:35], XTITLE='2015', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin15[35:40], pdf15[35:40], XTITLE='2015.25', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  
  
 ; stop
  ;ram_speci_11

  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7May24ESA_intpl_wNAN_fract_new.sav'
  ;restore, '/Users/nwalia/IDLWorkspace/Aram_p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'
  
  restore, '/Users/nwalia/IDLWorkspace/Aram_fract_Sep.sav'
  restore, '/Users/nwalia/IDLWorkspace/Aram_pres_fract_Sep.sav'



  all_ESA6= []

  l=180
  m=90
  zl=6

  num = STRTRIM(zl, 1)
  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  for yo = 11, 15 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reverse(reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90))')
    void = execute('Flux_ESA2_'+yos+' = reverse(reform(ESA2_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA3_'+yos+' = reverse(reform(ESA3_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA4_'+yos+' = reverse(reform(ESA4_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA5_'+yos+' = reverse(reform(ESA5_intpl[yo-9,0:l-1, 0:m-1]))')
    void = execute('Flux_ESA6_'+yos+' = reverse(reform(ESA6_intpl[yo-9,0:l-1, 0:m-1]))')
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
;    void = execute('gamma_'+year+'_'+zone+'= fltarr(l, m)')
;
;
;    for lati = 0, m-1 do begin
;      for loni = 0, l-1 do begin
;
;
;        ;void = execute('if (lat_arr[lati] ge -60) and (lat_arr[lati] le 30) and (lon_arr[loni] ge 179) and (lon_arr[loni] le 359)  then pos_arr_'+ynn+'[loni, lati] = 1')
;        ; void = execute('if (lat_arr[lati] lt -60) or (lat_arr[lati] gt 30) or (lon_arr[loni] lt 179) or (lon_arr[loni] gt 359) then pos_arr_'+ynn+'[loni, lati] = -1')
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

    void = execute('Flux_'+year+'_'+zone+'=[]')
    void = execute('f_'+year+'_'+zone+'=[]')
    void = execute('gamma_'+year+'_'+zone+'_full=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA2=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA3=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA4=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA5=[]')
    void = execute('Flux_'+year+'_'+zone+'_full_ESA6=[]')

    Energy = [0.71, 1.11, 1.74, 2.73, 4.29]


    for j = 0, 90-1 do begin
      for i = 0, 180-1 do begin

        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(Flux_ESA2_'+year+'[i, j]), (Flux_ESA3_'+year+'[i, j]), (Flux_ESA4_'+year+'[i, j]), (Flux_ESA5_'+year+'[i, j]), (Flux_ESA6_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(Flux_ESA2_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(Flux_ESA3_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(Flux_ESA4_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(Flux_ESA5_'+year+'[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(Flux_ESA6_'+year+'[i, j])]')
        
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then fin_arr'+year+'_'+zone+'=where(finite(Flux_'+year+'_'+zone+'))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then f_'+year+'_'+zone+' = LINFIT(alog(Energy[fin_arr'+year+'_'+zone+']), alog(Flux_'+year+'_'+zone+'[fin_arr'+year+'_'+zone+']))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
      endfor

    endfor


    void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full, /nan)')
    void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full, /nan)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
    void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
    void = execute('Flux_'+year+'_'+zone+'_sd = [stddev(Flux_'+year+'_'+zone+'_full_ESA2)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA2)), stddev(Flux_'+year+'_'+zone+'_full_ESA3)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA3)), stddev(Flux_'+year+'_'+zone+'_full_ESA4)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA4)), stddev(Flux_'+year+'_'+zone+'_full_ESA5)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA5)), stddev(Flux_'+year+'_'+zone+'_full_ESA6)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA6))]')


    ;    ;for oyn = 18, 20 do begin
    ;    for oyn = 16, 19 do begin
    ;      oynn= oyn + 1
    ;      yn = STRTRIM(oyn, 1)
    ;      ynn = STRTRIM(oynn, 1)
    ;      zone = STRTRIM(oynn-16, 1)
    ;
    ;      void = execute('pos_arr_'+yn+'= intarr(l, m)')
    ;      void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    ;      ;void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')
    ;      void = execute('gamma_'+year+'_'+zone+'= fltarr(l, m)')
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
    ;      void = execute('Flux_'+year+'_'+zone+'=[]')
    ;      void = execute('f_'+year+'_'+zone+'=[]')
    ;      void = execute('gamma_'+year+'_'+zone+'_full=[]')
    ;      void = execute('Flux_'+year+'_'+zone+'_full_ESA2=[]')
    ;      void = execute('Flux_'+year+'_'+zone+'_full_ESA3=[]')
    ;      void = execute('Flux_'+year+'_'+zone+'_full_ESA4=[]')
    ;      void = execute('Flux_'+year+'_'+zone+'_full_ESA5=[]')
    ;      void = execute('Flux_'+year+'_'+zone+'_full_ESA6=[]')
    ;
    ;      for j = 0, 90-1 do begin
    ;        for i = 0, 180-1 do begin
    ;
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1]), (ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2]), (ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3]), (ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4]), (ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j]/sp[b-9,j, i,1])]')
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j]/sp[b-9,j, i,2])]')
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j]/sp[b-9,j, i,3])]')
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j]/sp[b-9,j, i,4])]')
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j]/sp[b-9,j, i,5])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_intpl[b-9, i, j]), (ESA3_intpl[b-9, i, j]), (ESA4_intpl[b-9, i, j]), (ESA5_intpl[b-9, i, j]), (ESA6_intpl[b-9, i, j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_intpl[b-9, i, j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_intpl[b-9, i, j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_intpl[b-9, i, j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_intpl[b-9, i, j])]')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_intpl[b-9, i, j])]')
    ;          Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then fin_arr'+year+'_'+zone+'=where(finite(Flux_'+year+'_'+zone+'))')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy[fin_arr'+year+'_'+zone+']), alog(Flux_'+year+'_'+zone+'[fin_arr'+year+'_'+zone+']))')
    ;          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy), alog(Flux_'+year+'_'+zone+'))')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
    ;          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
    ;
    ;        endfor
    ;
    ;      endfor
    ;
    ;      void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full, /nan)')
    ;      void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full, /nan)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
    ;      void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
    ;
    ;
    ;    endfor

    ;stop

  endfor
  gamma_aram_scal =[gamma_11_0_avg, gamma_12_0_avg, gamma_13_0_avg, gamma_14_0_avg, gamma_15_0_avg]/gamma_ram_scal
  esa2_aram_scal = [flux_11_0_avg[0], flux_12_0_avg[0], flux_13_0_avg[0], flux_14_0_avg[0], flux_15_0_avg[0]]/ esa2_ram_scal
  esa3_aram_scal = [flux_11_0_avg[1], flux_12_0_avg[1], flux_13_0_avg[1], flux_14_0_avg[1], flux_15_0_avg[1]]/ esa3_ram_scal
  esa4_aram_scal = [flux_11_0_avg[2], flux_12_0_avg[2], flux_13_0_avg[2], flux_14_0_avg[2], flux_15_0_avg[2]]/ esa4_ram_scal
  esa5_aram_scal = [flux_11_0_avg[3], flux_12_0_avg[3], flux_13_0_avg[3], flux_14_0_avg[3], flux_15_0_avg[3]]/ esa5_ram_scal
  esa6_aram_scal = [flux_11_0_avg[4], flux_12_0_avg[4], flux_13_0_avg[4], flux_14_0_avg[4], flux_15_0_avg[4]]/ esa6_ram_scal
  esa2_ratio = (esa2_aram_scal[0]+esa2_aram_scal[1]+esa2_aram_scal[2]+esa2_aram_scal[3]+esa2_aram_scal[4])/5
  esa3_ratio = (esa3_aram_scal[0]+esa3_aram_scal[1]+esa3_aram_scal[2]+esa3_aram_scal[3]+esa3_aram_scal[4])/5
  esa4_ratio = (esa4_aram_scal[0]+esa4_aram_scal[1]+esa4_aram_scal[2]+esa4_aram_scal[3]+esa4_aram_scal[4])/5
  esa5_ratio = (esa5_aram_scal[0]+esa5_aram_scal[1]+esa5_aram_scal[2]+esa5_aram_scal[3]+esa5_aram_scal[4])/5
  esa6_ratio = (esa6_aram_scal[0]+esa6_aram_scal[1]+esa6_aram_scal[2]+esa6_aram_scal[3]+esa6_aram_scal[4])/5
  gamma_ratio = (gamma_aram_scal[0]+gamma_aram_scal[1]+gamma_aram_scal[2]+gamma_aram_scal[3]+gamma_aram_scal[4])/5
  ;stop
  
;  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;  gamma_1 = [flux_11_0_avg[0], flux_12_0_avg[0], flux_13_0_avg[0], flux_14_0_avg[0], flux_15_0_avg[0]]
;  gamma_er1 = [flux_11_0_sd[0], flux_12_0_sd[0], flux_13_0_sd[0], flux_14_0_sd[0], flux_15_0_sd[0]]
;  g2a = errorplot(time1, gamma_1/esa2_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[200, 400], xminor=0,XTITLE="Year in HS", YTITLE="ESA2")
;  ;g2a = errorplot(time1, gamma_1/esa2_aram_scal, gamma_er1, /overplot)
;  g2a.symbol= 'o'
;  g2a.SYM_SIZE= 1
;  g2a.SYM_FILLED=1
;  g2a.FONT_SIZE=15
;  g2a.LINESTYLE='-.'
;
;  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;  gamma_1 = [flux_11_0_avg[1], flux_12_0_avg[1], flux_13_0_avg[1], flux_14_0_avg[1], flux_15_0_avg[1]]
;  gamma_er1 = [flux_11_0_sd[1], flux_12_0_sd[1], flux_13_0_sd[1], flux_14_0_sd[1], flux_15_0_sd[1]]
;  g3a = errorplot(time1, gamma_1/esa3_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[80, 140], xminor=0,XTITLE="Year in HS", YTITLE="ESA3")
;  ;g3a = errorplot(time1, gamma_1/esa3_aram_scal, gamma_er1, /overplot)
;  g3a.symbol= 'o'
;  g3a.SYM_SIZE= 1
;  g3a.SYM_FILLED=1
;  g3a.FONT_SIZE=15
;  g3a.LINESTYLE='-.'

;  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;  gamma_1 = [flux_11_0_avg[2], flux_12_0_avg[2], flux_13_0_avg[2], flux_14_0_avg[2], flux_15_0_avg[2]]
;  gamma_er1 = [flux_11_0_sd[2], flux_12_0_sd[2], flux_13_0_sd[2], flux_14_0_sd[2], flux_15_0_sd[2]]
;  g4a = errorplot(time1, gamma_1/esa4_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[20, 60], xminor=0,XTITLE="Year in HS", YTITLE="ESA4")
;  ;g4a = errorplot(time1, gamma_1/esa4_aram_scal, gamma_er1, /overplot)
;  g4a.symbol= 'o'
;  g4a.SYM_SIZE= 1
;  g4a.SYM_FILLED=1
;  g4a.FONT_SIZE=15
;  g4a.LINESTYLE='-.'
  ;
;  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;  gamma_1 = [flux_11_0_avg[3], flux_12_0_avg[3], flux_13_0_avg[3], flux_14_0_avg[3], flux_15_0_avg[3]]
;  gamma_er1 = [flux_11_0_sd[3], flux_12_0_sd[3], flux_13_0_sd[3], flux_14_0_sd[3], flux_15_0_sd[3]]
;  g5a = errorplot(time1, gamma_1/esa5_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[10, 20], xminor=0,XTITLE="Year in HS", YTITLE="ESA5")
;  ;g5a = errorplot(time1, gamma_1/esa5_aram_scal, gamma_er1, /overplot)
;  g5a.symbol= 'o'
;  g5a.SYM_SIZE= 1
;  g5a.SYM_FILLED=1
;  g5a.FONT_SIZE=15
;  g5a.LINESTYLE='-.'
;  ;
  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  gamma_1 = [flux_11_0_avg[4], flux_12_0_avg[4], flux_13_0_avg[4], flux_14_0_avg[4], flux_15_0_avg[4]]
  gamma_er1 = [flux_11_0_sd[4], flux_12_0_sd[4], flux_13_0_sd[4], flux_14_0_sd[4], flux_15_0_sd[4]]
  g6a = errorplot(time1, gamma_1/esa6_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[2, 8], xminor=0,XTITLE="Year in HS", YTITLE="ESA6")
  ;g6a = errorplot(time1, gamma_1/esa6_aram_scal, gamma_er1, /overplot)
  g6a.symbol= 'o'
  g6a.SYM_SIZE= 1
  g6a.SYM_FILLED=1
  g6a.FONT_SIZE=15
  g6a.LINESTYLE='-.'
;  
  
  
  
  stop
;  
;  gamma_avg_Aram = (gamma_11_0_avg+gamma_12_0_avg+gamma_13_0_avg+gamma_14_0_avg+gamma_15_0_avg)/6
;  esa2_avg_Aram = (flux_11_0_avg[0]+flux_12_0_avg[0]+flux_13_0_avg[0]+flux_14_0_avg[0]+flux_15_0_avg[0])/6
;  esa3_avg_Aram = (flux_11_0_avg[1]+flux_12_0_avg[1]+flux_13_0_avg[1]+flux_14_0_avg[1]+flux_15_0_avg[1])/6
;  esa4_avg_Aram = (flux_11_0_avg[2]+flux_12_0_avg[2]+flux_13_0_avg[2]+flux_14_0_avg[2]+flux_15_0_avg[2])/6
;  esa5_avg_Aram = (flux_11_0_avg[3]+flux_12_0_avg[3]+flux_13_0_avg[3]+flux_14_0_avg[3]+flux_15_0_avg[3])/6
;  esa6_avg_Aram = (flux_11_0_avg[4]+flux_12_0_avg[4]+flux_13_0_avg[4]+flux_14_0_avg[4]+flux_15_0_avg[4])/6
;  gamma_ratio =  gamma_avg_Aram/gamma_avg_ram
  
 
;  
;  
  
  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
  gamma_1 = [gamma_11_0_avg, gamma_12_0_avg, gamma_13_0_avg, gamma_14_0_avg, gamma_15_0_avg]
  gamma_er1 = [gamma_11_0_sd, gamma_12_0_sd, gamma_13_0_sd, gamma_14_0_sd, gamma_15_0_sd]
  ;g1a = errorplot(time1, gamma_1/gamma_ratio , gamma_er1, /overplot)
  g1a = errorplot(time1, gamma_1/gamma_aram_scal , gamma_er1, /overplot)
  g1a.symbol= 'o'
  g1a.SYM_SIZE= 1
  g1a.SYM_FILLED=1
  g1a.FONT_SIZE=15
  g1a.LINESTYLE='-.'
  
;  g1a.save, 'mir_speci_hsm.png'


  
;  esa2_ratio = esa2_avg_Aram/esa2_avg_ram
;  esa3_ratio = esa3_avg_Aram/esa3_avg_ram
;  esa4_ratio = esa4_avg_Aram/esa4_avg_ram
;  esa5_ratio = esa5_avg_Aram/esa5_avg_ram
;  esa6_ratio = esa6_avg_Aram/esa6_avg_ram
;  
;  
;  time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;    gamma_1 = [flux_11_0_avg[0], flux_12_0_avg[0], flux_13_0_avg[0], flux_14_0_avg[0], flux_15_0_avg[0]]
;    gamma_er1 = [flux_11_0_sd[0], flux_12_0_sd[0], flux_13_0_sd[0], flux_14_0_sd[0], flux_15_0_sd[0]]
;    g2a = errorplot(time1, gamma_1/esa2_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[200, 400], xminor=0,XTITLE="Year in HS", YTITLE="ESA2")
;    
;    g2a.symbol= 'o'
;    g2a.SYM_SIZE= 1
;    g2a.SYM_FILLED=1
;    g2a.FONT_SIZE=15
;     g2a.LINESTYLE='-.'
;  
;    time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;    gamma_1 = [flux_11_0_avg[1], flux_12_0_avg[1], flux_13_0_avg[1], flux_14_0_avg[1], flux_15_0_avg[1]]
;    gamma_er1 = [flux_11_0_sd[1], flux_12_0_sd[1], flux_13_0_sd[1], flux_14_0_sd[1], flux_15_0_sd[1]]
;    g3a = errorplot(time1, gamma_1/esa3_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[80, 140], xminor=0,XTITLE="Year in HS", YTITLE="ESA3")
;    g3a.symbol= 'o'
;    g3a.SYM_SIZE= 1
;    g3a.SYM_FILLED=1
;    g3a.FONT_SIZE=15
;     g3a.LINESTYLE='-.'
;  
;    time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;    gamma_1 = [flux_11_0_avg[2], flux_12_0_avg[2], flux_13_0_avg[2], flux_14_0_avg[2], flux_15_0_avg[2]]
;    gamma_er1 = [flux_11_0_sd[2], flux_12_0_sd[2], flux_13_0_sd[2], flux_14_0_sd[2], flux_15_0_sd[2]]
;    g4a = errorplot(time1, gamma_1/esa4_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[20, 60], xminor=0,XTITLE="Year in HS", YTITLE="ESA4")
;    g4a.symbol= 'o'
;    g4a.SYM_SIZE= 1
;    g4a.SYM_FILLED=1
;    g4a.FONT_SIZE=15
;     g4a.LINESTYLE='-.'
;;  
;    time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;    gamma_1 = [flux_11_0_avg[3], flux_12_0_avg[3], flux_13_0_avg[3], flux_14_0_avg[3], flux_15_0_avg[3]]
;    gamma_er1 = [flux_11_0_sd[3], flux_12_0_sd[3], flux_13_0_sd[3], flux_14_0_sd[3], flux_15_0_sd[3]]
;    g5a = errorplot(time1, gamma_1/esa5_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[10, 20], xminor=0,XTITLE="Year in HS", YTITLE="ESA5")
;    g5a.symbol= 'o'
;    g5a.SYM_SIZE= 1
;    g5a.SYM_FILLED=1
;    g5a.FONT_SIZE=15
;     g5a.LINESTYLE='-.'
;;  
;    time1 = [2011.75, 2012.75, 2013.75, 2014.75, 2015.75]
;    gamma_1 = [flux_11_0_avg[4], flux_12_0_avg[4], flux_13_0_avg[4], flux_14_0_avg[4], flux_15_0_avg[4]]
;    gamma_er1 = [flux_11_0_sd[4], flux_12_0_sd[4], flux_13_0_sd[4], flux_14_0_sd[4], flux_15_0_sd[4]]
;    g6a = errorplot(time1, gamma_1/esa6_ratio, gamma_er1, /overplot);, xrange=[2010, 2016], yrange=[2, 8], xminor=0,XTITLE="Year in HS", YTITLE="ESA6")
;    g6a.symbol= 'o'
;    g6a.SYM_SIZE= 1
;    g6a.SYM_FILLED=1
;    g6a.FONT_SIZE=15
;     g6a.LINESTYLE='-.'
;  
  
  
  
 ;stop
  
  ;ram_speci_11
  ;Aram_speci_11
  
  mx = 3.0
  mn = 1.0
  binsize = 0.05
  yrange = [0, 800]
  
;  pdf9 = HISTOGRAM(gamma_9_0_full, LOCATIONS=xbin9,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin9[0:4], pdf9[0:4], XTITLE='2009', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin9[5:9], pdf9[5:9], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin9[10:14], pdf9[10:14], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin9[15:19], pdf9[15:19], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin9[20:24], pdf9[20:24], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin9[25:29], pdf9[25:29], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin9[30:35], pdf9[30:35], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin9[35:40], pdf9[35:40], XTITLE='2009', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;    
;    pdf10 = HISTOGRAM(gamma_10_0_full, LOCATIONS=xbin10,  MAX= mx, MIN= mn, binsize = binsize)
;
;  graphic = BARPLOT(xbin10[0:4], pdf10[0:4], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )
;
;  graphic = BARPLOT(xbin10[5:9], pdf10[5:9], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin10[10:14], pdf10[10:14], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin10[15:19], pdf10[15:19], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin10[20:24], pdf10[20:24], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin10[25:29], pdf10[25:29], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin10[30:35], pdf10[30:35], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
;
;  graphic = BARPLOT(xbin10[35:40], pdf10[35:40], XTITLE='2010', YTITLE='Number of pixels', FONT_SIZE = 20, $
;    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  pdf11 = HISTOGRAM(gamma_11_0_full/gamma_aram_scal[0], LOCATIONS=xbin11,  MAX= mx, MIN= mn, binsize = binsize)

  graphic = BARPLOT(xbin11[0:4], pdf11[0:4], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

  graphic = BARPLOT(xbin11[5:9], pdf11[5:9], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[10:14], pdf11[10:14], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[15:19], pdf11[15:19], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[20:24], pdf11[20:24], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[25:29], pdf11[25:29], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[30:35], pdf11[30:35], XTITLE='2011', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

  graphic = BARPLOT(xbin11[35:40], pdf11[35:40], XTITLE='2011.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
    xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
    
    ;-------------
    
    pdf12 = HISTOGRAM(gamma_12_0_full/gamma_aram_scal[1], LOCATIONS=xbin12,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin12[0:4], pdf12[0:4], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin12[5:9], pdf12[5:9], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin12[10:14], pdf12[10:14], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin12[15:19], pdf12[15:19], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin12[20:24], pdf12[20:24], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin12[25:29], pdf12[25:29], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin12[30:35], pdf12[30:35], XTITLE='2012', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin12[35:40], pdf12[35:40], XTITLE='2012.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      
    ;-------------

    pdf13 = HISTOGRAM(gamma_13_0_full/gamma_aram_scal[2], LOCATIONS=xbin13,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin13[0:4], pdf13[0:4], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin13[5:9], pdf13[5:9], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin13[10:14], pdf13[10:14], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin13[15:19], pdf13[15:19], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin13[20:24], pdf13[20:24], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin13[25:29], pdf13[25:29], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin13[30:35], pdf13[30:35], XTITLE='2013', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin13[35:40], pdf13[35:40], XTITLE='2013.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      
      ;-------------

    pdf14 = HISTOGRAM(gamma_14_0_full/gamma_aram_scal[3], LOCATIONS=xbin14,  MAX= mx, MIN= mn, binsize = binsize)

    graphic = BARPLOT(xbin14[0:4], pdf14[0:4], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'medium violet red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0 )

    graphic = BARPLOT(xbin14[5:9], pdf14[5:9], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'red', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin14[10:14], pdf14[10:14], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'dark orange', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin14[15:19], pdf14[15:19], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'yellow', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin14[20:24], pdf14[20:24], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'lime', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin14[25:29], pdf14[25:29], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'cyan', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin14[30:35], pdf14[30:35], XTITLE='2014', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'blue', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )

    graphic = BARPLOT(xbin14[35:40], pdf14[35:40], XTITLE='2014.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
      
      ;-------------

    pdf15 = HISTOGRAM(gamma_15_0_full/gamma_aram_scal[4], LOCATIONS=xbin15,  MAX= mx, MIN= mn, binsize = binsize)

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

    graphic = BARPLOT(xbin15[35:40], pdf15[35:40], XTITLE='2015.75', YTITLE='Number of pixels', FONT_SIZE = 20, $
      xthick = 2, ythick = 2, AXIS_STYLE=1, COLOR='black', fill_color = 'black', xrange = [mn, mx], yrange = yrange, transparency=30, histogram =0, /overplot )
  

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
;  time17 = [2018,2019]
;
;  gamma_1 = [gamma_16_0_avg, gamma_17_0_avg, gamma_18_0_avg, gamma_19_0_avg, gamma_20_0_avg]
;  gamma_1a = [gamma_16_0_avg, gamma_17_0_avg, gamma_18_0_avg, gamma_19_0_avg]
;  gamma_1b = [gamma_19_0_avg, gamma_20_0_avg]
;  gamma_2 = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg, gamma_20_1_avg]
;  gamma_2a = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg]
;  gamma_2b = [gamma_19_1_avg, gamma_20_1_avg]
;  gamma_3 = [gamma_18_2_avg, gamma_19_2_avg, gamma_20_2_avg]
;  gamma_3a = [gamma_18_2_avg, gamma_19_2_avg]
;  gamma_3b = [gamma_19_2_avg, gamma_20_2_avg]
;  gamma_4 = [gamma_19_3_avg, gamma_20_3_avg]
;  gamma_7 =  [gamma_16_1_avg]
;  gamma_8 =  [gamma_17_2_avg]
;  gamma_9 = [gamma_18_3_avg]
;  gamma_13 = [gamma_15_0_avg]
;  gamma_14 = [gamma_15_0_avg, gamma_16_0_avg]
;  gamma_15 = [gamma_16_1_avg, gamma_17_1_avg]
;  gamma_16 = [gamma_17_2_avg, gamma_18_2_avg]
;  gamma_17 = [gamma_18_3_avg, gamma_19_3_avg]
;
;
;  gamma_er1 = [gamma_16_0_sd, gamma_17_0_sd, gamma_18_0_sd, gamma_19_0_sd, gamma_20_0_sd]
;  gamma_er1a = [gamma_16_0_sd, gamma_17_0_sd, gamma_18_0_sd, gamma_19_0_sd]
;  gamma_er1b = [gamma_19_0_sd, gamma_20_0_sd]
;  gamma_er2 = [gamma_17_1_sd, gamma_18_1_sd, gamma_19_1_sd, gamma_20_1_sd]
;  gamma_er2a = [gamma_17_1_sd, gamma_18_1_sd, gamma_19_1_sd]
;  gamma_er2b = [gamma_19_1_sd, gamma_20_1_sd]
;  gamma_er3 = [gamma_18_2_sd, gamma_19_2_sd, gamma_20_2_sd]
;  gamma_er3a = [gamma_18_2_sd, gamma_19_2_sd]
;  gamma_er3b = [gamma_19_2_sd, gamma_20_2_sd]
;  gamma_er4 = [gamma_19_3_sd, gamma_20_3_sd]
;  gamma_er7 =  [gamma_16_1_sd]
;  gamma_er8 =  [gamma_17_2_sd]
;  gamma_er9 = [gamma_18_3_sd]
;  gamma_er13 = [gamma_15_0_sd]
;  gamma_er14 = [gamma_15_0_sd, gamma_16_0_sd]
;  gamma_er15 = [gamma_16_1_sd, gamma_17_1_sd]
;  gamma_er16 = [gamma_17_2_sd, gamma_18_2_sd]
;  gamma_er17 = [gamma_18_3_sd, gamma_19_3_sd]
;
;
;  g1a = errorplot(time1, gamma_1a, gamma_er1a, xrange=[2014, 2021], yrange=[1.1, 2.6], xminor=0,XTITLE="Year in HS", YTITLE="Spectral Index")
;  g1a.symbol= 'o'
;  g1a.SYM_SIZE= 1
;  g1a.SYM_FILLED=1
;  g1a.FONT_SIZE=15
;
;  g1b = errorplot(time1b, gamma_1b, gamma_er1b, /overplot)
;  g1b.symbol= 'o'
;  g1b.SYM_SIZE= 1
;  g1b.SYM_FILLED=1
;  g1b.FONT_SIZE=15
;  g1b.LINESTYLE='-.'
;
;  g2a = errorplot(time2a, gamma_2a, gamma_er2a, /overplot)
;  g2a.symbol= 'o'
;  g2a.SYM_SIZE= 1
;  g2a.SYM_FILLED=1
;  g2a.FONT_SIZE=15
;  g2a.COLOR ="blue"
;  g2a.ERRORBAR_COLOR="blue"
;
;  g2b = errorplot(time2b, gamma_2b, gamma_er2b, /overplot)
;  g2b.symbol= 'o'
;  g2b.SYM_SIZE= 1
;  g2b.SYM_FILLED=1
;  g2b.FONT_SIZE=15
;  g2b.COLOR ="blue"
;  g2b.ERRORBAR_COLOR="blue"
;  g2b.LINESTYLE='-.'
;
;  g3a = errorplot(time3a, gamma_3a, gamma_er3a, /overplot)
;  g3a.symbol= 'o'
;  g3a.SYM_SIZE= 1
;  g3a.SYM_FILLED=1
;  g3a.FONT_SIZE=15
;  g3a.COLOR ="green"
;  g3a.ERRORBAR_COLOR="green"
;
;  g3b = errorplot(time3b, gamma_3b, gamma_er3b, /overplot)
;  g3b.symbol= 'o'
;  g3b.SYM_SIZE= 1
;  g3b.SYM_FILLED=1
;  g3b.FONT_SIZE=15
;  g3b.COLOR ="green"
;  g3b.ERRORBAR_COLOR="green"
;  g3b.LINESTYLE='-.'
;
;  ;g4 = errorplot(time4, gamma_4, gamma_er4, /overplot)
;  ;g4.symbol= 'o'
;  ;g4.SYM_SIZE= 1
;  ;g4.SYM_FILLED=1
;  ;g4.FONT_SIZE=15
;  ;g4.COLOR ="orange"
;  ;g4.ERRORBAR_COLOR="orange"
;  ;g4.LINESTYLE='-.'
;
;
;  g6 = errorplot(time13, gamma_13, gamma_er13, /overplot)
;  g6.symbol= 'X'
;  g6.SYM_SIZE= 1
;  g6.SYM_FILLED=1
;  g6.FONT_SIZE=15
;
;  g7 = errorplot(time7, gamma_7, gamma_er7, /overplot)
;  g7.symbol= 'X'
;  g7.SYM_SIZE= 1
;  g7.SYM_FILLED=1
;  g7.FONT_SIZE=15
;  g7.COLOR ="blue"
;  g7.ERRORBAR_COLOR="blue"
;
;  g8 = errorplot(time8, gamma_8, gamma_er8, /overplot)
;  g8.symbol= 'X'
;  g8.SYM_SIZE= 1
;  g8.SYM_FILLED=1
;  g8.FONT_SIZE=15
;  g8.COLOR ="green"
;  g8.ERRORBAR_COLOR="green"
;
;  ;g9 = errorplot(time9, gamma_9, gamma_er9, /overplot)
;  ;g9.symbol= 'X'
;  ;g9.SYM_SIZE= 1
;  ;g9.SYM_FILLED=1
;  ;g9.FONT_SIZE=15
;  ;g9.COLOR ="orange"
;  ;g9.ERRORBAR_COLOR="orange"
;
;
;  g14 = errorplot(time14, gamma_14, gamma_er14, /overplot)
;  ;g10.symbol= '.'
;  ;g10.SYM_SIZE= 1
;  ;g10.SYM_FILLED=1
;  g14.FONT_SIZE=15
;  g14.COLOR ="black"
;  g14.ERRORBAR_COLOR="black"
;  g14.LINESTYLE='--'
;
;  g15 = errorplot(time15, gamma_15, gamma_er15, /overplot)
;  g15.FONT_SIZE=15
;  g15.COLOR ="blue"
;  g15.ERRORBAR_COLOR="blue"
;  g15.LINESTYLE='--'
;
;  g16 = errorplot(time16, gamma_16, gamma_er16, /overplot)
;  g16.FONT_SIZE=15
;  g16.COLOR ="green"
;  g16.ERRORBAR_COLOR="green"
;  g16.LINESTYLE='--'
;
;  ;g17 = errorplot(time17, gamma_17, gamma_er17, /overplot)
;  ;g17.FONT_SIZE=15
;  ;g17.COLOR ="orange"
;  ;g17.ERRORBAR_COLOR="orange"
;  ;g17.LINESTYLE='--'
;
;
;
;
;  g16.save, 'speci_hsm.png'

  stop
  
  end