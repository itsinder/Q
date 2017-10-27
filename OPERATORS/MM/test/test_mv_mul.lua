-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
num_trials = 1
if arg[1] ~= nil then
  num_trials = tonumber(arg[1])
end
local x1 = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8}, 'F8')
local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
local X = {x1, x2}
local Y = Q.mk_col({100, 200}, 'F8')
for i = 1, num_trials do 
  Z = Q.mv_mul(X, Y)
  Z:eval()
end
print(Z:num_elements())
print("Completed mv_mul")
Q.print_csv(Z, nil, "_out1.txt")
print("================")
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
