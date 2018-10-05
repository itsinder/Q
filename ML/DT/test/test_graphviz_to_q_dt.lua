local graphviz_to_D = require 'Q/ML/DT/lua/graphviz_to_Qdt'['graphviz_to_D']
local print_dt      = require 'Q/ML/DT/lua/graphviz_to_Qdt'['print_dt']

local file = '/home/newvm/WORK/Q/ML/DT/test/graphviz.txt'
local feature_list = { "age", "yop", "no_of_pos_axillary_nodes", "survival_status"}

local D = graphviz_to_D(file, feature_list)

local f = io.open("graphviz_dt.txt", "w")
f:write("digraph Tree {\n")
f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
f:write("edge [fontname=helvetica] ;\n")

-- print decision tree in a file
print_dt(D, f)

f:write("}\n")
f:close()

--local pl = require 'pl.pretty'
--pl.dump(D)
local status = os.execute("diff graphviz.txt graphviz_dt.txt")
assert(status == 0, "graphviz.txt and graphviz_dt files not matched")
print("Successfully created D from graphviz file")