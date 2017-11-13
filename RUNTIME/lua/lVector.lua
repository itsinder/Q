local ffi    = require 'Q/UTILS/lua/q_ffi'
local qconsts= require 'Q/UTILS/lua/q_consts'
local log    = require 'Q/UTILS/lua/log'
local register_type = require 'Q/UTILS/lua/q_types'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local plpath = require "pl.path"
local Vector = require 'libvec'
--====================================
local lVector = {}
lVector.__index = lVector

setmetatable(lVector, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lVector, "lVector")
-- -- TODO Indrajeet to change
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--    local otype = original_type( obj )
--    if  otype == "table" and getmetatable( obj ) == lVector then
--       return "lVector"
--    end
--    return otype
-- end

function lVector:get_name()
  -- the name of an lVector is the name of its base Vector
  if ( qconsts.debug ) then self:check() end
  return Vector.get_name(self._base_vec)
end

function lVector:set_name(vname)
  -- the name of an lVector is the name of its base Vector
  if ( qconsts.debug ) then self:check() end
  assert(vname)
  assert(type(vname) == "string")
  local status = Vector.set_name(self._base_vec, vname)
  assert(status)
  return self
end

function lVector:cast(new_field_type)
  assert(new_field_type)
  assert(type(new_field_type) == "string")
  local new_field_width
  if is_base_qtype(new_field_type) then 
    new_field_width = qconsts.qtypes[new_field_type].width
  elseif ( new_field_type == "B1" ) then
    new_field_width = 0
  else
    assert(nil, "Cannot cast to ", new_field_type)
  end
  if ( self._nn_vec ) then 
    assert(nil, "TO BE IMPLEMENTED")
  end
  local status = Vector.cast(self._base_vec,new_field_type, new_field_width)
  assert(status)
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:is_memo()
  if ( qconsts.debug ) then self:check() end
  return Vector.is_memo(self._base_vec)
end

function lVector:file_size()
  if ( qconsts.debug ) then self:check() end
  return Vector.file_size(self._base_vec)
end


function lVector:is_eov()
  if ( qconsts.debug ) then self:check() end
  return Vector.is_eov(self._base_vec)
end

function lVector.new(arg)
  local vector = setmetatable({}, lVector)
  -- for meta data stored in vector
  vector._meta = {}

  local num_elements
  local qtype
  local field_width
  local file_name
  local nn_file_name
  local has_nulls
  local is_nascent
  local is_memo = true -- default to true
  assert(type(arg) == "table", "lVector construction requires table as arg")

  if ( arg.is_memo ~= nil ) then 
    assert(type(arg.is_memo) == "boolean")
    is_memo = arg.is_memo
  end
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

  if arg.gen then 
    is_nascent = true
    if ( arg.has_nulls == nil ) then
      has_nulls = true
    else
      assert(type(arg.has_nulls) == "boolean")
      has_nulls = arg.has_nulls
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
      if ( arg.has_nulls ) then assert(arg.has_nulls == true) end
    else
      has_nulls  = false
      if ( arg.has_nulls ) then assert(arg.has_nulls == false) end
    end
    is_nascent = false
  end

  if ( qtype == "SC" ) then 
    qtype = qtype .. ":" .. tostring(field_width)
  end
  if ( arg.num_elements ) then  -- TODO P4: Move to Lua style
    num_elements = arg.num_elements
  end
  vector._base_vec = Vector.new(qtype, file_name, is_memo, 
    num_elements)
  assert(vector._base_vec)
  local num_elements = Vector.num_elements(vector._base_vec)
  if ( has_nulls ) then 
    if ( not is_nascent ) then 
      assert(num_elements > 0)
    end
    vector._nn_vec = Vector.new("B1", nn_file_name, is_memo, num_elements)
    assert(vector._nn_vec)
  end
  if ( ( arg.name ) and ( type(arg.name) == "string" ) )  then
    Vector.set_name(vector._base_vec, arg.name)
  end 
  return vector
end

