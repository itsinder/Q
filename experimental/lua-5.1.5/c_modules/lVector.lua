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

  local num_elements
  local qtype
  local field_width
  local is_read_only
  local file_name
  local nn_file_name
  local has_nulls
  local is_nascent
  assert(type(arg) == "table", "lVector construction requires table as arg")

  -- Validity of qtype will be checked for by vector
  qtype = assert(arg.qtype, "lVector needs qtype to be specified")
   --=============================
  field_width = nil
  assert(qconsts.qtypes[qtype], "Invalid qtype provided")
  if qtype == "SC" then
    field_width = assert(arg.width, "Constant length strings need a length to be specified")
    assert(type(field_width) == "number", "field width must be a number")
    assert(field_width >= 2)
  else
    assert(arg.width == nil, "do not provide width except for SC")
    field_width = qconsts.qtypes[qtype].width
  end
   --=============================
  is_read_only = false
  if ( arg.is_read_only ) then
    assert(type(arg.is_read_only) == "boolean")
    is_read_only = arg.is_read_only
  end

  vector._qtype = qtype
  vector._field_width = field_width
  vector._is_read_only = is_read_only

  if arg.gen then 
    is_nascent = true
    if ( arg.has_nulls == false ) then 
      has_nulls = false
    else
      has_nulls = true
    end
    assert(type(arg.gen) == "function" or type(arg.gen) == "boolean" , 
    "supplied generator must be a function or boolean as placeholder ")
    vector._gen = arg.gen
  else -- materialized vector
     file_name = assert(arg.file_name, 
     "lVector needs a file_name to read from")
     assert(type(file_name) == "string", 
     "lVector's file_name must be a string")

    if arg.nn_file_name then
      nn_file_name = arg.nn_file_name
      assert(type(nn_file_name) == "string", 
      "Null vector's file_name must be a string")
      has_nulls = true
    else
      has_nulls  = false
    end
    is_nascent = false
  end
  vector._has_nulls = has_nulls
  vector.file_name = file_name
  vector.nn_file_name = nn_file_name

  if ( qtype == "SC" ) then 
    qtype = qtype .. ":" .. tostring(field_width)
  end
  if ( arg.num_elements ) then  -- TODO P4: Move to Lua style
    num_elements = arg.num_elements
  end
  vector._base_vec = Vector.new(qtype, file_name, is_read_only,num_elements)
  assert(vector._base_vec)
  local num_elements = Vector.num_elements(vector._base_vec)
  if ( vector._has_nulls ) then 
    if ( not is_nascent ) then 
      assert(num_elements > 0)
    end
    vector._nn_vec = Vector.new("B1", nn_file_name, is_read_only, 
      num_elements)
    assert(vector._nn_vec)
  end
  return vector
end

function lVector:persist(is_persist)
  if ( is_persist == nil ) then 
    is_persist = true
  else
    assert(type(is_persist) == "boolean")
  end
  Vector.persist(self._base_vec, is_persist)
  if ( vector._has_nulls ) then 
    Vector.persist(self._nn_vec, is_persist)
  end
end

function lVector:get_chunk_num()
  return Vector.chunk_num(self._base_vec)
end

function lVector:num_elements()
  return Vector.num_elements(self._base_vec)
end

function lVector:length()
  return Vector.num_elements(self._base_vec)
end

function lVector:fldtype()
  return self._qtype
end

function lVector:qtype()
  return self._qtype
end

function lVector:field_size()
  return self._field_width
end

function lVector:field_width()
  return self._field_width
end

function lVector:check()
  local chk = Vector.check(self._base_vec)
  assert(chk, "Error on base vector")
  local num_elements = Vector.num_elements(self._base_vec)
  if ( self._has_nulls ) then 
    assert(self._nn_vec)
    local nn_num_elements = Vector.num_elements(self._nn_vec)
    chk = Vector.check(self._nn_vec)
    assert(num_elements == nn_num_elements)
    assert(chk, "Error on nn vector")
  else
    assert(not self._nn_vec)
  end
  -- TODO: Check that following are same for base_vec and nn_vec
  -- (a) num_elements DONE
  -- (b) is_persist  
  -- (c) Anything else?
  return true
end

function lVector:set_generator(gen)
  assert(Vector.num_elements(self._base_vec) == 0, 
    "Cannot set generator once elements generated")
  assert(Vector.is_nascent(self._base_vec), 
    "Cannot set generator for materialized vector")
  assert(type(gen) == "function")
  self._gen = gen
end

function lVector:eov()
  Vector.eov(self._base_vec)
  if self._nn_vec then 
    Vector.eov(self._nn_vec)
  end
  return true
