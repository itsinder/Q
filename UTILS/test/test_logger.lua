l = require 'Q/UTILS/lua/logger'
local tests = {}
tests.test_debug = function()
  assert( l.new({outfile = "t"}):debug('hey') == true) 
end
x()

tests.tests_warn = function()
  assert( l.new({outfile = "t", level="warn"}):debug('hey') == false)
end

return tests
