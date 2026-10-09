; sheath_xcorrel_fnc_sokol.pro
;
; this function calculates the correlation between 1 AU SW pressure
; and ENA pressure for various TS distances.  It returns a set of time delays and 
; distances based on local minima in the correlation analysis.  It is based on 
; the "omni_sheath_find*.pro" procedure.  See notes for these for further details.
; 
; Version history:  *_sokol.pro uses the latitude-dependent time-varying solar wind
;                   speeds from Justyna Solok for the purposes of determining
;                   the propagation time to the TS. Here, it is assumed that an
;                   average speed is adequate.
;                   
;                   sheath_xcorrel_fnc_sokol.pro replaces correlation method with
;                   cross-correlation between SW pressure and heliosheath pressure
;                   
;                   4/13/2020:  New speed vs latitude profile incorporated.  Not
;                   only updates file to late 2019 (2019.828), but includes a new
;                   analysis of the IPS data by Sokol.
; 
; Inputs:     lat:  The latitudes of the ENA observations, passed to find the
;                   solar wind speed to use
; 



function sheath_xcorrel_fnc_sokol, enaflux, enaflux_err, yfrac, latcen, latdel, dts, ths_min, ths_max

;enaflux has dimensions of 6 energies x the number of time steps

path = ''

common share, flux, enerf, kappa
!quiet = 1
!except = 0

ps = 0
device, decomposed = 0

omni = read_omni_daily()

mp = 1.67e-24 ;(proton mass in g)
press = omni.v*omni.v*omni.n*mp*(1e5)^2*1e9   ;units are ndynes/cm^2
ig = where(omni.v lt 99999. and omni.n lt 999.,ng)
date = omni.year + omni.doy/365. + omni.hour/(365.*24)

;central energies
enert = [0.45, 0.71, 1.10, 1.74, 2.73, 4.29]
ener = [0.71, 1.10, 1.74, 2.73, 4.29]  ;keV

;minimum and maximum overlapping energy bin indicies
ebin_min = 0
ebin_max = 4
n_ebin = ebin_max-ebin_min + 1

s = size(enaflux)
nmap = s[2]

