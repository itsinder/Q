local log    = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Column = {}
Column.__index = Column
local ffi = require 'Q/UTILS/lua/q_ffi'

setmetatable(Column, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

-- TODO Indrajeet to change
local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
   local otype = original_type( obj )
   if  otype == "table" and getmetatable( obj ) == Column then
      return "Column"
   end
   return otype
end

function Column.new(arg)
   local column = setmetatable({}, Column)
   -- for meta data stored in column
   column._meta = {}

   assert(type(arg) == "table", "Column construction requires table for arg list")

   -- Validity of qtype will be checked for by vector
   column._qtype = assert(arg.qtype, "Column needs qtype to be specified")
   if column._qtype == "SC" then
      column._width = assert(arg.width, "Constant length strings need a length to be specified")
   else
      assert(arg.width == nil)
   end

   if arg.gen ~= nil and arg.gen ~= false then -- nacent vector
      -- column._gen = arg.gen
      assert(type(column._gen) == "function" or type(column._gen) == "boolean" , "The supplied generator must be a function or a boolean for enabling setting in the future")
      column._nn = arg.nn or false
   else -- materialized vector
      column._filename = assert(arg.filename, "Column needs a filename to read from")
      assert(type(column._filename) == "string", "Vector's filename must be a string")

      if arg.nn_filename then
         column._nn_filename = arg.nn_filename
         assert(type(column._nn_filename) == "string", "Null vector's filename must be a string")
         column._nn = true
      else
         column._nn = false
      end
   end
end

function Column:set_generator(gen)
   if self._last_chunk_number == nil then
      assert(type(gen) == "`function")
      self._gen = gen
   else
      error("Cannot change the generator once a chunk has already been set")
   end
end


function Column:get_chunk(num)
   if self:materialized() == true then
      -- get the chunks from the vectors
      return nil
   else
      assert(self._gen ~= nil, "The Column must have a generator")
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
end

function Column:meta()
   local nn_vec = self._nn_vec
   if nn_vec ~= nil then 
      nn_vec = (nn_vec:meta())()
   end
   return {
      "vec" = (self._vec:meta())(),
      "nn_vec" = nn_vec 
   }
end

return Column
