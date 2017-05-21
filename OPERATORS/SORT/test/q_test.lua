require 'sort'
q = require'q'
local q_core = require 'q_core'
local mk_col = require 'mk_col'
local print_csv = require 'print_csv'
local save = require 'save'
x = mk_col({10, 20, 30, 40}, 'I4')
print(type(x))
print(x:length())
sort(x, "dsc")
print_csv(x, nil, "")
-- TODO Improve checking of output 
save('tmp.save')
