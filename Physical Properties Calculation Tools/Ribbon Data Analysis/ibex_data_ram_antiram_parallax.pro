PRO IBEX_DATA_RAM_ANTIRAM_parallax, MAPNAME, SEPNAME, VER, cpath

  ver = '230809a'

  cpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Code\RibbonPeak_Moment\Ram_ARam_Only\NewSet_230322\MCFIT\Multivariate\'
  cd, cpath

  SEPNAME = 'L'
  MAPNAME = 'Theseus'

  path_str = strsplit(cpath, '\', /extract)
  dp = strjoin(path_str[0:5], '\')+'\Data\'

  DPATH = DP+MAPNAME+'-'+SEPNAME+'\'
  DPATH_NEW = DPATH+MAPNAME+'RibbonSep_RC_Peak_Moment_'+VER+'\'

  YEAR_MIN = 2009
  if mapname eq 'ISOC' then IF SEPNAME eq 'D' then YEAR_MAX = 2019 else YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020
  if mapname eq 'Theseus' then YEAR_MAX = 2022 ; ISOC = 2019, THESEUS = 2020

  fpath = 'C:\Users\368809\sjnoh\Ribbon_Statistics_with_iter_CGcor\Ribbon_Statistics_with_iter_CGcor\Figure\Theseus-L_RC_Iteration\230809a\Parallax\'

  ;  win = window(dim = [3600, 2800], /buffer)
  ;  win.refresh, /disable
  ;  pos1 = make_plot_pos(0.05, 0.75, 0.95, 0.95, 3, /row, gap = 0.09)
  ;  pos2 = make_plot_pos(0.05, 0.525, 0.95, 0.725, 3, /row, gap = 0.09)
  ;  pos11 = [[pos1], [pos2]]
  ;
  ;  pos1 = make_plot_pos(0.05, 0.255, 0.95, 0.455, 3, /row, gap = 0.09)
  ;  pos2 = make_plot_pos(0.05, 0.030, 0.95, 0.230, 3, /row, gap = 0.09)
  ;  pos22 = [[pos1], [pos2]]

  lonlim = [200, 40]
  latlim = [0, 50d]

  p1_res = replicate(!values.d_nan, YEAR_MAX-YEAR_MIN+1, 25, 5)
  p2_res = replicate(!values.d_nan, YEAR_MAX-YEAR_MIN+1, 25, 5)
  p3_res = replicate(!values.d_nan, YEAR_MAX-YEAR_MIN+1, 25, 5)
  p4_res = replicate(!values.d_nan, YEAR_MAX-YEAR_MIN+1, 25, 5)

  for yidx = YEAR_MIN, YEAR_MAX do begin
    year = string(yidx, format = '(I4)')

    cb_range = fltarr(2, 2, 5)
    ec_str = 'EC'
    GDF_STR = 'RBN'

    ESA_MAP_ram = !null
    ESA_MAP_aram = !null

    MOM1_ram = !null
    MOM1_aram = !null

    PEAK_ram = !null
    PEAK_aram = !null

    FOR ESA = 2, 6 DO BEGIN

      for RAM = 0, 1 do begin
        if RAM eq 0 then str = 'Ram' else str = 'ARam'


        restore, DPATH_NEW+mapname+'-'+sepname+'_RBN_SEP_'+year+'_'+str+'.sav'
        ESA_STR = strcompress(esa, /rem)
        !NULL = EXECUTE('esa_map = ESA'+ESA_STR+'_'+GDF_STR+'_MAP')

        !NULL = EXECUTE('ESA_NUM_MOM = ESA'+ESA_STR+'_NUM_MOM')
        !NULL = EXECUTE('ESA_MOM2_4 = ESA'+ESA_STR+'_MOM2_4')


        P0 = RC_C_LONLAT[ESA-2, 1]
        T0 = RC_C_LONLAT[ESA-2, 2]

        ; 111111111111111 esa map from rc to ec
        res = meshgrid(LON_ARR, lat_rc)
        lat_mat = res.remove()
        lon_mat = res.remove()
        conv = conv_coord_ec_rc(lON_mat, lat_mat-90, P0, T0)
        P1 = conv.LON
        T1 = conv.LAT
        ;      T1 = T1-90
        LON_IDX = interpol(dindgen(LON_ARR.length), LON_ARR, P1)
        LAT_IDX = interpol(dindgen(lat_rc.length), lat_rc, T1)


        if ram eq 0 then begin
          ESA_MAP_ram = INTERPOLATE(esa_map, LON_IDX, LAT_IDX, /DOUBLE)
          mom1_ram = conv_coord_ec_rc(lon_arr, reform(ESA_NUM_MOM[0, *]), P0, T0, /rev)
          peak_ram = conv_coord_ec_rc(lon_arr, reform(ESA_MOM2_4[0, *]), P0, T0, /rev)
        endif
        if ram eq 1 then begin
          ESA_MAP_aram = INTERPOLATE(esa_map, LON_IDX, LAT_IDX, /DOUBLE)
          mom1_aram = conv_coord_ec_rc(lon_arr, reform(ESA_NUM_MOM[0, *]), P0, T0, /rev)
          peak_aram = conv_coord_ec_rc(lon_arr, reform(ESA_MOM2_4[0, *]), P0, T0, /rev)
        endif

        ; 111111111111111 esa map from rc to ec

      ENDFOR ; RAM

      ;                    ESA_MAP_ram[where(ESA_MAP_ram/max(ESA_MAP_ram) lt 0.1)] = 0
      ;                    ESA_MAP_aram[where(ESA_MAP_aram/max(ESA_MAP_aram) lt 0.1)] = 0

      ;                SP = spec_plot(ESA_MAP_ram, LON_ARR, LAT_ARR, XR = [0, 360], YR = [-90, 90], TITLE = 'RAM', xtitle = 'Lon_EC', ytitle = 'Lat_EC', data_min = 0, data_max = 230)
      ;                P = SCATTERPLOT(MOM1_RAM.LON, MOM1_RAM.LAT, OVER = SP, SYMBOL = '*', SYM_COLOR = 'WHITE')
      ;                P = SCATTERPLOT(PEAK_RAM.LON, PEAK_RAM.LAT, OVER = SP, SYMBOL = '*', SYM_COLOR = 'GRAY')
      ;          sp.save, fpath+'2009Ram.png', res = 150
      ;          SP = spec_plot(ESA_MAP_aram, LON_ARR, LAT_ARR, XR = [0, 360], YR = [-90, 90], TITLE = 'ARAM', xtitle = 'Lon_EC', ytitle = 'Lat_EC', data_min = 0, data_max = 230)
      ;          P = SCATTERPLOT(MOM1_ARAM.LON, MOM1_ARAM.LAT, OVER = SP, SYMBOL = '*', SYM_COLOR = 'WHITE')
      ;          P = SCATTERPLOT(PEAK_ARAM.LON, PEAK_ARAM.LAT, OVER = SP, SYMBOL = '*', SYM_COLOR = 'GRAY')
      ;          sp.save, fpath+'2009ARam.png', res = 150

      lonarr_idx = where(lon_arr ge lonlim[0] or lon_arr le lonlim[1])
      latarr_idx = where(lat_arr ge latlim[0] and lat_arr le latlim[1])

      ;          lonlim = [125:179]
      ;          lonlim = [90:179]
      ;          latlim = [45:70]

      data_lim = 10

      ESA_MAP_ram = ESA_MAP_ram[lonarr_idx, *]
      ESA_MAP_aram = ESA_MAP_aram[lonarr_idx, *]
      lon_tmp = double(lon_arr[lonarr_idx])
      lon_tmp[where(lon_tmp lt 90)] = lon_tmp[where(lon_tmp lt 90)]+360
      iidx = sort(lon_tmp)
      lon_tmp = lon_tmp[iidx]
      ESA_MAP_ram = ESA_MAP_ram[iidx, *]
      ESA_MAP_aram = ESA_MAP_aram[iidx, *]

      lon_new = lon_tmp[data_lim:lon_tmp.length-1-data_lim]

      ESA_MAP_ram = ESA_MAP_ram[*, latarr_idx]
      ESA_MAP_aram = ESA_MAP_aram[*, latarr_idx]
      lat_tmp = double(lat_arr[latarr_idx])

      lag = linspace(-10, 10, 1000)

      angle_diff1 = replicate(!values.d_nan, lat_tmp.length) ; convolution
      angle_diff2 = replicate(!values.d_nan, lat_tmp.length) ; regression
      for latidx = 0, lat_tmp.length-1 do begin
        ESA1 = ESA_MAP_ram[*, latidx]
        ESA2 = ESA_MAP_aram[*, latidx]

        ;            lon_int = linspace(lon_tmp[0], lon_tmp[-1], 1000)
        ;            esa2_tmp = interpol(esa2, lon_tmp, lon_int, QUADRATIC = 1)

        ;            p = plot(lon_tmp, esa1, /over, yr = [0, 130], co = 'red', xtitle = 'Lon_EC', ytitle = 'Flux', font_size = 15, title = 'ESA'+esa_str+', Lat_EC = '+string(lat_tmp[latidx]))

        res_conv = replicate(!values.d_nan, lag.length)
        res_regress = replicate(!values.d_nan, lag.length)
        res_regress1 = replicate(!values.d_nan, lag.length)
        for lagidx = 0, lag.length-1 do begin
          esa2_int = interpol(esa2, lon_tmp, lon_new-lag[lagidx], QUADRATIC = 1)

          ;              esa2_int_tmp = interpol(esa2_tmp, lon_int, lon_tmp+lag[lagidx], QUADRATIC = 1)
          lon_e2 = lon_tmp+lag[lagidx]

          ; lon new
          esa1_trunc = esa1[data_lim:lon_tmp.length-1-data_lim]
          ; lon new
          lon_e1 = lon_tmp

          conv_tmp = (esa2_int*esa1_trunc)
          res_conv[lagidx] = total(esa2_int*esa1_trunc);/total(conv_tmp ne 0)
          res_regress[lagidx] = (r_correlate(esa2_int, esa1_trunc))[0]
          ;              res_regress1[lagidx] = (r_correlate(esa2_int_tmp, esa1_trunc))[0]
          ;              p = plot(lon_tmp, esa1_trunc, over = 1)
          ;              p = plot(lon_tmp, esa2_int, over = 1, co = 'blue')

          ;              p = plot(lon_tmp, esa2_int, over = p, co = 'blue')

          ;              if lagidx ne 0 then  p.erase
          ;              p = plot(lon_new, esa2_int, over = p, co = 'sky blue')
          ;          if lag[lagidx] gt 2.7 then stop
        endfor

        ;            p = plot(lon_tmp, esa2, over = p, co = 'blue')
        ;            p = plot(lon_tmp, esa1, /over, yr = [0, 130], co = 'red', xtitle = 'Lon_EC', ytitle = 'Flux', font_size = 15, title = 'ESA'+esa_str+', Lat_EC = '+string(lat_tmp[latidx]))


        ;            p = plot(lag, res_regress, thick = 2, ytitle = 'ROCC', xtitle = 'Longitude Shift', font_size = 15)
        ;            p = plot(lag, res_conv, thick = 2, ytitle = 'Ram*ARam', xtitle = 'Longitude Shift', font_size = 15)

        tmp1 = max(res_conv, idx1)
        angle_diff1[latidx] = lag[idx1] ; (-) to compensate the interpolation effect
        tmp2 = max(res_regress, idx2)
        angle_diff2[latidx] = lag[idx2] ; (-) to compensate the interpolation effect
        ;            print, lat_tmp[latidx], lag[idx1], lag[idx2]

        if lat_tmp[latidx] eq 41 then stop
        ;            res1 = c_correlate(esa1, esa2, lag)
        ;            tmp1 = max(res1, idx1)
        ;            angle_diff2[latidx] = lon_diff[idx1]
      endfor

      ;          p1 = angle_diff1/2d * cos(lat_tmp*!dpi/180d)
      ;          p2 = angle_diff2/2d * cos(lat_tmp*!dpi/180d)


      ; RAM
      iidx = where((MOM1_RAM.Lon ge lonlim[0]+2*data_lim or MOM1_RAM.Lon le lonlim[1]-2*data_lim) and (MOM1_RAM.lat ge latlim[0]-2*data_lim and MOM1_RAM.lat le latlim[1]+2*data_lim))
      Lon_Ram_Mom = MOM1_RAM.Lon[iidx]
      Lat_Ram_Mom = MOM1_RAM.Lat[iidx]
      idx = where(Lon_Ram_Mom lt 90, /null, tmp)
      if tmp ne 0 then Lon_Ram_Mom[idx] = Lon_Ram_Mom[idx]+360
      iiidx = sort(Lon_Ram_Mom)
      momlon_RAM = Lon_Ram_Mom[iiidx]
      momlat_RAM = Lat_Ram_Mom[iiidx]
      iiidx = sort(momlat_RAM)
      momlon_RAM = momlon_RAM[iiidx]
      momlat_RAM = momlat_RAM[iiidx]

      momlon_RAM_int = INTERPOL(momlon_RAM, momlat_RAM, lat_tmp)

      iidx = where((peak_RAM.Lon ge lonlim[0]+2*data_lim or peak_RAM.Lon le lonlim[1]-2*data_lim) and (peak_RAM.lat ge latlim[0]-2*data_lim and peak_RAM.lat le latlim[1]+2*data_lim))
      Lon_Ram_Peak = peak_RAM.Lon[iidx]
      Lat_Ram_Peak = peak_RAM.Lat[iidx]
      idx = where(Lon_Ram_Peak lt 90, /null, tmp)
      if tmp ne 0 then Lon_Ram_Peak[idx] = Lon_Ram_Peak[idx]+360
      iiidx = sort(Lon_Ram_Peak)
      Peaklon_RAM = Lon_Ram_Peak[iiidx]
      Peaklat_RAM = Lat_Ram_Peak[iiidx]
      iiidx = sort(Peaklat_RAM)
      Peaklon_RAM = Peaklon_RAM[iiidx]
      Peaklat_RAM = Peaklat_RAM[iiidx]

      Peaklon_RAM_int = INTERPOL(Peaklon_RAM, Peaklat_RAM, lat_tmp)
      ; RAM


      ; aram
      iidx = where((MOM1_aram.Lon ge lonlim[0]+2*data_lim or MOM1_aram.Lon le lonlim[1]-2*data_lim) and (MOM1_aram.lat ge latlim[0]-2*data_lim and MOM1_aram.lat le latlim[1]+2*data_lim))
      Lon_aram_Mom = MOM1_aram.Lon[iidx]
      Lat_aram_Mom = MOM1_aram.Lat[iidx]
      idx = where(Lon_aram_Mom lt 90, /null, tmp)
      if tmp ne 0 then Lon_aram_Mom[idx] = Lon_aram_Mom[idx]+360
      iiidx = sort(Lon_aram_Mom)
      momlon_aram = Lon_aram_Mom[iiidx]
      momlat_aram = Lat_aram_Mom[iiidx]
      iiidx = sort(momlat_aram)
      momlon_aram = momlon_aram[iiidx]
      momlat_aram = momlat_aram[iiidx]

      momlon_aram_int = INTERPOL(momlon_aram, momlat_aram, lat_tmp)

      iidx = where((peak_aram.Lon ge lonlim[0]+2*data_lim or peak_aram.Lon le lonlim[1]-2*data_lim) and (peak_aram.lat ge latlim[0]-2*data_lim and peak_aram.lat le latlim[1]+2*data_lim))
      Lon_aram_Peak = peak_aram.Lon[iidx]
      Lat_aram_Peak = peak_aram.Lat[iidx]
      idx = where(Lon_aram_Peak lt 90, /null, tmp)
      if tmp ne 0 then Lon_aram_Peak[idx] = Lon_aram_Peak[idx]+360
      iiidx = sort(Lon_aram_Peak)
      Peaklon_aram = Lon_aram_Peak[iiidx]
      Peaklat_aram = Lat_aram_Peak[iiidx]
      iiidx = sort(Peaklat_aram)
      Peaklon_aram = Peaklon_aram[iiidx]
      Peaklat_aram = Peaklat_aram[iiidx]

      Peaklon_aram_int = INTERPOL(Peaklon_aram, Peaklat_aram, lat_tmp)
      ; aram

      angle_diff3 = Momlon_RAM_int - Momlon_aRAM_int
      angle_diff4 = Peaklon_RAM_int - Peaklon_aRAM_int


      pangle1 = angle_diff1/2d * cos(lat_tmp*!dpi/180d)
      pangle2 = angle_diff2/2d * cos(lat_tmp*!dpi/180d)
      pangle3 = angle_diff3/2d * cos(lat_tmp*!dpi/180d)
      pangle4 = angle_diff4/2d * cos(lat_tmp*!dpi/180d)
      stop
      pp1 = plot(pangle1, lat_tmp, symbol = '*', xr = [-5, 5], yr = latlim, name = 'Convolution '+string(mean(pangle1), format = '(f6.3)')+string(1d/sin(mean(pangle1)*!DTOR), format = '(f8.2)') + ' AU', xtitle = 'Parallax Angle', ytitle = 'Lat_EC', font_size = 15) ; convol
      pp2 = plot(pangle2, lat_tmp, symbol = '*', over = pp1, co = 'blue', name = 'Correlation '+string(mean(pangle2), format = '(f6.3)')+string(1d/sin(mean(pangle2)*!DTOR), format = '(f8.2)') + ' AU') ; regress
      pp3 = plot(pangle3, lat_tmp, symbol = '*', over = pp1, co = 'orange', name = '1st moment '+string(mean(pangle3), format = '(f6.3)')+string(1d/sin(mean(pangle3)*!DTOR), format = '(f8.2)') + ' AU') ;  moment
      pp4 = plot(pangle4, lat_tmp, symbol = '*', over = pp1, co = 'red', name = 'Peak '+string(mean(pangle4), format = '(f6.3)')+string(1d/sin(mean(pangle4)*!DTOR), format = '(f8.2)') + ' AU') ; peak
      lgd = legend(target = [pp1, pp2, pp3, pp4], pos = [0.9, 0.85], /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)
      PP1.SAVE, fpath+'YEAR'+strcompress(YIDX, /rem)+'_ESA'+strcompress(esa, /rem)+'.png', res = 150
      pp1. close
      PRINT, '============================'
      PRINT, YIDX
      PRINT, 'ESA'+STRCOMPRESS(ESA, /REM)
      print, 'convolution', mean(pangle1)
      print, 'regression', mean(pangle2)
      print, 'peak (moment)', mean(pangle3)
      print, 'peak (gauss fit)', mean(pangle4)
      PRINT, '============================'

      p1_res[YIDX-YEAR_MIN, *, ESA-2] = PANGLE1
      p2_res[YIDX-YEAR_MIN, *, ESA-2] = PANGLE2
      p3_res[YIDX-YEAR_MIN, *, ESA-2] = PANGLE3
      p4_res[YIDX-YEAR_MIN, *, ESA-2] = PANGLE4
stop
    ENDFOR ; ESA

  ENDFOR ; YEAR
  year_arr = [year_min:year_max]
  for esa = 2, 6 do begin
    ESA_STR = strcompress(esa, /rem)

    ;    pp1 = plot(year_arr, (mean(p1_res, dim = 2))[*, esa-2], co = 'black', xr = [2008, 2023], title = 'ESA'+esa_str, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = 'Convolution'+string(mean((mean(p1_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p1_res, dim = 2))[*, esa-2])*!DTOR), format = '(f7.2)') + ' AU')
    ;    pp2 = plot(year_arr, (mean(p2_res, dim = 2))[*, esa-2], co = 'blue', over = pp1, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = 'Correlation'+string(mean((mean(p2_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p2_res, dim = 2))[*, esa-2])*!DTOR), format = '(f7.2)') + ' AU')
    ;    pp3 = plot(year_arr, (mean(p3_res, dim = 2))[*, esa-2], co = 'orange', over = pp1, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = '1st moment'+string(mean((mean(p3_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p3_res, dim = 2))[*, esa-2])*!DTOR), format = '(f7.2)') + ' AU')
    ;    pp4 = plot(year_arr, (mean(p4_res, dim = 2))[*, esa-2], co = 'red', over = pp1, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = 'Peak'+string(mean((mean(p3_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p4_res, dim = 2))[*, esa-2])*!DTOR), format = '(f7.2)') + ' AU')

    pp1 = errorplot(year_arr, (mean(p1_res, dim = 2))[*, esa-2], (stddev(p1_res, dim = 2))[*, esa-2], co = 'black', symbol = '*', errorbar_color = 'black', xr = [2008, 2023], title = 'ESA'+esa_str, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = 'Convolution'+string(mean((mean(p1_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p1_res, dim = 2))[*, esa-2])*!DTOR), format = '(f8.2)') + ' AU')
    pp2 = errorplot(year_arr, (mean(p2_res, dim = 2))[*, esa-2], (stddev(p2_res, dim = 2))[*, esa-2], co = 'blue', symbol = '*', errorbar_color = 'blue', over = pp1, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = 'Correlation'+string(mean((mean(p2_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p2_res, dim = 2))[*, esa-2])*!DTOR), format = '(f8.2)') + ' AU')
    pp3 = errorplot(year_arr, (mean(p3_res, dim = 2))[*, esa-2], (stddev(p3_res, dim = 2))[*, esa-2], co = 'orange', symbol = '*', errorbar_color = 'orange', over = pp1, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = '1st moment'+string(mean((mean(p3_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p3_res, dim = 2))[*, esa-2])*!DTOR), format = '(f8.2)') + ' AU')
    pp4 = errorplot(year_arr, (mean(p4_res, dim = 2))[*, esa-2], (stddev(p4_res, dim = 2))[*, esa-2], co = 'red', symbol = '*', errorbar_color = 'red', over = pp1, xtitle = 'Year', ytitle = 'Parallax Angle', font_size = 15, name = 'Peak'+string(mean((mean(p3_res, dim = 2))[*, esa-2]), format = '(f6.3)')+string(1d/sin(mean((mean(p4_res, dim = 2))[*, esa-2])*!DTOR), format = '(f8.2)') + ' AU')

    lgd = legend(target = [pp1, pp2, pp3, pp4], pos = [0.9, 0.85], /auto_text_color, shadow = 0, linestyle = 6, sample_width = 0, transparency = 100)

    pp1.save, fpath+'TimeSeries_ESA'+strcompress(esa, /rem)+'.png', res = 150
    pp1.close
  endfor
  stop

END