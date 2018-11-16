local qc      = require 'Q/UTILS/lua/q_core'
local Q       = require 'Q'
local kmeans  = require 'kmeans'
local check   = require 'check'
local Vector  = require 'libvec'

local function run_kmeans(
  args
  )
  
  assert(args and (type(args) == "table"))
  
  local perc_diff = 0.1
  if ( args.perc_diff ) then
    local x_perc_diff = args.perc_diff
    assert(type(x_perc_diff) == "number")
    assert( (x_perc_diff > 0 ) and ( x_perc_diff < 100 ) )
    perc_diff = x_perc_diff
  end
  local nK = assert(args.k)
  assert((type(nK) == "number") and ( nK > 0 ) and ( nK < 16 ))
  
  local max_iter = 1000
  if ( args.max_iter ) then 
    local x_max_iter = args.max_iter
    assert((type(x_max_iter) == "number") and ( x_max_iter > 0 ))
    max_iter = x_max_iter
  end
  
  local seed = qc.RDTSC()
  if ( args.seed ) then 
    local x_seed = args.seed
    assert((type(x_seed) == "number") and ( x_seed > 0 ))
    seed = x_seed
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
  local nI, nJ = assert(check.data(D))
  
  -- set chunk size to encompass data set (okay for small data sets)
  local chunk_size = 1024
  while chunk_size < nI do
    chunk_size = chunk_size * 2
  end
  print("chunk_size set to ", chunk_size)
  package.loaded['Q/UTILS/lua/q_consts'].chunk_size = chunk_size
  Vector.set_chunk_size(chunk_size);

  local old_class, num_in_class = kmeans.init(seed, nI, nJ, nK)
 

  local n_iter = 1
  while true do 
    local means = kmeans.update_step(D, nI, nJ, nK, old_class, num_in_class)
    local new_class, num_in_class = 
      kmeans.assignment_step( D, nI, nJ, nK, means)
    is_stop, n_iter = kmeans.check_termination(
      old_class, new_class, nI, nJ, nK, perc_diff, n_iter, max_iter)
    if ( is_stop ) then break else old_class = new_class end
  end
  print("Success")
end
return run_kmeans