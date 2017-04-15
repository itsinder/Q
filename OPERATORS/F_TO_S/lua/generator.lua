  local plfile = require 'pl.file'
  dofile '../../../UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"

  require("aux")
  require("gen_doth")
  require("gen_dotc")
  plfile.delete("_qfns_f_to_s.lua")

  local operator_file = assert(arg[1])
  assert(plfile.access_time(operator_file))
  local T = dofile(operator_file)
  

  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  args = nil -- not being used just yet
  for i, v in ipairs(T) do
    -- ==================
    local str = "function " .. v .. "(fld)\n"
    str = str .. "  expander(\"f_to_s\", \"" .. v .. "\", fld)\n"
    str = str .. "end\n"
    local f = assert(io.open("_qfns_f_to_s.lua", "a"))
    f:write(str)
    f:close()
    -- ==================

    local base_name = v
    local str = 'require \'' .. base_name .. '_specialize\''
    loadstring(str)()
    for i, intype in ipairs(types) do 
      local stat_chk = base_name .. '_specialize'
      local stat_chk_fn = assert(_G[stat_chk], 
      "function not found " .. stat_chk)
      local status, subs, tmpl = pcall(stat_chk_fn, intype)
      if ( status ) then 
      -- TODO Improve following.
      local T = dofile(tmpl)
      T.fn            = subs.fn
      T.intype        = subs.intype
      T.reducer       = subs.reducer
      T.t_reducer     = subs.t_reducer
      T.disp_intype   = subs.disp_intype
      T.reduce_intype = subs.reduce_intype
      T.init_val      = subs.init_val     
      gen_doth(T.fn, T, incdir)
      gen_dotc(T.fn, T, srcdir)
      print("Generated ", T.fn)
    else
    end
    end
  end
