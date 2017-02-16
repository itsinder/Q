
-- TODO local md5 = require 'md5'
function lambda_static_checker(
  f1type, 
  f2type, 
  optargs
  )
    assert(optargs)
    assert(type(optargs) == "table")
    assert(f1type == optargs.i1type)
    assert(f2type == optargs.i2type)
    local o1type = assert(optargs.o1type) -- output type specified 
    local c_code_for_operator = assert(optargs.code) -- 
    local tmpl = 'f1f2opf3.tmpl'
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.includes = optargs.includes -- not mandatory
    subs.fn = "xxx" -- TODO "f1f2opf3" .. md5(table_to_string(optargs))
    subs.in1type = f1type
    subs.in2type = f2type
    subs.returntype = o1type
    subs.argstype = "void *"
    subs.c_code_for_operator = c_code_for_operator 

    return subs, tmpl
end
