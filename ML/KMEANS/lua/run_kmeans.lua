local qc      = require 'Q/UTILS/lua/q_core'
local Q       = require 'Q'
local kmeans  = require 'kmeans'

local function run_kmeans(
  args
  )
  
  assert(args and (type(args) == "table"))
  
  local nK = assert(args.k)
  assert((type(nK) == "number") and ( nK > 0 ) and ( nK < 16 ))
  
  local max_iter = args.max_iter
  if ( max_iter ) then 
    assert((type(max_iter) == "number") and ( max_iter > 0 ))
  end
  
  local data_file = args.data_file
  assert(qc.isfile(data_file), "File not found " .. data_file)
  
  local meta_file = args.meta_file
  assert(qc.isfile(meta_file), "File not found " .. meta_file)
  
  local M = loadfile(meta_file)()
  local optargs = args.load_optargs
  if ( not D ) then 
    print("Loading data")
    D = Q.load_csv(data_file, M, optargs)
  end
  local old_class = kmeans.init(D, nK)
  while true do 
    local means = kmeans.update_step(D, nK, old_class)
    -- assert(nil, "PREMATURE")
    new_class = kmeans.assignment_step(D, nK, means)
    is_stop = kmeans.check_termination(old_class, new_class)
    if ( is_stop ) then break else old_class = new_class end
    n_iter = n_iter + 1 
    if ( n_iter > max_iter ) then print("Exceeded limit") break end
  end
  print("Success")
end
return run_kmeans
