local utils = require 'test_utils'

return function(expected)
  return function (func_res)
    print (func_res, expected)
    return func_res == expected  
  end
end
