function ibex_hi_calc_los_pressure_parallel, flux, fluxerr, n_cores=n_cores

  ;#use this if flux and fluxerr is two dimension or more (e.g., flux array with (lat,lon,ESA) or (lat, ESA)).
  ;#uses parallel computation utilizing 100% of the CPU power (if N_CORES are not set).



  null = 0

  input_size = size(flux)

  ;Build IDL Bridges (Make sure to build this at the top level, out side of the for loop)
  if n_elements(n_cores) eq 0 then begin

    idl_bridges = build_bridges()

  endif

  if n_elements(n_cores) ne 0 then begin

    idl_bridges = build_bridges(n_cores)

  endif

  ;==========================================================================================
  ;Save output files from the parallelized spectral index calculator

  if input_size[0] eq 2 then begin

    ;Generate Pointer arrays for output files

    pressure_arr       = ptr_new(dblarr(input_size[2], 6))
    pressure_sigma_arr = ptr_new(dblarr(input_size[2], 6))

    counter = 0LL

    for angle_loop = 0LL, input_size[2]-1LL do begin

      tmp_flux    = reform(flux   [*,angle_loop])

      tmp_fluxerr = reform(fluxerr[*,angle_loop])

      err_string = 'err_string_'+strcompress(string(indgen(n_elements(idl_bridges))), /remove_all)

      pressure_calc_result = {angle_loop : angle_loop, $
        pressure        : pressure_arr, $
        pressure_sigma  : pressure_sigma_arr}

      ibex_hi_pressure_auto_bridge = get_idle_bridge(idl_bridges)
      ibex_hi_pressure_auto_bridge->setproperty, callback='ibex_hi_pressure_parallel_callback_2d_data'
      ibex_hi_pressure_auto_bridge->setproperty, userdata=pressure_calc_result

      ibex_hi_pressure_auto_bridge.setvar, 'tmp_flux',    tmp_flux
      ibex_hi_pressure_auto_bridge.setvar, 'tmp_fluxerr', tmp_fluxerr
      ibex_hi_pressure_auto_bridge.setvar, 'interval_idx0', angle_loop
      ibex_hi_pressure_auto_bridge.setvar, 'interval_idx1', 0
      ibex_hi_pressure_auto_bridge.setvar, 'interval_idx2', 0

      bridge_index = where(ibex_hi_pressure_auto_bridge eq idl_bridges, /null, /l64)

      tmp_error_string = reform(err_string[bridge_index])

      ibex_hi_pressure_auto_bridge.setvar, 'error_string', tmp_error_string

      tmp_execute_string='ibex_hi_calc_los_pressure, interval_idx0, interval_idx1, interval_idx2, tmp_flux, tmp_fluxerr, pressure, pressure_sigma'

      ibex_hi_pressure_auto_bridge.execute, /nowait, tmp_execute_string

      ;      print, strcompress(string(counter+1, format='(i)'), /remove_all)+'/'+$
      ;        strcompress(string(input_size[2], format='(i)'), /remove_all)+' samples completed for spectral index calculation [2d data]'

      counter += 1LL

    endfor

  endif

  if input_size[0] eq 3 then begin

    ;generate pointer arrays for output files

    pressure_arr       = ptr_new(dblarr(input_size[1], input_size[2], 6))
    pressure_sigma_arr = ptr_new(dblarr(input_size[1], input_size[2], 6))

    counter = 0LL

    for angle_loop = 0LL, input_size[1]-1LL do begin

      for angle_loop1 = 0LL, input_size[2]-1LL do begin

        tmp_flux    = reform(flux   [angle_loop,angle_loop1,*])

        tmp_fluxerr = reform(fluxerr[angle_loop,angle_loop1,*])

        err_string = 'err_string_'+strcompress(string(indgen(n_elements(idl_bridges))), /remove_all)

        pressure_calc_result = {angle_loop : angle_loop, angle_loop1:angle_loop1,$
          pressure        : pressure_arr, $
          pressure_sigma  : pressure_sigma_arr}

        ibex_hi_pressure_auto_bridge = get_idle_bridge(idl_bridges)
        ibex_hi_pressure_auto_bridge ->setproperty, callback='ibex_hi_pressure_parallel_callback_3d_data'
        ibex_hi_pressure_auto_bridge ->setproperty, userdata=pressure_calc_result

        ibex_hi_pressure_auto_bridge.setvar, 'tmp_flux',    tmp_flux
        ibex_hi_pressure_auto_bridge.setvar, 'tmp_fluxerr', tmp_fluxerr
        ibex_hi_pressure_auto_bridge.setvar, 'interval_idx0', angle_loop
        ibex_hi_pressure_auto_bridge.setvar, 'interval_idx1', angle_loop1
        ibex_hi_pressure_auto_bridge.setvar, 'interval_idx2', 0

        bridge_index = where(ibex_hi_pressure_auto_bridge eq idl_bridges, /null, /l64)

        tmp_error_string = reform(err_string[bridge_index])

        ibex_hi_pressure_auto_bridge.setvar, 'error_string', tmp_error_string

        tmp_execute_string='ibex_hi_calc_los_pressure, interval_idx0, interval_idx1, interval_idx2, tmp_flux, tmp_fluxerr, pressure, pressure_sigma'

        ibex_hi_pressure_auto_bridge.execute, /nowait, tmp_execute_string

        ;        print, strcompress(string(counter+1, format='(i)'), /remove_all)+'/'+$
        ;          strcompress(string(input_size[1]*input_size[2], format='(i)'), /remove_all)+' samples completed for spectral index calculation'

        counter += 1LL

      endfor

    endfor

  endif

  if input_size[0] eq 4 then begin

    ;generate pointer arrays for output files

    pressure_arr       = ptr_new(dblarr(input_size[1], input_size[2], input_size[3], 6))
    pressure_sigma_arr = ptr_new(dblarr(input_size[1], input_size[2], input_size[3], 6))

    counter = 0LL

    for angle_loop = 0LL, input_size[1]-1LL do begin

      for angle_loop1 = 0LL, input_size[2]-1LL do begin

        for angle_loop2 = 0LL, input_size[3]-1LL do begin

          tmp_flux    = reform(flux   [angle_loop,angle_loop1,angle_loop2,*])

          tmp_fluxerr = reform(fluxerr[angle_loop,angle_loop1,angle_loop2,*])

          err_string = 'err_string_'+strcompress(string(indgen(n_elements(idl_bridges))), /remove_all)

          pressure_calc_result = {angle_loop : angle_loop, angle_loop1:angle_loop1, angle_loop2:angle_loop2,$
            pressure        : pressure_arr, $
            pressure_sigma  : pressure_sigma_arr}

          ibex_hi_pressure_auto_bridge = get_idle_bridge(idl_bridges)
          ibex_hi_pressure_auto_bridge ->setproperty, callback='ibex_hi_pressure_parallel_callback_4d_data'
          ibex_hi_pressure_auto_bridge ->setproperty, userdata=pressure_calc_result

          ibex_hi_pressure_auto_bridge.setvar, 'tmp_flux',    tmp_flux
          ibex_hi_pressure_auto_bridge.setvar, 'tmp_fluxerr', tmp_fluxerr
          ibex_hi_pressure_auto_bridge.setvar, 'interval_idx0', angle_loop
          ibex_hi_pressure_auto_bridge.setvar, 'interval_idx1', angle_loop1
          ibex_hi_pressure_auto_bridge.setvar, 'interval_idx2', angle_loop2

          bridge_index = where(ibex_hi_pressure_auto_bridge eq idl_bridges, /null, /l64)

          tmp_error_string = reform(err_string[bridge_index])

          ibex_hi_pressure_auto_bridge.setvar, 'error_string', tmp_error_string

          tmp_execute_string='ibex_hi_calc_los_pressure, interval_idx0, interval_idx1, interval_idx2, tmp_flux, tmp_fluxerr, pressure, pressure_sigma'

          ibex_hi_pressure_auto_bridge.execute, /nowait, tmp_execute_string

          ;        print, strcompress(string(counter+1, format='(i)'), /remove_all)+'/'+$
          ;          strcompress(string(input_size[1]*input_size[2], format='(i)'), /remove_all)+' samples completed for spectral index calculation'

          counter += 1LL

        endfor

      endfor

    endfor

  endif

  barrier_bridges, idl_bridges

  spec_fit_str = create_struct($
    'flux',           flux, $
    'fluxerr',        fluxerr, $
    'pressure',       (*pressure_calc_result.pressure), $
    'pressure_sigma', (*pressure_calc_result.pressure_sigma))

  burn_bridges, idl_bridges

  return, spec_fit_str

end