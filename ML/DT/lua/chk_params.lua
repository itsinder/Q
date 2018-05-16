local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'

local function chk_params(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha -- Scalar F4 > 0
  )
  -- START: Checking
  local nT = 0

  local sone = Scalar.new(1, "F4")
  --==============================================
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
  assert(nT > 0)
  assert(utils.table_length(T) == nT)
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
  assert(type(alpha) == "Scalar")
  assert(alpha > 0 )
  --=====================================
  -- STOP : Checking
  return nT, n, ng
end

return chk_params
