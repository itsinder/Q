local Q       = require 'Q'
local qconsts = require 'Q/UTILS//lua/q_consts'
local eigen   = require 'Q/OPERATORS/PCA/lua/eigen'

local function pca(X)
  -- TODO add input error checking
  assert(type(X) == "table", "input needs to be a table of column")
  local n = X[1]:length()
  local p = #X
  -- Step 1: standardize the input
  local std_X = {}
  for i, X_i in ipairs(X) do
    assert(type(X_i) == "lVector", "need to pass in a table of column")
    local mean = Q.sum(X_i):eval() / n
    local diff = Q.vssub(X_i, mean)
    local sum_sqr = Q.sum_sqr(diff):eval()
    local sigma = math.sqrt( sum_sqr / (n - 1) )
    local x = Q.vsdiv(diff, sigma)
    x:eval()
    std_X[i] = x
    print("eval'd x ")
  end
  print("standardization complete")

  -- Step 2: compute the variance covariance matrix

  Q.print_csv(std_X, nil, "")
  local CM = Q.corr_mat(std_X)
  print("corr mat complete")
  
  for i=1,p do
    CM[i]:eval()
    print("Printing CM ", i)
    Q.print_csv(CM[i], nil, "")
  end

  -- Step 3: find the eigenvectors of the variance covariance matrix
  local eigen_info = eigen(CM)
  print("eigenvectors complete")
  return eigen_info.eigenvectors
  
end
return pca
--return require('Q/q_export').export('pca', pca)
