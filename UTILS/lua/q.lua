local ffi = require "ffi"
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local q_root = os.getenv("Q_ROOT")
assert(plpath.isdir(q_root))

incfile = q_root .. "/include/q.h"
assert(plpath.isfile(incfile))
ffi.cdef(plfile.read(incfile))

sofile = q_root .. "/lib/libq.so"
assert(plpath.isfile(sofile))
local cee =  ffi.load(sofile)
local q = {}
local q_mt = {
   __newindex = function(self, key, value)
      print("newindex metamethod called")
      print(key, value)
      error("Assignment to q is not allowed")
   end,
   __index = function(self, key)
      -- Called only when the string we want to use is an
      -- entry in the table, so our variable names
      if key == "NULL" then
         return ffi.NULL
      else
         return cee[key]
      end
   end,
}
return setmetatable(q, q_mt)