function lVector:persist(is_persist)
  local base_status = true
  local nn_status = true
  if ( is_persist == nil ) then 
    is_persist = true
  else
    assert(type(is_persist) == "boolean")
  end
  base_status = Vector.persist(self._base_vec, is_persist)
  if ( self._nn_vec ) then 
    nn_status = Vector.persist(self._nn_vec, is_persist)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function lVector:nn_vec()
  -- TODO Can only do this when vector has been materialized
  -- That is because one generator starts feeding 2 vectors and 
  -- we are not prepared for that
  -- P1 Fix this code. In current state, it is not working
  assert(self:is_eov())
  local vector = setmetatable({}, lVector)
  vector._meta = {}
  vector._base_vec = self._nn_vec
  if ( qconsts.debug ) then self:check() end
  return vector
end
  
function lVector:drop_nulls()
  assert(self:is_eov())
  self._nn_vec = nil
  self:set_meta("has_nulls", false)
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:make_nulls(bvec)
  assert(self:is_eov())
  assert(self._nn_vec == nil) 
  assert(type(bvec) == "lVector")
  assert(bvec:fldtype() == "B1")
  assert(bvec:num_elements() == self:num_elements())
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  self:set_meta("has_nulls", true)
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function lVector:memo(is_memo)
  local base_status = true
  local nn_status = true
  if ( is_memo == nil ) then 
    is_memo = true
  else
    assert(type(is_memo) == "boolean")
  end
  base_status = Vector.memo(self._base_vec, is_memo)
  if ( self._nn_vec ) then 
    nn_status = Vector.persist(self._nn_vec, is_memo)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function lVector:chunk_num()
  if ( qconsts.debug ) then self:check() end
  return Vector.chunk_num(self._base_vec)
end

function lVector:chunk_size()
  if ( qconsts.debug ) then self:check() end
  return Vector.chunk_size(self._base_vec)
end

function lVector:has_nulls()
  if ( qconsts.debug ) then self:check() end
  if ( self._nn_vec ) then return true else return false end
end

function lVector:num_elements()
  if ( qconsts.debug ) then self:check() end
  return Vector.num_elements(self._base_vec)
end

function lVector:length()
  if ( qconsts.debug ) then self:check() end
  return Vector.num_elements(self._base_vec)
end

function lVector:fldtype()
  if ( qconsts.debug ) then self:check() end
  return Vector.fldtype(self._base_vec)
end

function lVector:qtype()
  if ( qconsts.debug ) then self:check() end
  return Vector.fldtype(self._base_vec)
end

function lVector:field_size()
  if ( qconsts.debug ) then self:check() end
  return Vector.field_size(self._base_vec)
end

function lVector:field_width()
  if ( qconsts.debug ) then self:check() end
  return Vector.field_size(self._base_vec)
end

function lVector:file_name()
  if ( qconsts.debug ) then self:check() end
  return self:meta().base.file_name
end

function lVector:nn_file_name()
  local vec_meta = self:meta()
  local nn_file_name = nil
  if vec_meta.nn then
    nn_file_name = vec_meta.nn.file_name
  end
  if ( qconsts.debug ) then self:check() end
  return nn_file_name
end

function lVector:check()
  local chk = Vector.check(self._base_vec)
  assert(chk, "Error on base vector")
  local num_elements = Vector.num_elements(self._base_vec)
  if ( self._nn_vec ) then 
    local nn_num_elements = Vector.num_elements(self._nn_vec)
    chk = Vector.check(self._nn_vec)
    assert(num_elements == nn_num_elements)
    assert(chk, "Error on nn vector")
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
  assert(not self:is_eov(), 
    "Cannot set generator for materialized vector")
  assert(type(gen) == "function")
  self._gen = gen
end

function lVector:eov()
  local status = Vector.eov(self._base_vec)
  assert(status)
  if self._nn_vec then 
    local status = Vector.eov(self._nn_vec)
    assert(status)
  end
-- destroy generator and therebuy release resources held by it 
  self._gen = nil 
  if ( Vector.num_elements(self._base_vec) == 0 ) then 
    return nil
  end
  if ( qconsts.debug ) then self:check() end
  return true
end

function lVector:put1(s, nn_s)
  assert(s)
  assert(type(s) == "Scalar")
  local status = Vector.put1(self._base_vec, s)
  assert(status)
  if ( self._nn_vec ) then 
    assert(nn_s)
    assert(type(nn_s) == "Scalar")
    assert(nn_s:fldtype() == "B1")
    local status = Vector.put1(self._nn_vec, nn_s)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

