l = require 'Q/UTILS/lua/logger'
local function x()
  assert( l.new({outfile = "t"}):debug('hey') == true) 
end
x()

local function y()
  assert( l.new({outfile = "t", level="warn"}):debug('hey') == false)
end

