local ffi    = require 'Q/UTILS/lua/q_ffi'
local qconsts= require 'Q/UTILS/lua/q_consts'
local log    = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Vector = require 'libvec' ;
--====================================
local lVector = {}
lVector.__index = lVector

setmetatable(lVector, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

-- TODO Indrajeet to change
local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
   local otype = original_type( obj )
   if  otype == "table" and getmetatable( obj ) == lVector then
      return "lVector"
   end
   return otype
end

function lVector.new(arg)
  local vector = setmetatable({}, lVector)
  -- for meta data stored in vector
  vector._meta = {}

  assert(type(arg) == "table", "lVector construction requires table as arg")

  -- Validity of qtype will be checked for by vector
  local qtype = assert(arg.qtype, "lVector needs qtype to be specified")
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

  if arg.gen ~= nil and arg.gen ~= false then -- nacent vector
    -- vector._gen = arg.gen
    assert(type(arg.gen) == "function" or type(arg.gen) == "boolean" , 
    "supplied generator must be a function or boolean indicating " ..
    "function will be specified in future")
      vector._nn = arg.nn or false
  else -- materialized vector
     vector._file_name = assert(arg.file_name, 
     "lVector needs a file_name to read from")
     assert(type(vector._file_name) == "string", 
     "lVector's file_name must be a string")

    if arg.nn_file_name then
      vector._nn_file_name = arg.nn_file_name
      assert(type(vector._nn_file_name) == "string", 
      "Null vector's file_name must be a string")
      vector._nn = true
    else
      vector._nn = false
    end
  end

  if ( qtype == "SC" ) then 
    qtype = qtype .. ":" .. tostring(field_width)
  end
  vector._base_vec = Vector.new(qtype, vector._file_name, 0, is_read_only )
  local num_elements = Vector.num_elements(vector._base_vec)
  if ( vector._nn ) then 
    assert(num_elements > 0)
    vector._nn_vec = Vector.new("B1", vector._nn_file_name, 
      is_read_only, num_elements)
  end
  return vector
end

function lVector:check()
  chk = Vector.check(self._base_vec)
  assert(chk, "Error on base vector")
  if ( Vector._nn_vec ) then 
    chk = Vector.check(self._nn_vec)
    assert(chk, "Error on nn vector")
  end
  return true
end

function lVector:set_generator(gen)
  if ( ( self.num_elements == 0 ) and ( not self._file_name ) )  then 
    assert(type(gen) == "function")
    self._gen = gen
  else
    error("Cannot change generator once elements generated")
   end
end

function lVector:get_chunk(chunk_num)
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
      assert(self._gen ~= nil, "The lVector must have a generator")
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

function lVector:meta()
   local nn_vec = self._nn_vec
   if nn_vec ~= nil then 
      nn_vec = (nn_vec:meta())()
   end
   --[[ TODO
   return {
      "vec" = (self._vec:meta())(),
      "nn_vec" = nn_vec 
   }
   --]]
end

return lVector
