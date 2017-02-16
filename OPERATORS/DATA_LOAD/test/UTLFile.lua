local lu = require("luaunit")
local ffi = require("ffi")
local lib = ffi.load("./UTCFile.so")

ffi.cdef [[
  void *malloc(size_t size);
  void free(void *ptr);
  
  void initialize( int32_t *a, int32_t *b, uint64_t n);
  int add_I4_I4_I4( int32_t *a, int32_t *b, uint64_t n, int32_t *c);
]]

Type="int32_t"


function testUnitPrimitive()
  n = 5
  sizeofdata = n * 4 
  local a = ffi.C.malloc(sizeofdata)
  local b = ffi.C.malloc(sizeofdata)
  
  lib["initialize"](a, b, n)

  c = ffi.new(Type .. "[" .. n .. "]"); 
  status = lib["add_I4_I4_I4"](a, b, n, c )
    
    --[[
    for i=1, n do
      print(c[i])
    end
    --]]
  lu.assertEquals(c[1], 2)
  lu.assertEquals(c[2], 6)
  lu.assertEquals(c[3], 12)
  lu.assertEquals(c[4], 20)
  lu.assertEquals(c[5], 30)
  
  ffi.gc( a, ffi.C.free )
  ffi.gc( b, ffi.C.free )
end

os.exit( lu.LuaUnit.run() )
