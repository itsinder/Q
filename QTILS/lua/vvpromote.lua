-- local Q = require 'Q'

local T = {} 
local function vvpromote(x, y)
 -- TODO P1 to be written

  assert(x and type(x) == "lVector")
  assert(y and type(y) == "lVector")
  if ( x:fldtype() == y:fldtype() ) then 
    return x, y
  end
end
T.vvpromote = vvpromote
require('Q/q_export').export('vvpromote', vvpromote)
return T