function lVector:start_write()
  local nn_X, nn_nX
  local X, nX = Vector.start_write(self._base_vec)
  assert(X)
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    nn_X, nn_nX = Vector.start_write(self._nn_vec)
    assert(nn_nX == nX)
    assert(nn_nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end

function lVector:end_write()
  local status = Vector.end_write(self._base_vec)
  assert(status)
  if ( self._nn_vec ) then
    local status = Vector.end_write(self._nn_vec)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

function lVector:put_chunk(base_addr, nn_addr, len)
  local status
  assert(len)
  assert(type(len) == "number")
  assert(len >= 0)
  if ( len == 0 )  then -- no more data
    status = Vector.eov(self._base_vec)
    if ( self._nn_vec ) then
      status = Vector.eov(self._nn_vec)
    end
  else
    assert(base_addr)
    status = Vector.put_chunk(self._base_vec, base_addr, len)
    assert(status)
    if ( self._nn_vec ) then
      assert(nn_addr)
      status = Vector.put_chunk(self._nn_vec, nn_addr, len)
      assert(status)
    end
  end
  if ( qconsts.debug ) then self:check() end
end

function lVector:eval()
  if ( not self:is_eov() ) then
    local chunk_num = self:chunk_num() 
    local base_len, base_addr, nn_addr 
    repeat
      base_len, base_addr, nn_addr = self:chunk(chunk_num)
      chunk_num = chunk_num + 1 
    until base_len ~= qconsts.chunk_size
    -- if ( self:length() > 0 ) then self:eov() end
    -- Changed above to following
    if ( self:length() == 0 ) then 
      return nil 
    else 
      self:eov() 
    end
  end
  -- else, nothing do to since vector has been materialized
  if ( qconsts.debug ) then self:check() end
  return self
end

function lVector:release_vec_buf(chunk_size)
  local status
  assert(Vector.release_vec_buf(self._base_vec, chunk_size))
  if ( self._nn_vec ) then
    assert(Vector.release_vec_buf(self._nn_vec, chunk_size))
  end
  if ( qconsts.debug ) then self:check() end
  return true
end

function lVector:get_vec_buf()
  local nn_buf
  local base_buf = assert(Vector.get_vec_buf(self._base_vec))
  if ( self._nn_vec ) then
    nn_buf = assert(Vector.get_vec_buf(self._nn_vec))
  end
  if ( qconsts.debug ) then self:check() end
  return base_buf, nn_buf
end

function lVector:get_all()
  -- TODO P2. This is the same as chunk() without parameters
  -- Consider deprecating this in the near future
  local nn_addr, nn_len
  local base_addr, base_len = assert(Vector.get(self._base_vec, 0, 0))
  assert(base_len > 0)
  assert(base_addr)
  if ( self._nn_vec ) then
    nn_addr, nn_len = assert(Vector.get(self._nn_vec, 0, 0))
    assert(nn_len == base_len)
    assert(nn_addr)
  end
  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr, nn_addr
end

function lVector:get_one(idx)
  -- TODO More checks to make sure that this is only for 
  -- vectors in file mode. We may need to move vector from buffer 
  -- mode to file mode if we are at last chunk and is_eov == true
  local nn_addr, nn_len, nn_scalar
  local base_data, base_len, base_scalar = assert(Vector.get(self._base_vec, idx, 1))
  assert(type(base_scalar) == "Scalar")
  if ( self._nn_vec ) then
    nn_scalar = assert(Vector.get(self._nn_vec, 0, 0))
    assert(type(nn_scalar) == "Scalar")
  end
  if ( qconsts.debug ) then self:check() end
  return base_scalar, nn_scalar
end


function lVector:chunk(chunk_num)
  local status
  local l_chunk_num = 0
  local base_addr, base_len
  local nn_addr,   nn_len  
  local is_nascent = Vector.is_nascent(self._base_vec)
  local is_eov = self:is_eov() 
  if ( chunk_num ) then 
    assert(type(chunk_num) == "number")
    assert(chunk_num >= 0)
    l_chunk_num = chunk_num
  else
    -- Note from Krushnakant: When I call chunk() method for nascent
    -- vector without passing chunk number, what should be it's behavior?
    -- As per my thinking, it should return me the current chunk,
    if ( is_nascent ) then 
      l_chunk_num = Vector.chunk_num(self._base_vec)
    else
      l_chunk_num = 0
      -- NOT an error assert(nil, "Provide chunk_num for chunk() on materialized vector")
    end
  end
  -- There are 2 conditions under which we do not need to compute
  -- cond1 => Vector has been materialized
  local cond1 = is_eov
  -- cond2 => Vector is nascent and you are asking for current chunk
  -- or previous chunk 
  local cond2 = ( not is_eov ) and 
          ( ( ( Vector.chunk_num(self._base_vec) == l_chunk_num ) and 
          ( Vector.num_in_chunk(self._base_vec) > 0 ) ) or 
          ( ( l_chunk_num < Vector.chunk_num(self._base_vec) ) and 
          ( Vector.is_memo(self._base_vec) == true ) ) )
  if ( cond1 or cond2 ) then 
    base_addr, base_len = Vector.get_chunk(self._base_vec, l_chunk_num)
    if ( not base_addr ) then
      if ( qconsts.debug ) then self:check() end
      return 0
    end
    if ( self._nn_vec ) then 
      nn_addr,   nn_len   = Vector.get_chunk(self._nn_vec, l_chunk_num)
      assert(nn_addr)
      assert(base_len == nn_len)
    end
    if ( qconsts.debug ) then self:check() end
    return base_len, base_addr, nn_addr
  else
    assert(self._gen)
    assert(type(self._gen) == "function")
    local buf_size, base_data, nn_data = self._gen(l_chunk_num, self)
    if ( buf_size < qconsts.chunk_size ) then
      if ( base_data ) then
        self:put_chunk(base_data, nn_data, buf_size)
      end
      self:eov()
      --return buf_size, base_data, nn_data -- DISCUSS WITH KRUSHNAKANT
    else
      if ( base_data ) then 
        -- this is the simpler case where generator malloc's
        self:put_chunk(base_data, nn_data, buf_size)
      else
        -- this is the advanced case of using the Vector's buffer.
        local chk =  self:chunk_num()
        assert(chk == l_chunk_num)
      end
    end
    if ( qconsts.debug ) then self:check() end
    return self:chunk(l_chunk_num)
    -- NOTE: Could also do return chunk_size, base_data, nn_data
    --[[
    status = self._gen(chunk_num, self)
    assert(status)
    return self:chunk(chunk_num)
    --]]
  end
  -- NOTE: Indrajeet suggests: return self:chunk(chunk_num)
end

function lVector:meta()
  local base_meta = load(Vector.meta(self._base_vec))()
  local nn_meta = nil
  if ( self._nn_vec ) then 
    nn_meta = load(Vector.meta(self._nn_vec))()
  end
  if ( qconsts.debug ) then self:check() end
  return { base = base_meta, nn = nn_meta, aux = self._meta}
end

function lVector:reincarnate()
  if ( qconsts.debug ) then self:check() end
  if ( not self:is_eov()) then
    return nil
  end
  
  -- Set persist flag
  self:persist(true)
  
  local T = {}
  T[#T+1] = "lVector ( { "

  T[#T+1] = "qtype = \"" 
  T[#T+1] = Vector.fldtype(self._base_vec)
  T[#T+1] = "\", "

  T[#T+1] = "file_name = \"" 
  T[#T+1] = self:file_name()
  T[#T+1] = "\", "

  if ( self:nn_file_name() ) then 
    T[#T+1] = "nn_file_name = \"" 
    T[#T+1] = self:nn_file_name()
    T[#T+1] = "\", "
  end

  T[#T+1] = " } ) "
  if ( qconsts.debug ) then self:check() end
  return table.concat(T, '')
end


function lVector:set_meta(k, v)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  -- assert(v): do not do this since it is used to set meta of key to nil
  assert(type(k) == "string")
  self._meta[k] = v
end

function lVector:get_meta(k)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end

return lVector
