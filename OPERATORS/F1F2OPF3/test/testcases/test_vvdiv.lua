-- data for div operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/output_qtype'
return { 
  data = {
    { a = {70,55,30,90}, b = {10,5,3,10}, z = {7,11,10,9} }, -- simple values
  },
  output_qtype = qtype["promote"]
}