local test = require 'test_logistic_regression'

test('mnist', os.getenv('Q_SRC_ROOT')..'/DATA_SETS/MNIST/mnist.tar.gz', 32 * 32, 10)
