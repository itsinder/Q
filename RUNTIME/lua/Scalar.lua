-- Coding convention. Local variables start with underscore
local qconsts = require 'Q/UTILS/lua/q_consts'
local log = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Scalar = {}
Scalar.__index = Scalar
local ffi = require 'Q/UTILS/lua/q_ffi'

setmetatable(Scalar, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
  local otype = original_type( obj )
  if  otype == "table" and getmetatable( obj ) == Scalar then
    return "Scalar"
  end
  return otype
end

function Scalar.new(arg)
  assert(type(arg) == "table",
  "Scalar: Constructor needs a table as input argument. Instead got " .. type(arg))

  local scalar = setmetatable({}, Scalar)
  -- local field_type = assert(arg.field_type, "Scalar needs a type to be specified")
  -- assert(qconsts.qtypes[field_type] ~= nil, "Must be a valid field type")
  -- scalar._field_type = field_type

  if arg.next ~= nil then
    assert(type(arg.next) == "function",
    "Scalar: Table must have argument [next] which must be a function")
    assert(type(arg.func) == "function",
    "Scalar: Table must have arg [func] which must be a function used to extract scalar")
    scalar._next = arg.next
    scalar._func = arg.func
    scalar._index = 0
  else
    assert(arg.value ~= nil, "Need the [value] to be stored by scalar")
    scalar._func = function(x) return x end
    scalar._val = arg.value
  end
  return scalar
end

function Scalar:next()
  assert(self._next ~= nil,  'Scalar: The scalar is materialized')
  local val = self._next(self._index)
  self._index = self._index + 1
  if val ~= nil then
    self._val = val
  else
    self._next = nil
  end
  return self._next ~= nil
end

function Scalar:value()
  -- We are allowing user to obtain partial values
  assert(self._val ~= nil, "The scalar has not been evaluated yet")
  return self._func(self._val)
end

function Scalar:eval()
  local status = self._next ~= nil
  while status == true do
    status = self:next()
  end
  return self:value()
end

-- Commented out as scalar can return multiple values
-- function Scalar.__len(self)
--   return qconsts[self._field_type].width
-- end
-- 
-- function Scalar.__tostring(self)
--   local len qconsts[self.field_type]['max_txt_width']
--   local func = Q[qconsts[self_field_type]['ctype_to_txt']]
--   local mem = ffi.malloc(len)
--   return tostring(func(self:value(), mem, len))
-- end
return Scalar
