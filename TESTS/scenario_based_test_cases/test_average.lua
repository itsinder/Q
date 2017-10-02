local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local metadata = {
 { name = "eng", has_nulls = true, qtype = "I4", is_load = true }, 
 { name = "phy", has_nulls = true, qtype = "I4", is_load = true }
}

local M = dofile("meta.lua")
load_csv_result = Q.load_csv("test.csv", metadata, {use_accesslator = false})


Q.print_csv(load_csv_result, nil, "")

col_add = Q.vvadd(load_csv_result[1], load_csv_result[2])
col_add:eval()

Q.print_csv(col_add, nil, "")

div = Q.mk_col({2, 2, 2, 2}, "I4")

col_average = Q.vvdiv(col_add, div)
col_average:eval()

Q.print_csv(col_average, nil, "")

load_csv_result[#load_csv_result + 1] = col_average

Q.print_csv(load_csv_result, nil, "")

Q.print_csv(load_csv_result, nil, "average.csv")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
