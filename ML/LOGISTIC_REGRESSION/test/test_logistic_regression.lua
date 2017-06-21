local Q = require 'Q'
local log_reg = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'

local data_file = os.getenv("Q_SRC_ROOT")..'/DATA_SETS/MNIST/mnist.tar.gz'
os.execute('tar -xzf '..data_file)

local train_X_file = 'mnist/train_data.csv'
local train_y_file = 'mnist/train_labels.csv'
local test_X_file = 'mnist/test_data.csv'
local test_y_file = 'mnist/test_labels.csv'

local image_dim = 32
local num_cols = image_dim * image_dim
local x_cols = {}
for i = 1, num_cols do
  x_cols[i] = { name = tostring(i), qtype = "F8", has_nulls = false, is_dict = false, is_load = true }
end
local y_cols = {{ name = tostring(i), qtype = "F8", has_nulls = false, is_dict = false, is_load = true }}

local train_X = Q.load_csv(train_X_file, x_cols)
local train_y = Q.load_csv(train_y_file, y_cols)
local test_X = Q.load_csv(test_X_file, x_cols)
local test_y = Q.load_csv(test_y_file, y_cols)

local betas, step = log_reg.make_multinomial_trainer(train_X, train_y, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10})

local function fraction_correct()
  local get_class = log_reg.package_betas(betas)
  local num_correct = 0
  for i = 1, #test_X do
    if get_class(test_X[i]) == y[i - 1] then
      num_correct = num_correct + 1
    end
  end
  return num_correct / #test_X
end

for i = 1, 100 do
  step()
  print(fraction_correct() * 100 .. "% correct after training step " .. i .. "\n")
end
