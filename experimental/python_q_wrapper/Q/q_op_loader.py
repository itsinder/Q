from Q import executor
from q_helper import call_lua_op


non_vec_operators = [
    "print_csv",
    "load_csv"
]


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


def op_wrapper(op_name):
    return lambda *x: call_lua_op(op_name, *x)

