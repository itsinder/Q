--==== From https://www.lua.org/pil/12.1.2.html
-- local -- dbg = require 'Q/UTILS/lua/debugger'
local plpath = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'

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
      for k,v in pairs(value) do      -- save its fields
        local fieldname = string.format("%s[%s]", name, basicSerialize(k))
                save(fieldname, v, saved, file)
      end
    end
  elseif ( type(value) == "lVector" ) then 
    -- TODO Indrajeet to check
    file:write(name, " = ")
    local persist_str = value:reincarnate()
    if ( persist_str ) then 
      file:write(persist_str)
      file:write("\n")
      save(name .. "._meta", value._meta, saved, file)
      file:write(name .. ":persist(true)")
      file:write("\n")
    else
      print("Not saving lVector because not eov ", name)
    end
  elseif ( type(value) == "Scalar" ) then
    -- Currently not supported
  else
    error("cannot save " .. name .. " of type " .. type(value))
  end
end

local function save_global(filename)
  --[[
  Q.save() works as below
  - if filename arg is provided and
      - if it's a absolute path then continues using provided filename
      - if not a absolute path then prepends $HOME/local/Q/meta to filepath
  - if filename arg is not provided then checks for the Q_METADATA_FILE env variable,
  - if Q_METADATA_FILE variable is set then uses this path or else uses default path present in q_consts.lua ($HOME/local/Q/meta/saved.meta)
  ]]
  --[[
  Q.save("/tmp/saved.meta") : passing absolute path as argument saves the state at given location in the given file
  Q.save("saved.meta")      : passing filename saves the state at default location (prepends $HOME/local/Q/meta to filename)
                              in the given file
  Q.save()                  : without passing filename saves at qconsts.default_meta_file location 
                              which points to "$HOME/local/Q/meta/saved.meta" value
      -- if Q_METADATA_FILE is set, then it saves the file at the location specified in Q_METADATA_FILE environment variable
      -- if Q_METADATA_FILE is not set, then it saves the state at the default location 
        specified by the qconsts.default_meta_file  variable which points to "$HOME/local/Q/meta/saved.meta" value
]]
  
  local default_file_name = qconsts.default_meta_file
  if not filename then
    local metadata_file = os.getenv("Q_METADATA_FILE")
    if metadata_file then
      filename = metadata_file
    else
      filename = default_file_name
    end
  end
  -- check does the (abs) valid filepath exists
  if not plpath.isabs(filename) then
    -- prepend '$HOME/local/Q/meta' path to file name, 
    -- we are not going to use Q_METADATA_DIR env variable in Q
    filename = string.format("%s/%s", plpath.dirname(qconsts.default_meta_file), filename)
  end
   
  -- TODO: what if file already exists, for now it overrides (w+) the file 
  local file = assert(io.open(filename, "w+"), "Unable to open file for writing")
  file:write("local lVector = require 'Q/RUNTIME/lua/lVector'\n")
  -- file:write("local Vector = require 'libvector'\n")
  -- file:write("local Dictionary = require 'Dictionary'\n")

  local saved = {}
  -- TODO get requires in place to be added in v2 like require "Vector"
  for k,v in pairs(_G) do
      if not is_g_exception(k,v) then
        -- print("Saving ", k, v)
        save(k, v, saved, file)
      end
  end
  file:close()
  print("Saved to " .. filename)
  return filename
end
return require('Q/q_export').export('save', save_global)
--return save_global
