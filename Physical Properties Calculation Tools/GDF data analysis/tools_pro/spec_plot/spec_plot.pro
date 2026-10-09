function linfit_spec, cax, newax

  compile_opt idl2, hidden

  s = value_locate(cax, newax) > 0L < (n_elements(cax)-2)
  return, (newax - cax[s]) / (cax[s+1] - cax[s]) + s

end




pro reconstruct_array, cdata, ax, dim, set_bd, bd, set_log, gap, interp

  compile_opt idl2, hidden

  if set_bd then begin

    mn = min([ax.flatten(), bd.flatten()], /nan, max=mx)
    newax = linspace(mn, mx, dim)
    new_img = make_array(dim, (cdata.dim)[1], value=!values.f_nan)

    if ax.ndim eq 2 then begin

      for j = 0, (cdata.dim)[1] - 1 do begin
        cbd = reform(bd[*, j, *])
        cax = reform(ax[*, j])
        ccd = reform(cdata[*, j])
        fini = where(finite(cax) and (total(finite(cbd), 2) eq 2) and finite(ccd))
        cax = cax[fini]
        cbd = cbd[fini, *]
        ccd = ccd[fini]
        idx = between(newax, cbd[*, 0], cbd[*, 1])
        for k = 0, n_elements(idx) - 1 do begin
          new_img[idx[k], j] = ccd[k]
        endfor
      endfor

    endif else begin

      fini = where(finite(ax) and (total(finite(bd), 2) eq 2))
      cax = ax[fini]
      cbd = bd[fini, *]
      ccd = cdata[fini, *]

      s = sort(cax)
      cax = cax[s]
      cbd = cbd[s, *]
      ccd = ccd[s, *]

      uni = uniq(cax)
      cax = cax[uni]
      cbd = cbd[uni, *]
      ccd = ccd[uni, *]


      idx = between(newax, cbd[*, 0], cbd[*, 1])
      for j = 0, n_elements(idx) - 1 do begin
        cidx = idx[j]
        tmp = ccd[j, *]

        for k = 0, n_elements(cidx) - 1 do begin
          new_img[cidx[k], *] = tmp
        endfor
      endfor

    endelse


    cdata = temporary(new_img)
    ax = temporary(newax)

  endif else begin

    if ax.ndim eq 1 then begin
      s = sort(ax)
      ax = ax[s]
      cdata = cdata[s, *]

      uni = uniq(ax)
      ax = ax[uni]
      cdata = cdata[uni, *]

      if keyword_set(set_log) then begin
        con = where(ax gt 0, cnt)
        if cnt le 1 then message, 'y 축 값 확인'

        ax = ax[con]
        cdata = cdata[con, *]
      endif

      if n_elements(gap) eq 1 then begin
        dgap = ax[1:*] - ax[0:-2]
        gap_idx = where(dgap gt gap[0], cnt, /null)
        if cnt ge 1 then begin

          val = (ax[gap_idx] + ax[gap_idx+1])/2
          tmp = lindgen(cnt)+1

          gap_idx += tmp
          ax = insert_array(ax, val, gap_idx)
          cdata = insert_array(cdata, !values.f_nan, gap_idx, 0)
        endif
      endif


      if keyword_set(set_log) then begin
        ax = alog10(ax)
      endif

      mn = min(ax, max=mx)
      newax = linspace(mn, mx, dim)

      ;idx = interpol(dindgen(ax.length), ax, newax)
      idx = linfit_spec(ax, newax)
      if n_elements(gap_idx) ge 1 then begin
        if keyword_set(set_log) then begin
          tmp = between(10^newax, 10^ax[gap_idx-1], 10^ax[gap_idx+1])
        endif else begin
          tmp = between(newax, ax[gap_idx-1], ax[gap_idx+1])
        endelse
        con = where(tmp ne !null, cnt)
        if cnt eq 0 then begin
          tmp = !null
        endif else begin
          tmp = (tmp[con]).toarray(dim=1)
        endelse
        idx[tmp] = -999
      endif

      if ~keyword_set(interp) then idx = round(idx)

      new_img = interpolate(cdata, idx, lindgen((cdata.dim)[1]), /grid, missing=!values.f_nan)

      cdata = temporary(new_img)
      ax = temporary(newax)

    endif else begin

      new_img = make_array(dim, (cdata.dim)[1], value=!values.f_nan)

      if keyword_set(set_log) then begin
        cax = ax
        bad = where(~finite(cax), cnt)
        if cnt ne 0 then cax[bad] = -999
        good = where(cax gt 0, complement=bad)
        cax[good] = alog10(cax[good])
        cax[bad] = !values.f_nan
        ax[bad] = !values.f_nan
        newax = linspace(min(cax, /nan), max(cax, /nan), dim)

        cax = 0

      endif else begin
        mn = min(ax, /nan, max=mx)
        newax = linspace(mn, mx, dim)
      endelse


      for j = 0, (cdata.dim)[1] - 1 do begin

        cax = ax[*, j]
        ccd = cdata[*, j]

        s = sort(cax)
        cax = cax[s]
        ccd = ccd[s]

        fini = where(finite(cax), cnt)
        if cnt le 1 then continue
        cax = cax[fini]
        ccd = ccd[fini]

        uni = uniq(cax)
        cax = cax[uni]
        ccd = ccd[uni]

        if n_elements(gap) eq 1 then begin
          tmp = cax[1:*] - cax[0:-2]
          con = where(tmp gt gap[0], cnt)
          if cnt ge 1 then begin
            val = (cax[con] + cax[con+1])/2
            tmp = lindgen(cnt)+1

            con += tmp
            cax = insert_array(cax, val, con)
            ccd = insert_array(ccd, !values.f_nan, con)
          endif
        endif

        if keyword_set(set_log) then begin
          cax = alog10(cax)
        endif

        idx = linfit_spec(cax, newax)
        ;;;idx = interpol(dindgen(cax.length), cax, newax)

        if ~keyword_set(interp) then idx = round(idx)
        new_img[0, j] = reform(interpolate(transpose(ccd), 0, idx, missing=!values.f_nan, /grid))

      endfor

      cdata = temporary(new_img)
      ax = temporary(newax)

    endelse
  endelse

