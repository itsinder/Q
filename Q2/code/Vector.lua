local Vector = {}
Vector.__index = Vector
g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_chunk_size = 64
local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

local function random_string(length_inp)
    math.randomseed(os.time())
    local length = length_inp or 11
    if length > 0 then
        return random_string(length - 1) .. charset[math.random(1, #charset)]
    end
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


local ffi = require 'ffi'
ffi.cdef([[
typedef struct {
  char *fpos;
  void *base;
  unsigned short handle;
  short flags;
  short unget;
  unsigned long alloc;
  unsigned short buffincrement;
} FILE;
void * malloc(size_t size);
void free(void *ptr);
typedef struct {void* ptr_mmapped_file; size_t ptr_file_size; int status; } mmap_struct;
mmap_struct* vector_mmap(const char* file_name, bool is_write);
int vector_munmap(mmap_struct* map);
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
int fwrite(void *Buffer,int Size,int Count,FILE *ptr);
int fflush(FILE *stream);
    ]])

local c = ffi.load('./vector_mmap.so')
local C = ffi.C
local DestructorLookup = {}
setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })
function Vector.destructor(data)
    print "bye" -- Works with Lua but not luajit so adding a little hack
    if type(data) == type(Vector) then
        print "gc is called directly"
        C.free(data.destructor_ptr)
    else
        print "using ptr"
        local tmp_slf = DestructorLookup[data]
        DestructorLookup[data] = nil
        C.free(data)
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

function Vector:set_generator(gen)
    if type(gen) ~= "Generator" then
        error("Expected a generator set to gen")
    end
    self.generator = gen
    self.input_from_generator = true
    self.field_type = gen.field_type
    self.field_size = gen.field_size
    self.length = gen.length
    self.field_size = gen.field_size
    self.memoized = true
    self.is_materialized = false
    self.input_from_file = false
    self.filename = get_new_filename(10) -- file name to write to
    return self

end

function Vector:read_file_vector(arg)
    self.input_from_file = true
    self.filename = arg.filename
    self.f_map = ffi.gc(c.vector_mmap(self.filename, false), c.vector_munmap)
    if self.f_map.status ~= 0 then
        error("Mmap failed")
    end
    self.cdata = self.f_map.ptr_mmapped_file
    --mmap the file
    --take length of file to be length of vector
    self.memoized = true
    self.is_materialized = true
    self.length = tonumber(self.f_map.ptr_file_size) / self.field_size
    self.max_chunks = math.ceil(self.length/self.chunk_size)
    return self
end

function Vector:write_file_vector(arg)
    self.output_to_file = true
    self.filename = arg.filename or get_new_filename(10)
    self.is_materialized = false
    return self
end

function Vector.new(arg)
    local self = setmetatable({}, Vector)
    self.destructor_ptr=ffi.gc(C.malloc(1), Vector.destructor) -- Destructor hack for luajit
    DestructorLookup[self.destructor_ptr] = self
    if type(arg) ~= "table" then
        error("Called constructor with incorrect arguements")
    end
    self.chunk_size = arg.chunk_size or g_chunk_size
    if arg.generator ~= nil then -- generator as input
        local gen = arg.generator
        if type(gen) ~= "Generator" then
            error("Expected a generator set to gen")
        end
        return self:set_generator(gen)
    end

    -- No generator
    if arg.field_type == nil or g_valid_types[arg.field_type] == nil
        then error("Valid type not given")
    end
    self.field_type = arg.field_type
    -- TODO only size maybe type is not important
    -- Make changes to enable registering of global structs etc. Type or number.
    -- If number alone then type is custom
    if arg.field_size == nil then -- for constant length string. For errors I can set the size to -1 and catch that if needed
        local type_val =  g_valid_types[arg.field_type]
        if type_val == nil then
            error("Invalid type")
        end
        self.field_size = ffi.sizeof(type_val)
    else
        self.field_size = arg.field_size
    end
    -- what are the cases where field type is irrelevant

    if arg.write_vector == true then
        return self:write_file_vector(arg)
    end
    if arg.filename ~= nil then -- filename means read from file
        self:read_file_vector(arg)
    else
        error('No data input to vector. Need either a file or a generator')
    end

    local buff_size = self.field_size * self.chunk_size
    self.buffer = ffi.gc( C.malloc(buff_size), C.free)
    return self
end

function Vector:length()
    return self.length
end

function Vector:fldtype()
    return self.field_type
end

function Vector:sz()
    --size of each entry
    return self.field_size
end

function Vector:memo(bool) 
    if type(bool) ~= "boolean" then
        error("Incorrect type supplied")
    end
    if self.last_chunk_number ~= nil then
        error("Cannot set this after calls to chunk")
    end
    if self.input_from_file then
        error("Input from file is always memoized and cannot be changed")
    end
    self.memoized = bool
