import lupa
lua = lupa.LuaRuntime(unpack_returned_tuples=True)
lua.execute("Q = require 'Q'")


from lua_executor import Executor
executor = Executor()


from utils import Utils
utils = Utils()


from constants import *


from q_op_loader import op_wrapper
from q_op_loader import q_operators
for op_name in q_operators:
    globals()[op_name] = op_wrapper(op_name)


from q_helper import *
