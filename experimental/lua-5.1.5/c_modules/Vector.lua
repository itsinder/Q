local ffi    = require 'Q/UTILS/lua/q_ffi'
local log    = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

-- TODO Indrajeet to change
local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
   local otype = original_type( obj )
   if  otype == "table" and getmetatable( obj ) == Vector then
      return "Vector"
   end
   return otype
end

function Vector.new(arg)
   local vector = setmetatable({}, Vector)
   -- for meta data stored in vector
   vector._meta = {}

   assert(type(arg) == "table", "Vector construction requires table as arg")

   -- Validity of qtype will be checked for by vector
   local qtype = assert(arg.qtype, "Vector needs qtype to be specified")
   --=============================
   local field_width = nil
   assert(qconsts.qtypes[qtype], "Invalid qtype provided")
   if qtype == "SC" then
      field_width = assert(arg.width, "Constant length strings need a length to be specified")
      assert(type(field_width) == "number", "field width must be a number")
      assert(field_width >= 2)
   else
      assert(arg.width == nil, "do not provide width except for SC")
   end
   --=============================
   local is_read_only = false
   if ( arg.is_read_only ) then
     assert(type(arg.is_read_only) == "boolean")
     is_read_only = arg.is_read_only
   end

   vector._qtype = qtype
   vector._width = field_width
   vector._is_read_only = is_read_only
   vector._base_vec = Vector.new(qtype, field_width, is_read_only)

   if arg.gen ~= nil and arg.gen ~= false then -- nacent vector
      -- vector._gen = arg.gen
      assert(type(vector._gen) == "function" or type(vector._gen) == "boolean" , "The supplied generator must be a function or a boolean for enabling setting in the future")
      vector._nn = arg.nn or false
   else -- materialized vector
      vector._filename = assert(arg.filename, "Vector needs a filename to read from")
      assert(type(vector._filename) == "string", "Vector's filename must be a string")

      if arg.nn_filename then
         vector._nn_filename = arg.nn_filename
         assert(type(vector._nn_filename) == "string", "Null vector's filename must be a string")
         vector._nn = true
      else
         vector._nn = false
      end
   end

   if ( qtype == "SC" ) then qtype = qtype .. ":" .. tostring(field_width)
   vector._base_vec = Vector.new(qtype, file_name, is_read_only )
   if ( nn_file_name ) then 
     vector._nn_vec = Vector.new("B1", nn_file_name, is_read_only)
   end
end

function Vector:set_generator(gen)
  if ( ( self.num_elements == 0 ) and ( not self._file_name ) )  then 
    assert(type(gen) == "function")
    self._gen = gen
  else
    error("Cannot change generator once elements generated")
   end
end

function Vector:get_chunk(chunk_num)
  if ( not chunk_num ) then 
  else
    assert(type(chunk_num) == "integer")
    assert(chunk_num >= 0)
  end
  return self.get_chunk(chunk_num)
  --[[
   if self:materialized() == true then
      -- get the chunks from the vectors
      return nil
   else
      assert(self._gen ~= nil, "The Vector must have a generator")
      -- maybe this check is redundant
      if self._last_chunk_number == nil then
         assert(num == 0, "Only the same or immediate chunk number can be asked for")
      else
         assert(num == self._last_chunk_number or num == self._last_chunk_number + 1,
         "Only the same or immediate chunk number can be asked for")
         if num == self._last_chunk_number then
            -- TODO return the current chunk
            return nil
         else
            -- TODO there is some error checking we need to think about
            self._gen(num)
         end
      end
   end
   --]]
end

function Vector:meta()
   local nn_vec = self._nn_vec
   if nn_vec ~= nil then 
      nn_vec = (nn_vec:meta())()
   end
   return {
      "vec" = (self._vec:meta())(),
      "nn_vec" = nn_vec 
   }
end

return Vector
