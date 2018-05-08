local T = {}
local function index(x, y)
-- Q.index() : searches the index of given value(i.e. y) from the given vector(i.e. x)
            -- if found, returns index(a lua number)
            -- else returns nil
-- Convention: Q.index(vector, value)
-- 1) vector : a vector
-- 2) value  : number or Scalar value
  local expander = require 'Q/OPERATORS/INDEX/lua/expander_index'
  local Scalar = require 'libsclr'
  assert(x, "no arg x to index")
  assert(y, "no arg y to index")
  assert(type(x) == "lVector", "x is not lVector")
  -- TODO: discuss with Ramesh: whether to support type(y) as Scalar?
  assert(type(y) == "Scalar" or type(y) == "number", "y is not Scalar or number")
  if(type(y) == "number") then
    y = assert(Scalar.new(y, x:fldtype()), "value out of range")
  end
  local status, col = pcall(expander, "index", x, y)
  if not status then print(col) end
  assert(status, "Could not execute INDEX")
  return col
end
T.where = index
require('Q/q_export').export('index', index)

return T
