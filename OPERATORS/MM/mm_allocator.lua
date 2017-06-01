local q_core = require 'q_core'

return function(X, Y)
  assert(type(X) == "table", "X should be a table of columns")
  assert(type(Y) == "table", "Y should be a table of columns")

  for i, v in ipairs(X) do
    assert(type(v) == "Column", "X["..i.."] should be a column")
    assert(v:fldtype() == "F8", "X["..i.."] should be a column of doubles")
  end

  for i, v in ipairs(Y) do
    assert(type(v) == "Column", "Y["..i.."] should be a column")
    assert(v:fldtype() == "F8", "Y["..i.."] should be a column of doubles")
  end

  local X_chunks = q_core.cast('double**', q_core.mallloc(#X * q_core.sizeof('double*')))
  local Y_chunks = q_core.cast('double**', q_core.mallloc(#Y * q_core.sizeof('double*')))
  
  return X_chunks, Y_chunks
end


  
