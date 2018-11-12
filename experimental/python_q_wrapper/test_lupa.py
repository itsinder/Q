from Q import executor


q_op_str = \
    """
    local Q = require 'Q'
    local t = {}
    for i, v in pairs(Q) do
        t[i] = v
    end
    return t
    """
q_operators = [ str(x) for x in dict(executor.execute(q_op_str)).keys() ]

#for i in q_operators:
#    print(i)



func_str = \
    """
    function(a, b)
        assert(nil)
        return a + b
    end
    """

func = executor.eval(func_str)
try:
    print(func(5, 9))
except Exception as e:
    print(str(e))
print("Done")
