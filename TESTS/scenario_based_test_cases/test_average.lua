local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local metadata = {
 { name = "eng", has_nulls = true, qtype = "I4", is_load = true }, 
 { name = "phy", has_nulls = true, qtype = "I4", is_load = true }
}

local M = dofile("meta.lua")
load_csv_result = Q.load_csv("test.csv", metadata)


Q.print_csv(load_csv_resut, nil, "")

col_add = Q.vvadd(load_csv_result[1], load_csv_result[2])
div = Q.mk_col({2, 2, 2, 2}, "I4")

col_average = Q.vvdiv(col_add, div)

load_csv_result[#load_csv_result + 1] = col_average

Q.print_csv(load_csv_resut, nil, "")

Q.print_csv(load_csv_result, nil, "average.csv")
