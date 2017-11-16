l = require 'Q/UTILS/lua/logger'
local function x()
  l.new({outfile = "t"}):debug('hey')
end
x()
