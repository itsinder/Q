local t1 = require 'Q/OPERATORS/F1S1OPF2/lua/arith_operators'
local t2 = require 'Q/OPERATORS/F1S1OPF2/lua/cmp2_operators'
for i, v in ipairs(t2) do t1[#t1+1] = v end
local t2 = require 'Q/OPERATORS/F1S1OPF2/lua/cmp_operators'
for i, v in ipairs(t2) do t1[#t1+1] = v end
local t2 = require 'Q/OPERATORS/F1S1OPF2/lua/operators0'
for i, v in ipairs(t2) do t1[#t1+1] = v end

-- for k, v in ipairs(t1) do print(k, v) end
return t1