require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Q = require 'Q'
local load_data = require 'load_data'
local log_reg   = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'

local test = {} 
--=================================================
test.t1 = function()
  local q_src_root = os.getenv('Q_SRC_ROOT')
  assert(plpath.isdir(q_src_root))
  local data_file = q_src_root .. '/DATA_SETS/REALLY_SIMPLE/really-simple.tar.gz'
  local num_cols = 1
  local train_X, train_y, test_X, test_y = load_data(data_file, num_cols)
  local beta = log_reg.lr_setup(train_X, train_y)
  local num_iters = 10
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