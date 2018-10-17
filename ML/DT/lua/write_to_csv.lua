local tablex = require 'pl.tablex'

local write_to_csv = function(result, csv_file_path, sep)
  assert(result)
  assert(type(result) == "table")
  assert(csv_file_path)
  assert(type(csv_file_path) == "string")
  sep = sep or ','

  local accuracy = result['accuracy']
  local accuracy_std_deviation = result['accuracy_std_deviation']
  local gain = result['gain']
  local gain_std_deviation = result['gain_std_deviation']
  local cost = result['cost']
  local cost_std_deviation = result['cost_std_deviation']
  local precision = result['precision']
  local precision_std_deviation = result['precision_std_deviation']
  local recall = result['recall']
  local recall_std_deviation = result['recall_std_deviation']
  local f1_score = result['f1_score']
  local f1_score_std_deviation = result['f1_score_std_deviation']
  local c_d_score = result['c_d_score']
  local c_d_score_std_deviation = result['c_d_score_std_deviation']
  local n_nodes = result['n_nodes']

  local file = assert(io.open(csv_file_path, "w"))

  file:write("alpha,accuracy,precision,recall,f1_score,c_d_score,gain,cost,nodes\n")
  for i, v in tablex.sort(accuracy) do
    file:write(i .. "," .. accuracy[i] .. "," .. precision[i] .. "," .. recall[i] .. "," .. f1_score[i] .. "," .. c_d_score[i] .. "," .. gain[i] .. "," .. cost[i] .. "," .. n_nodes[i])
    file:write('\n')
  end

  file:close()
end

return write_to_csv
