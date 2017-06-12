local Q = require 'Q'
local log_reg = require 'Q/ML/LOGISTIC_REGRESSION/lua/logistic_regression'

local function load_data(path, prefix)
  local load_csv()
  local train_X
  local train_y
  local test_X
  test_X = Q.transpose(test_X)
  local test_Y
  local _, test_Y_chunk = test_Y:chunk(-1)

  local betas, step = log_reg.make_multinomial_trainer

  local function fraction_correct()
    local get_class = log_reg.package_betas(betas)
    local num_correct = 0
    for i = 1, #test_X do
      if get_class(test_X[i]) == y[i - 1] then
        num_correct += 1
      end
    end
    return num_correct / #test_X
  end

  for i = 1, 100 do
    step()
    print(fraction_correct() * 100 .. "% correct after training step " .. i .. "\n")
  end
end
