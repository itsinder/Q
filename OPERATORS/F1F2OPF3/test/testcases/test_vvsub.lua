-- data for sub operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/output_qtype'
return { 
  data = {
    { a = {20,40,30,100}, b = {10,20,10,10}, z = {10,20,20,90} }, -- simple values
  },
  output_qtype = qtype["promote"]
}