-- require 'strict'
local ffi = require 'ffi'
local plfile = require 'pl.file'
x = require 'Q/UTILS/lua/compiler'
local dotc = [[ #include "./boom.h"
int boom(void){
printf("hello\n");
return 0;
}
]]
local doth = [[ #include <stdio.h>
extern int boom(void);
]]
-- local cdef = x('#include <stdio.h>\nint boom(void);', '#include <stdio.h>\nint boom(void){printf("hello\n"); return 0;}', 't')
-- print(doth, dotc, 'boom')
local h_path, so_path = "./boom.h" , "./libboom.so"
x(doth, h_path, dotc, so_path, 'boom') 
ffi.cdef(plfile.read(h_path))
local X = ffi.load(so_path)
assert(tonumber(X.boom()) == 0 )

