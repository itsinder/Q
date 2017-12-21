-- Test to view meta data of global vectors
local Q = require 'Q'

local meta_table, meta_json = Q.view_meta()
assert(type(meta_table) == "table")
assert(meta_json)
print(meta_json)

