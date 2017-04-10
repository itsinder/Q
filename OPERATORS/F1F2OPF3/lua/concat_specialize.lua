
function concat_specialize(
  f1type, 
  f2type, 
  optargs
  )
    local outtype = optargs.outtype -- okay for outtype to be nil
    local ok_intypes = { I1 = true, I2 = true, I4 = true }
    local ok_outtypes = { I2 = true, I4 = true, I8 = true }

    assert(ok_intypes[f1type], "input type " .. f1type .. " not acceptable")
    assert(ok_intypes[f2type], "input type " .. f2type .. " not acceptable")

    local w1   = assert(g_qtypes[f1type].width)
    local w2   = assert(g_qtypes[f2type].width)

    local shift = w2 * 8 -- convert bytes to bits 
    local l_outtype = nil
    if ( f1type == "I4" ) then 
      l_outtype = "I8"
    elseif( f1type == "I2" ) then 
      if ( f2type == "I4" ) then
        l_outtype = "I8"
      elseif( f2type == "I2" ) then
        l_outtype = "I4"
      elseif( f2type == "I1" ) then
        l_outtype = "I4"
      end
    elseif( f1type == "I1" ) then 
      if ( f2type == "I4" ) then
        l_outtype = "I8"
      elseif( f2type == "I2" ) then
        l_outtype = "I4"
      elseif( f2type == "I1" ) then
        l_outtype = "I2"
      end
    end
    assert(l_outtype, "Control should never come here")
    assert(ok_outtypes[l_outtype], "output type " .. 
    l_outtype .. " not acceptable")
    if ( outtype ) then 
      assert(ok_outtypes[outtype], "output type " ..
      outtype .. " not acceptable")
      local width_l_outtype = assert(g_qtypes[l_outtype].width, "ERROR")
      local width_outtype   = assert(g_qtypes[outtype].width, "ERROR")
      assert( width_outtype >= width_l_outtype,
      "specfiied outputtype not big enough")
      l_outtype = outtype
    end
    local tmpl = 'base.tmpl'
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.includes = "#include <math.h>\n#include <curl/curl.h>"
    subs.fn = 
    "concat_" .. f1type .. "_" .. f2type .. "_" .. l_outtype 
    subs.in1type = g_qtypes[f1type].ctype
    subs.in2type = g_qtypes[f2type].ctype
    subs.out_c_type = g_qtypes[l_outtype].ctype
    subs.c_code_for_operator = 
    " c = ( (" .. subs.out_c_type .. ")a << " .. shift .. " ) | b; "

    return subs, tmpl
end
