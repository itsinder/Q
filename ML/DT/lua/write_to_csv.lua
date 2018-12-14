local tablex = require 'pl.tablex'

local write_to_csv = function(result, csv_file_path, sep)
  assert(result)
  assert(type(result) == "table")
  assert(csv_file_path)
  assert(type(csv_file_path) == "string")
  sep = sep or ','
  local file = assert(io.open(csv_file_path, "w"))
  local hdr = 'alpha'
  for k, v in pairs(result) do
    for k1, v1 in pairs(v) do
      hdr = hdr .. "," .. k1 .. "," .. k1 .. "_sd"
    end
  end
  file:write(hdr .. "\n")
  for k, v in pairs(result) do
    file:write(k)
    for k1, v1 in pairs(v) do
      avg_score = v1.avg
      sd_score = v1.sd
      file:write("," .. avg_score .. "," .. sd_score)
    end
    file:write("\n")
  end
  file:close()
  --[[
  file:write("alpha,accuracy,precision,recall,f1_score,mcc,payout\n")
  for i, v in tablex.sort(result) do
    local accuracy = v.accuracy.avg
    local accuracy_sd = v.accuracy.sd
    local precision = v.precision.avg
    local precision_sd = v.precision.sd
    local recall = v.recall.avg
    local recall_sd = v.recall.sd
    local f1_score = v.f1_score.avg
    local f1_score_sd = v.f1_score.sd
    local mcc = v.mcc.avg
    local mcc_sd = v.mcc.sd
    local payout = v.payout.avg
    local payout_sd = v.payout.sd
    file:write(i .. "," .. accuracy .. "," .. precision .. "," .. recall .. "," .. f1_score .. "," .. mcc .. "," .. payout)
  end
  file:close()
  ]]
end

return write_to_csv
