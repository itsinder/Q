require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Q = require 'Q'
local log_reg = require 'Q/ML/LOGREG/lua/logistic_regression'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local data_dir = Q_SRC_ROOT ..  "/ML/LOGREG/data/"
assert(plpath.isdir(data_dir))

--=================================================
local function run_logistic_regression(
  train_file, 
  meta_data,
  optargs,
  goal,
  num_iters
  )
  assert(plpath.isfile(train_file))
  if ( not num_iters ) then  num_iters = 10 end
  assert(type(num_iters) == "number") 
  assert(num_iters >= 1 )
  --==========================================
  local T = Q.load_csv(train_file, meta_data, optargs)
  local T_train, g_train = extract_goal(T, goal)

  local beta = log_reg.lr_setup(T_train, g_train)
  for i = 1, num_iters do
    beta = assert(log_reg.beta_step(T_train, g_train, beta))
    if ( ( i % 1000 )  == 0 ) then 
      print("completed iterations ", g_iter) 
    end
  end
  print("completed iterations ", g_iter)
end
local train_file = data_dir .. "/study_hours_vs_pass/train.csv"
local M = { 
  {name = "hours", qtype = "F4"},
  {name = "pass", qtype = "F4"},
}
local optargs = {
  is_hdr = true
}
local goal = "pass"
local num_iters = 1
run_logistic_regression(
  train_file, 
  M,
  optargs,
  goal,
  num_iters
  )
