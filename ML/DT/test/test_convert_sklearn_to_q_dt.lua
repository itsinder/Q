local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
local plpath = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))
local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']

local tests = {}

tests.t1 = function()
  
  local feature_list = { "id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean","compactness_mean", "concavity_mean", "concave points_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concave points_se", "symmetry_se", "fractal_dimension_se", "radius_worst","texture_worst", "perimeter_worst", "area_worst", "smoothness_worst","compactness_worst", "concavity_worst", "concave points_worst", "symmetry_worst", "fractal_dimension_worst" }
  
  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(path_to_here .. "sklearn_gini_graphviz.txt", feature_list)
  
  -- perform the preprocess activity
  -- initializes n_H1 and n_T1 to zero
  preprocess_dt(tree)
  
  -- printing the decision tree in gini graphviz format
  local file_name = path_to_here .. "/output_q_format_graphviz.txt"
  local f = io.open(file_name, "w")
  f:write("digraph Tree {\n")
  f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  f:write("edge [fontname=helvetica] ;\n")
  local seperator = "<br/>"
  local root_node_str = tree.node_idx ..  " [label=<" .. feature_list[tree.feature] .. " &le; " .. tree.threshold .. seperator .. "benefit = " .. tree.benefit .. seperator .. "value = [" .. tostring(tree.n_T) ..", " .. tostring(tree.n_H) .."]>,fillcolor=\"#e5813963\"] ;\n"
  f:write(root_node_str)
  print_dt(tree, f, feature_list)
  f:write("}\n")
  f:close()

end

return tests