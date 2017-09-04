local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local utils = require 'Q/UTILS/lua/test_utils'

return {
  tests = 
    {
      { 
        name = "mkcol_I1", 
        input = { {10, 20, 30, 40, 50, 60}, "I1" },
        check = function(col)
              return utils.col_as_str(col) == "10,20,30,40,50,60,"
          end
      },
      { 
        name = "mkcol_I4", 
        input = { {10, 20, 30, 40, 50, 60}, "I4" },
        check = function(col)
              return utils.col_as_str(col) == "10,20,30,40,50,60,"
          end
      },      
    }
}