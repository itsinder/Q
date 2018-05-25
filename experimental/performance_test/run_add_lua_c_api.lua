require("add")

local function sum_of_n()
  local input = 100000000

  local output = add(input)
  --print(tonumber(output))
end

for i = 1, 100 do
  sum_of_n()
end
print("DONE")
