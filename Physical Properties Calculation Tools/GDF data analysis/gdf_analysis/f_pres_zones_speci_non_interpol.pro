pro f_pres_zones_speci_non_interpol
;5Oct
  ;restore, 'ESA_intpl.sav'
  all_ESA6= []
  l=180
  m=90
  zl=5;3;4;5

  ;restore, 'all_pres_8Aug_ag.sav'
  restore, '/Users/nwalia/IDLWorkspace/all_pres_7May_ag.sav'
  restore, '/Users/nwalia/IDLWorkspace/p_RS_7Mayall_pres_intpl_wNan_fract_new.sav'

  pf = 0.6 ; percentage factor to be multiplied with max flux
  pfs = STRTRIM(pf, 2)

  ;mid_arr = ['A_20', 'A_20']
  ;last_arr = ['B_antiram', 'B_ram']
  mid_arr = ['A_20']
  last_arr = ['B_ram']
  ;last_arr = ['B_aram']

  ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/asurv_map_04-05-2023/surv_map.sav
  ;sp = surv_struct.YEARLY_SURV_SC_RAM
  ;restore, '/Users/nwalia/data/survival_prob_theseus/surv_map_2009_2022.sav'
  ;sp = surv_struct.THESEUS_YEARLY_SURV_SC_RAM

  restarri = 0
  ;for restarri = 0, 1 do begin
  for yo = 11, 16 do begin
    yos = STRTRIM(yo, 1)
    void = execute('Pres_all_'+yos+' = reform((Pres_ESA2[yo-9,0:l-1, 0:m-1]+Pres_ESA3[yo-9,0:l-1, 0:m-1]+Pres_ESA4[yo-9,0:l-1, 0:m-1]+Pres_ESA5[yo-9,0:l-1, 0:m-1]+Pres_ESA6[yo-9,0:l-1, 0:m-1]), 180, 90)')
  endfor


  for b = 11, 16 do begin
    ;for b = 16, 22 do begin

    year = STRTRIM(b, 2)

    ;restore, '/Users/nwalia/data/Theseus_Flux_yearly_4.7.23/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/LRS_Jun27/gdf_sc_frame_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'
    ;restore, '/Users/nwalia/data/RS_8Aug23/cg_sp/ram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'
    restore, '/Users/nwalia/data/svgp_tot_and_gdf/seperated_maps/gdf_cg_sp/antiram/data/SAV/Theseus-L_RBN_SEP_20'+year+mid_arr[restarri]+year+last_arr[restarri]+'.sav'


    oyn = 11
    oynn= oyn + 1
    yn = STRTRIM(oyn, 1)
    ynn = STRTRIM(oynn, 1)
    zone = STRTRIM(1, 1)

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

        ;void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[i, j]/sp[b-9,j, i,1]), (ESA3_GDF_MAP[i, j]/sp[b-9,j, i,2]), (ESA4_GDF_MAP[i, j]/sp[b-9,j, i,3]), (ESA5_GDF_MAP[i, j]/sp[b-9,j, i,4]), (ESA6_GDF_MAP[i, j]/sp[b-9,j, i,5])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_GDF_MAP[i, j]/sp[b-9,j, i,1])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_GDF_MAP[i, j]/sp[b-9,j, i,2])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_GDF_MAP[i, j]/sp[b-9,j, i,3])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_GDF_MAP[i, j]/sp[b-9,j, i,4])]')
        ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_GDF_MAP[i, j]/sp[b-9,j, i,5])]')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[i, j]), (ESA3_GDF_MAP[i, j]), (ESA4_GDF_MAP[i, j]), (ESA5_GDF_MAP[i, j]), (ESA6_GDF_MAP[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_GDF_MAP[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_GDF_MAP[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_GDF_MAP[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_GDF_MAP[i, j])]')
        void = execute('if (pos_arr_'+ynn+'[i,j] eq 1)   then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_GDF_MAP[i, j])]')
        Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then f_'+year+'_'+zone+' = LINFIT(alog(Energy), alog(Flux_'+year+'_'+zone+'))')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
        void = execute('if pos_arr_'+ynn+'[i,j] eq 1  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
      endfor

    endfor


    void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full)')
    void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
    void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
    void = execute('Flux_'+year+'_'+zone+'_sd = [stddev(Flux_'+year+'_'+zone+'_full_ESA2)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA2)), stddev(Flux_'+year+'_'+zone+'_full_ESA3)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA3)), stddev(Flux_'+year+'_'+zone+'_full_ESA4)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA4)), stddev(Flux_'+year+'_'+zone+'_full_ESA5)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA5)), stddev(Flux_'+year+'_'+zone+'_full_ESA6)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA6))]')
    

    ;oyn = 17
    ;oynn= oyn + 1
    ;yn = STRTRIM(oyn, 1)
    ;ynn = STRTRIM(oynn, 1)
   ; zone = STRTRIM(oynn-16, 1)

    ;void = execute('pos_arr_'+yn+'= intarr(l, m)')
   ; void = execute('pos_arr_'+ynn+'= intarr(l, m)')
    ;void = execute('gamma_'+year+'_'+zone+'= intarr(l, m)')

    ;for lati = 0, m-1 do begin
    ;  for loni = 0, l-1 do begin

     ;   void = execute('if (Pres_all_'+yn+'[loni, lati] ge pf*max(Pres_all_'+yn+')) and (loni gt 70)  then pos_arr_'+yn+'[loni, lati] = 1')
    ;    void = execute('if (Pres_all_'+yn+'[loni, lati] lt pf*max(Pres_all_'+yn+')) then pos_arr_'+yn+'[loni, lati] = -1')

    ;  endfor
   ; endfor

   ; for lati = 0, m-1 do begin
    ;  for loni = 0, l-1 do begin

    ;    void = execute('if Pres_all_'+ynn+'[loni, lati] ge pf*max(Pres_all_'+ynn+') then pos_arr_'+ynn+'[loni, lati] = 1 else pos_arr_'+ynn+'[loni, lati] = -1')

    ;  endfor
   ; endfor

   ; d=[]
    ;d_o=[]
  ;  dd=[]
   ; e=[]
   ; indices=[]

   ; void = execute('Flux_'+year+'_'+zone+'=[]')
   ; void = execute('f_'+year+'_'+zone+'=[]')
   ; void = execute('gamma_'+year+'_'+zone+'_full=[]')
   ; void = execute('Flux_'+year+'_'+zone+'_full_ESA2=[]')
   ; void = execute('Flux_'+year+'_'+zone+'_full_ESA3=[]')
   ; void = execute('Flux_'+year+'_'+zone+'_full_ESA4=[]')
   ; void = execute('Flux_'+year+'_'+zone+'_full_ESA5=[]')
   ; void = execute('Flux_'+year+'_'+zone+'_full_ESA6=[]')

   ; for j = 0, 90-1 do begin
   ;   for i = 0, 180-1 do begin

       
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[i, j]), (ESA3_GDF_MAP[i, j]), (ESA4_GDF_MAP[i, j]), (ESA5_GDF_MAP[i, j]), (ESA6_GDF_MAP[i, j])]')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_GDF_MAP[i, j])]')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_GDF_MAP[i, j])]')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_GDF_MAP[i, j])]')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_GDF_MAP[i, j])]')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_GDF_MAP[i, j])]')
   ;     Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy), alog(Flux_'+year+'_'+zone+'))')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
   ;     void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')


    ;  endfor

    ;endfor


    ;void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full)')
    ;void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
    ;void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
    ;void = execute('Flux_'+year+'_'+zone+'_sd = [stddev(Flux_'+year+'_'+zone+'_full_ESA2)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full)), stddev(Flux_'+year+'_'+zone+'_full_ESA3)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full)), stddev(Flux_'+year+'_'+zone+'_full_ESA4)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full)), stddev(Flux_'+year+'_'+zone+'_full_ESA5)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full)), stddev(Flux_'+year+'_'+zone+'_full_ESA6)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))]')


    for oyn = 12, 15 do begin

      oynn= oyn + 1
      yn = STRTRIM(oyn, 1)
      ynn = STRTRIM(oynn, 1)
      zone = STRTRIM(1, 1)

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

          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[i, j]/sp[b-9,j, i,1]), (ESA3_GDF_MAP[i, j]/sp[b-9,j, i,2]), (ESA4_GDF_MAP[i, j]/sp[b-9,j, i,3]), (ESA5_GDF_MAP[i, j]/sp[b-9,j, i,4]), (ESA6_GDF_MAP[i, j]/sp[b-9,j, i,5])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_GDF_MAP[i, j]/sp[b-9,j, i,1])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_GDF_MAP[i, j]/sp[b-9,j, i,2])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_GDF_MAP[i, j]/sp[b-9,j, i,3])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_GDF_MAP[i, j]/sp[b-9,j, i,4])]')
          ;void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_GDF_MAP[i, j]/sp[b-9,j, i,5])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+' = [(ESA2_GDF_MAP[i, j]), (ESA3_GDF_MAP[i, j]), (ESA4_GDF_MAP[i, j]), (ESA5_GDF_MAP[i, j]), (ESA6_GDF_MAP[i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA2 = [Flux_'+year+'_'+zone+'_full_ESA2,(ESA2_GDF_MAP[i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA3 = [Flux_'+year+'_'+zone+'_full_ESA3,(ESA3_GDF_MAP[i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA4 = [Flux_'+year+'_'+zone+'_full_ESA4,(ESA4_GDF_MAP[i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA5 = [Flux_'+year+'_'+zone+'_full_ESA5,(ESA5_GDF_MAP[i, j])]')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then Flux_'+year+'_'+zone+'_full_ESA6 = [Flux_'+year+'_'+zone+'_full_ESA6,(ESA6_GDF_MAP[i, j])]')
          Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then f_'+year+'_'+zone+' = LINFIT(alog(Energy), alog(Flux_'+year+'_'+zone+'))')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1) then gamma_'+year+'_'+zone+'[i,j] =  abs(f_'+year+'_'+zone+'[1])')
          void = execute('if (pos_arr_'+ynn+'[i,j] eq 1) and (pos_arr_'+yn+'[i,j] eq -1)  then gamma_'+year+'_'+zone+'_full = [gamma_'+year+'_'+zone+'_full, abs(f_'+year+'_'+zone+'[1])]')
        endfor

      endfor


      void = execute('gamma_'+year+'_'+zone+'_avg = mean(gamma_'+year+'_'+zone+'_full)')
      void = execute('gamma_'+year+'_'+zone+'_sd = stddev(gamma_'+year+'_'+zone+'_full)/sqrt(n_elements(gamma_'+year+'_'+zone+'_full))')
      void = execute('Flux_'+year+'_'+zone+'_avg = [mean(Flux_'+year+'_'+zone+'_full_ESA2), mean(Flux_'+year+'_'+zone+'_full_ESA3), mean(Flux_'+year+'_'+zone+'_full_ESA4), mean(Flux_'+year+'_'+zone+'_full_ESA5), mean(Flux_'+year+'_'+zone+'_full_ESA6)]')
      void = execute('Flux_'+year+'_'+zone+'_sd = [stddev(Flux_'+year+'_'+zone+'_full_ESA2)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA2)), stddev(Flux_'+year+'_'+zone+'_full_ESA3)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA3)), stddev(Flux_'+year+'_'+zone+'_full_ESA4)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA4)), stddev(Flux_'+year+'_'+zone+'_full_ESA5)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA5)), stddev(Flux_'+year+'_'+zone+'_full_ESA6)/sqrt(n_elements(Flux_'+year+'_'+zone+'_full_ESA6))]')

    endfor

    ESA2_GDF_MAP=[]
    ESA3_GDF_MAP=[]
    ESA4_GDF_MAP=[]
    ESA5_GDF_MAP=[]
    ESA6_GDF_MAP=[]

    ;stop

  endfor

  all_ESA6= []

  ;save, filename='7May_speci_non_intpl.sav'

  stop
  
  Energy = [0.71, 1.11, 1.74, 2.73, 4.29]

