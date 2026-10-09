function ibex_hi_get_ena_source_dist, resolution, plot=plot, mollweide=mollweide, cylindrical=cylindrical, macro=macro

  if keyword_set(macro) ne 0 then begin

    dist_map_full_reisenfeld, /ts, /zirn, dist_data=ts_distance
    dist_map_full_reisenfeld, /hs, /zirn, dist_data=hs_thickness

  endif else begin

    csv_file = '/Users/nwalia/data/all.csv'

    csv_struct = read_csv(csv_file) ;1-deg resolution

    ts_distance  = dblarr(360,180)
    hs_thickness = dblarr(360,180)
    
    lat_skipper = 0LL
    
    for lon_loop = 0LL, 359LL do begin

      ts_distance  [lon_loop,*] = (csv_struct.([5]))[lat_skipper:lat_skipper+179LL]
      hs_thickness [lon_loop,*] = (csv_struct.([6]))[lat_skipper:lat_skipper+179LL]
      
      lat_skipper += 180LL
      
    endfor

  endelse
  
  ;shift longitude by 180 degrees

  dist_dim_size = size(ts_distance, /dim)

  lon_shift_idx = shift(lindgen(dist_dim_size[0]), dist_dim_size[0]/2d)

  ts_distance  = (ts_distance  [lon_shift_idx,*])
  hs_thickness = (hs_thickness [lon_shift_idx,*])

  tmp_ena_source_dist = ts_distance+hs_thickness/2D

  lat_dim = 180LL/resolution
  lon_dim = 360LL/resolution

  lat_del = resolution
  lon_del = resolution

  ena_source_dist = congrid(tmp_ena_source_dist, lon_dim, lat_dim, /center)

  if keyword_set(plot) eq 1 then begin

    cleanplot, /silent

    color_tbl_thomas

    ps_window_val=pswindow()

    ps_window_val.yoffset=ps_window_val.yoffset*1

    ps_window_val.xoffset=ps_window_val.xoffset*1

    maincharsize=0.5
    first_row_hor_fact  = -0.025
    second_row_hor_fact = 0.022

    pos1 = [0.1,  0.49, 0.37, 0.89] + [first_row_hor_fact,  0, first_row_hor_fact,  0]
    pos2 = [0.39, 0.49, 0.66, 0.89] + [first_row_hor_fact,  0, first_row_hor_fact,  0]
    pos3 = [0.68, 0.49, 0.95, 0.89] + [first_row_hor_fact,  0, first_row_hor_fact,  0]
    pos4 = [0.2,  0.14, 0.47, 0.54] + [second_row_hor_fact, 0, second_row_hor_fact, 0]
    pos5 = [0.49, 0.14, 0.76, 0.54] + [second_row_hor_fact, 0, second_row_hor_fact, 0]

    if keyword_set(mollweide) eq 0 and keyword_set(cylindrical) eq 0 then mollweide=1

    sym_c=dindgen(17)*(!const.pi*2d/16d)

    usersym, cos(sym_c), sin(sym_c), /fill

    p0lon  = 255.7d
    p0lat  = 5.1d
    latmin = -90d
    latmax = 90d
    lonmin = 0d
    lonmax = 360d
    nose_lon = 180.+75.7
    nose_lat = 5.1

    if n_elements(mollweide) eq 0 and n_elements(cylindrical) ne 0 then begin

      p0lat = 0d

    endif

    tmp_filename = 'ibex-hi_'+strcompress(string(resolution, format='(I)'), /remove_all)+'deg'

    set_plot, 'ps'  ; set the plotting device to postscript.
    device, decomposed=0, filename=tmp_filename+'_ts_hs_dist.ps', bits_per_pixel=8, /helvetica, /color, _extra=ps_window_val

    ;=================================================================================================================================================
    !p.font=0
    !p.multi=0
    !p.background=255
    !p.color=0
    !x.margin=!x.margin/2d
    !y.margin=!y.margin/2d
    !p.charthick=1

    maincharsize=0.5
    first_row_hor_fact  = -0.025
    second_row_hor_fact = 0.022

    pos1 = [0.1,  0.49, 0.37, 0.89] + [first_row_hor_fact,  0, first_row_hor_fact,  0]
    pos2 = [0.39, 0.49, 0.66, 0.89] + [first_row_hor_fact,  0, first_row_hor_fact,  0]
    pos3 = [0.68, 0.49, 0.95, 0.89] + [first_row_hor_fact,  0, first_row_hor_fact,  0]
    pos4 = [0.2,  0.14, 0.47, 0.54] + [second_row_hor_fact, 0, second_row_hor_fact, 0]
    pos5 = [0.49, 0.14, 0.76, 0.54] + [second_row_hor_fact, 0, second_row_hor_fact, 0]

    title_str_arr = ['Termination Shock Distance', 'Heliosheath Thickness', 'Estimated ENA Source Distance']

    min_yr = 0
    max_yr = 3.5

    mag_factor=10.

    lat_arr = findgen(180d/lat_del,        start=-90d + lat_del/2d, increment=lat_del)
    lon_arr = shift(findgen(360d/lon_del,  start=lon_del/2d,        increment=lon_del), 0)

    e_loop = 1LL;esa_step

    tmp_im_pos = scope_varfetch(strcompress('pos'+string(e_loop), /remove_all))
    tmp_title  = title_str_arr [e_loop-1LL]

    for plot_loop = 0LL, n_elements(title_str_arr)-1LL do begin

      if plot_loop eq 0 then begin
        tmp_e_skymap = ts_distance
        loadct, 52, /silent
        tvlct,red,green,blue,/get
        blue[0] = 255
        red[0] = 255
        green[0] = 255
        tvlct,red,green,blue
        color_limit=[70, 140]
        ct_val=520
        cb_title = 'Distance [AU]'
      endif
      if plot_loop eq 1 then begin
        tmp_e_skymap = hs_thickness
        loadct, 74, /silent
        tvlct,red,green,blue,/get
        blue[0] = 255
        red[0] = 255
        green[0] = 255
        tvlct,red,green,blue
        color_limit=[10, 250]
        ct_val=74
        cb_title = 'Distance [AU]'
      endif
      if plot_loop eq 2 then begin
        tmp_e_skymap = ena_source_dist
        loadct, 34, /silent
        tvlct,red,green,blue,/get
        blue[0] = 255
        red[0] = 255
        green[0] = 255
        tvlct,red,green,blue
        color_limit=[80,260]
        ct_val=33
        cb_title = 'Distance [AU]'
      endif

      ;==================================================================================================

      imsize=size(reform(tmp_e_skymap))
      magnifiedimg = congrid(tmp_e_skymap, mag_factor*imsize[1],mag_factor*imsize[2])

      map_spec_esa = bytscl(magnifiedimg, min=color_limit[0], max=color_limit[1])

      if n_elements(mollweide) ne 0 and n_elements(cylindrical) eq 0 then begin

        map_set, p0lat, 360.-p0lon,0, /advance, /isotropic, /mollweide, /noborder, title='' ;

      endif else begin

        map_set, p0lat, 360.-p0lon,0, /advance, /isotropic, /cylindrical, /noborder, title='' ;

      endelse

      result = map_image(map_spec_esa, startx, starty, xsize, ysize, compress=1, latmin=latmin, lonmin=lonmin, latmax=latmax, lonmax=lonmax, scale=im_qual)

      pos = fltarr(4)
      pos[0] = startx / float(!d.x_vsize)
      pos[1] = starty / float(!d.y_vsize)
      pos[2] = (startx + xsize) / float(!d.x_vsize)
      pos[3] = (starty + ysize) / float(!d.y_vsize)
      imdisp, result, pos=pos, /usepos, /noscale
      loadct, 0, /silent

      if n_elements(draw_ribbon_boundary_only) eq 0 then begin

        map_grid, latdel=30, londel=30, color=255, /label, /horizon,$
          lats = [-90,-60,-30,0,30,60,90],latnames=[' ','-60','-30',' ','30',' ',' '],$
          lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=[' ','-30','-60','-90','-120','-150','180',' ',' ',' ',' ',' '],$
          latlab=0,glinestyle=0, glinethick=2, charthick=1.2, charsize=1.3, font=0
        map_grid, latdel=30, londel=30, /label, color=0, /horizon,$
          lats = [-90,-60,-30,0,30,60,90],latnames=[' ','-60','-30',' ','30',' ',' '],$
          lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=[' ','-30','-60','-90','-120','-150','180',' ',' ',' ',' ',' '],$
          latlab=0,glinestyle=1, glinethick=0.2, charthick=1, charsize=1.3, font=0

      endif

      plots, [105], [5], psym=8, symsize=1.5, color=0
      xyouts, 108, 12, 'Upwind', /data, color=0,charsize=1.5, alignment=0.5

      plots, [105], [34], psym=8, symsize=1.5, color=0
      xyouts, 108, 41, 'V1', /data, color=0, charsize=1.5, alignment=0.5

      plots, [71], [-32], psym=8, symsize=1.5, color=0
      xyouts, 74, -25, 'V2', /data, color=0, charsize=1.5, alignment=0.5

      if n_elements(cylindrical) ne 0 then begin

        color_bar, [color_limit[0], color_limit[1]], cb_title, [0.25,0.1,0.75,0.12], fontsize=0.8, ct=ct_val, /horizontal, /min_black_sat
        loadct, 0, /silent
        xyouts, mean([pos[0], pos[2]]), tmp_im_pos[3]-0.05, title_str_arr[plot_loop], font=0, charsize=1.7, alignment=0.5, /normal

      endif

      if n_elements(mollweide) ne 0 then begin

        color_bar, [color_limit[0], color_limit[1]], cb_title, [0.25,0.1,0.75,0.12], fontsize=0.8, ct=ct_val, /horizontal, /min_black_sat
        loadct, 0, /silent
        xyouts, mean([pos[0], pos[2]]), tmp_im_pos[3]-0.05, title_str_arr[plot_loop], font=0, charsize=1.7, alignment=0.5, /normal

      endif

      erase

    endfor

    color_tbl_thomas
    cleanplot, /silent

    device, /close

    set_plot, 'x'

    cgps2pdf, tmp_filename+'_ts_hs_dist.ps'

    cleanplot, /silent

    au_to_meter    = 149597870691D

    keV_to_joule   = 1.6021766339999D-16

    proton_mass_kg = 1.67262192D * 1D-27

    evals = [0.38d, 0.71d, 1.11d, 1.74d, 2.73d, 4.29d]

    travel_time = dblarr(n_elements(ena_source_dist[*,0]), n_elements(ena_source_dist[0,*]),6)

    travel_time[*,*,0] = safe_div(ena_source_dist*au_to_meter, sqrt(2d*evals[0]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,1] = safe_div(ena_source_dist*au_to_meter, sqrt(2d*evals[1]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,2] = safe_div(ena_source_dist*au_to_meter, sqrt(2d*evals[2]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,3] = safe_div(ena_source_dist*au_to_meter, sqrt(2d*evals[3]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,4] = safe_div(ena_source_dist*au_to_meter, sqrt(2d*evals[4]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,5] = safe_div(ena_source_dist*au_to_meter, sqrt(2d*evals[5]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)

    pos_arr = dblarr(6,4)
    pos_arr [0,*] =[0.0045586405321955681, 0.63498312234878540, 0.32905098795890808, 0.85545557737350464]
    pos_arr [1,*] =[0.33775383234024048, 0.63498312234878540, 0.66224616765975952, 0.85545557737350464]
    pos_arr [2,*] =[0.67094904184341431, 0.63498312234878540, 0.99544137716293335, 0.85545557737350464]
    pos_arr [3,*] =[0.0045586405321955681, 0.13498312234878540, 0.32905098795890808, 0.35545557737350464]
    pos_arr [4,*] =[0.33775383234024048, 0.13498312234878540, 0.66224616765975952, 0.35545557737350464]
    pos_arr [5,*] =[0.67094904184341431, 0.13498312234878540, 0.99544137716293335, 0.35545557737350464]

    set_plot, 'ps'  ; set the plotting device to postscript.
    device, decomposed=0, filename=tmp_filename+'_ENA_travel_time.ps', bits_per_pixel=8, /helvetica, /color, _extra=ps_window_val, /landscape

    ;=================================================================================================================================================
    !p.font=0
    !p.multi=0
    !p.background=255
    !p.color=0
    !x.margin=!x.margin/2d
    !y.margin=!y.margin/6d
    !p.charthick=1

    ;  a=image(flux_map[*,*,1], map_projection='mollweide')
    ibex_official_ctable

    nose_lon = 180.+75.7
    nose_lat = +5.1
    p0lon = nose_lon
    p0lat = nose_lat

    mag_factor=10d * 2/6D

    latmin = -90d
    latmax = 90d
    lonmin = 0d
    lonmax = 360d

    !p.multi=[0,3,2,0,0]

    spec_map   = travel_time
    unit_title = 'ENA Arrival Time [Year]'
    tmp_ct     = 11

    color_bar_min = 0
    color_bar_max = 3.5

    for e_loop = 1, 5 do begin

      tmp_pos=reform(pos_arr[e_loop-1LL,*])

      shift_xpos = 0.175
      shift_ypos = 0.2

      if e_loop ge 4 then begin

        x_width = abs(tmp_pos[2]-tmp_pos[0])
        y_width = abs(tmp_pos[3]-tmp_pos[1])
        tmp_pos[0]+=shift_xpos
        tmp_pos[2] = tmp_pos[0]+x_width

        tmp_pos[1]+=shift_ypos
        tmp_pos[3] = tmp_pos[1]+y_width

      endif

      imsize=size(reform(spec_map[*,*,e_loop]))
      magnifiedimg = congrid(reform(spec_map[*,*,e_loop]), mag_factor*imsize[1],mag_factor*imsize[2])

      map_spec_esa = bytscl(magnifiedimg, min=color_bar_min, max=color_bar_max)

      if keyword_set(cylindrical) eq 1 and keyword_set(mollweide) eq 0 then begin

        map_set, 0,360.-p0lon,0, /advance, /isotropic, /noborder, /cylindrical, position=tmp_pos

      endif

      if keyword_set(mollweide) eq 1 and keyword_set(cylindrical) eq 0 then begin

        map_set, p0lat,360.-p0lon,0, /advance, /isotropic, /noborder, /mollweide, position=tmp_pos

      endif

      result = map_image(map_spec_esa, startx, starty, xsize, ysize, compress=1, latmin=latmin, lonmin=lonmin, latmax=latmax, lonmax=lonmax, scale=0.1)


      ;tv, result, startx, starty
      pos = fltarr(4)
      pos[0] = startx / float(!d.x_vsize)
      pos[1] = starty / float(!d.y_vsize)
      pos[2] = (startx + xsize) / float(!d.x_vsize)
      pos[3] = (starty + ysize) / float(!d.y_vsize)


      loadct, 11, /silent
      tvlct,red,green,blue,/get
      blue[0] = 255
      red[0] = 255
      green[0] = 255
      tvlct,red,green,blue

      imdisp, result, pos=pos, /usepos, /noscale

      loadct, 0, /silent

      map_grid, latdel=30, londel=30, color=230, /label, /horizon,$
        lats = [-90,-60,-30,0,30,60,90],latnames=[' ','-60','-30','0','30','60',' '],$
        lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0',' ','-60',' ','-120',' ','180',' ','120',' ','60',' '],$
        latlab=0, glinestyle=1, glinethick=0.5, charthick=0.5, charsize=0.5, font=0, position=pos

      loadct, 0, /silent
      plots, [105], [5], psym=8, symsize=0.7, color=0
      xyouts, 108, 12, 'Upwind', /data, color=0,charsize=1, alignment=0.5, font=0

      plots, [105], [34], psym=8, symsize=0.7, color=0
      xyouts, 108, 41, 'V1', /data, color=0, charsize=1, alignment=0.5, font=0

      plots, [71], [-32], psym=8, symsize=0.7, color=0
      xyouts, 74, -25, 'V2', /data, color=0, charsize=1, alignment=0.5, font=0

      ;      map_grid, latdel=30, londel=30, /label, color=0,/horizon,$
      ;        lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
      ;        lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
      ;        latlab=0,glinestyle=0, glinethick=0, charthick=1, charsize=0.5, font=0

      if e_loop eq 0 then tmp_title_string = 'ESA 1 (~0.38 keV)'
      if e_loop eq 1 then tmp_title_string = 'ESA 2 (~0.71 keV)'
      if e_loop eq 2 then tmp_title_string = 'ESA 3 (~1.11 keV)'
      if e_loop eq 3 then tmp_title_string = 'ESA 4 (~1.74 keV)'
      if e_loop eq 4 then tmp_title_string = 'ESA 5 (~2.73 keV)'
      if e_loop eq 5 then tmp_title_string = 'ESA 6 (~4.29 keV)'

      xyouts, mean([pos[0], pos[2]]), pos[3]+0.02, tmp_title_string, font=0, charsize=1.2, /normal, alignment=0.5

      vert_shift = 0.05

      hor_shift  = 0.05

    endfor

    color_bar, [color_bar_min, color_bar_max], unit_title, [0.2, 0.23, 0.8, 0.245], $
      /hor, ct=tmp_ct, fontsize=1.5, /min_black_sat

    xyouts, 0.5, 0.99, 'IBEX-Hi ENA Travel Time from Estimated Source Region', font=0, charsize=1.2, /normal, alignment=0.5

    color_tbl_thomas
    device, /close
    color_tbl_thomas
    set_plot, 'win'

    cgps2pdf, tmp_filename+'_ENA_travel_time.ps'

    cleanplot, /silent

  endif

  return, transpose(ena_source_dist)

end