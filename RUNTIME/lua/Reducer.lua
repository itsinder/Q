-- Coding convention. Local variables start with underscore
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local record_time = require 'Q/UTILS/lua/record_time'
local log = require 'Q/UTILS/lua/log'
local register_type = require 'Q/UTILS/lua/q_types'
local Reducer = {}
Reducer.__index = Reducer
local ffi = require 'Q/UTILS/lua/q_ffi'

setmetatable(Reducer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

register_type(Reducer, "Reducer")
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--   local otype = original_type( obj )
--   if  otype == "table" and getmetatable( obj ) == Reducer then
--     return "Reducer"
--   end
--   return otype
-- end

function Reducer.new(arg)
  local start_time = qc.RDTSC()
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
  record_time(start_time, "Reducer.new")
  return reducer
end

function Reducer:next()
  local start_time = qc.RDTSC()
  if self._gen == nil then return false end
  -- assert(self._gen ~= nil,  'Reducer: The reducer is materialized')
  local val = self._gen(self._index)
  self._index = self._index + 1
  if val ~= nil then
    self._value = val
  else
    self._gen = nil
  end
  record_time(start_time, "Reducer.next")
  return self._gen ~= nil
end

function Reducer:get_name()
  return self._name
end

function Reducer:set_name(value)
  assert( (value == nil) or ( type(value) == "string") )
  self._name = value
  return self
end

function Reducer:value()
  -- We are allowing user to obtain partial values
  local start_time = qc.RDTSC()
  assert(self._value ~= nil, "The reducer has not been evaluated yet")
  record_time(start_time, "Reducer.value")
  return self._func(self._value)
end

function Reducer:eval()
  local start_time = qc.RDTSC()
  local status = self._gen ~= nil
  while status == true do
    status = self:next()
  end
  record_time(start_time, "Reducer.eval")
  return self:value()
end

return Reducer
