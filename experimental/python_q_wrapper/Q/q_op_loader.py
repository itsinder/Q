import Q.lua_executor as executor
from Q.q_helper import call_lua_op


q_op_str = \
    """
    local Q = require 'Q'
    local t = {}
    for i, v in pairs(Q) do
        t[i] = v
    end
    return t
    """
q_operators = [str(x) for x in dict(executor.execute_lua(q_op_str)).keys()]


def op_wrapper(op_name):
    return lambda *y: call_lua_op(op_name, *y)
