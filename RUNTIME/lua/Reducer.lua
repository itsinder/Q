-- Coding convention. Local variables start with underscore
local qconsts = require 'Q/UTILS/lua/q_consts'
local log = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Reducer = {}
Reducer.__index = Reducer
local ffi = require 'Q/UTILS/lua/q_ffi'

setmetatable(Reducer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
  local otype = original_type( obj )
  if  otype == "table" and getmetatable( obj ) == Reducer then
    return "Reducer"
  end
  return otype
end

function Reducer.new(arg)
  assert(arg.coro == nil, "Migrate code to reducer style, where gen, func, value must be specified")
  assert(type(arg) == "table",
  "Reducer: Constructor needs a table as input argument. Instead got " .. type(arg))

  local reducer = setmetatable({}, Reducer)
  -- gen is optional
  -- value is optional
  -- func is necessary
  assert(type(arg.func) == "function",
  "Reducer: Table must have arg [func] which must be a function used to extract reducer")
  reducer._get_scalars = arg.get_scalars

  if arg.gen == nil then
    reducer._value= assert(arg.value, "value cannot be nil if there is no method to generate new values")
  else
    assert(type(arg.func) == "function", "Function expected to extract scalars")
    reducer._func = arg.func
    reducer._value = arg._value
    reducer._gen = arg.gen
  end
  reducer._index = 0
  return reducer
end

function Reducer:next()
  if self._gen == nil then return false end
  -- assert(self._gen ~= nil,  'Reducer: The reducer is materialized')
  local val = self._gen(self._index)
  self._index = self._index + 1
  if val ~= nil then
    self._value = val
  else
    self._gen = nil
  end
  return self._gen ~= nil
end

function Reducer:value()
  -- We are allowing user to obtain partial values
  assert(self._value ~= nil, "The reducer has not been evaluated yet")
  return self._func(self._value)
end

function Reducer:eval()
  local status = self._gen ~= nil
  while status == true do
    status = self:next()
  end
  return self:value()
end

return Reducer