local LD_LIBRARY_PATH = assert(os.getenv("LD_LIBRARY_PATH"), "LD_LIBRARY_PATH must be set")
local Q_ROOT = os.getenv("Q_ROOT") -- TODO DISCUSS WITH SRINATH
local Q_TRACE_DIR = os.getenv('Q_TRACE_DIR')

local compile = require 'Q/UTILS/lua/compiler'
-- local dbg = require 'Q/UTILS/lua/debugger'
local incfile = Q_ROOT .. "/include/q_core.h"
local inc_dir = Q_ROOT .. "/include/"
local ffi = require 'Q/UTILS/lua/q_ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'
local Logger = require 'Q/UTILS/lua/logger'
local lib_dir = Q_ROOT .. "/lib/"
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local pldir = require 'pl.dir'
local qconsts = require 'Q/UTILS/lua/q_consts'
local timer = require 'posix.time'

local trace_logger = Logger.new({outfile = Q_TRACE_DIR .. "/qcore.log"})
assert(plpath.isfile(incfile), "File not found " .. incfile)
ffi.cdef(plfile.read(incfile))
qc = ffi.load('libq_core.so')
local function_lookup = {}
local qt = {}
local libs = {}

local function load_lib(hfile)
  local file = hfile
  file = file:match('[^/]*$')
  assert(#file > 0, "filename must be valid")
  local function_name, subs = file:gsub("%.h$", "")
  assert(subs == 1, "Should be only one extension")
  local so_name = "lib" .. function_name .. ".so"
  if so_name ~= "libq_core.so" then
    local status, msg = pcall(ffi.cdef, plfile.read(hfile))
    if status then
      local status, q_tmp = pcall(ffi.load, so_name)
      if status then
        assert(function_lookup[function_name] == nil,
          "Library name is already declared: " .. function_name)
        libs[function_name] = q_tmp
        function_lookup[function_name] = libs[function_name][function_name]
      else
        print("Unable to load lib " .. so_name, q_tmp)
      end
    else
      print("Unable to load lib " .. so_name, msg)
    end
  end

end

----- Init Lookup ----
local function add_libs()
  local h_files = pldir.getfiles(Q_ROOT .. "/include", "*.h")
  local libs = {}
  for file_id=1,#h_files do
    load_lib(h_files[file_id])
  end
end

local function get_qc_val(val)
  return qc[val]
end

local function q_add(doth, dotc, function_name)
  -- the lib is absent or the doth is missing compile it
  assert(function_lookup[function_name] == nil and qt[function_name] == nil,
    "Function is already registered")
  if type(doth) == "table" then -- means this is subs and tmpl
    local subs, tmpl = doth, dotc
    doth = gen_code.doth(subs, tmpl)
    dotc = gen_code.dotc(subs, tmpl)
  end

  -- TODO document function_lookup
  local h_path = inc_dir .. function_name .. ".h"
  local so_path = lib_dir  .. "lib" .. function_name .. ".so"
  -- print("so path", so_path)
  if plpath.isfile(h_path) == false or plpath.isfile(so_path) == false then
    compile(doth, h_path, dotc, so_path, function_name)
  end
  load_lib(h_path)
  -- ffi.cdef(plfile.read(h_path))
 --  local q_tmp = ffi.load("lib" .. function_name .. ".so")

  --  function_lookup[function_name] = q_tmp

  -- function_lookup[function_name] = q_tmp[function_name]
  -- lib_table[#lib_table + 1] = q_tmp
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
      rawset(self,key, wrap(value , key))
    end
  end,
  __index = function(self, key)
    -- dbg()
    if key == "q_add" then return q_add end
    local func = function_lookup[key]
    -- dbg()
    if func ~= nil then
      return wrap(func, key) -- two layers of lookup as we are caching the whole c lib
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
