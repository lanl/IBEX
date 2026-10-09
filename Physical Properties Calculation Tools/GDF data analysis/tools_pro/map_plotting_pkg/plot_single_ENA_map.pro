;Plots a single IBEX ENA map assuming an ISOC map file format (2D array of flux values)
; Note to user: 
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro plot_single_ENA_map
;Upwind center (Ref: McComas et al. 2015)
nose_lon = 180.+75.7
nose_lat = +5.1

;------------
;THe following lines need to be tailored for specific map file to be plotted
thispath = '/Users/Dan/IDL/IBEX/map_plotting_code/'
colorbar_range=[0,110]
e_value = 1.74 ;keV
map_file = thispath + '/hvset2013A-trp-flux100-hi-4-flux.txt' 
;------------

mag_factor=10. 
!p.position=0
!p.font=1
plots_across=1
plots_down=1
!p.multi=[0,plots_across,plots_down,0,0]
device, retain=2
window, 0, xsize=1200,ysize=700

load_ibex_color_table

;;;+ Reading different energies for the same map
flux_map = read_ibex_ena_skymaps(map_file) 
;esa = 4 
;eff_drop = 0.904 ;efficiency correction for Map 3
;gtriples = [.00013,.00037,.00073,.0014,.0025,.0042]
;enert = [0.45, 0.71, 1.10, 1.74, 2.73, 4.29]
;flux_map = flux_mapa/gtriples[esa-1]/enert[esa-1]/eff_drop
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
stop
end
