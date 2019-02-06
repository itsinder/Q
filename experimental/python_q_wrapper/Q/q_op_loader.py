import Q.lua_executor as executor
from Q.q_helper import call_lua_op
from Q import constants as q_consts


q_operators = list(executor.execute_lua(q_consts.q_op_str).values())

def op_wrapper(op_name):
    return lambda *args: call_lua_op(op_name, *args)
