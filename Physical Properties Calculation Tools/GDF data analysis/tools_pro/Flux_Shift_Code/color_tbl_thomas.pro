PRO COLOR_TBL_THOMAS

  ; Thomas Kyoung-Ho Kim
  ; Graduate Research Assistant / PhD Student
  ; Southwest Research Institute / University of Texas at San Antonio
  ;
  ;=============================================================
  ;============Configuring color table for the plot=============
  DEVICE, SET_FONT='Helvetica Bold', /TT_FONT
  DEVICE, DECOMPOSED=0
  !P.BACKGROUND=255
  !P.COLOR=0
  LOADCT, 33, /SILENT
  TVLCT, R, G, B, /GET
  RED=CONGRID(R[49:253], 256, /INTERP)
  GREEN=CONGRID(G[49:253], 256, /INTERP)
  BLUE=CONGRID(B[49:253], 256, /INTERP)
  RED[0]=0
  GREEN[0]=0
  BLUE[0]=0
  RED[255]=255
  GREEN[255]=255
  BLUE[255]=255
  TVLCT, RED, GREEN, BLUE
  ;=============================================================
  ;
END