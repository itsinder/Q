local ffi = require "ffi"
ffi.cdef([[
void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
size_t strlen(const char *str);
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
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
int fwrite(void *Buffer,int Size,int Count,FILE *ptr);
int fflush(FILE *stream);
]])
local plpath = require 'pl.path'
local plfile = require 'pl.file'

-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")
local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local Q_ROOT = os.getenv("Q_ROOT") -- TODO DISCUSS WITH SRINATH
-- print (Q_ROOT)
-- Sri 27/05/17: why global decl for infile, sofile? making local to see if something breaks

local incfile = Q_ROOT .. "/include/q_core.h"
assert(plpath.isfile(incfile), "File not found " .. incfile)
ffi.cdef(plfile.read(incfile))

-- TODO issue with load indicates install issue; but is separate flow... is check needed?
local cee =  ffi.load('libq.so')
local q_core = {}
q_core.Q_ROOT = Q_ROOT
q_core.gc = ffi.gc
q_core.cast = ffi.cast
q_core.sizeof = ffi.sizeof
q_core.NULL = ffi.NULL
q_core.string = ffi.string
q_core.cee = cee
q_core.copy = ffi.copy
q_core.new = ffi.new
q_core.fill = ffi.fill
q_core.malloc = function(n, free_func)
   assert(n > 0, "Cannot malloc 0 or less bytes")
   local c_mem = nil
   if free_func == nil then
      c_mem = assert(q_core.gc(ffi.C.malloc(n), ffi.C.free))
   elseif type(free_func) == "function" then
      c_mem = assert(q_core.gc(ffi.C.malloc(n), free_func))
   else
      error("Invalid free function specified")
   end
   return c_mem
end


q_core.memset = function(buffer, value, size)
   assert( buffer ~= nil, "Buffer cannot be nil")
   assert(size > 0, "Cannot memset 0 or less bytes")
   assert(ffi.C.memset(buffer, value, size), "ffi memset failed")
end

q_core.memcpy = function(dest, src, size)
   assert( dest ~= nil, " destination buffer cannot be nil")
   assert( src ~= nil, " source buffer cannot be nil")
   assert(size > 0, "Cannot memset 0 or less bytes")
   assert(ffi.C.memcpy(dest, src, size), "ffi memcpy failed")
end

local q_core_mt = {
   __newindex = function(self, key, value)
      print("newindex metamethod called")
      print(key, value)
      error("Assignment to q_core is not allowed")
   end,
   __index = function(self, key)
      -- Called only when the string we want to use is an
      -- entry in the table, so our variable names
      if key == "NULL" then
         return ffi.NULL
      else
         return cee[key]
      end
   end,
}
return setmetatable(q_core, q_core_mt)
