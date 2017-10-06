  local gen_code = require("Q/UTILS/lua/gen_code")
  local plpath = require "pl.path"
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8', 'B1' }

  local num_produced = 0
  local sp_fn = assert(require("convert_specialize"))

  local function generate_files(in_qtype, args)
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

  for _, in_qtype in ipairs(qtypes) do 
    for _, out_qtype in ipairs(qtypes) do 
      if ( out_qtype ~= in_qtype ) then
        args = {}
        args.qtype = out_qtype
        local safe_flag = true
        local unsafe_flag = true
        if out_qtype == "B1" or in_qtype == "B1" then
          safe_flag = false
          if out_qtype == "F4" or out_qtype == "F8" or in_qtype == "F4" or in_qtype == "F8" then
            unsafe_flag = false
          end
        end
        if unsafe_flag then
          --Generate files for unsafe mode
          args.is_safe = false
          status = pcall(generate_files, in_qtype, args)
          assert(status, "Failed to generate files for unsafe mode")
        end
        if safe_flag then
          --Generate files for safe mode
          args.is_safe = true
          status = pcall(generate_files, in_qtype, args)
          assert(status, "Failed to generate files for safe mode")
        end
      end
    end
  end
  assert(num_produced > 0)
