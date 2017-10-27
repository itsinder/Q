require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local load_data = require 'load_data'
local log_reg   = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'

--=================================================
local data_file = os.getenv('Q_SRC_ROOT')..'/DATA_SETS/REALLY_SIMPLE/really-simple.tar.gz'
local num_cols = 1
train_X, train_y, test_X, test_y = load_data('really-simple', data_file, num_cols)
beta = log_reg.lr_setup(train_X, train_y)
local num_iters = 1000000
g_iter = 0
for i = 1, num_iters do
  g_iter = i
  beta = log_reg.beta_step(train_X, train_y, beta)
  if ( ( i % 1000 )  == 0 ) then 
    -- collectgarbage()
    print("completed iterations ", g_iter) 
  end
end
print("completed iterations ", g_iter)
  

print("Completed test_really_simple")
os.exit()
