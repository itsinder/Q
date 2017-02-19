
function concat_static_checker(
  f1type, 
  f2type, 
  optargs
  )
    local fouttype = optargs[fouttype] -- okay for fouttype to be nil
    local ok_intypes = { I1 = true, I2 = true, I4 = true }
    local ok_outtypes = { I2 = true, I4 = true, I8 = true }

    local w1   = assert(g_qtypes[f1type].width)
    local w2   = assert(g_qtypes[f2type].width)
    local shift = w2 * 8 -- convert bytes to bits 
    if ( not ok_intypes[f1type] ) then 
      print("input type", f1type, " not acceptable"); return nil; 
    end
    if ( not ok_intypes[f2type] ) then 
      print("input type", f2type, " not acceptable"); return nil; 
    end
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
    assert(l_outtype ~= nil, "Control should never come here")
    local l_wout = assert(g_qtypes[l_outtype].width, "ERROR")
    if ( fouttype ~= nil ) then 
      local wout   = assert(g_qtypes[fouttype].width, "ERROR")
      if ( not ok_outtypes[fouttype] ) then 
        print("fouttype is not valid destination type for concat")
        return nil
      end
      if ( wout >= l_wout ) then 
        print("Adjusting ", f1type, f2type, l_outtype, fouttype)
        l_outtype = fouttype
      else
        print("specified output type", l_outtype, " is not big enough")
        return nil
      end
    end
    local tmpl = 'base.tmpl'
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.includes = "#include <math.h>\n#include <curl/curl.h>"
    subs.fn = 
    "concat_" .. f1type .. "_" .. f2type .. "_" .. l_outtype 
    subs.in1type = g_qtypes[f1type].ctype
    subs.in2type = g_qtypes[f2type].ctype
    subs.returntype = g_qtypes[l_outtype].ctype
    subs.argstype = "void *"
    subs.c_code_for_operator = 
    " c = ( (" .. subs.returntype .. ")a << " .. shift .. " ) | b; "

    return subs, tmpl
end
