local Vector = require 'libvec'
local qconsts = require 'Q/UTILS/lua/q_consts'

-- input args are in the order below
-- M - metadata containing qtype, file_name, is_read_only, is_memo, num_elements depending on vector type (nascent / materialized)
return function( M )
  assert(M.qtype, "qtype is not provided")
  
  local field_size = qconsts.qtypes[M.qtype].width
  
  -- Check for SC type
  if M.qtype == "SC" then
    assert(M.field_size, "Field size is not provided for SC")
    assert(type(M.field_size) == "number", "Provided field_size is not number")
    M.qtype = "SC:" .. M.field_size
    field_size = M.field_size
  end
  
  -- Create Vector
  local status, x = pcall(Vector.new, M.qtype, M.file_name, M.is_memo, M.num_elements)
  if not status then
    print(x)
    x = nil
  end
  return x
end