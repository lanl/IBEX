;============================================================
;$
; :Description:
;    Describe the procedure.
;
; :Params:
;    target
;
;
; :Keywords:
;    data_log
;    location  :  'top' or 'bottom' or 'left' or 'right'
;    position
;    device
;    gap
;    rgb_table
;    range
;    _extra
;
;
; :Author: DaeKyu Shin
;          Department of Astronomy and Space Science
;          Chungbuk National University
;          Cheongju 361-763, South Korea
;
; :E_mail: tlseorb0111@naver.com
;
; :Last Modited: 2015. 8. 15
;
;============================================================
function color_bar, target, $
  data_log = data_log, $
  location = location, $
  position = position, $
  device = device, $
  gap = gap, $
  width = width, $
  rgb_table = rgb_table, $
  range = range, $
  _extra = _extra


  if n_elements(location) eq 0 then loc = 'RIGHT' else loc = location
  loc = strupcase(loc)


  ;;=============================== default position ===============================
  if n_elements(position) eq 0 then begin
    img_pos = target.position
    position = img_pos

    if n_elements(width) eq 0 then width = 0.05 else width = width
    if n_elements(gap) eq 0 then cgap = 0.02 else cgap = gap[0]
    case loc of
      'RIGHT' : begin
        position[0] = img_pos[2] + cgap
        position[2] = position[0] + width
      end

      'LEFT' : begin
        position[2] = img_pos[0] - cgap
        position[0] = position[2] - width
      end

      'TOP' : begin
        position[1] = img_pos[3] + cgap
        position[3] = position[1] + width
      end

      'BOTTOM' : begin
        position[3] = img_pos[1] - cgap
        position[1] = position[3] - width
      end

      else : message, 'LOCATION 확인'

    endcase

  endif






  ;;=============================== range setting ===============================
  if n_elements(range) ne 0 then begin
    dmin = min(range)
    dmax = max(range)

    if keyword_set(data_log) then begin
      if min(range) le 0 then message, 'RANGE 확인 0보다 작습니다.'
      dmin = alog10(dmin)
      dmax = alog10(dmax)
    endif

    if typename(target) eq 'IMAGE' or typename(target) eq 'CONTOUR' then begin
      target.min_value = dmin
      target.max_value = dmax
    endif
  endif else begin
    if typename(target) eq 'IMAGE' or typename(target) eq 'CONTOUR' then begin
      dmin = target.min_value
      dmax = target.max_value
    endif else begin
      dmin = 0
      dmax = 255
    endelse
  endelse


  if n_elements(dmin) ne 1 then begin
    print, 'DATA 가 RGB 형식이면 COLOR_BAR를 쓸수 없습니다.'
    return, !null
  endif


  if ~finite(dmin) or ~finite(dmax) then begin
    dmin = 0
    dmax = 255
  endif



  ;;================= make color bar image array ================
  img = bindgen(256)
  img = rebin(img, 256, 10)


  case loc of
    'RIGHT' : begin
      img = transpose(img)
      if keyword_set(data_log) then ylog = 1
      x = dindgen(10)
      y = linspace(dmin, dmax, 256)
    end

    'LEFT' : begin
      img = transpose(img)
      if keyword_set(data_log) then ylog = 1
      x = dindgen(10)
      y = linspace(dmin, dmax, 256)
    end

    'TOP' : begin
      if keyword_set(data_log) then xlog = 1
      y = dindgen(10)
      x = linspace(dmin, dmax, 256)
    end

    'BOTTOM' : begin
      if keyword_set(data_log) then xlog = 1
      y = dindgen(10)
      x = linspace(dmin, dmax, 256)
    end

    else : message, 'LOCATION 확인'


  endcase



  if n_elements(rgb_table) eq 0 then rgb = target.rgb_table else rgb = rgb_table

  c = image(img, x, y, $
    current = target, $
    aspect_ratio = 0, $
    position = position, $
    device = device, $
    rgb_table = rgb, $
    axis_style = 2, $
    xlog = xlog, $
    ylog = ylog, $
    _extra = _extra)



  ax = c.axes
  case loc of
    'RIGHT' :
    'LEFT' : ax = shift(ax, 2)
    'TOP' : ax = shift(ax, 1)
    'BOTTOM' : ax = shift(ax, -1)
  endcase


  for j = 0, 2 do ax[j].hide = 1
  ax[-1].setproperty, $
    showtext = 1, $
    ;title = title, $
    ticklen = 0.5

  c._extra = _extra

  return, c

end


