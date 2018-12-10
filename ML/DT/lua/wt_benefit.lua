
--[[
variable description
n_T_R   - number of negatives (tails) on right
n_H_R   - number of positives (heads) on right
n_T_L   - number of negatives (tails) on left
n_H_L   - number of positives (heads) on left
]]
-- TODO: export this function as Q's function --> Q.wtbnfit
local function wt_benefit(
  n_T_L,
  n_H_L,
  n_T_R,
  n_H_R
  )
  -- check parameters
  assert(n_T_L > 0)
  assert(n_H_L > 0)
  assert(n_T_R > 0)
  assert(n_H_R > 0)

  -- determine total number on left and right
  local n_L = n_T_L + n_H_L -- total number on left
  local n_R = n_T_R + n_H_R -- total number on right

  local n = n_L + n_R -- total number

  -- determine left and right weightage
  local w_L = n_L / n -- weightage on left
  local w_R = n_R / n -- weightage on right

  local p_H_L = n_H_L / n_L -- prob of heads on left
  local p_H_R = n_H_R / n_R -- prob of heads on left
  local p_T_L = n_T_L / n_L -- prob of tails on left
  local p_T_R = n_T_R / n_R -- prob of tails on left

  local o_H = n_T / n_H -- odds for heads 
  local o_T = n_H / n_T -- odds for tails 

  -- calculate benefit
  local b_H_L = ( o_H * p_H_L ) - ( 1 * p_T_L )
  local b_T_L = ( o_T * p_T_L ) - ( 1 * p_H_L )
  local b_H_R = ( o_H * p_H_R ) - ( 1 * p_T_R )
  local b_T_R = ( o_T * p_T_R ) - ( 1 * p_H_R )

  local b_L = math.max(b_H_L, b_T_L) -- benefit on left
  local b_R = math.max(b_H_R, b_T_R) -- benefit on right

  local b = ( w_L * b_L ) + ( w_R * b_R ) -- total benefit

  return b
end

return wt_benefit
