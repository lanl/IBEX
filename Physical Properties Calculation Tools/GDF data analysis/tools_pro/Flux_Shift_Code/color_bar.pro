pro color_bar, lim, ytit, pos, ct = ct, horizontal = horizontal, fontsize = fontsize, $
min_black_sat=min_black_sat, max_white_sat=max_white_sat, reverse_ct=reverse_ct
  ;I have finaly gotten smart and wrote a stupid color bar procedure.
  ;This will place a color bar that ranges the full rang of the
  ;currently loaded colar table.
  ;lim = vector of size 2 (lower bound, upper bound)
  ;title = the title to put along the y axis
  ;pos = the 4 element vector ofthe location to place the color bar

  if(n_elements(ct) eq 0) then begin
    color_tbl_thomas
  endif else if ct eq 109 then begin

    device, set_font='Helvetica Bold', /tt_font
    device, decomposed=0
    !p.background=255
    !p.color=0
    loadct, 56, /silent
    tvlct, r, g, b, /get
    red=r
    green=g
    blue=b
    red[0]=0
    green[0]=0
    blue[0]=0
    tvlct, red, green, blue

  endif else if ct eq 999 then begin

    device, set_font='Helvetica Bold', /tt_font
    device, decomposed=0
    !p.background=255
    !p.color=0
    loadct, 33, /silent
    red = [$
      0,  64,  62,  60,  59,  57,  55,  53,  51,  49,  48,  46,  44,  42,  40,  38,$
      37,  35,  33,  31,  29,  27,  26,  24,  22,  20,  18,  16,  15,  13,  11,  9,$
      7,   5,   4,   2,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   6,  12,  18,  24,  30,  36,$
      43,  49,  55,  61,  67,  73,  79,  85,  91,  97, 103, 109, 115, 121, 128, 134,$
      140, 146, 152, 158, 164, 170, 176, 182, 188, 194, 200, 206, 213, 219, 225, 231,$
      237, 243, 249, 255, 254, 253, 252, 251, 249, 248, 247, 246, 245, 244, 243, 242,$
      241, 240, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 227, 226, 225, 224,$
      223, 222, 221, 220, 219, 218, 216, 215, 214, 213, 212, 211, 210, 209, 208, 207,$
      205, 204, 203, 202, 201, 200, 201, 203, 204, 205, 207, 208, 209, 211, 212, 213,$
      215, 216, 217, 219, 220, 221, 223, 224, 225, 227, 228, 230, 231, 232, 234, 235,$
      236, 238, 239, 240, 242, 243, 244, 246, 247, 248, 250, 251, 252, 254, 255, 255]

    green = [$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   6,  12,  18,  24,  30,  36,  42,  47,  53,  59,  65,$
      71,  77,  83,  89,  95, 101, 107, 113, 119, 125, 130, 136, 142, 148, 154, 160,$
      166, 172, 178, 184, 190, 196, 202, 208, 213, 219, 225, 231, 237, 243, 249, 255,$
      253, 252, 250, 249, 247, 246, 244, 243, 241, 240, 238, 236, 235, 233, 232, 230,$
      229, 227, 226, 224, 222, 221, 219, 218, 216, 215, 213, 212, 210, 209, 207, 205,$
      204, 202, 201, 199, 198, 196, 195, 193, 192, 190, 192, 193, 195, 196, 198, 199,$
      201, 202, 204, 205, 207, 209, 210, 212, 213, 215, 216, 218, 219, 221, 223, 224,$
      226, 227, 229, 230, 232, 233, 235, 236, 238, 240, 241, 243, 244, 246, 247, 249,$
      250, 252, 253, 255, 250, 245, 240, 235, 229, 224, 219, 214, 209, 204, 199, 194,$
      189, 184, 178, 173, 168, 163, 158, 153, 148, 143, 138, 133, 127, 122, 117, 112,$
      107, 102,  97,  92,  87,  82,  76,  71,  66,  61,  56,  51,  46,  41,  36,  31,$
      25,  20,  15,  10,   5,   0,   3,   6,   9,  12,  16,  19,  22,  25,  28,  31,$
      34,  37,  41,  44,  47,  50,  53,  56,  59,  62,  66,  69,  72,  75,  78,  81,$
      84,  87,  91,  94,  97, 100, 103, 106, 109, 112, 116, 119, 122, 125, 128, 255]


    blue = [$
      0,  64,  69,  75,  80,  86,  91,  97, 102, 108, 113, 119, 124, 129, 135, 140,$
      146, 151, 157, 162, 168, 173, 179, 184, 190, 195, 200, 206, 211, 217, 222, 228,$
      233, 239, 244, 250, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,$
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,$
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,$
      249, 243, 237, 231, 225, 219, 212, 206, 200, 194, 188, 182, 176, 170, 164, 158,$
      152, 146, 140, 134, 127, 121, 115, 109, 103,  97,  91,  85,  79,  73,  67,  61,$
      55,  49,  42,  36,  30,  24,  18,  12,   6,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,$
      0,   0,   0,   0,   0,   0,   6,  12,  19,  25,  31,  37,  44,  50,  56,  62,$
      68, 75,  81,  87,  93, 100, 106, 112, 118, 124, 131, 137, 143, 149, 155, 162,$
      168, 174, 180, 187, 193, 199, 205, 211, 218, 224, 230, 236, 243, 249, 255, 255]

    tvlct, red, green, blue

  endif else if ct eq 970 then begin

    device, set_font='Helvetica Bold', /tt_font
    device, decomposed=0
    !p.background=255
    !p.color=0
    loadct, 70, /silent
    tvlct, red, green, blue, /get
    red   = reverse(red)
    green = reverse(green)
    blue  = reverse(blue)
    red[0]=0
    green[0]=0
    blue[0]=0
    tvlct, red, green, blue

  endif else if ct eq 740 then begin
    
    loadct, 74, /silent
    tvlct, red, green, blue, /get
    red = reverse(red)
    green = reverse(green)
    blue = reverse(blue)
    red[0]=0
    green[0]=0
    blue[0]=0
    tvlct, red, green, blue
    
  endif else if ct eq 973 then begin
    
    loadct, 73, /silent
    tvlct, red, green, blue, /get
    red = reverse(red)
    green = reverse(red)
    blue = reverse(red)
    red[0]=0
    green[0]=0
    blue[0]=0
    tvlct, red, green, blue
    
  endif else if ct eq 520 then begin

    loadct, 52, /silent
    tvlct, red, green, blue, /get
    red = red
    green = green
    blue = blue
    red[0]=0
    green[0]=0
    blue[0]=0
    tvlct, red, green, blue

  endif else begin
    loadct, ct, /silent
    tvlct,red,green,blue,/get
    tvlct, red, green, blue    
  endelse
  
  if n_elements(reverse_ct) ne 0 then begin
    tvlct,red,green,blue,/get
    red   = reverse(red)
    green = reverse(green)
    blue  = reverse(blue)
    tvlct, red, green, blue
  endif
  
  if n_elements(min_black_sat) ne 0 then begin
    tvlct,red,green,blue,/get
    red[0]=0
    green[0]=0
    blue[0]=0
    tvlct, red, green, blue
  endif
  
  if n_elements(max_white_sat) ne 0 then begin
    tvlct,red,green,blue,/get
    red[255]=255
    green[255]=255
    blue[255]=255
    tvlct, red, green, blue  
  endif
  

  !p.font=0
  !p.BACKGROUND=255
  !p.color=0

  bar = fltarr(2, 256)
  bar[0,*] = findgen(256)
  bar[1,*] = findgen(256)

  blank = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']

  tmp_size = !P.charsize
  if(n_elements(fontsize) EQ 1) then !P.charsize = fontsize


  if(keyword_set(horizontal)) then begin
    plot, lim, [0,1], /nodata, /xstyle, /ystyle, $
      position = pos, xtickname = blank, $
      yminor = 1, yticks = 1, /noerase, ytickname = blank, $
      /normal , font=0
    tvimage, transpose(bar), /overplot
    plot, lim, [0,1], /nodata, /xstyle, /ystyle, $
      position = pos, xtickname = blank, $
      yminor = 1, yticks = 1, /noerase, ytickname = blank, $
      /normal, title = ytit, font=0
    axis, xaxis = 0, /xstyle  , font=0
  endif else begin
    plot, [0,1], lim, /nodata, /xstyle, /ystyle, $
      position = pos, xtickname = blank, $
      xminor = 1, xticks = 1, /noerase, ytickname = blank, $
      /normal, font=0
    tvimage, bar, /overplot
    plot, [0,1], lim, /nodata, /xstyle, /ystyle, $
      position = pos, xtickname = blank, $
      xminor = 1, xticks = 1, /noerase, ytickname = blank, $
      /normal, font=0
    axis, yaxis = 1, ytitle = ytit, /ystyle, font=0
  endelse

  !P.charsize  = tmp_size

end