;  p = errorplot(energy, FLUX_16_1_AVG, FLUX_16_1_SD, xrange=[0.5, 10], yrange = [1, 600], /xlog, /ylog)
;  p1 = errorplot(energy, FLUX_17_1_AVG, FLUX_17_1_SD, /xlog, /ylog, /overplot)
;  p2 = errorplot(energy, FLUX_18_1_AVG, FLUX_18_1_SD, /xlog, /ylog, /overplot)
;  p3 = errorplot(energy, FLUX_19_1_AVG, FLUX_19_1_SD, /xlog, /ylog, /overplot)
;  p4 = errorplot(energy, FLUX_20_1_AVG, FLUX_20_1_SD, /xlog, /ylog, /overplot)
;  p5 = errorplot(energy, FLUX_21_1_AVG, FLUX_21_1_SD, /xlog, /ylog, /overplot)
  
  p = errorplot(energy, FLUX_11_1_AVG, FLUX_11_1_SD, xrange=[0.5, 10], yrange = [1, 600], /xlog, /ylog)
  p1 = errorplot(energy, FLUX_12_1_AVG, FLUX_12_1_SD, /xlog, /ylog, /overplot)
  p2 = errorplot(energy, FLUX_13_1_AVG, FLUX_13_1_SD, /xlog, /ylog, /overplot)
  p3 = errorplot(energy, FLUX_14_1_AVG, FLUX_14_1_SD, /xlog, /ylog, /overplot)
  p4 = errorplot(energy, FLUX_15_1_AVG, FLUX_15_1_SD, /xlog, /ylog, /overplot)
  p5 = errorplot(energy, FLUX_16_1_AVG, FLUX_16_1_SD, /xlog, /ylog, /overplot)

  p.THICK=2
  p.ERRORBAR_THICK=2
  p.FONT_SIZE=15
  
  p1.THICK=2
  p1.ERRORBAR_THICK=2
  p1.COLOR ="blue"
  p1.ERRORBAR_COLOR="blue"
  p1.FONT_SIZE=15
  
  p2.THICK=2
  p2.ERRORBAR_THICK=2
  p2.COLOR ="green"
  p2.ERRORBAR_COLOR="green"
  p2.FONT_SIZE=15
  
  p3.THICK=2
  p3.ERRORBAR_THICK=2
  p3.COLOR ="orange"
  p3.ERRORBAR_COLOR="orange"
  p3.FONT_SIZE=15
  
  p4.THICK=2
  p4.ERRORBAR_THICK=2
  p4.COLOR ="red"
  p4.ERRORBAR_COLOR="red"
  p4.FONT_SIZE=15
  
  p5.THICK=2
  p5.ERRORBAR_THICK=2
  p5.COLOR ="hot pink"
  p5.ERRORBAR_COLOR="hot pink"
  p5.FONT_SIZE=15
  
  p5.save, 'zone1.png'

  

  time1 = [2017, 2018, 2019, 2020, 2021, 2022]
  time2 = [2018, 2019, 2020, 2021, 2022]
  time3 = [2019, 2020, 2021, 2022]
  time4 = [2020, 2021, 2022]
  time5 = [2021, 2022]
  time5b= [2022]
  time6 = [2016]
  time7 = [2017]
  time8 = [2018]
  time9= [2019]
  time10= [2020]
  time10b=[2021]
  time11= [2016,2017]
  time12 = [2017,2018]
  time13 = [2018,2019]
  time14 = [2019,2020]
  time15 = [2020,2021]
  time16 = [2021,2022]
  

  gamma_1 = [gamma_17_1_avg, gamma_18_1_avg, gamma_19_1_avg, gamma_20_1_avg, gamma_21_1_avg, gamma_22_1_avg]
  gamma_2 = [gamma_18_2_avg, gamma_19_2_avg, gamma_20_2_avg, gamma_21_2_avg, gamma_22_2_avg]
  gamma_3 = [gamma_19_3_avg, gamma_20_3_avg, gamma_21_3_avg, gamma_22_3_avg]
  gamma_4 = [gamma_20_4_avg, gamma_21_4_avg, gamma_22_4_avg]
  gamma_5 = [gamma_21_5_avg, gamma_22_5_avg]
  gamma_5b= [gamma_22_6_avg]
  gamma_6 =  [gamma_16_1_avg]
  gamma_7 =  [gamma_17_2_avg]
  gamma_8 = [gamma_18_3_avg]
  gamma_9 = [gamma_19_4_avg]
  gamma_10 = [gamma_20_5_avg]
  gamma_10b= [gamma_21_6_avg]
  gamma_11 = [gamma_16_1_avg, gamma_17_1_avg]
  gamma_12 = [gamma_17_2_avg, gamma_18_2_avg]
  gamma_13 = [gamma_18_3_avg, gamma_19_3_avg]
  gamma_14 = [gamma_19_4_avg, gamma_20_4_avg]
  gamma_15 = [gamma_20_5_avg, gamma_21_5_avg]
  gamma_16 = [gamma_21_6_avg, gamma_22_6_avg]

  
  gamma_er1 = [gamma_17_1_sd, gamma_18_1_sd, gamma_19_1_sd, gamma_20_1_sd, gamma_21_1_sd, gamma_22_1_sd]
  gamma_er2 = [gamma_18_2_sd, gamma_19_2_sd, gamma_20_2_sd, gamma_21_2_sd, gamma_22_2_sd]
  gamma_er3 = [gamma_19_3_sd, gamma_20_3_sd, gamma_21_3_sd, gamma_22_3_sd]
  gamma_er4 = [gamma_20_4_sd, gamma_21_4_sd, gamma_22_4_sd]
  gamma_er5 = [ gamma_21_5_sd, gamma_22_5_sd]
  gamma_er5b= [gamma_22_6_sd]
  gamma_er6 =  [gamma_16_1_sd]
  gamma_er7 =  [gamma_17_2_sd]
  gamma_er8 = [gamma_18_3_sd]
  gamma_er9 = [gamma_19_4_sd]
  gamma_er10 = [gamma_20_5_sd]
  gamma_er10b= [gamma_21_6_sd]
  gamma_er11 =  [gamma_16_1_sd, gamma_17_1_sd]
  gamma_er12 = [gamma_17_2_sd, gamma_18_2_sd]
  gamma_er13 = [gamma_18_3_sd, gamma_19_3_sd]
  gamma_er14 = [gamma_19_4_sd, gamma_20_4_sd]
  gamma_er15 = [gamma_20_5_sd, gamma_21_5_sd]
  gamma_er16 = [gamma_21_6_sd, gamma_22_6_sd]

  
  g1 = errorplot(time1, gamma_1, gamma_er1, xrange=[2015, 2023], yrange=[1.1, 2.4], XMAJOR=9, xminor=0, XTITLE="Year at 1 au", YTITLE="Spectral Index")
  g1.symbol= 'o'
  g1.SYM_SIZE= 1
  g1.SYM_FILLED=1
  g1.FONT_SIZE=15
  
  g2 = errorplot(time2, gamma_2, gamma_er2, /overplot)
  g2.symbol= 'o'
  g2.SYM_SIZE= 1
  g2.SYM_FILLED=1
  g2.FONT_SIZE=15
  g2.COLOR ="blue"
  g2.ERRORBAR_COLOR="blue"
  
  g3 = errorplot(time3, gamma_3, gamma_er3, /overplot)
  g3.symbol= 'o'
  g3.SYM_SIZE= 1
  g3.SYM_FILLED=1
  g3.FONT_SIZE=15
  g3.COLOR ="green"
  g3.ERRORBAR_COLOR="green"
  
  g4 = errorplot(time4, gamma_4, gamma_er4, /overplot)
  g4.symbol= 'o'
  g4.SYM_SIZE= 1
  g4.SYM_FILLED=1
  g4.FONT_SIZE=15
  g4.COLOR ="orange"
  g4.ERRORBAR_COLOR="orange"
  
  g5 = errorplot(time5, gamma_5, gamma_er5, /overplot)
  g5.symbol= 'o'
  g5.SYM_SIZE= 1
  g5.SYM_FILLED=1
  g5.FONT_SIZE=15
  g5.COLOR ="red"
  g5.ERRORBAR_COLOR="red"
  
  ;g5b = errorplot(time5b, gamma_5b, gamma_er5b, /overplot)
  ;g5b.symbol= 'o'
  ;g5b.SYM_SIZE= 1
  ;g5b.SYM_FILLED=1
  ;g5b.FONT_SIZE=15
  ;g5b.COLOR ="hot pink"
  ;g5b.ERRORBAR_COLOR="hot pink"
  
  g6 = errorplot(time6, gamma_6, gamma_er6, /overplot)
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
  
  g9 = errorplot(time9, gamma_9, gamma_er9, /overplot)
  g9.symbol= 'X'
  g9.SYM_SIZE= 1
  g9.SYM_FILLED=1
  g9.FONT_SIZE=15
  g9.COLOR ="orange"
  g9.ERRORBAR_COLOR="orange"
  
  g10 = errorplot(time10, gamma_10, gamma_er10, /overplot)
  g10.symbol= 'X'
  g10.SYM_SIZE= 1
  g10.SYM_FILLED=1
  g10.FONT_SIZE=15
  g10.COLOR ="red"
  g10.ERRORBAR_COLOR="red"
  
  ;g10b = errorplot(time10b, gamma_10b, gamma_er10b, /overplot)
  ;g10b.symbol= 'X'
  ;g10b.SYM_SIZE= 1
  ;g10b.SYM_FILLED=1
  ;g10b.FONT_SIZE=15
  ;g10b.COLOR ="hot pink"
  ;g10b.ERRORBAR_COLOR="hot pink"
  
  g11 = errorplot(time11, gamma_11, gamma_er11, /overplot)
  ;g10.symbol= '.'
  ;g10.SYM_SIZE= 1
  ;g10.SYM_FILLED=1
  g11.FONT_SIZE=15
  g11.COLOR ="black"
  g11.ERRORBAR_COLOR="black"
  g11.LINESTYLE='--'
  
  g12 = errorplot(time12, gamma_12, gamma_er12, /overplot)
  g12.FONT_SIZE=15
  g12.COLOR ="blue"
  g12.ERRORBAR_COLOR="blue"
  g12.LINESTYLE='--'
  
  g13 = errorplot(time13, gamma_13, gamma_er13, /overplot)
  g13.FONT_SIZE=15
  g13.COLOR ="green"
  g13.ERRORBAR_COLOR="green"
  g13.LINESTYLE='--'
  
  g14 = errorplot(time14, gamma_14, gamma_er14, /overplot)
  g14.FONT_SIZE=15
  g14.COLOR ="orange"
  g14.ERRORBAR_COLOR="orange"
  g14.LINESTYLE='--'
  
  g15 = errorplot(time15, gamma_15, gamma_er15, /overplot)
  g15.FONT_SIZE=15
  g15.COLOR ="red"
  g15.ERRORBAR_COLOR="red"
  g15.LINESTYLE='--'
  
  ;g16 = errorplot(time16, gamma_16, gamma_er16, /overplot)
  ;g16.FONT_SIZE=15
  ;g16.COLOR ="hot pink"
  ;g16.ERRORBAR_COLOR="hot pink"
  ;g16.LINESTYLE='--'
  
  g15.save, 'speci_au.png'
  
  stop
  
