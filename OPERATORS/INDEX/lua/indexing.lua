local T = {}

local function index(x, y)
-- Q.index() : searches the index of given value(i.e. y) from the given vector(i.e. x)
            -- if found, returns index(a lua number)
            -- else returns nil
-- In Q.index(), indexing starts with 0
-- Convention: Q.index(vector, value)
-- 1) vector : a vector
-- 2) value  : number or Scalar value
  local expander = require 'Q/OPERATORS/INDEX/lua/expander_index'
  local Scalar = require 'libsclr'
  assert(x, "no arg x to index")
  assert(y, "no arg y to index")
  assert(type(x) == "lVector", "x is not lVector")
  assert(type(y) == "Scalar" or type(y) == "number", "y is not Scalar or number")
  if(type(y) == "number") then
    y = assert(Scalar.new(y, x:fldtype()), "value out of range")
  end
  local status, col = pcall(expander, "index", x, y)
  if not status then print(col) end
  assert(status, "Could not execute INDEX")
  return col
end
T.index = index
require('Q/q_export').export('index', index)

local function indices(x)
  local expander = require 'Q/OPERATORS/INDEX/lua/expander_indices'
  assert(x, "no arg x to indices")
  assert(type(x) == "lVector",  "x is not lVector")
  assert(x:qtype() == "B1", "x is not B1")
  local status, col = pcall(expander, "indices", x)
  if not status then print(col) end
  assert(status, "Could not execute INDICES")
  return col
end
T.indices = indices
require('Q/q_export').export('indices', indices)

return T
