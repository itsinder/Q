local ffi = require 'ffi'
ffi.cdef([[ extern bool isfile ( const char * const ); ]])
local qc = ffi.load('libq_core')

local function restore(file_to_restore)

  local metadata_file 
  if ( file_to_restore ) then 
    metadata_file = file_to_restore
  else
    metadata_file = os.getenv("Q_METADATA_FILE")
  end
  assert(type(file_to_restore) == "string")
  assert(qc.isfile(file_to_restore), 
      "Meta file not found = " .. file_to_restore)

  local status, reason = pcall(dofile, filename)
  return status, reason -- responsibility of caller
end
return require('Q/q_export').export('restore', restore)
