local plpath = require 'pl.path'
local plfile = require 'pl.file'
local ffi = require 'Q/UTILS/lua/q_ffi'

local Q_ROOT = os.getenv("Q_ROOT") -- TODO DISCUSS WITH SRINATH
local incfile = Q_ROOT .. "/include/q_core.h"
assert(plpath.isfile(incfile), "File not found " .. incfile)
ffi.cdef(plfile.read(incfile))
return ffi.load('libq_core.so')
