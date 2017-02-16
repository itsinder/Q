require "Vector"
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
     local vec = arg.vec
     local chunks = vec.max_chunks -1 
	 if type(vec) ~= 'Vector' then error("Currently only wrap vectors") end
     self.gen = coroutine.create(
         function()
           for i=0, chunks-1 do
             coroutine.yield(vec:chunk(i))
         end
         return vec:chunk(chunks)
     end
       )
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
