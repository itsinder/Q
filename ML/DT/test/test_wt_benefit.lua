local wf_benefit = require 'Q/ML/DT/lua/wt_benefit'

local tests = {}

tests.t1 = function()
  local n_N_L = 40
  local n_P_L = 15
  local n_N_R = 20
  local n_P_R = 25

  local benefit = wf_benefit(n_N_L, n_P_L, n_N_R, n_P_R)
  print("Benefit is = " .. tostring(benefit))
end

return tests
