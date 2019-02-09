local ffi		= require 'Q/UTILS/lua/q_ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local Dnn		= require 'libdnn'
local register_type	= require 'Q/UTILS/lua/q_types'
local qc		= require 'Q/UTILS/lua/q_core'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
--====================================
local ldnn = {}
ldnn.__index = ldnn

setmetatable(ldnn, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(ldnn, "ldnn")
-- -- TODO Indrajeet to change WHAT IS THIS???? 
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--    local otype = original_type( obj )
--    if  otype == "table" and getmetatable( obj ) == ldnn then
--       return "ldnn"
--    end
--    return otype
-- end


function ldnn.new(mode, params)
  local dnn = setmetatable({}, ldnn)
  -- for meta data stored in dnn
  dnn._meta = {}
  local nl  -- num_layers
  local bsz -- batch_size
  local npl -- neurons_per_layer

  assert( mode and ( type(mode) == "string") ) 
  if ( mode == "new" ) then 
    assert(type(params) == "table", "dnn constructor requires table as arg")
    assert( ( params.npl) and 
            ( type(params.npl) == "table" ) and 
            ( #(params.npl) >= 3 ) )
    npl = params.npl
    nl = #params.npl
    --[[ TODO 
    assert( ( params.activation_function) and 
            ( type(params.activation_function) == "table" ) and 
            ( #(params.activation_function)  == nl) )
    --]]
    assert( ( params.bsz)  and 
            ( type(params.bsz) == "number" ) and 
            ( params.bsz >= 1 ) )
    bsz = params.bsz
  elseif ( mode == "hydrate" ) then 
    assert(nil, "TODO")
  else
    assert(nil, "Invalid mode of creation")
  end
  --==========================================
  -- c_npl = C neurons per layer 
  local c_npl = cmem.new(ffi.sizeof("int") * nl, "F4") 
  local  X = get_ptr(c_npl, "F4")
  for i = 1, nl do 
    X[i-1] = npl[i]
  end
  --==========================================
  ldnn._base_vec = Dnn.new(bsz, nl, c_npl)
  assert(ldnn._base_vec)
  dnn.npl = npl
  dnn.nl  = nl 
  dnn.bsz = bsz
  return dnn
end


function ldnn:set_sibling(x)
  assert(type(x) == "ldnn")
  local exists = false
  for k, v in ipairs(self.siblings) do
    if ( x == v ) then
      exists = true
    end
  end
  if ( not exists ) then
    self.siblings[#self.siblings+1] = x
  end
end
function ldnn:persist(is_persist)
  local base_status = true
  local nn_status = true
  if ( is_persist == nil ) then 
    is_persist = true
  else
    assert(type(is_persist) == "boolean")
  end
  base_status = dnn.persist(self._base_vec, is_persist)
  if ( self._nn_vec ) then 
    nn_status = dnn.persist(self._nn_vec, is_persist)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function ldnn:nn_vec()
  -- TODO Can only do this when dnn has been materialized
  -- That is because one generator starts feeding 2 dnns and 
  -- we are not prepared for that
  -- P1 Fix this code. In current state, it is not working
  assert(self:is_eov())
  local dnn = setmetatable({}, ldnn)
  dnn._meta = {}
  dnn._base_vec = self._nn_vec
  if ( qconsts.debug ) then self:check() end
  return dnn
end
  
function ldnn:drop_nulls()
  assert(self:is_eov())
  self._nn_vec = nil
  self:set_meta("has_nulls", false)
  if ( qconsts.debug ) then self:check() end
  return self
end

function ldnn:make_nulls(bvec)
  assert(self:is_eov())
  assert(self._nn_vec == nil) 
  assert(type(bvec) == "ldnn")
  assert(bvec:fldtype() == "B1")
  assert(bvec:num_elements() == self:num_elements())
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  self:set_meta("has_nulls", true)
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function ldnn:memo(is_memo)
  local base_status = true
  local nn_status = true
  if ( is_memo == nil ) then 
    is_memo = true
  else
    assert(type(is_memo) == "boolean")
  end
  base_status = dnn.memo(self._base_vec, is_memo)
  if ( self._nn_vec ) then 
    nn_status = dnn.persist(self._nn_vec, is_memo)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function ldnn:chunk_num()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.chunk_num
end

function ldnn:chunk_size()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.chunk_size
end

function ldnn:has_nulls()
  if ( qconsts.debug ) then self:check() end
  if ( self._nn_vec ) then return true else return false end
end

function ldnn:num_elements()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  -- added tonumber() because casted_base_vec.num_elements is of type cdata
  return tonumber(casted_base_vec.num_elements)
end

function ldnn:length()
  if ( not self:is_eov() ) then
    return nil
  end
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  -- added tonumber() because casted_base_vec.num_elements is of type cdata
  return tonumber(casted_base_vec.num_elements)
end

-- Older version of fldtype(), kept just for reference if required in future
function ldnn:fldtype_old()
  if ( qconsts.debug ) then self:check() end
  return dnn.fldtype(self._base_vec)
end

function ldnn:fldtype()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(casted_base_vec.field_type)
end

function ldnn:qtype()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(casted_base_vec.field_type)
end

function ldnn:field_size()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.field_size
end

function ldnn:field_width()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return casted_base_vec.field_size
end

function ldnn:file_name()
  if ( qconsts.debug ) then self:check() end
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  return ffi.string(casted_base_vec.file_name)
end

function ldnn:nn_file_name()
  local vec_meta = self:meta()
  local nn_file_name = nil
  if vec_meta.nn then
    nn_file_name = assert(vec_meta.nn.file_name)
  end
  if ( qconsts.debug ) then self:check() end
  return nn_file_name
end

function ldnn:check()
  local chk = dnn.check(self._base_vec)
  assert(chk, "Error on base dnn")
  local num_elements = dnn.num_elements(self._base_vec)
  if ( self._nn_vec ) then
    local nn_num_elements = dnn.num_elements(self._nn_vec)
    chk = dnn.check(self._nn_vec)
    assert(num_elements == nn_num_elements)
    assert(chk, "Error on nn dnn")
  end
  -- TODO: Check that following are same for base_vec and nn_vec
  -- (a) num_elements DONE
  -- (b) is_persist  
  -- (c) Anything else?
  return true
end

function ldnn:set_generator(gen)
  assert(self:num_elements() == 0,
  --assert(dnn.num_elements(self._base_vec) == 0, 
    "Cannot set generator once elements generated")
  assert(not self:is_eov(), 
    "Cannot set generator for materialized dnn")
  assert(type(gen) == "function")
  self._gen = gen
end

function ldnn:eov()
  local status = dnn.eov(self._base_vec)
  assert(status)
  if self._nn_vec then 
    local status = dnn.eov(self._nn_vec)
    assert(status)
  end
-- destroy generator and therebuy release resources held by it 
  self._gen = nil 
  --if ( dnn.num_elements(self._base_vec) == 0 ) then
  if ( self:num_elements() == 0 ) then
    return nil
  end
  if ( qconsts.debug ) then self:check() end
  return true
end

function ldnn:put1(s, nn_s)
  assert(s)
  assert(type(s) == "Scalar")
  local status = dnn.put1(self._base_vec, s)
  assert(status)
  if ( self._nn_vec ) then 
    assert(nn_s)
    assert(type(nn_s) == "Scalar")
    assert(nn_s:fldtype() == "B1")
    local status = dnn.put1(self._nn_vec, nn_s)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

function ldnn:start_write(is_read_only_nn)
  if ( is_read_only_nn ) then 
    assert(type(is_read_only_nn) == "boolean")
  end
  local nn_X, nn_nX
  local X, nX = dnn.start_write(self._base_vec)
  assert(X)
  assert(type(nX) == "number")
  assert(nX > 0)
  if ( self._nn_vec ) then
    if ( is_read_only_nn ) then 
      nn_X, nn_nX = assert(dnn.get(self._nn_vec, 0, 0))
    else
      nn_X, nn_nX = dnn.start_write(self._nn_vec)
    end
    assert(nn_nX == nX)
    assert(nn_nX)
  end
  if ( qconsts.debug ) then self:check() end
  return nX, X, nn_X
end

function ldnn:end_write()
  local status = dnn.end_write(self._base_vec)
  assert(status)
  if ( self._nn_vec ) then
    local status = dnn.end_write(self._nn_vec)
    assert(status)
  end
  if ( qconsts.debug ) then self:check() end
end

function ldnn:put_chunk(base_addr, nn_addr, len)
  local status
  assert(len)
  assert(type(len) == "number")
  assert(len >= 0)
  if ( len == 0 )  then -- no more data
    status = dnn.eov(self._base_vec)
    if ( self._nn_vec ) then
      status = dnn.eov(self._nn_vec)
    end
  else
    assert(base_addr)
    status = dnn.put_chunk(self._base_vec, base_addr, len)
    assert(status)
    if ( self._nn_vec ) then
      assert(nn_addr)
      status = dnn.put_chunk(self._nn_vec, nn_addr, len)
      assert(status)
    end
  end
  if ( qconsts.debug ) then self:check() end
end

function ldnn:delete()
  -- This method free up all dnn resources
  assert(self._base_vec)
  local status = dnn.delete(self._base_vec)
  assert(status)

  -- Check for nulls
  if ( self:has_nulls() ) then
    status = dnn.delete(self._nn_vec)
    assert(status)
  end

  return status
  -- if ( qconsts.debug ) then self:check() end
end

function ldnn:clone(optargs)
  assert(self._base_vec)
  -- Now we are supporting clone for non_eov dnn as well, so commenting below condition
  -- assert(self:is_eov(), "can clone dnn only if is EOV")
  
  local dnn = setmetatable({}, ldnn)
  -- for meta data stored in dnn
  dnn._meta = {}

  dnn._base_vec = dnn.clone(self._base_vec)
  assert(dnn._base_vec)

  -- Check for nulls
  if ( self:has_nulls() ) then
    dnn._nn_vec = dnn.clone(self._nn_vec)
    assert(dnn._nn_vec) 
  end

  -- copy aux metadata if any
  for i, v in pairs(self._meta) do
    dnn._meta[i] = v
  end

  -- check for the optargs
  if optargs then
    assert(type(optargs) == "table")
    for i, v in pairs(optargs) do
      -- currently entertaining just "name" field, in future there might be many other fields
      if i == "name" then
        dnn.set_name(dnn._base_vec, v)
      end
    end
  end
  return dnn
end

function ldnn:eval()
  if ( not self:is_eov() ) then
    local chunk_num = self:chunk_num() 
    local base_len, base_addr, nn_addr 
    repeat
      -- print("Requesting chunk " .. chunk_num .. " for " .. self:get_name())
      base_len, base_addr, nn_addr = self:chunk(chunk_num)
      chunk_num = chunk_num + 1 
    until ( base_len ~= qconsts.chunk_size )
    -- if ( self:length() > 0 ) then self:eov() end
    -- Changed above to following
    if ( self:length() == 0 ) then 
      return nil 
    else 
      self:eov() 
    end
  end
  -- else, nothing do to since dnn has been materialized
  if ( qconsts.debug ) then self:check() end
  return self
end

function ldnn:get_all()
  assert(self:is_eov())
  local nn_addr, nn_len
  local base_addr, base_len = assert(dnn.get(self._base_vec, 0, 0))
  assert(base_len > 0)
  assert(base_addr)
  if ( self._nn_vec ) then
    nn_addr, nn_len = assert(dnn.get(self._nn_vec, 0, 0))
    assert(nn_len == base_len)
    assert(nn_addr)
  end
  if ( qconsts.debug ) then self:check() end
  return base_len, base_addr, nn_addr
end

function ldnn:get_one(idx)
  -- TODO More checks to make sure that this is only for 
  -- dnns in file mode. We may need to move dnn from buffer 
  -- mode to file mode if we are at last chunk and is_eov == true
  local nn_data, nn_len, nn_scalar
  local base_data, base_len, base_scalar = assert(dnn.get(self._base_vec, idx, 1))
  assert(base_data)
  assert(type(base_data) == "CMEM")
  assert(type(base_len) == "number")
  assert(type(base_scalar) == "Scalar")
  if ( self._nn_vec ) then
    nn_data, nn_len, nn_scalar = assert(dnn.get(self._nn_vec, idx, 1))
    assert(type(nn_scalar) == "Scalar")
  end
  if ( qconsts.debug ) then self:check() end
  return base_scalar, nn_scalar
end


function ldnn:chunk(chunk_num)
  local status
  local base_addr, base_len
  local nn_addr,   nn_len  
  --local is_nascent = dnn.is_nascent(self._base_vec)
  local is_nascent = self:is_nascent()
  local is_eov = self:is_eov()
  assert(chunk_num, "chunk_num is a mandatory argument")
  assert(type(chunk_num) == "number")
  assert(chunk_num >= 0)
  local l_chunk_num = chunk_num
  -- There are 2 conditions under which we do not need to compute
  -- cond1 => dnn has been materialized
  local cond1 = is_eov
  -- cond2 => dnn is nascent and you are asking for current chunk
  -- or previous chunk 
  local cond2 = ( not is_eov ) and 
          ( ( ( self:chunk_num() == l_chunk_num ) and 
          ( self:num_in_chunk() > 0 ) ) or 
          ( ( l_chunk_num < self:chunk_num() ) and 
          ( self:is_memo() == true ) ) )
  if ( cond1 or cond2 ) then 
    base_addr, base_len = dnn.get_chunk(self._base_vec, l_chunk_num)
    if ( not base_addr ) then
      if ( qconsts.debug ) then self:check() end
      return 0
    end
    if ( self._nn_vec ) then 
      nn_addr,   nn_len   = dnn.get_chunk(self._nn_vec, l_chunk_num)
      assert(nn_addr)
      assert(base_len == nn_len)
    end
    if ( qconsts.debug ) then self:check() end
    if base_len < 1 then
      base_addr = nil
      nn_addr = nil
    end
    assert(chk_chunk_return(base_len, base_addr, nn_addr))
    return base_len, base_addr, nn_addr
  else
    assert(self._gen)
    assert(type(self._gen) == "function")
    local buf_size, base_data, nn_data = self._gen(chunk_num, self)
    assert(type(buf_size) == "number") -- THINK TODO 
    -- TODO DISCUSS following if with KRUSHNAKANT
    if ( buf_size < qconsts.chunk_size ) then
      if ( buf_size > 0 and base_data ) then
        self:put_chunk(base_data, nn_data, buf_size)
      end
      self:eov()
      --return buf_size, base_data, nn_data -- DISCUSS WITH KRUSHNAKANT
    else
      if ( base_data ) then 
        -- this is the simpler case where generator malloc's
        self:put_chunk(base_data, nn_data, buf_size)
      else
        -- this is the advanced case of using the dnn's buffer.
        -- local chk =  self:chunk_num()
        -- assert(chk == l_chunk_num)
      end
    end
    if ( qconsts.debug ) then self:check() end
    -- for conjoined dnns
    if self.siblings then
      for k, v in pairs(self.siblings) do
        v:chunk(l_chunk_num)
      end
    end
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

function ldnn:meta()
  -- with lua interpreter, load() is not supported with strings so using loadstring() 
  -- earlier with luajit interpreter, load() supported strings 
  local base_meta = loadstring(dnn.meta(self._base_vec))()
  local nn_meta = nil
  if ( self._nn_vec ) then 
    nn_meta = loadstring(dnn.meta(self._nn_vec))()
  end
  if ( qconsts.debug ) then self:check() end
  return { base = base_meta, nn = nn_meta, aux = self._meta}
end

function ldnn:serialize()
  if ( qconsts.debug ) then self:check() end
  -- TODO: Return weights and biases and other meta data 
  return true
end
  

function ldnn:get_meta(k)
  if ( qconsts.debug ) then self:check() end
  assert(k)
  assert(type(k) == "string")
  return self._meta[k]
end

return ldnn
