  local rootdir = os.getenv("Q_SRC_ROOT")
  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
  package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
  require("aux")
  require("gen_doth")
  require("gen_dotc")
  local plfile = require 'pl.file'

  dofile '../../../UTILS/lua/globals.lua'

  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local operator_file = assert(arg[1])
  local T = assert(dofile(operator_file))
  local types = { 'B1' }
  for i, base_name in ipairs(T) do
    -- ==================
    local str = "function " .. base_name .. "(f1, f2)\n"
    str = str .. "  expander(\"f1f2opf3\", \"" .. base_name .. "\", f1, f2)\n"
    str = str .. "end\n"
    local f = assert(io.open("_qfns_f1f2opf3.lua", "a"))
    f:write(str)
    f:close()
    -- ==================
    local str = 'require \'' .. base_name .. '_specialize\''
    assert(plfile.access_time(base_name .. "_specialize.lua"))
    loadstring(str)()
    local stat_chk = base_name .. '_specialize'
    local stat_chk_fn = assert(_G[stat_chk], "function not found " .. stat_chk)
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        local status, subs, tmpl = pcall(stat_chk_fn, in1type, in2type)
        if ( status ) then 
          -- TODO Improve following.
          local T = dofile(tmpl)
          T.fn         = subs.fn
          T.c_code_for_operator = subs.c_code_for_operator
          gen_doth(subs.fn, T, incdir)
          gen_dotc(subs.fn, T, srcdir)
          print("Produced ", T.fn)
        end
      end
    end
  end
