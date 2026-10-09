pro diff_maps

all_spec_in= []

  for a = 12, 20 do begin
    y = STRTRIM(a, 2)
    restore,'/Users/nwalia/IDLWorkspace/all_pres_7May_ag.sav'
    ;restore, '/Users/nwalia/Theseus 6-month Maps (10-27-2022)/SAV/20'+y+'A_Combined_Theseus_stitched_patched_2x2.sav'
    ;restore, '/Users/nwalia/Theseus 6-month Maps (10-27-2022)/SAV/20'+y+'B_Combined_Theseus_stitched_patched_2x2.sav'


    ;xp = spec_plot(ESA5_TOT_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(xp, range= [0,20])

    indices = make_array(180, 90)
    ;indices = make_array(6, 2)

    for i = 0, 179 do begin
      for j = 0, 89 do begin

        Flux = [ESA2_GDF_MAP[i, j], ESA3_GDF_MAP[i, j], ESA4_GDF_MAP[i, j], ESA5_GDF_MAP[i, j], ESA6_GDF_MAP[i, j]]
        Energy = [0.71, 1.11, 1.74, 2.73, 4.29]
        f = LINFIT(alog(Energy), alog(flux))
        ;print, f

        indices(i,j)=f[1]




      endfor
    endfor
    
    
    all_spec_in = [all_spec_in, indices]

    ;print, indices

    ;xp = spec_plot(abs(indices), LON_ARR, LAT_ARR)
    ;c= color_bar(xp, range= [-3,-1])
    ;c= color_bar(xp, range= [1,3])
    ;xp.Save, "spec_index"+y+"A.png"
    ;xp.Save, "spec_index"+y+"B.png"


   ; fp2 = spec_plot(ESA2_GDF_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(fp2, range= [1,300])
    ;fp2.Save, "ESA2_"+y+"A.png"
    ;fp2.Save, "ESA2_"+y+"B.png"

    ;fp3 = spec_plot(ESA3_GDF_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(fp3, range= [1,100])
    ;fp3.Save, "ESA3_"+y+"A.png"
    ;fp3.Save, "ESA3_"+y+"B.png"

    ;fp4 = spec_plot(ESA4_GDF_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(fp4, range= [1,50])
    ;fp4.Save, "ESA4_"+y+"A.png"
    ;fp4.Save, "ESA4_"+y+"B.png"

    ;fp5 = spec_plot(ESA5_GDF_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(fp5, range= [1,20])
    ;fp5.Save, "ESA5_"+y+"A.png"
    ;fp5.Save, "ESA5_"+y+"B.png"

    ;fp6 = spec_plot(ESA6_GDF_MAP, LON_ARR, LAT_ARR)
    ;c= color_bar(fp6, range= [1,7])
    ;fp6.Save, "ESA6_"+y+"A.png"
    ;fp6.Save, "ESA6_"+y+"B.png"



  endfor

;help, all_spec_in
l=180
m=89
diff_map15_16= all_spec_in[0:l-1, 0:m] - all_spec_in[l:l*2-1, 0:m]
diff_map16_17= all_spec_in[l:l*2-1, 0:m] - all_spec_in[l*2:l*3-1, 0:m]
diff_map17_18= all_spec_in[l*2:l*3-1, 0:m] - all_spec_in[l*3:l*4-1, 0:m]
diff_map18_19= all_spec_in[l*3:l*4-1, 0:m] - all_spec_in[l*4:l*5-1, 0:m]
diff_map19_20= all_spec_in[l*4:l*5-1, 0:m] - all_spec_in[l*5:l*6-1, 0:m]
diff_map15_20= all_spec_in[0:l-1, 0:m] - all_spec_in[l*5:l*6-1, 0:m]

;print, diff_map15_16
;help, diff_map15_16


xp15_16 = spec_plot(diff_map15_16, LON_ARR, LAT_ARR, RGB_TABLE=70)
c= color_bar(xp15_16, range= [-1.5,1.5], RGB_TABLE=70)
xp15_16.Save, "diff15_16A.png"

xp16_17 = spec_plot(diff_map16_17, LON_ARR, LAT_ARR, RGB_TABLE=70)
c= color_bar(xp16_17, range= [-1.5,1.5], RGB_TABLE=70)
xp16_17.Save, "diff16_17A.png"

xp17_18 = spec_plot(diff_map17_18, LON_ARR, LAT_ARR, RGB_TABLE=70)
c= color_bar(xp17_18, range= [-1.5,1.5], RGB_TABLE=70)
xp17_18.Save, "diff17_18A.png"

xp18_19 = spec_plot(diff_map18_19, LON_ARR, LAT_ARR, RGB_TABLE=70)
c= color_bar(xp18_19, range= [-1.5,1.5], RGB_TABLE=70)
xp18_19.Save, "diff18_19A.png"

xp19_20 = spec_plot(diff_map19_20, LON_ARR, LAT_ARR, RGB_TABLE=70)
c= color_bar(xp19_20, range= [-1.5,1.5], RGB_TABLE=70)
xp19_20.Save, "diff19_20A.png"

xp15_20 = spec_plot(diff_map15_20, LON_ARR, LAT_ARR, RGB_TABLE=70)
c= color_bar(xp15_20, range= [-1.5,1.5], RGB_TABLE=70)
xp15_20.Save, "diff15_20A.png"






end
