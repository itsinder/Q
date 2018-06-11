require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Q = require 'Q'
local log_reg = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'
local load_data_v1 = require 'Q/ML/LOGISTIC_REGRESSION/test/load_data_v1'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local data_dir = Q_SRC_ROOT .. "/ML/LOGISTIC_REGRESSION/test/data/study_hours_vs_pass"

--=================================================
local function run_logistic_regression(
  training_data_file, 
  training_meta_data_file,
  training_optargs_file,
  testing_data_file,
  testing_meta_data_file,
  testing_optargs_file,
  goal,
  num_iters
  )

  local T_train, g_train, nC_train = load_data_v1(
    training_data_file, training_meta_data_file,
    training_optargs_file, goal)
  local T_test, g_test, nC_test = load_data_v1(
    testing_data_file, testing_meta_data_file,
    testing_optargs_file, goal)
    assert(nC_train == nC_test)
    
  local beta = log_reg.lr_setup(train_X, train_g)
  if ( not num_iters ) then  num_iters = 10 end
  assert(type(num_iters) == "number") 
  assert(num_iters >= 1 )
  for i = 1, num_iters do
    beta = log_reg.beta_step(train_X, train_y, beta)
    assert(beta)
    if ( ( i % 1000 )  == 0 ) then 
      print("completed iterations ", g_iter) 
    end
  end
  print("completed iterations ", g_iter)
  print("Completed test_really_simple")
end
local train_data_file = "./data/study_hours_vs_pass/train.csv"
local train_meta_file = "./data/study_hours_vs_pass/meta.lua"
local train_optargs_file
local test_data_file = "./data/study_hours_vs_pass/train.csv"
local test_meta_file = "./data/study_hours_vs_pass/meta.lua"
local goal = "pass"
local num_iters = 1
local test_optargs_file
run_logistic_regression(
  train_data_file, 
  train_meta_file,
  train_optargs_file,
  test_data_file,
  test_meta_file,
  test_optargs_file,
  goal,
  num_iters
  )
