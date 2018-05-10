local Scalar = require 'libsclr'

local T = {}

local function avg(x)
  local Q = require 'Q'
  assert(x and type(x) == "lVector", "input must be of type lVector")
  local sum, count = Q.sum(x):eval()
  local avg
  if count:to_num() > 0 then
    -- TODO: use scalar division
    local avg = sum:to_num() / count:to_num()
    local z = Scalar.new(avg, "F8")
    return z
  else
    return nil
  end
end
T.avg = avg
require('Q/q_export').export('avg', avg)
return T
