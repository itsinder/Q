local function split_into_train_test (
  T,  -- table of m lVectors of length n
  split_ratio,  -- Scalar between 0 and 1 
  features_of_interest
  )
  assert(T)
  assert(type(T) == "table")
  if ( type(split_ration) == "number" ) then 
    split_ratio = assert(Scalar.new(split_ratio, "F4"))
  elseif ( type(split_ration) == "Scalar" ) then 
    assert(split_ratio:fldtype() == "F4")
  end
  assert ( (split_ratio > 0.0) and (split_ratio < 1.0 ) )

  local Train = {}
  local Test = {}
  local n
  local features_in_data = {}
  for k, v in pairs(T) do
    if ( not n ) then 
      n = v:length()
    else
      assert(n == v:length())
    end
    features_in_data[#features_in_data] = k
  end
  --==============================
  if not features_of_interest then
    local features_of_interest = {}
    for k, _ in pairs(T) do
      features_of_interest[#features_of_interest + 1] = k
    end
  end
  assert(type(features_of_interest) == "table")
  local num_features = 0
  for _, feature1 in pairs(features_of_interest) do 
    local found = false
    for feature2, _ in pairs(T) do 
      if ( feature1 == feature2 ) then found = true break end 
    end
    assert(found, "Feature not found in data set " .. feature1)
    num_features = num_features + 1
  end
  assert(num_features > 0)
  --=======================================
  local random_vec = Q.rand({lb = 0, ub = 1, qtype = "F4", len = n})
  local random_vec_bool = Q.vsleq(random_vec, split_ratio)
  for _, feature in pairs(features_of_interest) do
    Train[feature] = Q.where(T[v], random_vec_bool)
    Test [feature] = Q.where(T[v], Q.vnot(random_vec_bool))
  end
  return Train, Test
end
return split_into_train_test
