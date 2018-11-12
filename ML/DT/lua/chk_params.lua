local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'

local function chk_params(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha -- Scalar
  )
  -- START: Checking
  local nT = 0
  local n

  local sone = Scalar.new(1, "F4")
  --==============================================
  assert(type(T) == "table")
  -- Here, it's not sure that T is integer indexed table
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
  assert(type(alpha) == "Scalar")
  --=====================================
  assert(g:length() == n, tostring(g:length()) .. ", " .. tostring(n))
  assert(g:fldtype() == "I4")
  local minval, numval = Q.min(g):eval()
  -- TODO: do we require below assert - discuss with Ramesh
  -- assert(minval == Scalar.new(0, "I4"))
  local maxval, numval = Q.max(g):eval()
  local ng

  -- currently assuming g values to be 0 and 1
  local sum = Q.sum(g):eval()
  if sum:to_num() > 0 then
    ng = 2
  else
    ng = 1
  end
  --[[
  if maxval > minval then
    ng = maxval:to_num() - minval:to_num() + 1 -- number of values of goal attr
  else
    ng = maxval:to_num() + 1
  end
  ]]
  -- TODO: do we require below assert
  --assert(ng > 1)
  assert(ng <= 4) -- arbitary limit for now 
  --=====================================
  -- STOP : Checking
  return nT, n, ng
end

return chk_params
