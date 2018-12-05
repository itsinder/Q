local Q = require 'Q'
local Scalar = require 'libsclr'
local fns = {}

local szero = Scalar.new(0, "F4")
local sone = Scalar.new(1, "F4")


local function calc_gain_and_cost(
  D,		-- decision tree
  l_gain,	-- table containing gain value at each leaf node
  l_cost,	-- table containing cost value at each leaf node
  l_weight,	-- table containing weight value at each leaf node
  n_T,		-- total number of negatives (tails) in training dataset
  n_H		-- total number of positives (heads) in training dataset
  )
  if D.left and D.right then
    calc_gain_and_cost(D.left, l_gain, l_cost, l_weight, n_T, n_H)
    calc_gain_and_cost(D.right, l_gain, l_cost, l_weight, n_T, n_H)
  else
    local w = D.n_H1 + D.n_T1 -- weight at leaf node
    if w == 0 then
      -- TODO: maintain the count here, how many times this situation is occured for debugging
      return
    end

    local w_T = ( n_T / ( n_T + n_H ) )   -- weight of negatives (tails) in training dataset
    local w_H = ( n_H / ( n_T + n_H ) )   -- weight of positives (heads) in training dataset

    -- In the gain calculation, odds are set using n_H and n_T i.e overall ratio of heads & tails in training dataset
    -- In the cost calculation, odds are set using n_H0 and n_T0 i.e heads & tails at each leaf node
    -- we added w_T and w_H with n_T0 and n_H0 in the odds calcualtion for cost to avoid the division by zero situation
    -- for example, suppose leaf node distribution is n_H0 = 10, n_T0 = 0 then
    -- odds of betting tail = ( n_H0 / n_T0 ) = ( 10 / 0 ) -- division by zero
    -- with the addition of w_T and w_H
    -- odds of betting tail = ( n_H0 + w_H ) / ( n_T0 + w_T ) -- avoid division by zero

    -- Here, n_H0 and n_T0 are represented by D.n_H and D.n_T respectively

    local o_H_c = ( ( D.n_T + w_T  ) / ( D.n_H + w_H ) ) -- odds of betting head (used in cost calcuation)
    local o_T_c = ( ( D.n_H + w_H  ) / ( D.n_T + w_T ) ) -- odds of betting tail (used in cost calcuation)

    local o_H_g = ( n_T / n_H ) -- odds of betting head (used in gain calcuation)
    local o_T_g = ( n_H / n_T ) -- odds of betting tail (used in gain calcuation)

    local w_H0 = ( D.n_H / ( D.n_H + D.n_T ) ) -- weight of positives (heads) from training samples at visited leaf node
    local w_T0 = ( D.n_T / ( D.n_H + D.n_T ) ) -- weight of negatives (tails) from training samples at visited leaf node

    local w_H1 = ( D.n_H1 / ( D.n_H1 + D.n_T1 ) ) -- weight of positives (heads) from testing samples at visited leaf node
    local w_T1 = ( D.n_T1 / ( D.n_H1 + D.n_T1 ) ) -- weight of negatives (tails) from testing samples at visited leaf node

    local g_H = ( w_H0 * o_H_g ) + ( w_T0 * (-1) ) -- gain with betting head
    local g_T = ( w_T0 * o_T_g ) + ( w_H0 * (-1) ) -- gain with betting tail

    local g = math.max(g_H, g_T) -- gain at leaf node

    local c_H = ( w_H1 * o_H_c ) + ( w_T1 * (-1) ) -- cost of betting head
    local c_T = ( w_T1 * o_T_c ) + ( w_H1 * (-1) ) -- cost of betting tail

    local c = math.max(c_H, c_T) -- cost at leaf node

    l_gain[#l_gain+1] = g
    l_cost[#l_cost+1] = c
    l_weight[#l_weight+1] = w

    D.cost = c
    D.gain = g
  end
end


local function evaluate_dt(
  D,	-- decision tree
  g	-- lVector of length n, goal/target feature from training dataset
  )
  -- TODO: remove below hard-coding
  local ng = 2
  local cnts = Q.numby(g, ng):eval()
  local n_T, n_H
  n_T = cnts:get_one(0):to_num()         -- number of negatives (tails) in training dataset
  n_H = cnts:get_one(1):to_num()         -- number of positives (heads) in training dataset

  local l_gain = {} -- will contain gain at each leaf node (using testing data)
  local l_cost = {}  -- will contain cost at each leaf node (using testing data)
  local l_weight = {}   -- will contain weight at each leaf node (using testing data)
  calc_gain_and_cost(D, l_gain, l_cost, l_weight, n_T, n_H)

  assert(#l_gain > 0)
  assert(#l_cost > 0)
  assert(#l_weight > 0)
  assert(#l_cost == #l_weight)
  assert(#l_cost == #l_gain)

  -- calculate total gain & cost
  local total_gain = 0
  local total_cost = 0
  local total_weight = 0
  for i = 1, #l_weight do
    total_gain = ( total_gain + ( l_weight[i] * l_gain[i] ) )
    total_cost = ( total_cost + ( l_weight[i] * l_cost[i] ) )
    total_weight = ( total_weight + l_weight[i] )
  end
  local gain = ( total_gain / total_weight )
  local cost = ( total_cost / total_weight )

  return gain, cost
end


fns.evaluate_dt = evaluate_dt

return fns
