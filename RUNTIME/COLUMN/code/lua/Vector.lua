--[[
Vector Semantics
    1. Pull Semantics
        1.1 Generator
            Params
                generator - The generator that is the source of data
        1.2 Read file
            Params
                chunk_size (optional) - The number of fields in each chunk, defaults to g_chunk_size
                field_type - The field type used, which must be present in g_valid_types
                field_size (optional) - The size of each element, defaults to getting it from g_valid_types
                filename - The file to be read from
    2. Push Semantics
        2.1 Write file
            Params
                chunk_size (optional) - The number of fields in each chunk, defaults to g_chunk_size
                field_type - The field type used, which must be present in g_valid_types
                field_size (optional) - The size of each element, defaults to getting it from g_valid_types
                filename (optional) - The file to be written out to, defaults to a random unused file
]]
local plpath = require("pl.path")
local Vector = {}
Vector.__index = Vector
local valid_types = {}
valid_types['i'] = 'int'
valid_types['f'] = 'float'
valid_types['d'] = 'double'
valid_types['c'] = 'char'
local self_chunk_size = 64
local valid_meta = {}
valid_meta["dir"] = 1
g_valid_types = g_valid_types or valid_types
g_chunk_size = g_chunk_size or self_chunk_size
g_valid_meta = g_valid_meta or valid_meta

local charset = {}
local ffi = require 'ffi' -- TODO INDRAJEET CAn this be in q_core

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

