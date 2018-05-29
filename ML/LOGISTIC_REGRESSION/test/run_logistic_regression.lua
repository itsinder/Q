require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Q = require 'Q'
local log_reg = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'
local load_data_v1 = require 'Q/ML/LOGISTIC_REGRESSION/lua/load_data_v1'

--=================================================
local function run_logistic_regression(
  training_data_file, 
  training_meta_data_file,
  training_optargs_file,
  testing_data_file,
  testing_meta_data_file,
  testing_optargs_file,
  goal_attribute_name,
  num_iters
  )

  local T_train, g_train, nC_train = load_data_v1(
    training_data_file, training_meta_data_file,
    training_optargs_file, goal_attribute_name)
  local T_test, g_test, nC_test = load_data_v1(
    testing_data_file, testing_meta_data_file,
    testing_optargs_file, goal_attribute_name)
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

return test
