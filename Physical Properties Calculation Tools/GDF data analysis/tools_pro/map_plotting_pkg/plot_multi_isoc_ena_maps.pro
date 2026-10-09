;Plots multiple IBEX ENA maps located in a user-defined directory, assuming an ISOC map file format (2D array of flux values)
; Note to user: 
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro plot_multi_ISOC_ENA_maps
!quiet = 1
e_step = [0.45,0.71,1.11,1.74,2.73,4.29]

;find all the map files in the following directiory having the given root filename
thispath = '/Users/Dan/IDL/IBEX/11YearMaps/hvset_cg_2011A/prod/60d/'
files = file_search(thispath+'hv60.hide-trp-mono_80*flux.txt') 

nmaps = n_elements(files)
;Upwind center (Ref: McComas et al. 2015)
nose_lon = 180.+75.7
nose_lat = +5.1

mag_factor=10. 
!p.position=0
!p.font=1
plots_across=1
plots_down=1
!p.multi=[0,plots_across,plots_down,0,0]
device, retain=2
window, 0, xsize=1200,ysize=700

load_ibex_color_table

cbmax = [1200,800,400,140,60,18]  ;"standard" flux range maxima

for imap = 0, nmaps-1 do begin
  basename = strmid(files[imap],0,strlen(files[imap])-4)
;  esa = fix(strmid(basename,(strpos(basename,'hi-')+3),1))

;You may have to tailor the following lines to extract the energy step or energy value, depending on the map type.
; As delivered, this is intended to extract the energy value (e.g. 1.74) from the file name of a cg-corrected map
; file (e.g. 'hv60.hide-trp-mono_80-0.71-flux.txt') 
  e_value = float(strmid(basename,(strpos(basename,'80-')+3),4))
  esa = where(e_step eq e_value) + 1
; You would use the line below to pull out the energy step name  
;  e_value = e_step[esa-1] ;keV
  colorbar_range=[0,cbmax[esa-1]]
  map_file = basename + '.txt'

flux_map = read_ibex_ena_skymaps(map_file) 

latmin = -90
latmax = 90
lonmin = 0		
lonmax =  360	
p0lon = nose_lon
p0lat = nose_lat
ascii_map=flux_map
colorbar_title = 'Differential Flux [ENAs/(cm!U2!N s sr keV)];   ~'+strtrim(string(e_value, format='(F10.2)'),2)+' keV'
imSize=SIZE(ascii_map)
magnifiedImg = CONGRID(ascii_map, mag_factor*imsize[1],mag_factor*imsize[2])  
this_map = bytscl(magnifiedImg, min = colorbar_range[0], max = colorbar_range[1], top=255)
MAP_SET, p0lat,360.-p0lon,0, /advance,title=' ',position=[0.05,0.12,0.95,0.99],/ISOTROPIC,/noborder,limit=map_limits,/MOLLWEIDE
remap = map_image(this_map,Startx,Starty, xsize, ysize,/scale,COMPRESS=1, LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
pos = fltarr(4)
pos[0] = Startx / float(!d.x_vsize)
pos[1] = Starty / float(!d.y_vsize)
pos[2] = (Startx + xsize) / float(!d.x_vsize)
pos[3] = (Starty + ysize) / float(!d.y_vsize)
imdisp, remap, pos=pos, /usepos, /noscale
MAP_GRID, latdel=30, londel=30,/LABEL,color=fsc_color('yellow'),/horizon,$
lats = [-90,-60,-30,0,30,60,90],latnames=['-90','-60','-30','0','30','60',' '],$
lons = -1*[0,-30,-60,-90,-120,-150,180,150,120,90,60,30,0],lonnames=['0','-30','-60','-90','-120','-150','180','150','120','90','60','30'],$
latlab=0,glinestyle=0, glinethick=1.25, charthick=2, charsize=2.5
fsc_colorbar, range=colorbar_range,/overplot,position=[.1, .06, .9, .1], charsize=2.5,charthick=2.,$
color=fsc_color('yellow'),divisions=colorbar_divisions,/horizontal,title=colorbar_title
!p.multi = 0
device, retain=2

write_png,basename+'_map.png',tvrd(/true)
endfor

stop
end