local function random_string(length_inp)
    math.randomseed(os.time())
    local length = length_inp or 11
    local result = {}
      for loop = 1,length do
         result[loop] = charset[math.random(1, #charset)]
      end
      return table.concat(result)
end

local function get_new_filename(length)
    local name = nil
    while (name == nil)
    do
        name = "_" .. random_string(length)
        local f=io.open(name,"r")
        if f ~=nil then
            io.close(f)
            name = nil
        else
            return name
        end
    end
    return name
end

function is_int(n)
  return n == math.floor(n)
end

local q_core = require 'q_core'
local ffi_malloc = require 'ffi_malloc'

local DestructorLookup = {}
setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

function Vector.destructor(data)
    -- Works with Lua but not luajit so adding a little hack
    if type(data) == type(Vector) then
        q_core.free(data.destructor_ptr)
    else
        -- local tmp_slf = DestructorLookup[data]
        DestructorLookup[data] = nil
        q_core.free(data)
    end
end

Vector.__gc = Vector.destructor

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Vector then
        return "Vector"
    end
    return otype
end

local function set_generator(self, arg)
    local gen = arg.gen
    assert(type(gen) == "Generator", "Expected a generator set to gen")
    self.generator = gen
    self.input_from_generator = true
    self.field_type = gen.field_type
    self.field_size = gen.field_size
    self.my_length = gen.length
    self.memoized = true
    self.is_materialized = false
    self.input_from_file = false
    self.filename = arg.filename or get_new_filename(10) -- file name to write to
    return self

end

local function read_file_vector(self, arg)
    self.input_from_file = true
    self.filename = assert(arg.filename, "Filename not specified to read from")
    self.f_map = ffi.gc(q_core.f_mmap(self.filename, false), 
      q_core.f_munmap)
    assert(self.f_map.status == 0, "Mmap failed")
    self.cdata = self.f_map.ptr_mmapped_file
    --mmap the file
    --take length of file to be length of vector
    self.memoized = true
    self.is_materialized = true
    self.my_length = tonumber(self.f_map.file_size) / self.field_size
    self.max_chunks = math.ceil(self.my_length/self.chunk_size)
    return self
end

local function write_file_vector(self, arg)
    self.output_to_file = true
    self.filename = arg.filename or get_new_filename(10)
    -- ensure the file is empty to avoid confusion
	local f = io.open(self.filename,"r")
	if f ~= nil then
		io.close(f)
		os.remove(self.filename)
	end
   self.is_materialized = false
    self.my_length = 0
    return self
end

function Vector.new(arg)
    local vec = setmetatable({}, Vector)
    vec.meta = {}
    vec.destructor_ptr= ffi.gc(ffi_malloc(1), Vector.destructor) -- Destructor hack for luajit
    DestructorLookup[vec.destructor_ptr] = vec
    assert(type(arg) == "table", "Called constructor with incorrect arguements")
    vec.chunk_size = arg.chunk_size or g_chunk_size
    if arg.generator ~= nil then -- generator as input
        set_generator(vec, arg)
    else -- No generator
        assert(arg.field_type ~= nil and g_valid_types[arg.field_type] ~= nil, "Valid type not given")
        vec.field_type = arg.field_type
        if arg.field_size == nil then -- for constant length string this cannot be nil
            local type_val =  assert(g_valid_types[arg.field_type], "Invalid type")
            vec.field_size = ffi.sizeof(type_val)
        else
            vec.field_size = arg.field_size
        end

        if arg.write_vector == true then
            write_file_vector(vec, arg)
        else
            if arg.filename ~= nil then -- filename means read from file
                read_file_vector(vec, arg)
            else
               dbg() 
               error('No data input to vector. Need either a file or a generator')
            end
        end
    end
    local buff_size = vec.field_size * vec.chunk_size
    vec.buffer = ffi_malloc(buff_size)
    return vec
end

function Vector:length()
    return self.my_length
end

function Vector:fldtype()
    return self.field_type
end

function Vector:sz()
    --size of each entry
    return self.field_size
end

function Vector:memo(bool)
    assert(type(bool) == "boolean", "Incorrect type supplied")
    assert(self.input_from_file ~= true, "Input from file is always memoized and cannot be changed")
    assert(self.last_chunk_number == nil, "Cannot set this after calls to chunk")
    self.memoized = bool
end

function Vector:ismemo()
    return self.memoized
end

function Vector:last_chunk()
    return self.last_chunk_number
end

local function append_to_file(self, ptr, size)
    assert(ptr ~= nil, "No pointer given to write")
    assert(self.filename ~= nil, "Filename should have been set in constructor")
    size = size or self.chunk_size

    assert(self.input_from_file ~= true, "Cannot write to input file")

    if self.file == nil  or self.file == ffi.NULL then
        if self.field_type == "B1" then -- except for bits append only applies. TODO change this by buffering
            self.file = q_core.fopen(self.filename, "wb+")
        else
            self.file = q_core.fopen(self.filename, "ab+")
        end
        assert(self.file ~= ffi.NULL, "Unable to open file")
    end
    -- write out buffer to file
    -- TODO make more general based on field size
    if self.field_type == "B1" then
        assert(tonumber(q_core.write_bits_to_file(self.file, ptr, size, self.my_length)) == 0 , "Unable to write to file")
    else
        assert(q_core.fwrite(ptr,self.field_size, size, self.file) == size, "Unable to write to file")
    end
end

local function flush_remap_file(self)

    assert(self.filename ~= nil, "Filename should have been set in constructor")
    assert(self.input_from_file ~= true, "No need to mmap a file that is mmap in constructor")
    assert(self.file ~= nil, "No file to mmap to")
    q_core.fflush(self.file) -- fflush to current state before mmaping
    self.file_last_chunk_number = self.last_chunk_number
    self.f_map = ffi.gc(q_core.f_mmap(self.filename, false), 
    q_core.f_munmap)
    assert(self.f_map.status == 0, "Mmap failed")
    self.cdata = self.f_map.ptr_mmapped_file
end

function Vector:materialized()
    return self.is_materialized
end

local function get_from_generator(self, num)
    assert(self.generator:status() ~= "dead", "Cannot get more data from generator")
    local status, buffer, size = self.generator:get_next_chunk()
    assert(status, buffer)

    self.last_chunk_number = num
    -- if memoized then add to file
    if self.memoized then
        append_to_file(self, self.last_chunk_buf, self.last_chunk_size)
    end
    self.last_chunk_buf = buffer
    self.last_chunk_size = size
    -- now check if the materialization is complete
    if self.generator:status() == "dead" then
        assert(math.ceil(self.my_length/self.chunk_size) - 1  == num)
        self.is_materialized = true
        flush_remap_file(self)
    end
    return self.last_chunk_buf, self.last_chunk_size
end

local function get_from_file(self, num)
    if num >= 0 then
        if num < self.max_chunks then
            local chunk_size = self.chunk_size
            if num == self.max_chunks -1 then
                chunk_size = self.my_length - num*self.chunk_size
            end
            --return nil --return the mmapped location of the file
            -- TODO change this as we are doing custom types Think in terms of
            -- bytes and bits
            local ptr = ffi.cast("unsigned char*", self.cdata)
            return ffi.cast("void *", ptr + self.chunk_size * num * self.field_size), chunk_size
        else
            -- error('Invalid chunk number')
            -- TODO Or should i just return a 0 , nil , nil
            return 0, nil, nil
        end
    else
        return self.cdata, self.my_length -- a mmap to the ramfs file
    end

end

local function update_max_chunks(self)
 self.last_chunk_number = math.ceil(self.my_length/ self.chunk_size) -1
end

function Vector:get_element(num)
   -- assert(num <= self.my_length, "The element queried should be in the vector")
   assert(is_int(num), "chunks need to be integer type")
   assert(num >= 0, "Requires a a whole number")
   local chunk, size = self:chunk( math.floor(num / self.chunk_size))
   local offset = num % self.chunk_size
   assert(offset <= size , "element needs to be in current chunk")
   chunk = ffi.cast("unsigned char*", chunk)
   if self.field_type == "B1" then
      --first get offset in char and then get the correct bit
      local char_offset = offset / 8
      local bit_offset = offset % 8
      local char_value = chunk + char_offset
      local bit_value = tonumber( q_core.get_bit(char_value, bit_offset) )
      if bit_value == 0 then
         return ffi.NULL
      else
         return 1
      end
   else
      return ffi.cast("void *", chunk +  offset * self.field_size)

   end
end

function Vector:chunk(num)
    assert(type(num) == "number", "Require a number for chunk number")
    assert(is_int(num), "chunks need to be integer type")
    -- assert(num >= 0, "Requires a a whole number")

    if self:materialized() then
        return get_from_file(self, num)
    else -- if not materialized
        if num < 0 then return self.cdata, self.my_length end
        if num < self:last_chunk() then
            if self.memoized == true then
                if num > self.file_last_chunk_number then flush_remap_file(self) end
                local ptr = ffi.cast("unsigned char*", self.cdata)
                return ffi.cast("void *", ptr + self.chunk_size * num * self.field_size), self.chunk_size
            else
                error("Cannot return past chunk for non memoized function")
            end
        elseif num == self:last_chunk() then
            assert(self.my_length % self.chunk_size == 0, "Incomplete chunk cannot be returned")
             if num > self.file_last_chunk_number then flush_remap_file(self) end
             local ptr = ffi.cast("unsigned char*", self.cdata)
             return ffi.cast("void *", ptr + self.chunk_size * num * self.field_size), self.chunk_size
        elseif num == self:last_chunk() + 1 then
            if self.input_from_generator == true then
                local status, buffer, size = get_from_generator(self, num)
                assert(status, "No chunk found: " .. buffer)
                if self.memoized == true then
                    append_to_file(self, buffer, size)
                    self.my_length = self.my_length + size -- memoized
                else
                    self.my_length = size -- non memoized
                end
                update_max_chunks(self)
                return buffer, size
            elseif self.output_to_file == true then
                error("Vector does not support pull semantics in this mode")
            elseif self.input_from_file then
                error("I should not be here")
            end
        elseif num > self:last_chunk() + 1 then
            error("Cannot return the chunk yet, beyond max available")
        end

    end
end

function Vector:put_chunk(chunk, length)
     assert(self.output_to_file == true,  "Cannot be write to non output vector")
     assert(self.is_materialized ~= true, "The vector is already materialized")
    append_to_file(self, chunk, length)
    self.my_length = self.my_length + length
end

function Vector:eov()
    q_core.fflush(self.file)
    self.input_from_file = true
    self.f_map = ffi.gc(q_core.f_mmap(self.filename, false), q_core.f_munmap)
    assert(self.f_map.status == 0, "Mmap failed")
    self.cdata = self.f_map.ptr_mmapped_file
    --mmap the file
    --take length of file to be length of vector
    self.memoized = true
    self.is_materialized = true
    -- self.my_length = tonumber(self.f_map.ptr_file_size) / self.field_size
    self.max_chunks = math.ceil(self.my_length/self.chunk_size)
end

function Vector:delete()
    assert(tonumber(q_core.fclose(self.file)))
    self.f_map = nil -- Causing the file to be unmmapped 
    if self.memoized then
        os.remove(self.file_name)
    end
end

function Vector:persist()
    -- TODO Add routine to materialize if not already materialized
    if self.memoized then
        return string.format("Vector{field_type='%s', filename='%s',}", 
            self.field_type, plpath.abspath(self.filename))
    else 
        return nil
    end
end

function Vector:__tostring()
    return self:persist()
end

return Vector
