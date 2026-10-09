;Plots multiple Theseus flux unit maps created by Thomas Kim, located in a user-defined directory
; Note to user: 
; routines imdisp.pro, fsc_color.pro and fsc_colorbar.pro are from Fanning's Coyote IDL library

pro plot_kim_theseus_map
!quiet = 1
e_step = [0.45,0.71,1.11,1.74,2.73,4.29]
;basepath = '/Users/Dan/IDL/IBEX/LDRD_DR/Sky_Maps_Kim/Theseus_Ram_and_Antiram_Maps/'
basepath = '/Users/nwalia/Theseus 6-month Maps (10-27-2022)'
;localpath = 'Theseus/Theseus_IBEX_STM_22/'
localpath = 'CSV/'
thispath = basepath+localpath
;files = file_search(thispath+'*.CSV') ;find all the Osthus map files in this directiory
;files = thispath + '2009A_2009B_Combined_Theseus_ram_2x2.CSV'
;files = thispath + '2009A_Combined_Theseus_stitched_patched_2x2'
nmaps = n_elements(files)
basenames = strmid(files,0,strlen(files)-4)

;Upwind center (Ref: McComas et al. 2015)
nose_lon = 180.+75.7
nose_lat = +5.1

resolution = 2.0 ;degrees
mag_factor=5.
!p.position=0
!p.font=1
plots_across=1
plots_down=1
!p.multi=[0,plots_across,plots_down,0,0]
device, retain=2
loadct, 33

latmin = -90
latmax = 90
lonmin = 0
lonmax =  360
p0lon = nose_lon
p0lat = nose_lat

cbmax = [1200,800,200,140,60,18]

load_ibex_color_table

for imap = 0, nmaps-1 do begin
  basename = strmid(files[imap],0,strlen(files[imap])-4)
  esa = fix(strmid(basename,(strpos(basename,'esa')+3),1))
  map_file = basename + '.csv'
  flux_map = read_ibex_skymap_kim_theseus(map_file, resolution)

for ie = 0,4 do begin
  esa = ie+1
  e_value = e_step[esa] ;keV
  colorbar_range=[0,cbmax[esa]]
  out_map = basename +'_esa'+ strcompress(esa+1,/remove_all)
;  window, imap, xsize=1200,ysize=700
  window, 0, xsize=1200,ysize=700
  ;;;+ Reading different energies for the same map
  ;flux_map = flux_mapa
  print, esa+1, max(flux_map[*,*,ie])
  ;ascii_map=reverse(shift(flux_map[*,*,ie],-45,0),1)
  ascii_map=reverse(flux_map[*,*,ie],1)
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
  
  ; Write out flux and variance to files
  flux_mapr = rotate(ascii_map,5)
  s = size(flux_mapr)
  nlat = s[2]
  nlong = s[1]
  fmt_str = '('+strcompress(nlong,/remove_all)+'f11.2)'

  write_png,out_map+'.png',tvrd(/true)
endfor
endfor

stop
end
