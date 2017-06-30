local crange = {}
    crange.I1 = {
      min_val = 'SCHAR_MIN',
      max_val = 'SCHAR_MAX'
    }
    crange.I2 = {
      min_val = 'SHRT_MIN',
      max_val = 'SHRT_MAX'
    }
    crange.I4 = {
      min_val = 'INT_MIN',
      max_val = 'INT_MAX'
    }
    crange.I8 = {
      min_val = 'LLONG_MIN',
      max_val = 'LLONG_MAX'
    }
    crange.F4 = {
      min_val = 'FLT_MIN',
      max_val = 'FLT_MAX'
    }
    crange.F8 = {
      min_val = 'DBL_MAX',
      max_val = 'DBL_MIN'
    }
return crange
