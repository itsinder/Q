Q = require 'Q'
x1 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
X = {x1, x2}
Y = Q.mk_col({10, 20}, 'F8')
Z = Q.mvmul(X, Y)
w = Q.cmvmul(X, Y)
-- x = Q.sum(Q.vveq(z, w))
-- assert(x == x1:length())
Q.print_csv(Z, nil, "")
w:eval()
Q.print_csv(w, nil, "")
print("Completed")
os.exit()