end












function spec_plot, data, xaxis, yaxis, $
  xrange = xrange, $
  yrange = yrange, $
  xlog = xlog, $
  ylog = ylog, $
  data_log = data_log, $
  data_max = data_max, $
  data_min = data_min, $
  position = position, $
  device = device, $
  rgb_table = rgb_table, $
  current = current, $
  window = window, $
  buffer = buffer, $
  xgap = xgap, $
  ygap = ygap, $
  interp = interp, $
  overplot = overplot, $
  xbound = xbound, $
  ybound = ybound, $
  xdim = xdim, $
  ydim = ydim, $
  aspect_ratio = aspect_ratio, $
  rgb_reverse = rgb_reverse, $
  _extra = _extra


  compile_opt idl2


  if n_params() eq 0 or n_params() eq 2 then message, 'DATA, x, y 를 모두 넣어 주세요'

  ;; data, axis dimension 확인
  cdata = reform(data)
  if cdata.ndim ne 2 then message, 'data 는 2 차원이어야 합니다.'


  if n_elements(xaxis) eq 0 then xaxis = dindgen((cdata.dim)[0])
  cx = reform(xaxis)



  if n_elements(yaxis) eq 0 then yaxis = dindgen((cdata.dim)[1])
  cy = reform(yaxis)



  if n_elements(xbound) ne 0 then begin
    xbd = reform(xbound)
    set_xbd = 1
    if cx.ndim eq 2 then begin
      flag = (xbd.ndim ne 3) or ((xbd.dim)[-1] ne 2) or ~array_equal(cx.dim, (xbd.dim)[0:1])
      if flag then message, 'X bound의 dimension을 확인해 주세요'
    endif
    if cx.ndim eq 1 then begin
      flag = (xbd.ndim ne 2) or ((xbd.dim)[-1] ne 2) or ~array_equal(cx.dim, (xbd.dim)[0])
      if flag then message, 'X bound의 dimension을 확인해 주세요'
    endif
  endif else set_xbd = 0




  if n_elements(ybound) ne 0 then begin
    ybd = reform(ybound)
    set_ybd = 1
    if cy.ndim eq 2 then begin
      flag = (ybd.ndim ne 3) or ((ybd.dim)[-1] ne 2) or ~array_equal(cy.dim, (ybd.dim)[0:1])
      if flag then message, 'Y bound의 dimension을 확인해 주세요'
    endif
    if cy.ndim eq 1 then begin
      flag = (ybd.ndim ne 2) or ((ybd.dim)[-1] ne 2) or ~array_equal(cy.dim, (ybd.dim)[0])
      if flag then message, 'Y bound의 dimension을 확인해 주세요'
    endif
  endif else set_ybd = 0



  if cx.ndim eq 2 and cy.ndim eq 2 then message, 'Xaxis와 Yaxis 는 모두 2차원이어서는 안됩니다.'



  if keyword_set(xlog) and set_xbd then begin

    cx[where(cx le 0, /null)] = !values.f_nan
    cx = alog10(cx)
    fini = where(finite(cx), cnt)
    if cnt le 1 then message, 'X 축 값 확인, LOG 스케일을 설정하였지만 모두 음수이거나 0 입니다.'

    xbd[where(xbd le 0, /null)] = !values.f_nan
    xbd = alog10(xbd)
  endif


  if keyword_set(ylog) and set_ybd then begin
    cy[where(cy le 0, /null)] = !values.f_nan
    cy = alog10(cy)
    fini = where(finite(cy), cnt)
    if cnt le 1 then message, 'y 축 값 확인, LOG 스케일을 설정하였지만 모두 음수이거나 0 입니다.'

    ybd[where(ybd le 0, /null)] = !values.f_nan
    ybd = alog10(ybd)
  endif

  if n_elements(xgap) eq 1 and ~set_xbd then cxgap = xgap
  if n_elements(ygap) eq 1 and ~set_ybd then cygap = ygap









  ;; default rgb_table
  if n_elements(rgb_table) eq 0 then begin
    rgb_table = colortable(39)
    rgb_table = rgb_table[0:-10, *]
    rgb_table = congrid(rgb_table, 256, 3, /interp)
  endif else begin
    rgb_table = colortable(rgb_table)
    rgb_table = rgb_table[0:-10, *]
    rgb_table = congrid(rgb_table, 256, 3, /interp)
  endelse

  if keyword_set(rgb_reverse) then begin
    rgb_table = reverse(rgb_table, 1)
  endif


  ; get window
  if keyword_set(overplot) then spec_window = getwindows(/current)

  if obj_valid(spec_window) eq 0 then begin
    if typename(current) eq 'UNDEFINED' then spec_window = window(dim=[800, 500], buffer=buffer, loc=[0,0])
    if typename(current) eq 'GRAPHICSWIN' or typename(current) eq 'GRAPHICSBUFFER' then spec_window = current
    if isa(current, /scalar, /num) eq 1 then spec_window = getwindows(/current)
  endif
  if obj_valid(spec_window) eq 0 then spec_window = window(dim=[800, 500], buffer=buffer, loc=[0,0])

  windim = spec_window.dimension


  ;; default position
  if n_elements(position) eq 0 then begin
    pos = [0.15, 0.15, 0.78,0.85]
  endif else begin
    pos = double(position)
    if keyword_set(device) then pos /= [windim, windim]
  endelse




  if n_elements(xdim) eq 0 then xdim = round((pos[2] - pos[0])*windim[0])
  if n_elements(ydim) eq 0 then ydim = round((pos[3] - pos[1])*windim[1])



  nax_x = (reform(xaxis)).ndim
  nax_y = (reform(yaxis)).ndim

  if (nax_x eq 2) and (nax_y eq 1) then begin
    reconstruct_array, cdata, cx, xdim, set_xbd, xbd, xlog, cxgap, interp
    cdata = transpose(cdata)
    reconstruct_array, cdata, cy, ydim, set_ybd, ybd, ylog, cygap, interp
    cdata = transpose(cdata)
  endif


  if (nax_x eq 1) and (nax_y eq 2) then begin
    cy = transpose(cy)
    if set_ybd then ybd = transpose(ybd, [1, 0, 2])
    cdata = transpose(cdata)
    reconstruct_array, cdata, cy, ydim, set_ybd, ybd, ylog, cygap, interp
    cdata = transpose(cdata)
    reconstruct_array, cdata, cx, xdim, set_xbd, xbd, xlog, cxgap, interp
  endif

  if (nax_x eq 1) and (nax_y eq 1) then begin
    reconstruct_array, cdata, cx, xdim, set_xbd, xbd, xlog, cxgap, interp
    cdata = transpose(cdata)

    reconstruct_array, cdata, cy, ydim, set_ybd, ybd, ylog, cygap, interp
    cdata = transpose(cdata)
  endif



  if keyword_set(data_log) then begin
    cdata[where(~finite(cdata), /null)] = -999
    good = where(cdata gt 0, complement=bad, cnt_good, ncomplement=cnt_bad)
    if cnt_good ne 0 then cdata[good] = alog10(cdata[good])
    if cnt_bad ne 0 then cdata[bad] = !values.f_nan
  endif



  if keyword_set(data_log) then begin

    if n_elements(data_max) eq 1 then begin
      max_value = alog10(data_max)
      if data_max le 0 then max_value = max(alog10(cdata), /nan)
    endif else max_value = max(cdata, /nan)

    if n_elements(data_min) eq 1 then begin
      min_value = alog10(data_min)
      if data_min le 0 then min_value = min(alog10(cdata), /nan)
    endif else min_value = min(cdata, /nan)

  endif else begin


    if n_elements(data_max) eq 1 then begin
      max_value = data_max
    endif else max_value = max(cdata, /nan)

    if n_elements(data_min) eq 1 then begin
      min_value = data_min
    endif else min_value = min(cdata, /nan)

  endelse

  ;
  ;  if n_elements(data_max) eq 1 then begin
  ;    if keyword_set(data_log) then begin
  ;      max_value = alog10(data_max)
  ;    endif else begin
  ;      max_value = data_max
  ;    endelse
  ;  endif else begin
  ;    max_value = max(cdata, /nan)
  ;  endelse
  ;
  ;
  ;  if n_elements(data_min) eq 1 then begin
  ;    if keyword_set(data_log) then begin
  ;      min_value = alog10(data_min)
  ;    endif else begin
  ;      min_value = data_min
  ;    endelse
  ;  endif else begin
  ;    min_value = min(cdata, /nan)
  ;  endelse



  ;; default axis
  if n_elements(axis) eq 0 then axis = 2

  if n_elements(aspect_ratio) eq 0 then aspect_ratio = 0


  i = image(cdata[0:-2, 0:-2], cx[0:-2], cy[0:-2], $
    current = spec_window, $
    pos = pos, $
    aspect_ratio = aspect_ratio, $
    rgb_table = rgb_table, $
    axis = axis, $
    ylog = ylog, $
    xlog = xlog, $
    overplot = overplot, $
    xrange = xrange, $
    yrange = yrange, $
    min_value = min_value, $
    max_value = max_value, $
    _extra = _extra)


  return, i
end


