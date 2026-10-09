function ibex_hi_shift_flux_to_source_region, input_flux, input_flux_sigma, input_fractional_year, input_resolution, target_year_arr

  ;time-shift the observed flux at 1AU to when ENA was created at the source region
  ;(i.e., from 1AU to termination shock+heliosheath thickness/2)

  flux            = input_flux
  flux_sigma      = input_flux_sigma
  fractional_year = input_fractional_year
  resolution      = input_resolution

  source_dist=ibex_hi_get_ena_source_dist(resolution);, /plot, /mollweide)

  au_to_meter    = 149597870691D

  keV_to_joule   = 1.6021766339999D-16

  proton_mass_kg = 1.67262192D * 1D-27

  evals = [0.38d, 0.71d, 1.11d, 1.74d, 2.73d, 4.29d]

  travel_time = fractional_year*0D

  tmp_input_size = size(fractional_year, /dim)

  if n_elements(tmp_input_size) eq 4 then begin

    for map_loop = 0LL, tmp_input_size[0]-1LL do begin

      travel_time[map_loop,*,*,0] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[0]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
      travel_time[map_loop,*,*,1] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[1]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
      travel_time[map_loop,*,*,2] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[2]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
      travel_time[map_loop,*,*,3] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[3]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
      travel_time[map_loop,*,*,4] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[4]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
      travel_time[map_loop,*,*,5] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[5]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)

    endfor

  endif else begin

    travel_time[*,*,0] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[0]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,1] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[1]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,2] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[2]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,3] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[3]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,4] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[4]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)
    travel_time[*,*,5] = safe_div(source_dist*au_to_meter, sqrt(2d*evals[5]*keV_to_joule/proton_mass_kg))/(365d*24d*60d*60d)

  endelse

  if max(travel_time, /nan) eq 0D then stop

  time_at_hs = fractional_year; - travel_time

  ;Put negatives to zero values
  neg_idx = where(time_at_hs lt 0D, /null , /l64)

  if n_elements(neg_idx) gt 0 then time_at_hs[neg_idx]=0D

  input_min_time_bound = fractional_year * 0D
  input_max_time_bound = fractional_year * 0D

  extrapol_mul_target  = fractional_year * 0D + 1D

  target_snapshot_yr = dblarr(n_elements(target_year_arr),90,180,6)

  for target_yr_loop = 0LL, n_elements(target_year_arr)-1LL do begin

    target_snapshot_yr [target_yr_loop,*,*,*] = target_year_arr[target_yr_loop]

  endfor

  snapshot_flux       = flux*0D

  snapshot_flux_sigma = flux_sigma*0D

  for e_loop = 1LL, 5LL do begin

    for lat_loop = 0LL, 180LL/resolution-1LL do begin

      for lon_loop = 0LL, 360LL/resolution-1LL do begin

        if n_elements(tmp_input_size) eq 4 then begin

          input_min_time_bound[*,lat_loop,lon_loop,e_loop] = min(fractional_year[*,lat_loop,lon_loop,e_loop], /nan)
          input_max_time_bound[*,lat_loop,lon_loop,e_loop] = max(fractional_year[*,lat_loop,lon_loop,e_loop], /nan)

          for map_loop = 0LL, tmp_input_size[0]-1LL do begin
            ;identify extrapolated indices here for tracing back every flux values to ENA source region

            ;identify extrapolated indices here for ENA population at source region with targeted snapshot time
            tmp_max_hs_frac_yr     = max(time_at_hs [*,lat_loop,lon_loop,e_loop], /nan)
            tmp_min_hs_frac_yr     = min(time_at_hs [*,lat_loop,lon_loop,e_loop], /nan)

            tmp_target_snapshot_yr = target_snapshot_yr [map_loop,lat_loop,lon_loop,e_loop]

            if tmp_target_snapshot_yr gt tmp_max_hs_frac_yr or tmp_target_snapshot_yr lt tmp_min_hs_frac_yr then begin

              extrapol_mul_target [map_loop,lat_loop,lon_loop,e_loop] = 0D

            endif
            
            snapshot_flux [map_loop,lat_loop,lon_loop,e_loop] = $
              interpol(flux[*,lat_loop,lon_loop,e_loop], time_at_hs[*,lat_loop,lon_loop,e_loop], target_snapshot_yr[map_loop,lat_loop,lon_loop,e_loop], /nan)

          endfor

        endif

      endfor

    endfor

  endfor

  snapshot_flux_sigma   = snapshot_flux * safe_div(flux_sigma, flux)

  snapshot_flux       *= extrapol_mul_target

  snapshot_flux_sigma *= extrapol_mul_target

  return_str = create_struct($
    'target_snapshot_flux',       snapshot_flux, $
    'target_snapshot_flux_sigma', snapshot_flux_sigma, $
    'target_snapshot_yr',         target_snapshot_yr, $
    'shifted_time_at_hs',         time_at_hs)

  return, return_str

end