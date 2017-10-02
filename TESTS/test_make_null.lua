-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
Scalar = require 'libsclr' ; 

x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
y = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
bady1 = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 0}, "B1")
bady2 = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "I4")
-- print(Q.sum(x):eval())
-- print(Q.sum(y):eval())
x:make_nulls(y)
assert(x:has_nulls() == true)
-- ptrs should reflect existence of nn vector
len, xptr, nn_xptr = x:chunk()
assert(len > 0)
assert(xptr)
assert(nn_xptr) -- must have null value now 
--
-- cannot set null vector if one already set 
status = pcall(x.make_nulls, y)
assert(status == false)

-- try some "bad" values for bit vector
x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
status = pcall(x.make_nulls, x, bady1)
assert(status == false)
status = pcall(x.make_nulls, x, bady2)
assert(status == false)
status, err = pcall(x.make_nulls, x, y)
assert(status == true)

x:drop_nulls()
assert(x:has_nulls() == false)
-- multiple deletions of null vector okay
assert(x:drop_nulls())
assert(x:drop_nulls())
assert(x:drop_nulls())
-- can add null vector after deleting it 
status, err = pcall(x.make_nulls, x, y)
assert(status == true)

assert(x:check())


--==========================
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
