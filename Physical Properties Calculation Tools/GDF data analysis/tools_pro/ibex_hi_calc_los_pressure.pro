function pressure_ibex_, ener

  mh = 1.67D-24 ;grams
  nh = 0.127D    ;cm^-3  After Swaczyna et al. 2020
  kev2ergs = 1.602D-9  ;ergs/keV
  k = 1.381D-16 ;erg/K
  pico = 1D-12
  au = 1.496D13 ;cm

  sig = (4.15d - 0.531d*alog(ener))^2d*(1d - exp(-67.3d/ener))^4.5d * 1d-16
  dP0 = 4d*!pi*sqrt(2d*mh)*sqrt(ener*kev2ergs)/(3d*sig*nh)/au

  nener = n_elements(!enerf) - 1
  for i = nener-1,0,-1 do begin
    if ener ge !enerf[i] then break
  endfor

  ;i=where(reverse(!enerf[0:5]) le ener, /null, /l64)

  dPL = dP0 * !flux[i]*(ener/!enerf[i])^(-!kappa[i])/pico

  return, dPL

end

pro ibex_hi_calc_los_pressure, index0, index1, index2, input_flux, input_flux_sigma, pressure, pressure_sigma

  

  ;flux and flux_sigma should be 6-element arrays
  ;this is here to avoid altering the input
  flux       = input_flux
  flux_sigma = input_flux_sigma

  dpl_arr    = input_flux * 0D
  dplerr_arr = input_flux_sigma *0D

  ;central energies
  enert = [0.45D, 0.71D, 1.10D, 1.74D, 2.73D, 4.29D]

  log_f   = alog10(flux[1:5])
  log_e   = alog10(enert[1:5])
  kappa_f = dblarr(6)
  enerf   = [.57D,enert[1:5],6D]  ;full energy range for IBEX total flux calc

  for i = 0LL,3LL do kappa_f[i+1LL] = -(log_f[i+1LL]-log_f[i])/(log_e[i+1LL]-log_e[i])

  ;spectral indices for the ends are set to the adjacent ones
  kappa_f[0] = kappa_f[1]
  kappa_f[5] = kappa_f[4]

  pflux      = dblarr(6)
  pflux[1:5] = flux[1:5]

  ; determine flux for the lowest energy (0.52 keV) by extrapolation of the
  ; power law
  pflux[0] = pflux[1]*(enerf[0]/enerf[1])^(-kappa_f[0])

  ;--------------------------------------------------------------------
  ; calculate partial pressures for each of the 'nmap' spectra for IBEX

  ;energy ranges for the 5 ESA steps
  bot_e = [.57D,sqrt(enert[1:4]*enert[2:5])]
  mid_e = enert[1:5]
  top_e = [sqrt(enert[1:4]*enert[2:5]),6D]

  ;initialize partial pressure arrays:
  dPL    = dblarr(5)
  dPLerr = dblarr(5)

  ;partial pressures for north pole

  flux  = reform(pflux)
  kappa = reform(kappa_f)

  defsysv, '!flux', flux
  defsysv, '!kappa', kappa
  defsysv, '!enerf', enerf

  ;dPL = qromb('pressure_ibex_', bot_e, top_e, /double)

  ;calculate piecewise pressure values
  mh = 1.67D-24 ;grams
  nh = 0.127D    ;cm^-3  After Swaczyna et al. 2020
  kev2ergs = 1.602D-9  ;ergs/keV
  k = 1.381D-16 ;erg/K
  pico = 1D-12
  au = 1.496D13 ;cm

  for e_loop=0LL, 4LL do begin

    tmp_e_top    = top_e [e_loop]
    tmp_e_bottom = bot_e [e_loop]

    tmp_sig_bottom = (4.15d - 0.531d*alog(tmp_e_bottom))^2d*(1d - exp(-67.3d/tmp_e_bottom))^4.5d * 1d-16
    tmp_dP0_bottom = 4d*!pi*sqrt(2d*mh)*sqrt(tmp_e_bottom*kev2ergs)/(3d*tmp_sig_bottom*nh)/au

    tmp_sig_top    = (4.15d - 0.531d*alog(tmp_e_top))^2d*(1d - exp(-67.3d/tmp_e_top))^4.5d * 1d-16
    tmp_dP0_top    = 4d*!pi*sqrt(2d*mh)*sqrt(tmp_e_top*kev2ergs)/(3d*tmp_sig_top*nh)/au

    nener = n_elements(enerf) - 1
    for i = nener-1,0,-1 do begin
      if tmp_e_bottom ge enerf[i] then break
    endfor

    tmp_f_bottom = tmp_dP0_bottom*pflux[i]*(tmp_e_bottom/enerf[i])^(-kappa_f[i])/pico

    nener = n_elements(enerf) - 1
    for i = nener-1,0,-1 do begin
      if tmp_e_top ge enerf[i] then break
    endfor

    ;dPL = dP0 * !flux[i]*(ener/!enerf[i])^(-!kappa[i])/pico

    tmp_f_top    = tmp_dP0_top*pflux[i]*(tmp_e_top/enerf[i])^(-kappa_f[i])/pico

    tmp_e_arr = [tmp_e_bottom, tmp_e_top]
    tmp_f_arr = [tmp_f_bottom, tmp_f_top]

    dPL [e_loop] = int_tabulated(tmp_e_arr, tmp_f_arr, /double)

  endfor

  ; to determin error, we scale the partial press by fractional error in the
  ; flux associated with the corresponding ESAs.  This is not a precise calc
  ; of the error, as it depends on the fluxes in the adjacent steps as well,
  ; but it will have to do, since the exact error calc is too complicated to be
  ; worth the effort.
  dPLerr = dPL * flux_sigma[1:5]/flux[1:5]

  ;return 6 elements
  pressure       = [0D, dPL]
  pressure_sigma = [0D, dPLerr]
  

  
  stop

end