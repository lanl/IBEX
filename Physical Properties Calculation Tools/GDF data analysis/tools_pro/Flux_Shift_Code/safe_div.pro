;=========================================================
;Code developed by Thomas K. Kim, PhD (thomaskim@lanl.gov, thomas.k.kim87@gmail.com)
;=========================================================
;Caution: For loops and indexing are different for IDL and Python!
;I've created this library package to avoid unwanted errors and gazillion unwated messages.

FUNCTION SAFE_DIV, X, Y

  X = SORT_FINITE(X)
  Y = SORT_FINITE(Y)

  DIV_VAL = DOUBLE(X/Y)

  RETURN, SORT_FINITE(DIV_VAL)

END
