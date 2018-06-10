local Q = require 'Q'
local Scalar = require 'libsclr'
local cmem = require 'libcmem'
local ffi = require 'Q/UTILS/lua/q_ffi'
local chk_params = require 'Q/ML/KNN/lua/chk_params'
local plfile = require 'pl.file' -- TEMPORARY
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local hdr = plfile.read("../inc/calc_vote_per_g.h")
ffi.cdef(hdr)
local libc = ffi.load("../src/calc_vote_per_g.so")

--=======================================
local function mk_ptrs(T, m, name)
  assert(m > 0)
  local sz = m * ffi.sizeof("float *")
  -- TODO: P2 Using CMEM below causes a crash. Why?
  local c_T = ffi.gc(ffi.C.malloc(sz), ffi.C.free)
  c_T = ffi.cast("float ** ", c_T)
  i = 0
  for attr, vec in pairs(T) do
    local a, x_chunk, b = vec:get_all()
    c_T[i] = ffi.cast("float *",  get_ptr(x_chunk))
    i = i + 1
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
local function alt_voting(
  T_train, -- table of m lVectors of length n_train
  m,
  n_train,
  alpha, -- lVector of length m
  T_test, -- table of m lVectors of length n_test
  n_test,
  output, -- lVector of length n_test
  optargs
  )
  --[[
  m, n_train, n_test = chk_params(
    T_train, T_test, alpha, exponent)
    --]]
  
  local _, c_alpha,  _ = alpha:get_all()
  c_alpha= ffi.cast("float *",  get_ptr(c_alpha))

  local _, c_output, _ = output:start_write()
  c_output= ffi.cast("float *",  get_ptr(c_output))

  c_train = mk_ptrs(T_train, m, "train")
  c_test  = mk_ptrs(T_test, m, "test")
  libc.calc_vote_per_g(
    c_train, m, n_train, c_alpha, c_test, n_test, c_output)
  output:end_write()
  end
return alt_voting


