local Q_SRC_ROOT = os.getenv('Q_SRC_ROOT')
local Q_ROOT = os.getenv('Q_ROOT')
os.execute(string.format("rm %s/include/boom.h", Q_ROOT))
os.execute(string.format("rm %s/lib/libboom.so", Q_ROOT))

local qc = require 'Q/UTILS/lua/q_core'
local dotc = [[ #include "./boom.h"
int boom(){
printf("hello\n");
return 0;
}
]]
local doth = [[ #include <stdio.h>
extern int boom(void);
]]

assert( qc.q_add(doth, dotc, 'boom') == true)
assert( qc.q_add(doth, dotc, 'boom') == false)

qc.boom()
