local plfile = require 'pl.file'
local Q = require 'Q'
local x = Q.mk_col({"abc", "defg", "hijkl"}, "SC")
local tmpfile = "/tmp/_xxx"

local tests = {}
tests.t1 = function()
  Q.print_csv(x, { opfile = tmpfile } )
  local y = plfile.read(tmpfile)
  z = [[
abc
defg
hijkl
]]
  assert(y == z)
  plfile.delete(tmpfile)
end
return tests
