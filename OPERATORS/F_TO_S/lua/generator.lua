  local plfile = require 'pl.file'
  require 'Q/UTILS/lua/globals'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local gen_code = require("Q/UTILS/lua/gen_code")

  local operator_file = assert(arg[1])
  assert(plfile.access_time(operator_file))
  local operators = dofile(operator_file)

  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  local num_produced = 0
  for i, operator in ipairs(operators) do
    local sp_fn = assert(require(operator .. "_specialize"))
    for i, intype in ipairs(types) do 
      local status, subs, tmpl = pcall(sp_fn, intype)
      if ( status ) then 
        assert(type(subs) == "table")
        assert(type(tmpl) == "string")
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Generated ", subs.fn)
        num_produced = num_produced + 1
      else
        print("Failed ", intype, subs)
      end
    end
  end
  assert(num_produced > 0)
