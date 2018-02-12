local Q = require 'Q'

M = dofile './meta1.lua'
optargs = { is_hdr = true }
T = Q.load_csv("../data/data1.csv", M, optargs)
ccid = T[1]
assert(type(ccid) == "lVector")
-- Q.print_csv(ccid)
print("ALL DONE")
os.exit()
