-- Why did I write this?? TODO P3
local t1 = require 'arith_operators'
local t2 = require 'bop_operators'
for i, v in ipairs(t2) do t1[#t1+1] = v end
local t2 = require 'cmp_operators'
for i, v in ipairs(t2) do t1[#t1+1] = v end
local t2 = require 'concat_operators'
for i, v in ipairs(t2) do t1[#t1+1] = v end

-- for i, v in ipairs(t1) do print(i, v) end
return t1

