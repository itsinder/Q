-- https://en.wikipedia.org/wiki/K-means_clustering
local Q = require 'Q'
local Scalar = require 'libsclr'
-- ===========================================
-- nI = number of instances
-- nJ = number of attributes/features
-- nK = number of classes 

local function chk_means(means, nJ, nK)
  assert(nJ)
  assert(type(nJ) == "number")
  assert(nJ > 0)

  assert(nK)
  assert(type(nK) == "number")
  assert(nK > 0)

  assert(means)
  assert(type(means) == "table")

  for k, mu_k in pairs(means) do 
    for j, mu_k_j in pairs(mu_k) do 
      assert(type(mu_k_j) == "number") -- TODO P3 Should be Scalar
    end
  end
  return true
end
--===============================
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
  nK,
  means -- means is a table of J vectors of length K
  )
  --==== START: Error checking
  local nI, nJ = assert(chk_data(D))
  assert(chk_means, nJ, nK)
  --==== STOP: Error checking
  local dist = {}
  -- dist[k][i] is distance of ith instance from kth mean
  for k = 1, nK do 
    dist[k] = Q.const({val = 0, qtype = "F4", len = nI})
    for j, Dj in  pairs(D) do
      -- mu_j_k = value of jth feature for kth mean
      local mu_j_k = means[k][j]
      dist[k] = Q.vvadd(dist[k], Q.sqr(Q.vssub(Dj, mu_j_k)))
    end
  end
  for k = 1, nK do 
    dist[k]:eval()
  end
  -- start by assigning everything to class 1
  local best_clss = Q.const({val = 1, len = nI, qtype = "I4"})
  local best_dist = dist[1]
  
  for k = 2, nK do
    local x = Q.vvleq(best_clss, dist[k])
    best_dist = Q.ifxthenyelsez(x, best_dist, dist[k])
    best_clss = Q.ifxthenyelsez(x, best_clss, Scalar.new(k, "I4"))
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
      -- print("means[" .. k .. "][" .. j .. "] = " .. means[k][j])
    end
  end

  return means -- a table of nJ vectors of length nK
end
--================================
local function check_termination(old, new, nK)
  assert(chk_class(old, nK))
  assert(chk_class(new, nK))
  local num_diff = Q.sum(Q.vvneq(old, new)):eval():to_num()
  print("num_diff = " .. num_diff)
  if ( num_diff == 0 ) then return true else return false end 
end
--================================
local function init(D, nK)
  local nI, nJ = assert(chk_data(D))
  local class = Q.rand({len = nI, lb = 1, ub = nK, qtype = "I4"}):eval()
  return class
end
--================================
kmeans.assignment_step = assignment_step
kmeans.update_step = update_step
kmeans.init = init
kmeans.check_termination = check_termination

return kmeans
