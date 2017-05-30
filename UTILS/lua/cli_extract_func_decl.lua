local extract_func_decl = require 'UTILS/lua/extract_func_decl'

assert(#arg == 2, "Usage is lua " .. arg[0] .. " <infile> <opdir> ")
infile = arg[1]
opdir = arg[2]
local status = extract_func_decl(infile, opdir)
assert(status)
