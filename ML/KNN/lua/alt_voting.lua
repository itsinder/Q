local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/KNN/lua/chk_params'

--=======================================
local function mk_ptrs(T, m)
  local c_T = CMEM.new(m * ffi.sizeof("float *"))
  i = 0
  for k, v in pairs(T) do
    local x_len, x_chunk, nn_x_chunk = x:get_all()
    c_T[i] = x_chunk
  end
  return c_T
end
--=======================================
local function chk_data(T)
  assert(type(T) == "table")
  local m = 0
  local n 
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4")
    if ( m == 0 ) then
      n = v:length()
      assert(n > 0)
    else
      assert(n == v:length())
    end
    m = m + 1 
  end
  assert(m > 0)
  return m, n
end
--=======================================
local function chk_params(
    T_train, 
    T_test, 
    alpha, 
    exponent
    )
  assert(type(alpha) == "lVector")
  assert(type(exponent) == "Scalar")
  local m_train, n_train = chk_data(T_train)
  local m_test,  n_test  = chk_data(T_test)
  return m_train, n_train, n_test
end
--=======================================
local function voting(
  T_train, -- table of m lVectors of length n_train
  T_test, -- table of m lVectors of length n_test
  alpha, -- lVector of length m
  exponent,  -- Scalar
  rslt_g, -- lVector of length n_test
  optargs
  )
  m, n_train, n_test = chk_params(
    T_train, T_test, alpha, exponent)
  
  local x_len, c_alpha, nn_x_chunk = alpha:get_all()
  local x_len, c_output, nn_x_chunk = alpha:get_all()
  c_train = mk_ptrs(T_train, m)
  c_test  = mk_ptrs(T_test, m)
  qc["calc_vote_per_g"](
    c_train, m, n_train, c_alpha, c_test, n_test, c_output)
  end
return alt_voting
