local test = require 'test_logistic_regression'

test('really-simple', os.getenv('Q_SRC_ROOT')..'/DATA_SETS/REALLY_SIMPLE/really-simple.tar.gz', 1, 2)

os.exit()
