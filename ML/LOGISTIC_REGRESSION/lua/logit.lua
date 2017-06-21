local Q = require 'Q'

function logit(x)

  assert(type(x) == "Column", "input must be a column")

  local t1 = Q.exp(x)
  local t2 = Q.vsadd(t1, 1)
  local t3 = Q.vvdiv(t1, t2)
  local t4 = Q.vvdiv(t3, t2)

  local x_len = x:length()
  local nC = math.ceil( x_len / chunk_size )

  for i = 1, nC do
    t3:chunk(i)
    t4:chunk(i)
  end

  return t3, t4
  
end
