local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/KNN/lua/chk_params'

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

local function voting(
  T_train, -- table of m lVectors of length n_train
  T_test, -- table of m lVectors of length n_test
  alpha, -- lVector of length m
  exponent,  -- Scalar
  optargs
  )
  m_train, n_train, n_test = chk_params(
    T_train, T_test, alpha, exponent)
  
  c_T_train = CMEM.new()
  -- calc_vote_per_g(....)
  end
return alt_voting
