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
    local w = D.n_H1:to_num() + D.n_T1:to_num() -- weight at leaf node
    if w == 0 then
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

    local o_H_c = ( ( D.n_T:to_num() + w_T  ) / ( D.n_H:to_num() + w_H ) ) -- odds of betting head (used in cost calcuation)
    local o_T_c = ( ( D.n_H:to_num() + w_H  ) / ( D.n_T:to_num() + w_T ) ) -- odds of betting tail (used in cost calcuation)

    local o_H_g = ( n_T / n_H ) -- odds of betting head (used in gain calcuation)
    local o_T_g = ( n_H / n_T ) -- odds of betting tail (used in gain calcuation)

    local w_H1 = ( D.n_H1 / ( D.n_H1 + D.n_T1 ) ):to_num() -- weight of positives (heads) from testing samples at visited leaf node
    local w_T1 = ( D.n_T1 / ( D.n_H1 + D.n_T1 ) ):to_num() -- weight of negatives (tails) from testing samples at visited leaf node

    local g_H = ( w_H1 * o_H_g ) + ( w_T1 * (-1) ) -- gain with betting head
    local g_T = ( w_H1 * o_T_g ) + ( w_H1 * (-1) ) -- gain with betting tail

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


local function print_dt(
  D,            -- prepared decision tree
  f,            -- file_descriptor
  col_name      -- table of column names of train dataset
  )
  local label = "\"n_T0=" .. tostring(D.n_T) .. ", n_H0=" .. tostring(D.n_H)
  --print(D.feature, D.threshold, D.n_H, D.n_T)
  if D.left and D.right then
    label = label .. "\\n" .. col_name[D.feature] .. "<=" .. D.threshold .. "\\n" .. "benefit=" .. D.benefit .. "\""
    local left_label = "\"n_T0=" .. tostring(D.left.n_T) .. ", n_H0=" .. tostring(D.left.n_H)
    local right_label = "\"n_T0=" .. tostring(D.right.n_T) .. ", n_H0=" .. tostring(D.right.n_H)
    if D.left.feature then
      left_label = left_label .. "\\n" .. col_name[D.left.feature] .. "<=" .. D.left.threshold .. "\\n" .. "benefit=" .. D.left.benefit
    else
      left_label = left_label .. "\\n" .. "n_T1=" .. tostring(D.left.n_T1) .. ", n_H1=" .. tostring(D.left.n_H1)
      left_label = left_label .. "\\n" .. "cost=" .. tostring(D.left.cost) .. ", gain=" .. tostring(D.left.gain)
      -- leaf node
    end
    left_label = left_label .. "\""
    if D.right.feature then
      right_label = right_label .. "\\n" .. col_name[D.right.feature] .. "<=" .. D.right.threshold .. "\\n" .. "benefit=" .. D.right.benefit
    else
      right_label = right_label .. "\\n" .. "n_T1=" .. tostring(D.right.n_T1) .. ", n_H1=" .. tostring(D.right.n_H1)
      right_label = right_label .. "\\n" .. "cost=" .. tostring(D.right.cost) .. ", gain=" .. tostring(D.right.gain)
    end
    right_label = right_label .. "\""
    f:write(label .. " -> " .. left_label .. "\n")
    --print(label .. " -> " .. left_label)
    f:write(label .. " -> " .. right_label .. "\n")
    --print(label .. " -> " .. right_label)

    print_dt(D.left, f, col_name)
    print_dt(D.right, f, col_name)
  else
    -- nothing to do
  end
end


fns.predict = predict
fns.preprocess_dt = preprocess_dt
fns.evaluate_dt = evaluate_dt
fns.print_dt = print_dt

return fns
