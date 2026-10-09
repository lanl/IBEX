function pressure_ibex, ener

  common share, flux, enerf, kappa

  mh = 1.67d-24 ;grams
  nh = 0.127    ;cm^-3  After Swaczyna et al. 2020
  kev2ergs = 1.602e-9  ;ergs/keV
  k = 1.381e-16 ;erg/K
  pico = 1e-12
  au = 1.496e13 ;cm
  
  sig = (4.15-0.531*alog(ener))^2*(1-exp(-67.3/ener))^4.5 * 1e-16
  dP0 = 4*!pi*sqrt(2*mh)*sqrt(ener*kev2ergs)/(3*sig*nh)/au
  
  nener = n_elements(enerf) - 1
  for i = nener-1,0,-1 do begin
    if ener ge enerf[i] then break
  endfor
  dPL = dP0 * flux[i]*(ener/enerf[i])^(-kappa[i])/pico
  return, dPL
end