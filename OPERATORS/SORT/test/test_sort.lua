-- FUNCTIONAL 
Q = require 'Q'
require 'Q/UTILS/lua/strict'
x = Q.mk_col({10, 20, 30, 40}, 'I4')
print(type(x))
print(x:length())
Q.sort(x, "dsc")
Q.print_csv(x, nil, "")
save = require 'Q/UTILS/lua/save'
save('tmp.save')
print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
