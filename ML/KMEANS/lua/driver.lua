local Q = require 'Q'
local run_kmeans = require 'run_kmeans'

debug = true -- set to false once code stabilizes
local args = {}
args.k = 3
args.max_iter = 100
args.seed     = 1234567
args.perc_diff = 1
args.data_file = "../data/ds1.csv"
args.meta_file = "../data/ds1.meta.lua"
args.load_optargs = { is_hdr = true, use_accelerator = true }

-- Q.restore()
run_kmeans(args)
-- Q.save()
