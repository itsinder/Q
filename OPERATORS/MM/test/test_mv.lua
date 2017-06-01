Q = require 'Q'
x1 = Q.mk_col({10, 20, 30, 40}, 'F8')
x2 = Q.mk_col({10, 20, 30, 40}, 'F8')
X = {x1, x2}
Y = Q.mk_col({10, 20}, 'F8')
Z = Q.mvmul(X, Y)
Q.print_csv(Z, nil, "")
print("Completed")
os.exit()
