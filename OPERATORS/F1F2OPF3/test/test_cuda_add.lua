local Q = require 'Q'

local x = Q.mk_col({1, 2, 3, 4}, "I2")
local y = Q.mk_col({1, 2, 3, 4}, "I4")

local z = Q.vvadd(x, y)

Q.print_csv(z)

-- Added os.exit() to avoid the luajit error, refer email with subj "Luajit problem when running vvadd with CUDA"
--os.exit()
