-- local dbg = require 'Q/UTILS/lua/debugger'
local pl_path = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'

local function restore_global(filename)

  local default_file_name = qconsts.default_meta_file
  if not filename then
    local metadata_file = os.getenv("Q_METADATA_FILE")
    if metadata_file then
      filename = metadata_file
    else
      filename = default_file_name
    end
  end

  assert(filename ~= nil, "A valid filename \\ filepath  has to be given")
  
  -- check does the (abs) valid filepath exists
  if not pl_path.isabs(filename) then
    -- append Q_METADATA_DIR if filename/ relative path is provided 
    filename = string.format("%s/%s", os.getenv("Q_METADATA_DIR"), filename)
  end

  -- checking for file existence
  assert(pl_path.exists(filename), "File not found " .. filename)
  
  local status, reason = pcall(dofile, filename)
  assert(status, reason)
end
return require('Q/q_export').export('restore', restore_global)
-- returning status(true or false)
