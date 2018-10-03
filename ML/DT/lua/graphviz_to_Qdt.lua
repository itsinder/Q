local plstring = require 'pl.stringx'

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from_file(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

local function print_dt(
  D,	-- prepared decision tree
  f
)
  if D.left and D.right then
    local label = D.label
    local left_label = D.left.label
    local right_label = D.right.label
    f:write(label .. " -> " .. left_label .. "\n")
    f:write(label .. " -> " .. right_label .. "\n")

    print_dt(D.left, f)
    print_dt(D.right, f)
  else
    -- No tree available
  end
end

function modify(D, a, b)
  assert(a," a is required")
  if D.label == nil then 
    D.label = a
    D.left = {}
    D.left.label = b
  elseif  D.label == a and D.left == nil then
    D.left = {}
    D.left.label = b
  elseif  D.label == a and D.right == nil then
    D.right = {}
    D.right.label = b
  end
  if D.label ~= a and D.left ~= nil then
    modify(D.left, a, b)
  end
  if D.label ~= a and D.right ~= nil then
    modify(D.right, a, b)
  end
end
-- tests the functions above
local file = '/home/newvm/WORK/Q/ML/DT/test/graphviz.txt'
local lines = lines_from_file(file)

local D = {}
-- print all line numbers and their contents
for k,v in pairs(lines) do
  if k>3 then
    local a, b = plstring.splitv(v,'->')
    if a then 
      a= plstring.strip(a)
    end
    if b then 
      b= plstring.strip(b)
    end
    if a and b then
      modify(D, a, b)
   else
     -- nothing to do
   end
  end
end


-- print decision tree
local f = io.open("graphviz_dt.txt", "w")
f:write("digraph Tree {\n")
f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
f:write("edge [fontname=helvetica] ;\n")
print_dt(D, f)
f:write("}\n")
f:close()
local status = os.execute("diff graphviz.txt graphviz_dt.txt")
assert(status== 0, "not matched")
print("successfully created D from graphviz file")
