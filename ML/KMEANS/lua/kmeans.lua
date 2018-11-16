-- https://en.wikipedia.org/wiki/K-means_clustering
local Q = require 'Q'
-- ===========================================
-- nI = number of instances
-- nJ = number of attributes/features
-- nK = number of classes 

local function chk_class(class, nK)
  assert(nK)
  assert(type(nK) == "number")

  assert(class)
  assert(type(class) == "lVector")

  local qtype = class:fldtype()
  assert( ( qtype == "I1" ) or
          ( qtype == "I2" ) or
          ( qtype == "I4" ) or
          ( qtype == "I8" ) )
  -- class should be between 1 and nK
  local n1 = Q.sum(Q.vvor(Q.vslt(class, 1), Q.vsgt(class, nK))):eval()
  assert(n1:to_num() == 0)
  return true
end
--===============================
local function chk_data(D)
  assert(D and (type(D) == "table"))
  local nJ = 0
  local nI
  for j, v in pairs(D) do
    if ( not nI ) then 
      nI = v:length()
    else
      assert( nI == v:length())
    end
    nJ = nJ + 1 
  end
  assert(nI > 0)
  return nI, nJ
end
--================================
local kmeans = {}
local function assignment_step(
  D, -- D is a table of J Vectors of length nI
  means -- means is a table of J vectors of length K
  )
  --==== START: Error checking
  assert(means and (type(means) == "table"))
  local nI, nJ = assert(chk_data(D))
  --==== STOP: Error checking
  local dist = {}
  -- dist[k][i] is distance of ith instance from kth mean
  for k = 1, nK do 
    dist[k] = Q.const({val = 0, qtype = "F4", length = nI})
    for j = 1, nJ do
      -- mu_j_k = value of jth feature for kth mean
      local mu_j_k = means[j]:get_one(k-1)
      dist[k] = Q.sum(dist[j], Q.sqr(Q.sub(D[j], mu_j_k)))
    end
  end
  -- start by assigning everything to class 1
  local best_clss = Q.const({val = 1, len = nI, qtype = "I4"})
  local best_dist = dist[1]
  
  for k = 2, nK do
    local x = Q.vvleq(best_clss, dist[k])
    best_dist = Q.ifxthenyelsez(x, best_dist, dist[k])
    best_clss = Q.ifxthenyelsez(x, best_clss, k)
  end

  return best_clss -- vector of length nI
end
--================================
local function update_step(
  D, -- D is a table of nJ Vectors of length nI
  nK,
  class -- Vector of length nI
  )
  --==== START: Error checking
  assert(chk_class(class, nK))
  local nI, nJ = assert(chk_data(D))
  assert(class:length() == nI)
  --==== STOP: Error checking
  local means = {}
  for k = 1, nK do
    local x = Q.vseq(class, k):eval()
    means[k] = {}
    for j, Dj in pairs(D) do
      means[k][j] = Q.sum(Q.where(Dj, x)):eval():to_num() / nI
      print("means[" .. k .. "][" .. j .. "] = " .. means[k][j])
    end
  end

  return means -- a table of nJ vectors of length nK
--================================
end
local function init(D, nK)
  local nI, nJ = assert(chk_data(D))
  local class = Q.rand({len = nI, lb = 1, ub = nK, qtype = "I4"}):eval()
  return class
end
--================================
kmeans.assignment_step = assignment_step
kmeans.update_step = update_step
kmeans.init = init

return kmeans
