local Q = require 'Q'
local save = require 'Q/UTILS/lua/save'
local log_reg = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'
local ffi = require 'Q/UTILS/lua/q_ffi'

local meta_file = 'meta-mnist.lua'

local status = pcall(dofile, os.getenv("Q_METADATA_DIR")..'/'..meta_file)
if not status or not train_X or not train_y or not test_X or not test_y then
  local data_file = os.getenv("Q_SRC_ROOT")..'/DATA_SETS/MNIST/mnist.tar.gz'
  os.execute('tar -xzf '..data_file)

  local train_X_file = 'mnist/train_data.csv'
  local train_y_file = 'mnist/train_labels.csv'
  local test_X_file = 'mnist/test_data.csv'
  local test_y_file = 'mnist/test_labels.csv'

  local image_dim = 32
  local num_cols = image_dim * image_dim
  function cols(suff)
    local x_cols = {}
    for i = 1, num_cols do
      x_cols[i] = { name = 'x_'..tostring(i)..suff, qtype = "F8", has_nulls = false, is_dict = false, is_load = true }
    end
    local y_cols = {{ name = 'y'..suff, qtype = "F8", has_nulls = false, is_dict = false, is_load = true }}
    return x_cols, y_cols
  end

  local x_cols, y_cols = cols('train')
  train_X = Q.load_csv(train_X_file, x_cols)
  print('loaded train_X')
  train_y = Q.load_csv(train_y_file, y_cols)[1]
  print('loaded train_y')
  x_cols, y_cols = cols('test')
  test_X = Q.load_csv(test_X_file, x_cols)
  print('loaded test_X')
  test_y = Q.load_csv(test_y_file, y_cols)[1]
  print('loaded test_y')

  save(meta_file)
end

local _, test_y_c, len = test_y:chunk(-1)
test_y_c = ffi.cast('double*', test_y_c)

local betas, step = log_reg.make_trainer(train_X, train_y, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10})

local function fraction_correct()
  local _, _, get_classes = log_reg.package_betas(betas)
  local classes = get_classes(test_X)
  _, classes, _ = classes:chunk(-1)
  classes = ffi.cast('double*', classes)
  local num_correct = 0
  for i = 0, len - 1 do
    if classes[i] == test_y_c[i] then
      num_correct = num_correct + 1
    end
  end
  return num_correct / len
end

for i = 1, 100 do
  print('doing step '..i)
  step()
  print('did step '..i)
  print(fraction_correct() * 100 .. "% correct after training step " .. i)
end
