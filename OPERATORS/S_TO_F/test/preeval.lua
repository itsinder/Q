local Q = require 'Q'
local ffi = require 'Q/UTILS/lua/q_ffi'
local x = Q.const({ val = 1, len = 1025, qtype = 'F8' })
local y = Q.const({ val = 1, len = 1025, qtype = 'F8' })
local sz, xc, nxc = x:chunk(-1)
print(sz, xc, nxc)
assert(sz == 0 )
assert(xc == nil )
assert(nxc == nil )
local sz, xc, nxc = y:chunk(-1)
print(sz, xc, nxc)

assert(sz == 0 )
assert(xc == nil )
assert(nxc == nil )

print("Successfully completed in " .. arg[0])
