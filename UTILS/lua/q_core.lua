local plpath = require 'pl.path'
local plfile = require 'pl.file'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Q_ROOT = os.getenv("Q_ROOT") -- TODO DISCUSS WITH SRINATH
local inc_dir = Q_ROOT .. "/include/"
local LD_LIBRARY_PATH = assert(os.getenv("LD_LIBRARY_PATH"), "LD_LIBRARY_PATH must be set")
local lib_dir = LD_LIBRARY_PATH:sub(LD_LIBRARY_PATH:find('[^:]*$')) .. "/"
local incfile = Q_ROOT .. "/include/q_core.h"
local compile = require 'Q/UTILS/lua/compiler'

local dbg = require 'Q/UTILS/lua/debugger'
assert(plpath.isfile(incfile), "File not found " .. incfile)
ffi.cdef(plfile.read(incfile))
qc = ffi.load('libq_core.so')
local function_lookup = {}
local qt = {}

local function get_qc_val(val)
  return qc[val]
end

local function q_add(doth, dotc, lib_name)
  -- the lib is absent or the doth is missing compile it
  if  function_lookup[lib_name] == nil and qt[lib_name] == nil then
    local h_path = inc_dir .. lib_name .. ".h"
    local so_path = lib_dir .. "lib" .. lib_name .. ".so"
    if plpath.isfile(h_path) == false or plpath.isfile(so_path) == false then
      compile(doth, dotc, lib_name)
    end
    ffi.cdef(plfile.read(h_path))
    local q_tmp = ffi.load("lib" .. lib_name .. ".so")
    function_lookup[lib_name] = q_tmp[lib_name]
    return true
  else
    return false
  end
end
local qc_mt = {
  __newindex = function(self, key, value)
    if qconsts.debug == true then
      rawset(self,key, value)
    end
  end,
  __index = function(self, key)
    if key == "q_add" then return q_add end
    local func = function_lookup[key]
    if func ~= nil then
      return func
    else
      local status, fun = pcall(get_qc_val, key)
      if status == true then
        return fun
      else
        return nil
      end
    end
  end
}
setmetatable(qt, qc_mt)
return qt
