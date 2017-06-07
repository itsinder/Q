-- data for add operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {10,20,30,40}, b = {10,20,30,40}, z = {20,40,60,80} }, -- simple values
    -- only F4 and F8 type will be run for the below data
    { a = {10.1,20.2,30.2}, b = {10.5,20.3,30.3}, z = {20.6,40.5,60.5}, qtype = {"F4", "F8"} },  
  },
  output_ctype = "auto"
}