;internal pressure derived from ENA flux (assuming it is isotropic)
;
; dP*L = 4pi/3 * J(ena)/sig*n_H * sqrt(2*m_H) * E^1.5 * 0.6/au
;
; where v_o = is the observed speed (sqrt(2*E/m_H)) 
;
; units are dynes/cm^2 * AU
;
; -----------------------------------------------------------
; New method for computing partial pressures (as of 6/4/15):
; from 0.52 keV to 6 keV, by assuming a power law with a different exponent between
; measurements. For the ends (between 0.52 and .71 keV and 4.3 and 6.0 keV, assume
; the same exponent as between the adjacent two energies.
;
; First find spectral indices for consecutive pairs of flux measurements
log_f = alog10(enaflux[1:5,*])
log_e = alog10(enert[1:5])
kappa_f = fltarr(6,nmap)
enerf = [.57,enert[1:5],6.0]  ;full energy range for IBEX total flux calc

for i = 0,3 do kappa_f[i+1,*] = -(log_f[i+1,*]-log_f[i,*])/(log_e[i+1]-log_e[i])

;spectral indices for the ends are set to the adjacent ones
kappa_f[0,*] = kappa_f[1,*]
kappa_f[5,*] = kappa_f[4,*]

pflux = fltarr(6,nmap)
pflux[1:5,*] = enaflux[1:5,*]

; determine flux for the lowest energy (0.52 keV) by extrapolation of the
; power law
pflux[0,*] = pflux[1,*]*(enerf[0]/enerf[1])^(-kappa_f[0,*])

;--------------------------------------------------------------------
; calculate partial pressures for each of the 'nmap' spectra for IBEX

;energy ranges for the 5 ESA steps
bot_e = [.57,sqrt(enert[1:4]*enert[2:5])]
mid_e = enert[1:5]
top_e = [sqrt(enert[1:4]*enert[2:5]),6.0]

;initialize partial pressure arrays:
dPL = fltarr(5,nmap)
dPLerr = fltarr(5,nmap)

;partial pressures for north pole
for i = 0,nmap-1 do begin
  flux = reform(pflux[*,i])
  kappa = reform(kappa_f[*,i])
  dPL[*,i] = qromb('pressure_ibex',bot_e,top_e)
  ; to determin error, we scale the partial press by fractional error in the
  ; flux associated with the corresponding ESAs.  This is not a precise calc
  ; of the error, as it depends on the fluxes in the adjacent steps as well,
  ; but it will have to do, since the exact error calc is too complicated to be
  ; worth the effort.
  dPLerr[*,i] = dPL[*,i] * enaflux_err[1:5,i]/enaflux[1:5,i]
endfor

;done w/ partial pressure calculations
;--------------------------------------

loadct, 39
;---------------------------------------------------------------------------------------
;Begin looping through range of TS distances and HS thicknesses to calculate time shift:

; define an array to store correlation results
; elements are:  dts, ths, nlap, north slope, north slope uncertainty,
;   north zero intercept slope, diff, south slope, south slope uncertainty,
;   south zero intercept slope, diff
; number of iterations: X values of dts x Y values of ths = X*Y

dts_min = 100.
dts_max = 100.  ;effectively shutting off TS distance loop
;ths_min = 10.
;ths_max = 250.

n_ths = floor((ths_max-ths_min)/5. + 1)
n_dts = floor((dts_max-dts_min)/5. + 1)

;---------------------------------------
; Define here the elements contained in the returned structure
; corr_spec contains the cross-correlation for each combination of dts & ths
corr_spec = fltarr(n_dts,n_ths)
; 'traceback' contains the SW departure times for each combination of dts & ths
traceback = fltarr(n_dts,n_ths,5,nmap)
; vp: averages solar wind speed for skymap pixel at each SW departure time for each combination of dts & ths
vp = fltarr(n_dts,n_ths,5,nmap)

nstore = 5
max_idx = intarr(nstore,n_dts) ;array to store indices for locations of maxima
max_corr = fltarr(nstore,n_dts) ;array of maximum correlations
dts_val = fltarr(nstore,n_dts) ;array of termination shock distances
ths_val = fltarr(nstore,n_dts) ;array of heliosheath thickness values

iter = 0
ii = 0

;** TS distance loop commented out here
;for ii = 0,n_dts-1 do begin
;  dts = ii*5 + dts_min

for jj = 0,n_ths-1  do begin
  ths = jj*5 + ths_min

  ;build an array of time-shifted dates:
  ;smpress = smooth(press[ig],54)  
  smpress = smooth(press[ig],365)
  
  ;find the solar wind departure times from 1 AU for a set of IBEX map dates and energies
  ; A 5 x 'nmap' array of times is returned
  ;restore, path + 'speed_3Dseries5_trunc.sav'
  restore, path + 'speed3D_invariantModel_s02_scaledDiff2cal_2020a.sav' ; New 2020 version of speed v latitude
  sw_tshift = find_omni_time_lat_v3(yfrac,latcen,latdel,dts,ths,v_date,v_arr,vsw=vsw)
  
  ;print, latcen, dts,ths, yfrac[0], sw_tshift[0,0]
  
  press_samp = fltarr(5,nmap)
  traceback[ii,jj,*,*] = sw_tshift
  vp[ii,jj,*,*] = vsw
  
  for i = 0,4 do begin
    press_samp[i,*] = interpol(smpress,date[ig],sw_tshift[i,*])
  endfor
  
  start = sw_tshift[*,0]
  endr = sw_tshift[*,nmap-1]
  
  ;----------------------------------------------
  ;find the points where min and max ESAs overlap.  This is defined as all ESA min times that are greater than
  ;the first ESA max time minus .05 years (2.6 weeks)
  
  ilap = where(sw_tshift[ebin_max,*] le sw_tshift[ebin_min,nmap-1]+.33,nlap)
  
  
  ;print, 'distance to TS: ',dts,'  Heliosheath thickness: ',ths
  ;print, nlap
  tlap = reform(sw_tshift[ebin_max,0:nlap-1])
  prsamp_lap = reform(press_samp[ebin_max,0:nlap-1])
  
  dpl2_6 = fltarr(5,nlap)
  edpl2_6 = fltarr(5,nlap)
  
  for i = 0,4 do begin
  	dpl2_6[i,*] = interpol(dpl[i,*],sw_tshift[i,*],tlap)
  	edpl2_6[i,*] = interpol(dplerr[i,*],sw_tshift[i,*],tlap)
  endfor
  
  ; total heliosheath plasma pressure (PxL)
  pl2_6 = total(dpl2_6[ebin_min:ebin_max,*],1)
  sig_pl = sqrt(total(edpl2_6[ebin_min:ebin_max,*]^2,1))
  
  res = c_correlate(prsamp_lap,pl2_6,0)  ;calculate cross-correlation with zero lag
  
  meanp = mean(prsamp_lap)
  meanpl = mean(pl2_6)
  m = meanpl/meanp
  ;m = (max(yfit)+min(yfit))/(max(prsamp_lap) + min(prsamp_lap))
  
  corr_spec[ii,jj] = res
  
  iter++
endfor

;Look for maximum in corr_spec[ii,*]
  
  mindex = local_maxmin(corr_spec[ii,*],3)   ;first find indexes of all the local maxima for the ii'th TS distance
  maxval = max(corr_spec[ii,*],imax)    ;then find the true maximum from among these

  max_idx[0,ii] = imax
  max_corr[0,ii] = corr_spec[ii,imax]
  dts_val[0,ii] = dts
  ths_val[0,ii] = imax*5 + ths_min

max_struct = {idx: max_idx, val: max_corr, dts:dts_val, ths:ths_val, corr:corr_spec, t_omni:traceback, vp:vp}

;print, corr_res
!quiet = 0
!except = 1
return, max_struct
end
