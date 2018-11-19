local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/lua/"
local T = {}

local function print_to_csv (
  D,		-- prepared decision tree
  f, 		-- file_descriptor
  model_idx, -- idx of model 
  tree_idx,  -- idx of tree
  gb_val  
)
  local lines = model_idx .. "," .. tree_idx .. "," .. D.node_idx .. ","
  if D.left and D.right then
    lines = lines .. D.left.node_idx .. "," .. D.right.node_idx .. ","
    if D.feature and D.threshold then
      lines = lines .. D.feature .. "," .. D.threshold .. ","
    end
    lines = lines .. tostring(D.n_T) .. "," .. tostring(D.n_H) .. "," .. gb_val
    
    f:write(lines .. "\n")
    print_to_csv(D.left, f, model_idx, tree_idx, gb_val)
    print_to_csv(D.right, f, model_idx, tree_idx, gb_val)
  else
    -- No tree available
  end
end
-- TODO: doumentation
-- print decision tree in csv format
local print_ab_csv = function(tree, model_idx, tree_idx, gb_val)
  local f = io.open(path_to_here .. "dt.csv", "w")
  f:write("model_idx, tree_idx, node_idx, lchild_idx, rchild_idx, feature_idx, threshold, neg, pos, xgb_val\n")
  print_to_csv(tree, f, model_idx, tree_idx, gb_val)
  f:write("}\n")
  f:close()
  print("Written to" .. path_to_here .. "dt.csv file")
  return path_to_here .. "dt.csv"
end

T.print_ab_csv = print_ab_csv

return T