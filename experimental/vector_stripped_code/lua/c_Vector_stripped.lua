--local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'lua/q_ffi'
local qc      = require 'lua/q_core'

local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

function Vector.new(arg)
  local vec = setmetatable({}, Vector)
  --local qtype = assert(arg.field_type, "must specify fldtype for vector")
  local fldsz = 4
  vec._vec = ffi.malloc(ffi.sizeof("VEC_REC_TYPE"), qc.vec_free)
  vec._vec = ffi.cast("VEC_REC_TYPE *", vec._vec)
  qc.vec_new(vec._vec, "", fldsz, 64 * 1024)
  print("Created vec")
  return vec
end

function Vector:set(addr, idx, len)
  if ( idx == nil ) then idx = 0 end 
  addr = ffi.cast("char *", addr)
  qc.vec_set(self._vec, addr, idx, len)
end

return Vector
