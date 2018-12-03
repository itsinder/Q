
local tests = {}

tests.t1 = function()
  local test = require 'Q/ML/LOGISTIC_REGRESSION/test/test_logistic_regression'
  test('mnist', os.getenv('Q_SRC_ROOT')..'/DATA_SETS/MNIST/mnist.tar.gz', 32 * 32, 10)
end

return tests
