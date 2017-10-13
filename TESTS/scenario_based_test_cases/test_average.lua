local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local M = dofile("meta.lua")
load_csv_result = Q.load_csv("test.csv", M, {use_accelerator = false})

Q.print_csv(load_csv_result, nil, "")

col_add = Q.vvadd(load_csv_result[1], load_csv_result[2])

div = Q.mk_col({2, 2, 2, 2}, "I4")

col_average = Q.vvdiv(col_add, div)

load_csv_result[#load_csv_result + 1] = col_average:eval()

Q.print_csv(load_csv_result, nil, "")

Q.print_csv(load_csv_result, nil, "average.csv")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.execute("rm _*.bin") 
os.exit()
