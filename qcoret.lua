local ffi = require "ffi"
ffi.cdef([[
void *memset(void *s, int c, size_t n);
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
local q_root = os.getenv("Q_ROOT")
assert(plpath.isdir(q_root))

incfile = q_root .. "/include/q_core.h"
assert(plpath.isfile(incfile))
ffi.cdef(plfile.read(incfile))

sofile = q_root .. "/lib/libq_core.so"
assert(plpath.isfile(sofile))
local cee = ffi.load(sofile)


local q_core = {} 
q_core.gc = ffi.gc
q_core.cast = ffi.cast
q_core.sizeof = ffi.sizeof
q_core.NULL = ffi.NULL
local q_core_mt = {
    __newindex = function(self, key, value)
        print("newindex metamethod called")
        print(key, value)
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
    __len = function(self)
        print("len metamethod called")
    return #self.index_to_string end,
}

return setmetatable(q_core, q_core_mt)