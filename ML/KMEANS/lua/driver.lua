local Q = require 'Q'
local run_kmeans = require 'run_kmeans'

local args = {}
args.k = 3
args.data_file = "../data/ds1.csv"
args.meta_file = "../data/ds1.meta.lua"
args.load_optargs = { is_hdr = true, use_accelerator = true }

Q.restore()
run_kmeans(args)
Q.save()
