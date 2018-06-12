local Q = require 'Q'
local Scalar = require 'libsclr'
local plpath = require 'pl.path'
local alt_voting   = require 'Q/ML/KNN/lua/alt_voting'
local alt_scale    = require 'Q/ML/KNN/lua/alt_scale'
local prediction_from_votes = require 'Q/ML/KNN/lua/prediction_from_votes'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local qc = require 'Q/UTILS/lua/q_core'

local q_src_root = os.getenv("Q_SRC_ROOT")
assert(plpath.isdir(q_src_root))
local data_dir = q_src_root .. "/ML/KNN/data/"
assert(plpath.isdir(data_dir))

-- CHANGE BELOW 
local meta_data_file = data_dir .. "/occupancy/occupancy_meta.lua"
local data_file      = data_dir .. "/occupancy/occupancy.csv"
local split_ratio    = 0.8
local goal           = "occupy_status"
-- CHANGE ABOVE

T = Q.load_csv(data_file, dofile(meta_data_file))
Train, Test = split_train_test(T, split_ratio)
train, g_train, m_train, n_train = extract_goal(Train, goal)
test,  g_test,  m_test,  n_test  = extract_goal(Test,  goal)
-- Current implementation assumes 2 values of goal as 0, 1
local min_g, _ = Q.min(T[goal])
assert(min_g == 0)
local max_g, _ = Q.max(T[goal])
assert(max_g == 1)
--====================================================
alpha = Q.const({ val = 1, len = m, qtype = "F4"}):eval()
vote  = {}
num_g = {} 
-- num_g[g] == number of elements in training data where goal == g
local x
for g = min_g:to_num("I4"), max_g:to_num("I4") do
  local gval = Scalar.new(g, "I4")
  x = Q.vseq(g_train, gval)
  local l_train = {}
  for attr, vec in pairs(train) do
    l_train[attr] = Q.where(vec, x):eval()
    n_train = l_train[attr]:length()
    num_g[g] = n_train
  end
  vote[g] = Q.const({ val = 0, len = n_test, qtype = "F4"}):eval()
  
  local t_start = qc.get_time_usec()
  alt_voting(l_train, m, n_train, test, n_test, vote[g])
  local t_stop  = qc.get_time_usec()
  -- Q.print_csv(vote[g])
end
g_predicted = prediction_from_votes(vote) 
local n1, n2 = Q.sum(Q.vveq(g_predicted, g_test)):eval()
local accuracy = Scalar.new(100, "F8") * n1:conv("F8") / n2:conv("F8")
n1:conv("I8")
n2:conv("I8")
print("Time     " .. t_stop - t_start )
print("n_train  " .. n_train:to_str())
print("n_test   " .. n_test:to_str())
print("Accuracy " .. accuracy:to_str())
print("Correct  " .. n1:to_str() )
-- Q.print_csv({vote[0], vote[1], g_predicted, g_test}, { opfile = "_x" })
print("Done")
