  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
  local gen_code =  require("Q/UTILS/lua/gen_code")

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  local operations = { 'maxk', 'mink' }

  local sp_fn
  local num_produced = 0
  
  for _, op in ipairs(operations) do
    local sp_fn1_name = 'Q/OPERATORS/GETK/lua/' .. op .. '_specialize'
    local sp_fn2_name = 'Q/OPERATORS/GETK/lua/' .. op .. '_specialize_reducer'
    sp_fn1 = assert(require(sp_fn1_name))
    sp_fn2 = assert(require(sp_fn2_name))
    for _, qtype in ipairs(qtypes) do
      for _, sp_fn in pairs({sp_fn1, sp_fn2}) do
        local status, subs, tmpl = pcall(sp_fn, qtype, 4)
        if ( status ) then
          gen_code.doth(subs, tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          print("Generated ", subs.fn)
          num_produced = num_produced + 1
        else
          print(subs)
        end
      end
    end
  end

  assert(num_produced > 0)
