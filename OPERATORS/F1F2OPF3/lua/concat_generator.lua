  package.path = package.path.. ";../../../UTILS/lua/?.lua"
  require("aux")
  require("gen_doth")
  require("gen_dotc")
  local plfile = require 'pl.file'
  dofile '../../../UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local operator_file = assert(arg[1])
  assert(plfile.access_time(operator_file))
  local T = dofile(operator_file)
  --==================================================
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  for i, base_name in ipairs(T) do
    -- ==================
    local str = "function " .. base_name .. "(f1, f2, optargs)\n"
    str = str .. "  expander(\"f1f2opf3\", \"" .. base_name .. "\", f1, f2, optargs)\n"
    str = str .. "end\n"
    local f = assert(io.open("_qfns_f1f2opf3.lua", "a"))
    f:write(str)
    f:close()
    -- ==================
    local str = 'require \'' .. base_name .. '_specialize\''
    loadstring(str)() 
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        for k, outtype in ipairs(types) do 
          local optargs = {}
          optargs.outtype = outtype
          local stat_chk = base_name .. '_specialize'
          local stat_chk_fn = assert(_G[stat_chk], 
          "function not found " .. stat_chk)
          -- print("Lua premature", stat_chk); os.exit()
          local status, subs, tmpl = pcall(
          stat_chk_fn, in1type, in2type, optargs)
          if ( status) then
            -- TODO Improve following.
            local T = dofile(tmpl)
            T.fn       = subs.fn
            T.includes = subs.includes
            T.in1type  = subs.in1type
            T.in2type  = subs.in2type
            T.outtype  = subs.outtype
            T.argstype = subs.argstype
            T.c_code_for_operator = subs.c_code_for_operator
            gen_doth(T.fn, T, incdir)
            gen_dotc(T.fn, T, srcdir)
            print("Produced ", T.fn)
          end
        end
      end
    end
  end
