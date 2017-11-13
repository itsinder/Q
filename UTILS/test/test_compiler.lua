require 'strict'
local ffi = require 'ffi'
x = require 'compiler'
local dotc = [[ #include "./boom.h"
int boom(){
printf("hello\n");
return 0;
}
]]
local doth = [[ #include <stdio.h>
int boom();
]]
-- local cdef = x('#include <stdio.h>\nint boom(void);', '#include <stdio.h>\nint boom(void){printf("hello\n"); return 0;}', 't')
local cdef = x(doth, dotc, 'boom')
print(cdef)
ffi.cdef(cdef)
local X = ffi.load('libboom.so')
print(X.boom())

