local graphviz_to_D = require 'Q/ML/DT/lua/graphviz_to_q_dt'['graphviz_to_D']
local print_dt      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
local load_csv_col_seq = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
local plpath        = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))

local tests = {}

tests.t1 = function()
  local file = path_to_here .. 'graphviz.txt'
  local feature_list = { "age", "yop", "no_of_pos_axillary_nodes", "survival_status"}
  local goal_feature = "survival_status"
  
  local new_feature_list = load_csv_col_seq(feature_list, goal_feature)
  local D = graphviz_to_D(file, new_feature_list)

  local f = io.open(path_to_here .. "graphviz_dt.txt", "w")
  f:write("digraph Tree {\n")
  f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  f:write("edge [fontname=helvetica] ;\n")

  -- print decision tree in a file
  print_dt(D, f)
  f:write("}\n")
  f:close()

  local status = os.execute("diff " .. file .. " graphviz_dt.txt")
  assert(status == 0, "graphviz.txt and graphviz_dt files not matched")
  print("Successfully created D from graphviz file")

end

return tests