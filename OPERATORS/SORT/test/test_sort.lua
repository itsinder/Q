Q = require 'Q'
x = Q.mk_col({10, 20, 30, 40}, 'I4')
print(type(x))
print(x:length())
Q.sort(x, "dsc")
-- Q.sort(x, "dsc")
Q.print_csv(x, nil, "")
save = require 'Q/UTILS/lua/save'
save('tmp.save')
print("SUCCESS for " .. arg[0])
os.exit()
