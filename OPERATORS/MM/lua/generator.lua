  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath   = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  local types = { 'F4', 'F8' }

  local num_produced = 0
  for i, operator in ipairs(operators) do
    -- local sp_fn = assert(require((operator .. "_specialize")))
    local sp_fn = assert(require("specialize"))
    for i, in1_qtype in ipairs(types) do 
      for j, in2_qtype in ipairs(types) do 
        for k, out_qtype in ipairs(types) do 
          local status, subs, tmpl = pcall(
          sp_fn, operator, in1_qtype, in2_qtype, out_qtype)
          if ( status ) then 
            assert(type(subs) == "table")
            assert(type(tmpl) == "string")
            -- for k, v in pairs(subs) do print(k, v) end
            -- print(tmpl)
            gen_code.doth(subs, tmpl, incdir)
            gen_code.dotc(subs, tmpl, srcdir)
            print("Produced ", subs.fn)
            num_produced = num_produced + 1
          else
            print(status)
            print(subs)
          end
        end
      end
    end
  end
  assert(num_produced > 0)
