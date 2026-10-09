pro pres_zones_speci_non_interpol
;28Jun
;restore, 'ESA_intpl_wNAN.sav'
;restore, 'RS_2Aug23ESA_intpl_wNAN.sav'
;restore, 'RS_2Aug23all_pres_intpl_wNan.sav'
;restore, 'all_pres_8Aug.sav'
restore, 'p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

all_ESA6= []
;all_ESA5= []
l=180
m=90
zl=6
;zl=5
num = STRTRIM(zl, 1)
pf = 0.5 ; percentage factor to be multiplied with max flux
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
  ;void = execute('Pres_all_'+yos+' = reform((Pres_ESA2_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA3_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
  void = execute('Pres_all_'+yos+' = reform((Pres_ESA4_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA5_intpl[yo-9,0:l-1, 0:m-1]+Pres_ESA6_intpl[yo-9,0:l-1, 0:m-1]), 180, 90)')
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
  restore, '/Users/nwalia/data/RS_8Aug23/cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'


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
      void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[ i, j]), (ESA3_GDF_MAP[ i, j]), (ESA4_GDF_MAP[ i, j]), (ESA5_GDF_MAP[ i, j]), (ESA6_GDF_MAP[ i, j])]')
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
  void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')


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
         void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[ i, j]), (ESA3_GDF_MAP[ i, j]), (ESA4_GDF_MAP[ i, j]), (ESA5_GDF_MAP[ i, j]), (ESA6_GDF_MAP[ i, j])]')
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
    void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')


  endfor

  ;stop

endfor

all_ESA6= []
;all_ESA5= []

;save, filename='zones.sav'





SET_PLOT, 'PS'

time1 = [16, 17, 18, 19, 20, 21]
time1a = [16, 17, 18, 19]
time1b = [19, 20, 21]
time2 = [17, 18, 19, 20, 21]
time2a = [17, 18, 19]
time2b = [19, 20, 21]
time3 = [18, 19, 20, 21]
time3a = [18, 19]
time3b = [19, 20, 21]
time4 = [19, 20, 21]
time7 = [16]
time8 = [17]
time9 = [18]
time13= [15]

gamma_1 = [gamma_16_0_avg, gamma_17_0_avg, gamma_18_0_avg, gamma_19_0_avg, gamma_20_0_avg, gamma_21_0_avg]
gamma_1a = [gamma_16_0_avg, gamma_17_0_avg, gamma_18_0_avg, gamma_19_0_avg]
gamma_1b = [gamma_19_0_avg, gamma_20_0_avg, gamma_21_0_avg]
gamma_2 = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg, gamma_20_1_avg, gamma_21_1_avg]
gamma_2a = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg]
gamma_2b = [gamma_19_1_avg, gamma_20_1_avg, gamma_21_1_avg]
gamma_3 = [gamma_18_2_avg, gamma_19_2_avg, gamma_20_2_avg, gamma_21_2_avg]
gamma_3a = [gamma_18_2_avg, gamma_19_2_avg]
gamma_3b = [gamma_19_2_avg, gamma_20_2_avg, gamma_21_2_avg]
gamma_4 = [gamma_19_3_avg, gamma_20_3_avg, gamma_21_3_avg]
gamma_7 =  [gamma_16_1_avg]
gamma_8 =  [gamma_17_2_avg]
gamma_9 = [gamma_18_3_avg]
gamma_13 = [gamma_15_0_avg]

DEVICE, Bits_per_Pixel=8, Color=1, FILENAME='pres_zone_speci.ps'
plot, time1, gamma_1, color = fsc_color('black'), thick = 4, psym = 2, yrange = [1.5, 2.5], xrange = [15, 22], xtitle ='Year', ytitle='Spectral Index', xminor = 2, xthick = 4, ythick = 4, charthick = 4, charsize = 1.5
oplot, time1a, gamma_1a ,color = fsc_color('black'), thick = 2
oplot, time1b, gamma_1b ,color = fsc_color('black'), thick = 2, linestyle=2
oplot, time2, gamma_2 ,color = fsc_color('blue'), psym = 2, thick = 4
oplot, time2a, gamma_2a ,color = fsc_color('blue'), thick = 2
oplot, time2b, gamma_2b ,color = fsc_color('blue'), thick = 2, linestyle=2
oplot, time3, gamma_3 , color = fsc_color('green'), psym = 2, thick = 4
oplot, time3a, gamma_3a , color = fsc_color('green'), thick = 2
oplot, time3b, gamma_3b , color = fsc_color('green'), thick = 2, linestyle=2
oplot, time4, gamma_4 , color = fsc_color('orange'), psym = 2, thick = 4
oplot, time4, gamma_4 , color = fsc_color('orange'), thick = 2, linestyle=2
oplot, time7, gamma_7, color = fsc_color('blue'), psym = 1, thick = 4
oplot, time8, gamma_8, color = fsc_color('green'), psym = 1, thick = 4
oplot, time9, gamma_9, color = fsc_color('orange'), psym = 1, thick = 4
oplot, time13, gamma_13, color = fsc_color('black'), psym = 1, thick = 4
DEVICE, /CLOSE

stop

end

