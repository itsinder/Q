local Scalar = require 'libsclr'
local function to_scalar(x, qtype)
  assert(x, "must provide an input value")
  assert(qtype, "must provide qtype for Scalar")
  local retval 
  if ( ( type(x) == "number") or ( type(x) == "string" ) ) then 
    retval = assert(Scalar.new(x, qtype), "bad value for Scalar")
    return retval
  elseif ( type(x) == "Scalar") then 
    -- see if you can promote to desired type
    return x:conv(qtype)
  else
    assert(nil, "bad value for Scalar")
  end
end
return to_scalar
