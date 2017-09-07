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
  assert(type(arg) == "table",
  "Reducer: Constructor needs a table as input argument. Instead got " .. type(arg))

  local reducer = setmetatable({}, Reducer)
  -- next_chunk is optional
  -- value is optional
  -- get_scalars is necessary
  assert(type(arg.get_scalars) == "function",
  "Reducer: Table must have arg [func] which must be a function used to extract reducer")
  reducer._get_scalars = arg.get_scalars

  if arg.next_chunk == nil then
    reducer._value= assert(arg.value, "cannot have a nil value if there is no method to generate new values")
  else
    reducer._next = arg.next_chunk
    reducer._value = arg._value
  end
  reducer._index = 0
  return reducer
end

function Reducer:next()
  assert(self._next ~= nil,  'Reducer: The reducer is materialized')
  local val = self._next(self._index)
  self._index = self._index + 1
  if val ~= nil then
    self._value = val
  else
    self._next = nil
  end
  return self._next ~= nil
end

function Reducer:value()
  -- We are allowing user to obtain partial values
  assert(self._value ~= nil, "The reducer has not been evaluated yet")
  return self._func(self._value)
end

function Reducer:eval()
  local status = self._next ~= nil
  while status == true do
    status = self:next()
  end
  return self:value()
end

return Reducer
