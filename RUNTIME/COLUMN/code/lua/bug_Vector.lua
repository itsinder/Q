local qconsts = require 'Q/UTILS/lua/q_consts'
local plpath  = require 'pl.path'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local dbg = require 'Q/UTILS/lua/debugger'

local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

local function nascent_vec(self)
  local sz = qconsts.chunk_size * self.field_size
  print("Allocating bytes  = ", sz)
  self.chunk = ffi.new("char[?]", sz)
  assert(self.chunk)
  ffi.fill(self.chunk, sz)
  self.chunk_num    = 0
  self.num_in_chunk = 0
  self.num_elements = 0
  self.is_memo = true
  return self
end

function Vector:check()
  --================================================
  assert(self.field_type)
  assert(type(self.field_type) == "string")
  if ( self.field_type ~= "SC" ) then 
    assert(self.field_size == qconsts.qtypes[self.field_type].width)
  else
    assert(self.field_size >= 2)
  end
  --================================================
    assert(self.chunk)

    assert(self.chunk_num)
    assert(type(self.chunk_num) == "number")
    assert(self.chunk_num >= 0 )

    assert(self.num_in_chunk)
    assert(type(self.num_in_chunk) == "number")
    assert(self.num_in_chunk >= 0 )

    assert(self.is_write == nil)
    if ( self.chunk_num >= 1 ) then 
      assert(plpath.isfile("_xxx.bin"))
      local file_size = (self.chunk_num*self.field_size*qconsts.chunk_size)
      assert(file_size == plpath.getsize("_xxx.bin"))
      assert(((self.chunk_num * qconsts.chunk_size) + self.num_in_chunk)
      == self.num_elements)
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
    vec.field_size = qconsts.qtypes[qtype].width
  end
  --====== is vector materialized or nascent
    vec = assert(nascent_vec(vec))
  return vec
end

function Vector:set(addr, idx, len)
  assert(addr)
  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
    -- have to start writing from where you left off
    assert( idx == nil)
    local initial_num_elements = self.num_elements
    -- TODO < or <= ?
    -- if ( (len + num_in_chunk) < qconsts.chunk_size ) then
    local num_left_to_copy = len
    repeat 
      local space_in_chunk = qconsts.chunk_size - self.num_in_chunk
      if ( space_in_chunk == 0 )  then
        if ( self.is_memo ) then
          local use_c_code = true
          if ( use_c_code ) then 
            print("C: Writing to file", self.chunk)
            local status = qc["buf_to_file"](self.chunk,
            self.field_size, self.num_in_chunk, "_xxx.bin")
            print("C: Done with file")
          else 
            local fp = ffi.C.fopen("_xxx.bin", "a")
            print("L: Opened file")
            local nw = ffi.C.fwrite(self.chunk, self.field_size, 
              qconsts.chunk_size, fp);
            print("L: Wrote to file")
            -- assert(nw > 0 )
            ffi.C.fclose(fp)
            print("L: Done with file")
          end
        end
        self.num_in_chunk = 0
        self.chunk_num = self.chunk_num + 1
        space_in_chunk = qconsts.chunk_size
      end

      local num_to_copy  = len
      if ( space_in_chunk < len ) then 
        num_to_copy = space_in_chunk
      end
      num_left_to_copy = num_left_to_copy - num_to_copy
      self.num_in_chunk = self.num_in_chunk + num_to_copy
      self.num_elements = self.num_elements + num_to_copy
    until num_left_to_copy == 0
    assert(self.num_elements == initial_num_elements + len)
   -- if ( qconsts.debug ) then self:check() end
end

return require('Q/q_export').export('Vector', Vector)
