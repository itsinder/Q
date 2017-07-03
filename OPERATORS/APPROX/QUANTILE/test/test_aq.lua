local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local x = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, 'I4')
local quantiles, is_good = Q.approx_quantile(x, {num_quantiles = 2, err = 0.1 })
Q.print_csv(quantiles, nil, "")
print("SUCCESS for ", arg[0])
os.exit()
