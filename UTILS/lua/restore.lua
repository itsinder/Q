local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
-- TODO: Discuss with Ramesh, ffi can be removed
--ffi.cdef([[ extern bool isfile ( const char * const ); ]])
--local qc = ffi.load('libq_core')

local function restore(file_to_restore)
  assert(type(file_to_restore) == "string", "file name should be of type string")
  local metadata_file
  if ( file_to_restore ) then 
    metadata_file = file_to_restore
  else
    metadata_file = qconsts.DEFAULT_META_FILE
  end
  -- checking isfile present
  local fp = assert(io.open(metadata_file, 'r'),
      "Meta file not found = " .. file_to_restore)
  fp:close()
  local status, reason = pcall(dofile, metadata_file)
  return status, reason -- responsibility of caller
end
return require('Q/q_export').export('restore', restore)