end

function Vector:ismemo()
    return self.memoized
end

function Vector:last_chunk()
    return self.last_chunk_number
end


function Vector:append_to_file(ptr, size)
    ptr = ptr or self.last_chunk_buf
    size = size or self.chunk_size
    if self.filename == nil then error("Filename should have been set in constructor") end
    if self.input_from_file == true then error("Cannot write to input file") end
    if self.file == nil then
        self.file = C.fopen(self.filename, "ab+")
        if self.file == ffi.NULL then
            self.file = nil
            error('Unable to open file')
        end
    end
    -- write out buffer to file
    c.fwrite(ptr,self.field_size, size, self.file)
end

function Vector:map_to_file()
    if self.filename == nil then error("Filename should have been set in constructor") end
    if self.input_from_file == true then error("No need to mmap a file that is mmap in constructor") end
    if self.file == nil then error("No file to mmap to") end
    c.fflush(self.file) -- fflush to current state before mmaping
    self.file_last_chunk_number = self.last_chunk_number
    self.f_map = ffi.gc(c.vector_mmap(self.filename, false), c.vector_munmap)
    if self.f_map.status ~= 0 then
        error("Mmap failed")
    end
    self.cdata = self.f_map.ptr_mmapped_file
end

function Vector:materialized()
    return self.is_materialized
end

function Vector:get_from_generator(num)
    if self.generator:status() == "dead" then
        error("Cannot produce any more data")
    end
    status, buffer, size = self.generator:get_next_chunk()
    if status == false then error(buffer) end
    self.last_chunk_number = num
    -- if memoized then add to file
    if self.memoized then
        self:append_to_file(self.last_chunk_buf, self.last_chunk_size)
    end
    self.last_chunk_buf = buffer
    self.last_chunk_size = size
    -- now check if the materialization is complete
    -- Two ways to do it, check the length of the vector or
    -- status of generator. Right now just using length
    if self.generator:status() == "dead" then
        --if math.ceil(self.length/self.chunk_size) == num then
        --TODO Add assert to here whenever you know something has to be true
        self.is_materialized = true
        self:map_to_file()
    end
    return self.last_chunk_buf, self.last_chunk_size
end

function Vector:get_from_file(num)
    if num >= 0 then
        if num < self.max_chunks then
            local chunk_size = self.chunk_size
            if num == self.max_chunks -1 then
                chunk_size = self.length - num*self.chunk_size
            end
            --return nil --return the mmapped location of the file
            local ptr = ffi.cast(g_valid_types[self.field_type] .. '*', self.cdata)
            return ffi.cast('void*', ptr + self.chunk_size*num), chunk_size
        else
            error('Invalid chunk number')
        end
    else
        return self.cdata -- a mmap to the ramfs file --TODO Add vector length
    end

end

function Vector:chunk(num)
    if type(num) ~= "number" then
        error("Require a number for chunk number")
    end
    if self:materialized() then
        return self:get_from_file(num)
    else -- if not materialized
        if num < self:last_chunk() then
            if self.memoized == true then
                if num > self.file_last_chunk_number then
                    --flush temp file mmap updated file
                    self:map_to_file() -- better name flush and remmap
                end
                local ptr = ffi.cast(g_valid_types[self.field_type] .. '*', self.cdata)
                return ffi.cast('void*', ptr + self.chunk_size*num)
            else
                error("Cannot return past chunk for non memoized function")
            end
        elseif num == self:last_chunk() then
            return self.last_chun_kbuf, self.last_chunk_size
        elseif num == self:last_chunk() + 1 then
            if self.input_from_generator == true then
                return self:get_from_generator(num)
            elseif self.output_to_file == true then
                error("Yet to implement")
            elseif self.input_from_file then
                error("I should not be here")
            end
        elseif num > self:last_chunk() + 1 then
            error("Cannot return the chunk yet max number available is " .. self:last_chunk() .. " but was asked for " .. num)
        end

    end
end

function Vector:put_chunk(chunk, length)
    if self.output_to_file ~= true or self.is_materialized == true then
        error("This vector cannot be written to")
    end
    self:append_to_file(chunk, length)
end

function Vector:eov()
    c.fflush(self.file)
    self.input_from_file = true
    self.f_map = ffi.gc(c.vector_mmap(self.filename, false), c.vector_munmap)
    if self.f_map.status ~= 0 then
        error("Mmap failed")
    end
    self.cdata = self.f_map.ptr_mmapped_file
    --mmap the file
    --take length of file to be length of vector
    self.memoized = true
    self.is_materialized = true
    self.length = tonumber(self.f_map.ptr_file_size) / self.field_size
    self.max_chunks = math.ceil(self.length/self.chunk_size)
end
   
return Vector
