local Q = require 'Q'
local Scalar = require 'libsclr'
local fns = {}

local szero = Scalar.new(0, "F4")
local sone = Scalar.new(1, "F4")


local function calc_cost(
  D,            -- decision tree
  l_cost,       -- table containing cost value at each leaf node
  l_weight,     -- table containing weight value at each leaf node
  w_T,          -- weight of negatives (tails) in training dataset
  w_H           -- weight of positives (heads) in training dataset
  )
  if D.left and D.right then
    calc_cost(D.left, l_cost, l_weight, w_T, w_H)
    calc_cost(D.right, l_cost, l_weight, w_T, w_H)
  else
    local w = D.n_H1:to_num() + D.n_T1:to_num() -- weight at leaf node
    if w == 0 then
      return
    end

    -- In the cost calculation, odds are set using n_H and n_T of each leaf node
    -- we added w_T and w_H with n_T and n_H to avoid the division by zero
    -- for example, suppose leaf node distribution is n_H = 10, n_T = 0 then
    -- odds of betting tail = ( n_H / n_T ) = ( 10 / 0 ) -- division by zero
    -- with the addition of w_T and w_H
    -- odds of betting tail = ( n_H + w_H ) / ( n_T + w_T ) -- avoid division by zero
    local o_H = ( ( D.n_T:to_num() + w_T  ) / ( D.n_H:to_num() + w_H ) ) -- odds of betting head
    local o_T = ( ( D.n_H:to_num() + w_H  ) / ( D.n_T:to_num() + w_T ) ) -- odds of betting tail
    local w_H1 = ( D.n_H1 / ( D.n_H1 + D.n_T1 ) ):to_num() -- weight of positives (heads) from testing samples at visited leaf node
    local w_T1 = ( D.n_T1 / ( D.n_H1 + D.n_T1 ) ):to_num() -- weight of negatives (tails) from testing samples at visited leaf node

    local c_H = ( w_H1 * o_H ) + ( w_T1 * (-1) ) -- cost of betting head
    local c_T = ( w_T1 * o_T ) + ( w_H1 * (-1) ) -- cost of betting tail

    local c = math.max(c_H, c_T) -- cost at leaf node
    local w = D.n_H1:to_num() + D.n_T1:to_num() -- weight at leaf node

    l_cost[#l_cost+1] = c
    l_weight[#l_weight+1] = w
  end
end


local function evaluate_dt_cost(
  D,	-- decision tree
  g	-- lVector of length n, goal/target feature from training dataset
  )
  -- TODO: remove below hard-coding
  local ng = 2
  local cnts = Q.numby(g, ng):eval()
  local n_T, n_H
  n_T = cnts:get_one(0):to_num()         -- number of negatives (tails) in training dataset
  n_H = cnts:get_one(1):to_num()         -- number of positives (heads) in training dataset

  local w_T = ( n_T / ( n_T + n_H ) )   -- weight of negatives (tails) in training dataset
  local w_H = ( n_H / ( n_T + n_H ) )   -- weight of positives (heads) in training dataset

  local l_cost = {}  -- will contain cost at each leaf node (using testing data)
  local l_weight = {}   -- will contain weight at each leaf node (using testing data)
  calc_cost(D, l_cost, l_weight, w_T, w_H)

  assert(#l_cost > 0)
  assert(#l_weight > 0)
  assert(#l_cost == #l_weight)

  -- calculate total cost
  local total_cost = 0
  local total_weight = 0
  for i = 1, #l_weight do
    total_cost = ( total_cost + ( l_weight[i] * l_cost[i] ) )
    total_weight = ( total_weight + l_weight[i] )
  end
  local cost = ( total_cost / total_weight )

  return cost
end


-- set n_H1 and n_T1 at each leaf node to zero
local function preprocess_dt(
  D     -- prepared decision tree
  )
  if D.left and D.right then
    preprocess_dt(D.left)
    preprocess_dt(D.right)
  else
    D.n_H1 = szero
    D.n_T1 = szero
  end
end


local function predict(
  D,    -- prepared decision tree
  x,    -- a table with test features
  g_val -- goal value for test sample
  )
  assert(type(D) == 'table')
  assert(type(x) == 'table')

  while true do
    if D.left == nil and D.right == nil then
      if g_val == 0 then
        D.n_T1 = D.n_T1 + sone
      else
        D.n_H1 = D.n_H1 + sone
      end
      return D.n_H, D.n_T
    else
      local val = x[D.feature]
      if val:to_num() > D.threshold then
        --print("Right Subtree")
        D = D.right
      else
        --print("Left Subtree")
        D = D.left
      end
    end
  end
end


fns.predict = predict
fns.preprocess_dt = preprocess_dt
fns.evaluate_dt_cost = evaluate_dt_cost


return fns
