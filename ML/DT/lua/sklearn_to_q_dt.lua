local plstring = require 'pl.stringx'
local utils = require 'Q/UTILS/lua/utils'
local gini_to_q_graphviz = require 'Q/ML/DT/lua/sklearn_to_q_graphviz'['gini_to_q_graphviz']
local q_graphviz_to_D    = require 'Q/ML/DT/lua/graphviz_to_q_dt'['graphviz_to_D']
local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
local graphviz_to_D      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['graphviz_to_D']
local print_g_dt         = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
local plpath = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))
local fns = {}

-- graphviz_to_q() converts sklearn's graphviz file to Q dt structure

-- Usage:
-- graphviz_to_q(filename, feature_list, goal_feature):
          -- Where,
            -- i)  filename     : name of the sklearn's graphviz file
            -- ii) feature_list : list of dataset's features
            -- iii)goal_feature : name of the goal feature
          -- Returns,
            -- Q dt structure
local graphviz_to_q = function(sklearn_graphviz_filename, feature_list, goal_feature)
  -- converting sklearn gini graphviz to q graphviz format
  local q_graphviz_filename = gini_to_q_graphviz(sklearn_graphviz_filename)
  
  -- getting the correct sequence of the feature_list
  feature_list = load_csv_col_seq(feature_list, goal_feature)
  
  -- converting q graphviz format file to Q dt
  -- ( i.e. loading q graphviz to q data structure)
  local D = graphviz_to_D(q_graphviz_filename, feature_list)
  
--  -- printing the q decision tree structure in a file
--  local fp = io.open(path_to_here .. "graphviz_dt.txt", "w")
--  fp:write("digraph Tree {\n")
--  fp:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
--  fp:write("edge [fontname=helvetica] ;\n")

--  print_g_dt(D, fp)
--  fp:write("}\n")
--  fp:close()
  -- returning the Q dt
  return D
end

return graphviz_to_q
