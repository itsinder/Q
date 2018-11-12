local gini_to_q_dt = require 'Q/ML/DT/lua/sklearn_to_q'
local plpath       = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))

local tests = {}

-- testing the sklearn_to_q_dt conversion
tests.t1 = function()
  
  local features_list = { "id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean","compactness_mean", "concavity_mean", "concave points_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concave points_se", "symmetry_se", "fractal_dimension_se", "radius_worst","texture_worst", "perimeter_worst", "area_worst", "smoothness_worst","compactness_worst", "concavity_worst", "concave points_worst", "symmetry_worst", "fractal_dimension_worst" }
  local goal_feature = "diagnosis"
  
  -- converting sklearn gini graphviz to q dt
  local q_D = gini_to_q_dt(path_to_here .. "sklearn_gini_graphviz.txt", features_list, goal_feature )
  assert(type(q_D) == "table")
  print("Successfully completed test t1")
  
end

return tests