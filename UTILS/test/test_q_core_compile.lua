local qc = require 'Q/UTILS/lua/q_core'
local dotc = [[ #include "./boom.h"
int boom(){
printf("hello\n");
return 0;
}
]]
local doth = [[ #include <stdio.h>
int boom();
]]

assert( qc.q_add(doth, dotc, 'boom') == true)
assert( qc.q_add(doth, dotc, 'boom') == false)

qc.boom()
