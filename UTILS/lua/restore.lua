-- local dbg = require 'Q/UTILS/lua/debugger'
local pl_path = require 'pl.path'
local function restore_global(filename)
  if ( not filename ) then
    filename = os.getenv("Q_METADATA_FILE")
  end
  assert(filename ~= nil, "A valid filename \\ filepath  has to be given")
  
  -- check does the (abs) valid filepath exists
  if not pl_path.isabs(filename) then
    -- append Q_METADATA_DIR if filename/ relative path is provided 
    filename = string.format("%s/%s", os.getenv("Q_METADATA_DIR"), filename)
  end

  -- checking for file existence
  assert(pl_path.exists(filename), "Give a valid filename")
  
  local status, reason = pcall(dofile, filename)
  assert(status, reason)
end
return require('Q/q_export').export('restore', restore_global)
-- returning status(true or false)
