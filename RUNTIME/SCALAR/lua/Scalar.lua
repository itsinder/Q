local log = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Scalar = {}
Scalar.__index = Scalar
local ffi = require 'Q/UTILS/lua/q_ffi'
local DestructorLookup = {}

setmetatable(Scalar, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

function Scalar.destructor(data)
    -- Works with Lua but not luajit so adding a little hack
    if type(data) == type(Scalar) then
        ffi.free(data.destructor_ptr)
        DestructorLookup[data.destructor_ptr] = nil
    else
        -- local tmp_slf = DestructorLookup[data]
        DestructorLookup[data] = nil
        ffi.free(data)
    end
end

Scalar.__gc = Scalar.destructor

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
   assert(type(arg) == "table", "Called constructor with incorrect arguments")
   assert(type(arg.coro) == "thread", "Argument coro must have a coroutine")
   assert(Type(arg.func) == "function", "Need a function to extract the scalar")
   local scalar = setmetatable({}, Scalar)
   scalar.destructor_ptr = ffi.malloc(1, Scalar.destructor)
   DestructorLookup[scalar.destructor_ptr] = scalar
   scalar._coro = arg.coro
   scalar._func = arg.func
   return scalar
end

function Scalar:next()
   assert(coroutine.status(self._coro) ~= "dead" , "The coroutine is no longer alive")
   local status, val = coroutine.resume(scalar._coro)
   if status == true and val ~= nil then
      self._val = val
   end
end

function Scalar:value()
   assert(self._val ~= nil, "The scalar has not been evaluated yet")
   return self._func(self._val)
end
