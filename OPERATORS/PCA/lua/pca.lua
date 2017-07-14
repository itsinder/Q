local q       = require 'Q'
local qconsts = require 'Q/UTILS//lua/q_consts'
local eigen   = require 'Q/OPERATORS/PCA/lua/eigen'

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
  local VCM = Q.corr_mat(X)

  -- Step 3: find the eigenvectors of the variance covariance matrix
  local eigen_info = eigen(VCM)
  return eigen_info.eigenvectors
  
end
return pca

