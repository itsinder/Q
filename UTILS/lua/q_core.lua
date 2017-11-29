local plpath = require 'pl.path'
local plfile = require 'pl.file'
local pldir = require 'pl.dir'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Q_ROOT = os.getenv("Q_ROOT") -- TODO DISCUSS WITH SRINATH
local Q_TRACE_DIR = os.getenv('Q_TRACE_DIR')
local inc_dir = Q_ROOT .. "/include/"
local LD_LIBRARY_PATH = assert(os.getenv("LD_LIBRARY_PATH"), "LD_LIBRARY_PATH must be set")
local lib_dir = LD_LIBRARY_PATH:sub(LD_LIBRARY_PATH:find('[^:]*$')) .. "/"
local incfile = Q_ROOT .. "/include/q_core.h"
local compile = require 'Q/UTILS/lua/compiler'
local Logger = require 'Q/UTILS/lua/logger'
local timer = require 'posix.time'

local trace_logger = Logger.new({outfile = Q_TRACE_DIR .. "/qcore.log"})
-- local dbg = require 'Q/UTILS/lua/debugger'
assert(plpath.isfile(incfile), "File not found " .. incfile)
ffi.cdef(plfile.read(incfile))
qc = ffi.load('libq_core.so')
local function_lookup = {}
local qt = {}

----- Init Lookup ----
local function add_libs()
  local h_files = pldir.getfiles(Q_ROOT .. "/include", "*.h")
  local libs = {}
  for file_id=1,#h_files do
    local file = h_files[file_id]
    file = file:match('[^/]*$')
    assert(#file > 0, "filename must be valid")
    local lib_name, subs = file:gsub("%.h$", "")
    assert(subs == 1, "Should be only one extension")
    local so_name = "lib" .. lib_name .. ".so"
    if so_name ~= "libq_core.so" then
      ffi.cdef(plfile.read(h_files[file_id]))
      local q_tmp = ffi.load(so_name)
      assert(function_lookup[lib_name] == nil,
      "Library name is already declared: " .. lib_name)
      function_lookup[lib_name] = q_tmp[lib_name]
    end
  end
end

local function get_qc_val(val)
  return qc[val]
end

local function q_add(doth, dotc, lib_name)
  -- the lib is absent or the doth is missing compile it
  if  function_lookup[lib_name] == nil and qt[lib_name] == nil then
    local h_path = inc_dir .. lib_name .. ".h"
    local so_path = lib_dir .. "lib" .. lib_name .. ".so"
    if plpath.isfile(h_path) == false or plpath.isfile(so_path) == false then
      compile(doth, h_path, dotc, so_path, lib_name)
    end
    ffi.cdef(plfile.read(h_path))
    local q_tmp = ffi.load("lib" .. lib_name .. ".so")
    function_lookup[lib_name] = q_tmp[lib_name]
    return true
  else
    return false
  end
end

local function wrap(func, name)
  if qconsts.qc_trace == false then
    return func
  end

  return function(...)
    local start_time, stop_time
    start_time = timer.clock_gettime(0)
    local tbl = table.pack(func(...))
    stop_time = timer.clock_gettime(0)
    local time =  (stop_time.tv_sec*10^6 +stop_time.tv_nsec/10^3 - (start_time.tv_sec*10^6 +start_time.tv_nsec/10^3))/10^6
    trace_logger:trace(name, time)
    -- print("time taken", time)
    if tbl.n == 0 then
      return nil
    else
      return unpack(tbl)
    end
  end
end

local qc_mt = {
  __newindex = function(self, key, value)
    if qconsts.debug == true then
      rawset(self,key, wrap(value , key + '_override'))
    end
  end,
  __index = function(self, key)
    if key == "q_add" then return q_add end
    local func = function_lookup[key]
    if func ~= nil then
      return wrap(func, key)
    else
      local status, fun = pcall(get_qc_val, key)
      if status == true then
        return wrap(fun, key)
      else
        return nil
      end
    end
  end
}
setmetatable(qt, qc_mt)
add_libs()
return qt
