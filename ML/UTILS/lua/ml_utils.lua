local utils = {}

local accuracy_score = function(actual_val, predicted_val)
  assert(type(actual_val) == "table")
  assert(type(predicted_val) == "table")
  assert(#actual_val == #predicted_val)
  local len = #actual_val
  local correct = 0
  for i = 1, len do
    if actual_val[i] == predicted_val[i] then
      correct = correct + 1
    end
  end
  return (correct/#actual_val)*100
end

local confusion_matrix = function(actual_val, predicted_val)
  assert(type(actual_val) == "table")
  assert(type(predicted_val) == "table")
  assert(#actual_val == #predicted_val)
  local len = #actual_val
  local TP, TN, FP, FN = 0, 0, 0, 0
  for i = 1, len do
    if predicted_val[i] == 1 then
      if predicted_val[i] == actual_val[i] then
        TP = TP + 1  -- Actual value is positive and predicted as positive
      else
        FP = FP + 1  -- Actual value is negative but predicted as positive
      end
    else
      if predicted_val[i] == actual_val[i] then
        TN = TN + 1  -- Actual value is negative and predicted as negative
      else
        FN = FN + 1  -- Actual value is positive but predicted as negative
      end
    end
  end
  return { TP = TP, FN = FN, FP = FP, TN = TN }
end

local precision_score = function(actual_val, predicted_val, conf_matrix=nil)
  if not conf_matrix then
    conf_matrix = confusion_matrix(actual_val, predicted_val)
  end
  local precision = ( conf_matrix.TP / ( conf_matrix.TP + conf_matrix.FP ) )
  return precison
end

local recall_score = function(actual_val, predicted_val, conf_matrix=nil)
  if not conf_matrix then
    conf_matrix = confusion_matrix(actual_val, predicted_val)
  end
  local recall = ( conf_matrix.TP / ( conf_matrix.TP + conf_matrix.FN ) )
  return recall
end

local f1_score = function(actual_val, predicted_val, conf_matrix=nil)
  local precision = precision_score(actual_val, predicted_val, conf_matrix)
  local recall = recall_score(actual_val, predicted_val, conf_matrix)
  local f1 = ( ( 2 * precision * recall ) / ( precision + recall ) )
  return f1
end

local classification_report = function(actual_val, predicted_val)
  local accuracy = accuracy_score(actual_val, predicted_val)
  local conf_matrix = confusion_matrix(actual_val, predicted_val)
  local precision = precision_score(actual_val, predicted_val, conf_matrix)
  local recall = recall_score(actual_val, predicted_val, conf_matrix)
  local f1 = f1_score(actual_val, predicted_val, conf_matrix)
  local result = {}
  result["accuracy_score"] = accuracy
  result["confusion_matrix"] = conf_matrix
  result["precision_score"] = precision
  result["recall_score"] = recall
  result["f1_score"] = f1
  return result
end

local cross_val_score = function()
  --TODO: Complete implementation
end

local cross_val_predict = function()
  --TODO: Complete implementation
end

local greed_search_cv = function()
  --TODO: Complete implementation
end

local average_score = function(in_list)
  local average = 0
  for i = 1, #in_list do
    average = average + in_list[i]
  end
  average = average / #in_list
  return average
end


local std_deviation_score = function(in_list)
  local mean = calc_average(in_list)
  local mean_squared_dst = 0
  for i = 1, #in_list do
    mean_squared_dst = mean_squared_dst + ( ( in_list[i] - mean ) * ( in_list[i] - mean ) )
  end
  local std_deviation = math.sqrt(mean_squared_dst / #in_list)
  return std_deviation
end

utils.accuracy_score = accuracy_score
utils.average_score = average_score
utils.std_deviation_score = std_deviation_score
utils.greed_search_cv = greed_search_cv
utils.cross_val_predict = cross_val_predict
utils.cross_val_score = cross_val_score
utils.recall_score = recall_score
utils.precision_score = precision_score
utils.f1_score = f1_score
utils.classification_report = classification_report
utils.confusion_matrix = confusion_matrix

return utils

