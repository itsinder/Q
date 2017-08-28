local lVector = require 'Q/experimental/lua-515/c_modules/lVector'



-- input argument is metadata required for lVector 
return function( M )
  assert(M.qtype, "qtype is not provided")
  local x = lVector( M )
  return x
end