
s = "123";
x = C.ffi.malloc(4)
y = C.ffi.txt_to_I4(s, x)
assert(y == 0)

s = "123.0";
x = C.ffi.malloc(4)
y = C.ffi.txt_to_I4(s, x)
assert(y ~= 0)


a = C.ffi.new("int32_t [1, 2, 3, 4]")
b = C.ffi.new("float [5, 6, 7, 8]")
c = C.ffi.malloc(4 * sizeof(double));

status = add_I4_I4_I8(a, b, 4, c)
assert(status == 0 )
-- now some checking of c would be nice
