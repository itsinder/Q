require "Vector"
local ffi  = require "ffi"

local Generator = {}
Generator.__index = Generator
setmetatable(Generator, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Generator then
        return "Generator"
    end
    return otype
end


function Generator.new(arg)
    local self = setmetatable({}, Generator)
    if type(arg) ~= "table" then
        error("Called constructor with incorrect arguements")
    end
    if arg.vec ~= nil then
        local vec = arg.vec
        assert(type(vec) == 'Vector', "Generators can only use vectors in arg vec")
        local chunks = vec.max_chunks -1

        self.gen = coroutine.create(
            function()
                local i = 1
                local status = 0
                while status do
                    status, chunk, length = vec:chunk(i)
                    if status then
                        coroutine.yield(status, chunk, length)
                        i = i + 1
                    end
                end
            end
            )
    elseif arg.coro ~= nil then
        local coro = arg.coro
        assert(type(coro) == "thread", "Must be a coroutine")
        self.gen = coro
        self.field_type = assert(arg.field_type, "Requires a field type")
        
        if arg.field_size == nil then -- for constant length string this cannot be nil
            local type_val =  assert(g_valid_types[self.field_type], "Invalid type")
            self.field_size = ffi.sizeof(type_val)
        else
            self.field_size = arg.field_size
        end
        self.my_length = arg.length
    end
    return self
end

function Generator:status()
    return coroutine.status(self.gen)
end

function Generator:get_next_chunk()
    local status, buffer, size
    status, buffer, size = coroutine.resume(self.gen)
    return status, buffer, size
end

return Generator
