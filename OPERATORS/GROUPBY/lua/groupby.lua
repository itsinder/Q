local T = {}

-- TODO P4 consider auto-generating following


local function sumby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_sumby'
  assert(x, "no arg x to sumby")
  assert(g, "no arg g to sumby")
  local status, col = pcall(expander, "sumby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute SUMBY")
  return col
end
T.sumby = sumby
require('Q/q_export').export('sumby', sumby)


local function numby(g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_numby'
  assert(g, "no arg g to numby")
  local status, col = pcall(expander, "numby", g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute NUMBY")
  return col
end
T.numby = numby
require('Q/q_export').export('numby', numby)


local function maxby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_maxby_minby'
  assert(x, "no arg x to maxby")
  assert(g, "no arg g to maxby")
  local status, col = pcall(expander, "maxby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute MAXBY")
  return col
end
T.maxby = maxby
require('Q/q_export').export('maxby', maxby)


local function minby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_maxby_minby'
  assert(x, "no arg x to minby")
  assert(g, "no arg g to minby")
  local status, col = pcall(expander, "minby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute MINBY")
  return col
end
T.minby = minby
require('Q/q_export').export('minby', minby)


return T

