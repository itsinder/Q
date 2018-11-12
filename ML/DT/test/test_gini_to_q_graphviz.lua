local gini_to_q_graphviz = require 'Q/ML/DT/lua/sklearn_to_q_graphviz'['gini_to_q_graphviz']
local plpath = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))

local tests = {}

tests.t1 = function()
  -- converting sklearn gini graphviz to q graphviz format
  gini_to_q_graphviz(path_to_here .. "sklearn_gini_graphviz.txt")
end

return tests