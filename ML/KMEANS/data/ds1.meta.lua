local tbl = {}
local nF = 17
for i = 1, nF do
  local x = {}
  x.name = "feature_" .. i
  x.qtype = "F8"
  tbl[i] = x
end
return tbl
