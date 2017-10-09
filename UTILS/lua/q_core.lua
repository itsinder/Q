local plpath = require 'pl.path'
local plfile = require 'pl.file'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Q_ROOT = os.getenv("Q_ROOT") -- TODO DISCUSS WITH SRINATH
local incfile = Q_ROOT .. "/include/q_core.h"
assert(plpath.isfile(incfile), "File not found " .. incfile)
ffi.cdef(plfile.read(incfile))
qc = ffi.load('libq_core.so')

if qconsts.debug == true then
  local qc_mt = {
    __newindex = function(self, key, value)
      rawset(self,key, value)
    end,
    __index = function(self, key)
      return qc[key]
    end
  }
  local qc_replacement = {}
  setmetatable(qc_replacement, qc_mt)
  return qc_replacement
else
  return qc
end
