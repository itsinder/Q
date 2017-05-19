  local gen_code = require 'gen_code'
  local plpath = require 'pl.path'
  local plfile = require 'pl.file'
  loadfile 'globals.lua'
  local srcdir = '../gen_src/'
  local incdir = '../gen_inc/'
  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = assert(dofile(operator_file))
  --==================================================
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  for i, operator in ipairs(operators) do
    local sp_fn = require 'concat_specialize'

    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        for k, out_qtype in ipairs(types) do 
          local optargs = {}
          optargs.out_qtype = out_qtype
          -- print("Lua premature", stat_chk); os.exit()
          local status, subs, tmpl = pcall(
          sp_fn, in1type, in2type, optargs)
          if ( status) then
            assert(type(subs) == "table")
            assert(type(tmpl) == "string")
            gen_code.doth(subs, tmpl, incdir)
            gen_code.dotc(subs, tmpl, srcdir)
            print("Produced ", subs.fn)
          end
        end
      end
    end
  end
  file = io.open("_concat", "w+")
  io.output(file)
  io.write("Created concat files")
