-- data for mul operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/output_qtype'
return { 
  data = {
    { a = {10,2,35,10}, b = {10,20,2,9}, z = {100,40,70,90} }, -- simple values
  },
  output_qtype = qtype["promote"]
}