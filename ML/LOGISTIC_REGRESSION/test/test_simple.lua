local test = require 'Q/ML/LOGISTIC_REGRESSION/test/test_logistic_regression'

test('simple', os.getenv('Q_SRC_ROOT')..'/DATA_SETS/SIMPLE/simple.tar.gz', 2, 3)
