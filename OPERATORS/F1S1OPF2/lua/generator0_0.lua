  local gen_code = require("Q/UTILS/lua/gen_code")
  local plpath = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  local num_produced = 0
  local sp_fn = assert(require("convert_specialize"))
  for _, in_qtype in ipairs(qtypes) do 
    for _, out_qtype in ipairs(qtypes) do 
      args = {}
      args.is_safe = false
      args.qtype = out_qtype
      local status, subs, tmpl = pcall(sp_fn, in_qtype, args)
      if ( status ) then 
        assert(type(subs) == "table")
        gen_code.doth(subs,tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Produced ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
        os.exit()
      end
    end
  end
  assert(num_produced > 0)
