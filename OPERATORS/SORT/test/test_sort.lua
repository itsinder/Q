Q = require 'Q'
x = Q.mk_col({10, 20, 30, 40}, 'I4')
print(type(x))
print(x:length())
require 'Q/OPERATORS/SORT/lua/sort'
sort(x, "dsc")
-- Q.sort(x, "dsc")
Q.print_csv(x, nil, "")
save = require 'Q/UTILS/lua/save'
save('tmp.save')
print("Completed")
os.exit()
