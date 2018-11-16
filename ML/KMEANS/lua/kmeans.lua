
local function kmeans_1(
  D, -- D is a table of J Vectors of length I
  means -- means is a table of J vectors of length K
  )
  -- somethign
  local nJ = #D
  local nI
  for j, v in pairs(D) do
    if ( not nI ) then 
      nI = v:length()
    else
      assert( nI == v:length())
    end
  end
  
  -- start by assigning everything to class 1
  class = Q.const({val = 1, len = nI, qtype = "I1"})
  for j = 2, nJ do
    local x = Q.vvleq(dist[i], dist[j])
  end

  return class
end
