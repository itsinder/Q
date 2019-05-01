local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'

ffi.cdef([[ extern bool isfile ( const char * const ); ]])
local qc = ffi.load('libq_core')

local function basicSerialize (o)
    if type(o) == "number" or type(o) == "boolean" then
        return tostring(o)
    elseif type(o) == "string" then  
        return string.format("%q", o)
    else
        assert(nil)
    end
end

local function is_l_exception(k,v)
    if type(v) == "function" then return true end
    if type(v) == "cdata" then return true end
    return false
end

local function is_g_exception(k,v)
    if type(v) == "function" then return true end
    if type(v) == "cdata" then return true end
    if k == "coroutine" then return true end
    if k == "io" then return true end
    if k == "utils" then return true end
    if k == "Q" then return true end
    if k == "lVector" then return true end
    if k == "Vector" then return true end
    if k == "ffi" then return true end
    if k == "package" then return true end
    if k == "_G" then return true end
    if k == "jit" then return true end
    if k == "lfs" then return true end
    if k == "posix" then return true end
    if k == "q_core" then return true end
    if k == "q" then return true end
    if k == "math" then return true end
    if k == "table" then return true end
    if k == "os" then return true end
    if k == "string" then return true end
    if k == "debug" then return true end
    if k == "_VERSION" then return true end
    if k == "libs" then return true end
    if string.match(k, "^g_") then return true end
    if k == "bit" then return true end
    if k == "arg" then return true end
    if type(v) == "userdata" then return true end
    return false
end


-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function save(name, value, saved)
local function save(name, value, saved, file)
  if is_l_exception(name, value) then return end
  saved = saved or {}       -- initial value
  file = file or io
  if ( ( type(value) == "number" ) or ( type(value) == "string" ) or 
         ( type(value) == "boolean" ) ) then
      file:write(name, " = ")
      file:write(basicSerialize(value), "\n")
  elseif type(value) == "table" then
    file:write(name, " = ")
    if saved[value] then    -- value already saved?
      file:write(saved[value], "\n")  -- use its previous name
    else
      saved[value] = name   -- save name for next time
      file:write("{}\n")     -- create a new table
      for k, v in pairs(value) do      -- save its fields
        local fieldname = string.format("%s[%s]", name, basicSerialize(k))
                save(fieldname, v, saved, file)
      end
    end
  elseif ( type(value) == "lVector" ) then 
    -- TODO Indrajeet to check
    local persist_str = value:reincarnate()
    if ( persist_str ) then 
      file:write(name, " = ")
      file:write(persist_str)
      file:write("\n")
      save(name .. "._meta", value._meta, saved, file)
      file:write(name .. ":persist(true)")
      file:write("\n")
    else
      print("Not saving lVector because not eov or memo is set to false ", name)
    end
  elseif ( type(value) == "Scalar" ) then
    -- Currently not supported
    local scalar_str = value:reincarnate()
    file:write(name .. " = " .. scalar_str)
    file:write("\n")
  else
    error("cannot save " .. name .. " of type " .. type(value))
  end
end

local function save_global(file_to_save)
  
  local metadata_file
  if ( file_to_save ) then 
    metadata_file = file_to_save
  else
    metadata_file = qconsts.Q_METADATA_FILE
  end
  assert(type(metadata_file) == "string", "metadata file is not provided")
  local file_exists = qc.isfile(metadata_file)
  if ( file_exists == true ) then
    print("Warning! Over-writing meta data file ", metadata_file)
  end
  local fp = assert(io.open(metadata_file, "w+"), 
    "Unable to open file for writing" .. metadata_file)
  fp:write("local lVector = require 'Q/RUNTIME/lua/lVector'\n")
  fp:write("local Scalar  = require 'libsclr'\n")
  -- file:write("local Dictionary = require 'Dictionary'\n")

  local saved = {}
  -- TODO get requires in place to be added in v2 like require "Vector"
  for k,v in pairs(_G) do
      if not is_g_exception(k,v) then
        -- print("Saving ", k, v)
        save(k, v, saved, fp)
      end
  end
  fp:close()
  print("Saved to " .. metadata_file)
  return metadata_file
end
return require('Q/q_export').export('save', save_global)
