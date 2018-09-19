
--[[
variable description
n_T_R   - number of negatives (tails) on right
n_H_R   - number of positives (heads) on right
n_T_L   - number of negatives (tails) on left
n_H_L   - number of positives (heads) on left
]]
-- TODO: export this function as Q's function --> Q.wtbnfit
local function weighted_benefit(
  n_T_L,
  n_H_L,
  n_T_R,
  n_H_R
  )
  -- determine total number on left and right
  local n_L = n_T_L + n_H_L -- total number on left
  local n_R = n_T_R + n_H_R -- total number on right

  -- determine left and right weightage
  local w_L = n_L / ( n_L + n_R ) -- weightage on left
  local w_R = n_R / ( n_L + n_R ) -- weightage on right

  -- odds of betting heads or tails
  local o_T = ( ( n_H_L + n_H_R ) / ( n_T_L + n_T_R ) ) -- odds of betting tail
  local o_H = ( ( n_T_L + n_T_R ) / ( n_H_L + n_H_R ) ) -- odds of betting head

  -- calculate benefit
  local b_H_L = o_H * ( n_H_L / n_L ) + ( n_T_L / n_L ) * (-1) -- benefit of betting head on left
  local b_T_L = o_T * ( n_T_L / n_L ) + ( n_H_L / n_L ) * (-1) -- benefit of betting tail on left
  local b_H_R = o_H * ( n_H_R / n_R ) + ( n_T_R / n_R ) * (-1) -- benefit of betting head on right
  local b_T_R = o_T * ( n_T_R / n_R ) + ( n_H_R / n_R ) * (-1) -- benefit of betting tail on right

  local b_L = math.max(b_H_L, b_T_L) -- benefit on left
  local b_R = math.max(b_H_R, b_T_R) -- benefit on right

  local b = ( w_L * b_L ) + ( w_R * b_R ) -- total benefit

  return b
end

return weighted_benefit
