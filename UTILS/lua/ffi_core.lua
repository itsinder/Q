return function()
  require 'globals'
  local plfile = require 'pl.file'
  local plpath = require 'pl.path'
  assert(plpath.isfile(q_core_h), "File not found " .. q_core_h)
  local str = assert(plfile.read(q_core_h), "File empty")
  --================================
  local ffi = require 'ffi'
  ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  ]])
  ffi.cdef(plfile.read(q_core_h))
  print(plfile.read(q_core_h))
  ffi.load(q_core_so)
  return ffi
end
