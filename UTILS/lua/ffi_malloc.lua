local ffi = require 'ffi'
ffi.cdef([[
void * malloc(size_t size);
void free(void *ptr);
]])

return function(n)
  assert(n > 0, "Cannot malloc 0 or less bytes")
  local c_mem = assert(ffi.gc(ffi.C.malloc(n), ffi.C.free))
  return c_mem
end
