local lVector = require 'Q/RUNTIME/lua/lVector'

-- input argument is metadata required for lVector 
return function( M )
  assert(M.qtype, "qtype is not provided")
  local status, x = pcall(lVector,  M)
  if not status then
    print(x)
    x = nil
  end
  return x
end
