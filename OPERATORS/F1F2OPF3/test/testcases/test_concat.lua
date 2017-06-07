-- data for div operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/output_qtype'
return { 
  data = {
    { a = {1,52,37,92}, b = {1,5,3,10}, z = {4,2,1,2}, qtype = {"I1", "I2"} }, -- simple values
  },
  output_qtype = qtype["concat"]
}