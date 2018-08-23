local utils = {}

local calc_accuracy = function(actual_val, predicted_val)
  assert(type(actual_val) == "table")
  assert(type(predicted_val) == "table")
  assert(#actual_val == #predicted_val)
  local correct = 0
  for i = 1, #actual_val do
    if actual_val[i] == predicted_val[i] then
      correct = correct + 1
    end
  end
  return (correct/#actual_val)*100
end

utils.calc_accuracy = calc_accuracy

local calc_average = function(accuracy_list)
  local average = 0
  for i = 1, #accuracy_list do
    average = average + accuracy_list[i]
  end
  average = average / #accuracy_list
  return average
end

utils.calc_average = calc_average

return utils

