Q = require 'Q'

x = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, 'F8')

y = Q.approx_quantile(x, {err=2})
Q.print_csv(y, nil, "")
print("Completed")
os.exit()