end

function lVector:put1(s, nn_s)
  assert(s)
  assert(type(s) == "userdata")
  local status = Vector.put1(self._base_vec, s)
  assert(status)
  if ( self._has_nulls ) then 
    assert(nn_s)
    assert(type(nn_s) == "userdata")
    local status = Vector.put1(self._nn_vec, nn_s)
    assert(status)
  end
end

function lVector:put_chunk(base_addr, nn_addr, len)
  assert(len)
  assert(type(len) == "number")
  assert(len > 0)
  assert(base_addr)
  local status = Vector.put_chunk(self._base_vec, base_addr, len)
  assert(status)
  if ( self._has_nulls ) then
    assert(nn_addr)
    assert(self._nn_vec)
    local status = Vector.put_chunk(self._nn_vec, nn_addr, len)
    assert(status)
  end
end

function lVector:eval()
  if ( Vector.is_nascent(self._base_vec) ) then
    local chunk_num = self:get_chunk_num() 
    repeat
      local base_len, base_addr, nn_addr = self:get_chunk(chunk_num)
      chunk_num = chunk_num + 1 
    until base_len ~= qconsts.chunk_size
  end
  -- else, nothing do to since vector has been materialized
end

function lVector:release_vec_buf(chunk_size)
  local status
  assert(Vector.release_vec_buf(self._base_vec, chunk_size))
  if ( self._has_nulls ) then
    assert(Vector.release_vec_buf(self._nn_vec, chunk_size))
  end
  return true
end

function lVector:get_vec_buf()
  local nn_buf = nil
  local base_buf = Vector.get_vec_buf(self._base_vec)
  assert(base_buf)
  if ( self._has_nulls ) then
    nn_buf = Vector.get_vec_buf(self._nn_vec)
    assert(nn_buf)
  end
  return base_buf, nn_buf
end

function lVector:get_chunk(chunk_num)
  local status
  local l_chunk_num = -1
  local base_addr, base_len
  local nn_addr,   nn_len  
  if ( chunk_num ) then 
    assert(type(chunk_num) == "number")
    assert(chunk_num >= 0)
    l_chunk_num = chunk_num
  end
  -- There are 2 conditions under which we do not need to compute
  -- cond1 => Vector has been materialized
  local cond1 = not Vector.is_nascent(self._base_vec)
  -- cond2 => Vector is nascent and you are asking for current chunk
  local cond2 = ( Vector.is_nascent(self._base_vec) ) and 
          ( Vector.chunk_num(self._base_vec) == l_chunk_num ) and 
          ( Vector.num_in_chunk(self._base_vec) > 0 )
  if ( cond1 or cond2 ) then 
    base_addr, base_len = Vector.get_chunk(self._base_vec, l_chunk_num)
    if ( ( self._has_nulls ) and ( base_addr ) ) then 
      nn_addr,   nn_len   = Vector.get_chunk(self._nn_vec, l_chunk_num)
      assert(nn_addr)
      assert(base_len == nn_len)
    end
    return base_len, base_addr, nn_addr
  else
    assert(Vector.is_nascent(self._base_vec))
    -- generate data 
    assert(self._gen)
    assert(type(self._gen) == "function")
    local buf_size, base_data, nn_data = self._gen(l_chunk_num, self)
    if ( base_data ) then 
      -- this is the simpler case where generator malloc's
      self:put_chunk(base_data, nn_data, buf_size)
    else
      -- this is the advanced case of using the Vector's buffer.
      local chk =  self:get_chunk_num()
      assert(chk == l_chunk_num)
    end
    if ( buf_size < qconsts.chunk_size ) then
      self:eov()
    end
    return self:get_chunk(l_chunk_num)
    -- NOTE: Could also do return chunk_size, base_data, nn_data
    --[[
    status = self._gen(chunk_num, self)
    assert(status)
    return self:get_chunk(chunk_num)
    --]]
  end
  -- NOTE: Indrajeet suggests: return self:get_chunk(chunk_num)
end

function lVector:meta()
  local base_meta = load(Vector.meta(self._base_vec))()
  local nn_meta = nil
  if ( self._nn_vec ) then 
    nn_meta = load(Vector.meta(self._nn_vec))()
  else
  end
  return { base = base_meta, nn = nn_meta, aux = self._meta}
end

function lVector:set_meta(k, v)
  assert(k)
  -- assert(v): do not do this since it is used to set meta of key to nil
  assert(type(k) == "string")
  self._meta[k] = v
end

function lVector:get_meta(k)
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end


return lVector