;not using this anymore
  SET_PLOT, 'PS'
  DEVICE, Bits_per_Pixel=8, Color=1, FILENAME='gvst_sub_zone_ram.ps'
  plot, time1, gamma_1, color = fsc_color('black'), thick = 4, psym = 2, yrange = [1.5, 2.5], xrange = [15, 23], xtitle ='Year', ytitle='Spectral Index', xminor = 2, xthick = 4, ythick = 4, charthick = 4, charsize = 1.5
  oplot, time1, gamma_1 ,color = fsc_color('black'), thick = 2
  oplot, time2, gamma_2 ,color = fsc_color('blue'), psym = 2, thick = 4
  oplot, time2, gamma_2 ,color = fsc_color('blue'), thick = 2
  oplot, time3, gamma_3 , color = fsc_color('green'), psym = 2, thick = 4
  oplot, time3, gamma_3 , color = fsc_color('green'), thick = 2
  oplot, time4, gamma_4 , color = fsc_color('orange'), psym = 2, thick = 4
  oplot, time4, gamma_4 , color = fsc_color('orange'), thick = 2
  oplot, time5, gamma_5 , color = fsc_color('red'), psym = 2, thick = 4
  oplot, time5, gamma_5 , color = fsc_color('red'), thick = 2
  oplot, time7, gamma_7, color = fsc_color('black'), psym = 1, thick = 4
  oplot, time8, gamma_8, color = fsc_color('blue'), psym = 1, thick = 4
  oplot, time9, gamma_9, color = fsc_color('green'), psym = 1, thick = 4
  oplot, time10, gamma_10, color = fsc_color('orange'), psym = 1, thick = 4
  oplot, time11, gamma_11, color = fsc_color('red'), psym = 1, thick = 4
  oplot, time12, gamma_12, color = fsc_color('hot pink'), psym = 1, thick = 4
  DEVICE, /CLOSE

end