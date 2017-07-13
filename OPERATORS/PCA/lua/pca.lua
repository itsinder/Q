local q = require 'Q'
local qconsts = require 'Q/UTILS/q_consts.lua'

local function pca(X)
  -- TODO add input error checking
  local n = X[1]:length()
  local p = #X
  -- Step 1: standardize the input
  for i, X_i in ipairs(X) do
    local mean = Q.sum(X_i) / n
    local diff = Q.vssub(X_i, mean)
    local sum_sqr = Q.sum_sqr(diff)
    local sigma = math.sqrt( sum_sqr / (n - 1) )
    local new = Q.vsdiv(diff, sigma)
    X_i = new
  end

  -- Step 2: compute the variance covariance matrix
  local VCM = Q.var_covar(X)

  -- Step 3: find the eigenvectors of the variance covariance matrix
  local eigen_info = Q.eigen(VCM)
  return eigen_info.eigenvectors
  
end
return pca


    

