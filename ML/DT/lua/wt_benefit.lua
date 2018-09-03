
--[[
variable explanation
n_N_R   - number of negatives on right
n_P_R   - number of positives on right
n_N_L   - number of negatives on left
n_P_L   - number of positives on left
]]
-- TODO: export this function as Q's function --> Q.wtbnfit
local function weighted_benefit(
  n_N_L,
  n_P_L,
  n_N_R,
  n_P_R
  )
  -- determine total number on left and right
  local n_L = n_N_L + n_P_L -- total number on left
  local n_R = n_N_R + n_P_R -- total number on right

  -- determine left and right weightage
  local w_L = n_L / ( n_L + n_R ) -- weightage on left
  local w_R = n_R / ( n_L + n_R ) -- weightage on right

  -- payout offerd if bets heads or tails
  local o_N = ( ( n_P_L + n_P_R ) / ( n_N_L + n_N_R ) ) -- payout for betting tail
  local o_P = ( ( n_N_L + n_N_R ) / ( n_P_L + n_P_R ) ) -- payout for betting head

  -- calculate benefit
  local b_P_L = o_P * ( n_P_L / n_L ) + ( n_N_L / n_L ) * (-1) -- benefit of betting head on left
  local b_N_L = o_N * ( n_N_L / n_L ) + ( n_P_L / n_L ) * (-1) -- benefit of betting tail on left
  local b_P_R = o_P * ( n_P_R / n_R ) + ( n_N_R / n_R ) * (-1) -- benefit of betting head on right
  local b_N_R = o_N * ( n_N_R / n_R ) + ( n_P_R / n_R ) * (-1) -- benefit of betting tail on right

  local b_L = math.max(b_P_L, b_N_L) -- benefit on left
  local b_R = math.max(b_P_R, b_N_R) -- benefit on right

  local b = ( w_L * b_L ) + ( w_R * b_R ) -- total benefit

  return b
end

return weighted_benefit
