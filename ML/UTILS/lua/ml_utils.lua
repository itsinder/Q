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


local calc_average = function(in_list)
  local average = 0
  for i = 1, #in_list do
    average = average + in_list[i]
  end
  average = average / #in_list
  return average
end


local calc_std_deviation = function(in_list)
  local mean = calc_average(in_list)
  local mean_squared_dst = 0
  for i = 1, #in_list do
    mean_squared_dst = mean_squared_dst + ( ( in_list[i] - mean ) * ( in_list[i] - mean ) )
  end
  local std_deviation = math.sqrt(mean_squared_dst / #in_list)
  return std_deviation
end


utils.calc_accuracy = calc_accuracy
utils.calc_average = calc_average
utils.calc_std_deviation = calc_std_deviation

return utils

