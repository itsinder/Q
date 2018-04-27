local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'

local function chk_params(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  x, -- lVector of length m
  exponent, -- Scalar
  alpha -- table of m Scalars (scale for different attributes)
  )
  -- START: Checking
  local nT = 0
  local nx = 0
  local nalpha = 0
  local n

  local sone = Scalar.new(1, "F4")
  --==============================================
  assert(type(exponent) == "Scalar")
  assert(exponent:fldtype() == "F4")
  assert(exponent >= sone)
  --=====================================
  assert(type(T) == "table")
  for k, v in pairs(T) do
    n = v:length()
    break
  end
  for k, v in pairs(T) do
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4")
    assert(n == v:length())
    nT = nT + 1
  end
  assert(utils.table_length(T) == nT)
  --=====================================
  assert(type(alpha) == "table")
  for k, v in pairs(alpha) do
    assert(type(v) == "Scalar")
    assert(v:fldtype() == "F4")
    nalpha = nalpha + 1
  end
  assert(#alpha == nalpha)
  --=====================================
  assert(type(x) == "table")
  for k, v in pairs(x) do 
    assert(type(v) == "Scalar")
    assert(v:fldtype() == "F4")
    nx = nx + 1
  end
  assert(#x == nx)
  --=====================================
  assert(nx == nT)
  assert(nalpha == nx)
  --=====================================
  assert(g:length() == n)
  assert(g:fldtype() == "I4")
  local minval, numval = Q.min(g):eval()
  assert(minval == Scalar.new(0, "I4"))
  local maxval, numval = Q.max(g):eval()
  local ng = maxval:to_num() - minval:to_num() + 1 -- number of values of goal attr
  assert(ng > 1)
  assert(ng <= 4) -- arbitary limit for now 
  --=====================================
  -- STOP : Checking
  return nT, n, ng
end

return chk_params
