-- https://en.wikipedia.org/wiki/K-means_clustering
local Q = require 'Q'
local Scalar = require 'libsclr'
local check = require 'check'
-- ===========================================
-- nI = number of instances
-- nJ = number of attributes/features
-- nK = number of classes 

--================================
local rough_kmeans = {}
local function assignment_step(
  D, -- D is a table of J Vectors of length nI
  nI,
  nJ,
  nK,
  means, -- means is a table of J vectors of length K
  num_in_class
  )
  if debug then 
    local nI, nJ = assert(check.data(D))
    assert(check.means, nJ, nK)
  end
  local dist = {}
  -- dist[k][i] is distance of ith instance from kth mean
  for k = 1, nK do 
    dist[k] = Q.const({val = 0, qtype = "F4", len = nI})
    for j, Dj in  pairs(D) do
      -- mu_j_k = value of jth feature for kth mean
      local mu_j_k = means[k][j]
      dist[k] = Q.add(dist[k], Q.sqr(Q.vssub(Dj, mu_j_k)))
    end
  end
  -- start by assigning everything to class 1
  local best_clss = Q.const({val = 1, len = nI, qtype = "I4"})
  local best_dist = dist[1]
  for k = 2, nK do
    local x = Q.vvleq(best_dist, dist[k])
    best_dist = Q.ifxthenyelsez(x, best_dist, dist[k])
    best_clss = Q.ifxthenyelsez(x, best_clss, Scalar.new(k, "I4"))
  end
  -- Evaluate best clss and best distance
  while true do 
    local status = best_clss:next()
    if ( not status ) then break end 
    best_dist:next()
  end
  -- Compute membership in outer
  local in_outer = {} 
  local alpha = 1.2 -- TODO Input parameter
  for k = 1, nK do
    in_outer[k] = Q.vvleq(dist[k], Q.vsmul(best_dist, alpha))
  end
  num_claimants = Q.const({val = 0, qtype = "I1", len = n_I})
  for k = 1, nK do
    num_claimants = Q.vvadd(num_claimants,
                              Q.convert(in_outer[k], "I1"))
  end
  inner = Q.ifxthenyelsez(Q.vsgeq(num_claimants, 2), 0, best_class)
  local num_in_outer = {}
  for k = 1, nK do 
    num_in_outer[k] = Q.sum(in_outer[k]):eval():to_num()
  end
  num_in_inner = Q.numby(inner, n_K+1)
  return inner, num_in_inner, in_outer, num_in_outer
end
--================================
local function update_step(
  D, -- D is a table of nJ Vectors of length nI
  nI,
  nJ,
  nK,
  class, -- Vector of length nI
  num_in_inner,
  in_outer,
  num_in_outer
  )
  if ( debug ) then 
    assert(type(num_in_class) == "lVector")
    assert(num_in_class:length() == nK+1)
    assert(check.class(class, nK))
    local nI, nJ = assert(check.data(D))
    assert(class:length() == nI)
  end
  local means = {}
  -- accumulate stuff in "inner approximation"
  for k = 1, nK do
    local x = Q.vseq(class, k):eval()
    means[k] = {}
    for j, Dj in pairs(D) do
      means[k][j] = wt_inner * Q.sum(Q.where(Dj, x)):eval():to_num() / 
         num_in_inner:get_one(k):to_num()
      -- print("means[" .. k .. "][" .. j .. "] = " .. means[k][j])
    end
  end
  -- accumulate stuff in "outer approximation"
  for k = 1, nK do
    for j, Dj in pairs(D) do
      means[k][j] = means[k][j] + ( wt_outer *
        Q.sum(Q.where(Dj, in_outer[k])):eval():to_num() / 
         num_in_outer:get_one(k):to_num())
      -- print("means[" .. k .. "][" .. j .. "] = " .. means[k][j])
    end
  end
  return means -- a table of nK tables of length nJ
end
--================================
rough_kmeans.assignment_step = assignment_step
rough_kmeans.update_step = update_step

return rough_kmeans
