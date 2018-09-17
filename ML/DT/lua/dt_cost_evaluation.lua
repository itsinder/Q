local Q = require 'Q'
local Scalar = require 'libsclr'
local fns = {}


local szero = Scalar.new(0, "F4")
local sone = Scalar.new(1, "F4")

local function evaluate_dt_cost(
  D,	-- decision tree
  g	-- lVector of length n
  )
  -- TODO: remove below hard-coding
  local ng = 2
  local cnts = Q.numby(g, ng):eval()
  local n_N, n_P
  n_N = cnts:get_one(0):to_num()         -- number of negatives in training dataset
  n_P = cnts:get_one(1):to_num()         -- number of positives in training dataset

  local w_N = ( n_N / ( n_N + n_P ) )   -- weight of negatives in training dataset
  local w_P = ( n_P / ( n_N + n_P ) )   -- weight of positives in training dataset

  local l_benefit = {}  -- will contain benefit at each leaf node (using testing data)
  local l_weight = {}   -- will contain weight at each leaf node (using testing data)
  fns.calc_leaf_wt_benefit(D, l_benefit, l_weight, w_N, w_P)

  assert(#l_benefit > 0)
  assert(#l_weight > 0)
  assert(#l_benefit == #l_weight)

  -- calculate total cost
  local total_benefit = 0
  local total_wt = 0
  for i = 1, #l_weight do
    total_benefit = ( total_benefit + ( l_weight[i] * l_benefit[i] ) )
    total_wt = ( total_wt + l_weight[i] )
  end
  local cost = ( total_benefit / total_wt )

  return cost
end


local function calc_leaf_wt_benefit(
  D,            -- decision tree
  l_benefit,    -- table containing benefit value at each leaf node
  l_weight,     -- table containing weight value at each leaf node
  w_N,          -- weight of negatives in training sample
  w_P           -- weight of positives in training sample
  )
  -- print(w_N, w_P)
  if D.left and D.right then
    calc_leaf_wt_benefit(D.left, l_benefit, l_weight, w_N, w_P)
    calc_leaf_wt_benefit(D.right, l_benefit, l_weight, w_N, w_P)
  else
    local o_P = ( ( D.n_N:to_num() + w_N  ) / ( D.n_P:to_num() + w_P ) )
    local o_N = ( ( D.n_P:to_num() + w_P  ) / ( D.n_N:to_num() + w_N ) )
    local w_P1 = ( D.n_P1 / ( D.n_P1 + D.n_N1 ) ):to_num()
    local w_N1 = ( D.n_N1 / ( D.n_P1 + D.n_N1 ) ):to_num()

    local b_P = ( w_P1 * o_P ) + ( w_N1 * (-1) )
    local b_N = ( w_N1 * o_N ) + ( w_P1 * (-1) )

    local b = math.max(b_P, b_N)
    local w = D.n_P1:to_num() + D.n_N1:to_num()
    
    if w > 0 then
      l_benefit[#l_benefit+1] = b
      l_weight[#l_weight+1] = w
      -- print(w, b)
    end
  end
end


local function cost_calc_preprocess(
  D     -- prepared decision tree
  )
  if D.left and D.right then
    cost_calc_preprocess(D.left)
    cost_calc_preprocess(D.right)
  else
    D.n_P1 = szero
    D.n_N1 = szero
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
        D.n_N1 = D.n_N1 + sone
      else
        D.n_P1 = D.n_P1 + sone
      end
      return D.n_P, D.n_N
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
fns.cost_calc_preprocess = cost_calc_preprocess
fns.calc_leaf_wt_benefit = calc_leaf_wt_benefit
fns.evaluate_dt_cost = evaluate_dt_cost


return fns
