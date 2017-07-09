local qconsts = require 'Q/UTILS/lua/q_consts'
local plpath  = require 'pl.path'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
-- local dbg = require 'Q/UTILS/lua/debugger'

local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
  local otype = original_type( obj )
  if  otype == "table" and getmetatable( obj ) == Vector then
    return "Vector"
  end
  return otype
end

local function open_file_for_rw_access(self, arg) 

  assert(self.filename == nil)
  self.filename = assert(arg.filename, "Filename not specified for read")

  --mmap the file
  self.mmap = assert(ffi.gc(qc.f_mmap(self.filename, true), qc.f_munmap))

  self.num_elements = tonumber(self.map_len) / self.field_size
  assert(self.num_elements > 0 )
  assert(math.ceil(self.num_elements)  == self.num_elements)
  assert(math.floor(self.num_elements) == self.num_elements)

  return self
end

local function open_vec_for_append(self)
  self.chunk = assert(ffi.malloc(qconsts.chunk_size * vec.field_size))
  self.chunk_num    = 0
  self.num_in_chunk = 0
  self.num_elements = 0
  self.filename = ffi.malloc(qconsts.max_len_file_name+1)
  ffi.fill(self.filename, qconsts.max_len_file_name+1)
  self.is_memo = true
  qc['rand_file_name'](self.filename, qconsts.max_len_file_name)
  return self
end

function Vector:check()
  --================================================
  if self.mmap then 
    assert(self.mmap.file_name)
    assert(self.mmap.map_addr)
    assert(self.mmap.persist)
    assert(self.mmap.map_len > 0)
    assert(plpath.isfile(self.mmap.file_name))
    local file_size = plpath.getsize(vec.filename)
    assert(file_size > 0)
    local chk_len = tonumber(self.f_map.file_size) / self.field_size
    assert(math.ceil(chk_len) == self.num_elements)
    assert(math.floor(chk_len) == self.num_elements)
    assert(self.num_elements > 0)
  end
  --================================================
  if ( self.field_type ~= "SC" ) then 
    assert(self.field_size == q_consts.qtype[qtype].width)
  else
    assert(self.field_size >= 2)
  end
  --================================================
  if ( self.is_nascent ) then
    assert(self.chunk)

    assert(self.chunk_num)
    assert(type(self.chunk_num) == "number")
    assert(self.chunk_num >= 0 )

    assert(self.num_in_chunk)
    assert(type(self.num_in_chunk) == "number")
    assert(self.num_in_chunk >= 0 )

    if ( self.is_memo ) then
      assert(self.filename)
    else
      assert(self.filename == nil)
    end
    local filesize = plpath.getsize(self.filename)
    assert(filesize == (chunk_num * self.field_size))
    assert(((self.chunk_num * qconsts.chunk_size) + self.num_in_chunk)
      == self.num_elements)
    if ( ( self.chunk_num >= 1 ) and ( self.is_memo ) ) then 
      assert(self.mmap.file_name)
      assert(plpath.isfile(self.mmapfile_name))
      local file_size = ( chunk_num * self.field_size )
      assert(file_size == plpath.getsize(self.filename))
    end
  else
    assert(self.chunk == nil)
    assert(self.num_in_chunk == nil)
    assert(self.chunk_num == nil)
  end
  return true
end

function Vector.new(arg)
  local vec = setmetatable({}, Vector)

  -- set qtype
  assert(type(arg) == "table", "argument to constructor should be table")
  local qtype = assert(arg.field_type, "must specifyt fldtype for vector")
  assert(type(qtype) == "string")
  assert(qconsts.qtypes[qtype], "Valid qtype not given")
  vec.field_type = qtype

  -- set field_size
  if ( qtype == "SC" ) then 
    local fldsz = assert(arg.field_size, "Must specify field size for SC")
    assert(type(fldsz) == "number")
    assert(fldsz >= 2, "Field size must be >= 2 (one for nullc)")
    vec.field_size = fldsz
  else
    assert(arg.field_size == nil, "Can specify field size only for SC")
    vec.field_size = q_consts.qtype[qtype].width
  end
  --====== is vector materialized or nascent
  assert(arg.is_nascent)
  assert(type(arg.is_nascent) == "boolean")
  vec.is_nascent = arg.is_nascent
  if arg.is_nascent then 
    vec = assert(nascent_vec(vec))
  else
    vec = assert(materialized_vec(vec, arg))
  end
  return vec
end

function Vector:length()
  return self.num_elements
end

function Vector:fldtype()
  return self.field_type
end

function Vector:sz()
  return self.field_size
end

function Vector:memo(is_memo)
  assert(is_memo, "is_memo not specified")
  assert(type(is_memo) == "boolean", "Incorrect type supplied")
  if ( self.chunk ) then 
    if ( self.chunk_num > 0 ) then 
      assert(nil, "Too late to set memo")
    end
    if ( is_memo == self.is_memo ) then
      return -- No change made
    end
    if ( is_memo ) then 
      self.is_memo = true
      if ( not self.filename ) then 
        self.filename = ffi.malloc(32)
        qc['rand_file_name'](self.filename, 32-1)
      end
    else
      self.is_memo = false
      self.filename = nil
    end
  else
    -- change to log 
    print("No need to memo when materialized")
  end
end

function Vector:is_memo()
  return self.is_memo
end

function Vector:set(addr, idx, len)
  assert(addr)
  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  if ( chunk ) then
    -- have to start writing from where you left off
    assert( idx == nil)
    idx = self.num_in_chunk
    -- TODO < or <= ?
    -- if ( (len + num_in_chunk) < qconsts.chunk_size ) then
    local num_left_to_copy = len
    repeat 
      local space_in_chunk = qconsts.chunk_size - self.num_in_chunk)
      local num_to_copy = min(len, space_in_chunk)
      local dst = chunk + (idx * self.field_size)
      ffi.copy(dst, addr, num_to_copy)
      num_left_to_copy = num_left_to_copy - num_to_copy
      addr = addr + (num_to_copy * self.field_size)
      self.num_in_chunk = self.num_in_chunk + num_to_copy
    until num_left_to_copy == 0
  else
    assert(idx)
    assert(type(idx) == "number")
    assert(idx >= 0)
    assert(self.mmap)
    assert(idx < self.num_elements)
    assert(idx+len < self.num_elements)
    local dst = self.mmap.map_addr + (idx * self.field_size)
    local n = len * self.field_size
    ffi.copy(dst, addr, n)
  end
end

local function get(idx, len)
  local addr
  return addr
end

function Vector:eov()
  return self -- TODO 
end

function Vector:internals()
  return self -- TODO Check with IS
end

function Vector:delete()
  -- TODO 
end

function Vector:persist()
    -- TODO Add routine to materialize if not already materialized
    if self:ismemo() then
        return string.format("Vector{field_type='%s', filename='%s',}", 
            self.field_type, plpath.abspath(self.filename))
    else 
        return nil
    end
end

function Vector:__tostring()
    return self:persist()
end

return require('Q/q_export').export('Vector', Vector)
