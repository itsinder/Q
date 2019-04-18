local Q = require 'Q'
local function synth_data(
  num_attributes,
  num_metrics,
  num_instances
  )
  local nI = 1048576 -- number of instances
  local T = {}
  local nK = 10
  for i = 1, nK do 
    T["f" .. i] = Q.rand({lb = 0, ub = 8, qtype = "I1", len = nI}):eval()
  end
  local M = {}
  M["price"] = Q.rand({lb = 0, ub = 10000, qtype = "F4", len = nI}):eval()
  M["quantity"] = Q.rand({lb = 1, ub = 16, qtype = "I1", len = nI}):eval()
  return T, M
end
return synth_data
