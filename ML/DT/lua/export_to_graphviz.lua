local function print_dt(
  D,            -- prepared decision tree
  f,            -- file_descriptor
  col_name      -- table of column names of train dataset
  )
-- Preorder
  local seperator = "<br/>"
  local label = D.node_idx
  if D.left then
    local condition
    if D.left.feature then
      condition = " [label=<" .. col_name[D.left.feature] .. " &le; " .. D.left.threshold .. seperator .. "benefit = " .. D.left.benefit .. seperator
    else
      -- leaf node
      condition = " [label=<" .. "n_T1 =" .. tostring(D.left.n_T1) .. seperator .. "n_H1 = " .. tostring(D.left.n_H1) .. seperator .. "payout = " .. tostring(D.left.payout) .. seperator
    end
    local str = D.left.node_idx .. condition .. "value = [" .. tostring(D.left.n_T) ..", " .. tostring(D.left.n_H) .."]>,fillcolor=\"#e5813963\"] ;"

    f:write(str .. "\n")
    f:write(label .. " -> " .. D.left.node_idx .. " ;\n")
    print_dt(D.left, f, col_name)
  end
  if D.right then
    local condition
    if D.right.feature then
      condition = " [label=<" .. col_name[D.right.feature] .. " &le; " .. D.right.threshold .. seperator .. "benefit = " .. D.right.benefit .. seperator
    else
      -- leaf node
      condition = " [label=<" .. "n_T1 =" .. tostring(D.right.n_T1) .. seperator .. "n_H1 = " .. tostring(D.right.n_H1) .. seperator .. "payout = " .. tostring(D.right.payout) .. seperator
    end

    local str = D.right.node_idx .. condition .. "value = [" .. tostring(D.right.n_T) ..", " .. tostring(D.right.n_H) .."]>,fillcolor=\"#e5813963\"] ;"
    f:write(str .. "\n")
    f:write(label .. " -> " .. D.right.node_idx .." ;\n")
    print_dt(D.right, f, col_name)
  end
end

local function export_to_graphviz(file_name, tree, train_col_name)
  local f = io.open(file_name, "w")
  f:write("digraph Tree {\n")
  f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  f:write("edge [fontname=helvetica] ;\n")
  local seperator = "<br/>"
  local root_node_str = tree.node_idx ..  " [label=<" .. train_col_name[tree.feature] .. " &le; " .. tree.threshold .. seperator .. "benefit = " .. tree.benefit .. seperator .. "value = [" .. tostring(tree.n_T) ..", " .. tostring(tree.n_H) .."]>,fillcolor=\"#e5813963\"] ;\n"
  f:write(root_node_str)
  print_dt(tree, f, train_col_name)
  print("Exported the Q to graphviz file ", file_name)
  f:write("}\n")
  f:close()
end

return export_to_graphviz