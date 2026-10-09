PRO IBEX_DATA_RAM_ANTIRAM_flx_LinePlot, MAPNAME, SEPNAME, VER, cpath
  Load_IBEX_color_table
  tvlct,red,green,blue,/get
  co = [[red], [green], [blue]]
  e_step = [0.71,1.11,1.74,2.73,4.29]

  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  DPATH = DP+MAPNAME+'-'+SEPNAME+'\'
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+VER+'\'

  fname = mapname+'-'+sepname+'_RC_Iteration'
  FPATH = strjoin(path_str[0:5], '\')+'\Figure\'+fname+'\'+ver+'\'
  file_tmp = FPATH + 'RC_Summary_mom_dist_colored\Ribbon_Profile\'
  file_mkdir, file_tmp


  YEAR_MIN = 2009
  if mapname eq 'ISOC' then IF SEPNAME eq 'D' then YEAR_MAX = 2019 else YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  if mapname eq 'Theseus' then YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020

  win = window(dim = [1200, 800], /buffer)
  win.refresh, /disable

  ;  win = window(dim = [1200, 800])
  ;  win.refresh

  ;  pos1 = make_plot_pos(0.05, 0.75, 0.95, 0.95, 3, /row, gap = 0.09)
  ;  pos2 = make_plot_pos(0.05, 0.525, 0.95, 0.725, 3, /row, gap = 0.09)
  ;  pos11 = [[pos1], [pos2]]
  ;
  ;  pos1 = make_plot_pos(0.05, 0.255, 0.95, 0.455, 3, /row, gap = 0.09)
  ;  pos2 = make_plot_pos(0.05, 0.030, 0.95, 0.230, 3, /row, gap = 0.09)
  ;  pos22 = [[pos1], [pos2]]

  pos = make_plot_pos(0.05, 0.07, 0.93, 0.88, 5, /row, gap = 0.02)
  ;  co = rgb_vector(lon_arr.length, ct = 13)

  FOR ABIDX = 0, 0 DO BEGIN
    IF ABIDX THEN AB = 'AB' ELSE AB = 'BA'

    for RAM = 0, 0 do begin
      if RAM eq 0 then str = 'Ram' else str = 'ARam'

      FPATH = DPATH_NEW+'MapPlot_Mollweide\'+STR+'\'
      FILE_MKDIR, FPATH
      FOR GDF = 1, 1 DO BEGIN
        IF GDF EQ 0 THEN GDF_STR = 'GDF'
        IF GDF EQ 1 THEN GDF_STR = 'RBN'
        IF GDF EQ 2 THEN GDF_STR = 'TOT'

        esa_maps = dblarr(180, 90, 5, YEAR_MAX-YEAR_MIN+1)

        for yidx = YEAR_MIN, YEAR_MAX do begin
          year = string(yidx, format = '(I4)')

          restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav'

          cb_range = fltarr(2, 2, 5)
          ec_str = 'EC'


          tx = text(0.5, 0.97, year, alignment = 0.5, vertical_alignment = 0.5, font_size = 20)
          FOR ESA = 2, 6 DO BEGIN
            ESA_STR = strcompress(esa, /rem)
            IF GDF NE 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')
            IF GDF EQ 2 THEN !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_RBN_MAP + ESA'+ESA_STR+'_GDF_MAP')

            esa_maps[*, *, esa-2] = ESA_MAP


            ESA_MAP_tmp = ESA_MAP
            ESA_MAP_tmp = ESA_MAP_tmp/max(ESA_MAP_tmp, /nan)

            mx = max(ESA_MAP_tmp)
            dy = 0.05d

            yr = [0, 1 + dy*179]
            if esa eq 2 then $
              ext = {xr:[0, 180], yr:yr, current:win, pos:pos[*, esa-2], font_size:15, xtitle:'$\phi$ [$\deg$]', ytitle:'Flux [arb.]', ytickformat:'(a1)', xticklen:0.01, yticklen:0, title:'E '+string(e_step[ESA-2], format = '(f5.2)')+' keV'} $
            else $
              ext = {xr:[0, 180], yr:yr, current:win, pos:pos[*, esa-2], font_size:15, xtitle:'$\phi$ [$\deg$]', ytitle:'', ytickformat:'(a1)', xticklen:0.01, yticklen:0, title:string(e_step[ESA-2], format = '(f5.2)')+' keV'}

            for lonidx = 0, lon_arr.length-1, 5 do $
              p = plot(lat_rc, ESA_MAP_tmp[lonidx, *]+dy*(lonidx), co = 'black', _extra = ext)


          ENDFOR ; ESA

          ;            cb = spec_plot(transpose(rebin([0.:180], 181, 3)), xtickformat = '(a1)', rgb_table = 13, pos = [pos[2, -1]+0.01, pos[1, -1], pos[2, -1]+0.01+0.02, pos[3, -1]], current = win, xticklen = 0, yticklen = 0)
          ;            ax = cb.axes
          ;            for j = 0, 2 do ax[j].hide = 1
          ;            ax[-1].setproperty, $
          ;              showtext = 1, $
          ;              ;title = title, $
          ;              ticklen = 0.5
          ;            ax[2].TITLE = 'Lon$_{RC}$ [$\deg$]'



          pos_arr =  linspace(pos[1, -1], pos[1, -1] + (pos[3, -1] - pos[1, -1])*dy*179/(1 + dy*179), 361)
          lon_tmp = findgen(361)
          lon_tick = [0:360:60]

          for ll = 0, lon_tick.length-1 do $
            tx = text(pos[2, -1]+0.005, interpol(pos_arr, lon_tmp, lon_tick[ll]), string(lon_tick[ll], format = '(I3)'), vertical_alignment = 0.5, font_size = 15)

          tx = text(pos[2, -1]+0.05, 0.5, '$\lambda$ [$\deg$]', vertical_alignment = 0.5, orientation = 270, font_size = 15)

          win.refresh
          win.save, file_tmp+year+str+'.png', res = 150
          win.erase




        ENDFOR ; YEAR

      ENDFOR ; GDF
    ENDFOR ; RAM
  ENDFOR ; AB
  win.close
END