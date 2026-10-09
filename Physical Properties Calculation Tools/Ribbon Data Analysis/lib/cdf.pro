;
; Default n_interpol = 100
function CDF, x, n_interpol = n_interpol
  if keyword_set(n_interpol) then n_interpol = n_interpol else n_interpol = 1000
  
  x = x[where(finite(x))]

  x = x[sort(x)]

  y_cumul = total(replicate(1d, x.length), /cumul)
  y_cumul = y_cumul/max(y_cumul)

  x_new = linspace(x[0], x[-1], n_interpol)
  y_cumul_new = interpol(y_cumul, x, x_new, /nan)

  y_pdf_new = deriv(x_new, y_cumul_new)

  return, {x:x, y_cumul:y_cumul, x_new:x_new, y_cumul_new:y_cumul_new, y_pdf_new:y_pdf_new}
end