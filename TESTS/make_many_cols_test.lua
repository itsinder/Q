local Q = require 'Q'

for i = 1,10000 do
  local c1 = Q.mk_col({1, 9, 2, 8, 3, 7}, "I4")
  local c2 = Q.mk_col({7, 1, 3, 2, 1, 0}, "I4")
  c1:eval()
  c2:eval()
end
