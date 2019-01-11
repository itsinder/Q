import lupa


lua_runtime = lupa.LuaRuntime(unpack_returned_tuples=True)
lua_runtime.execute("Q = require 'Q'")


from src.q_op_loader import op_wrapper
from src.q_op_loader import q_operators
from src.q_op_stub import *
from src.q_helper import *
from src.constants import *


for op_name in q_operators:
    globals()[op_name] = op_wrapper(op_name)
