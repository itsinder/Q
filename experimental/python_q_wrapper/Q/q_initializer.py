from Q import executor
from Q import utils
from p_vector import PVector


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


def update_args(val):
    if isinstance(val, PVector):
        return val.get_base_vec()
    elif type(val) == list:
        new_list = []
        for arg in val:
            new_list.append(update_args(arg))
        return utils.to_lua_table(new_list)
    elif type(val) == dict:
        new_dict = {}
        for i, v in val.items():
            new_dict[i] = update_args(v)
        return utils.to_lua_table(new_dict)
    else:
        return val


def call_lua_op(op_name, *args):
    args_list = []
    for val in args:
        val = update_args(val)
        args_list.append(val)
    args_list = utils.to_lua_table(args_list)

    func_str = \
        """
        function(op_name, args)
            return Q[op_name](unpack(args))
        end
        """
    func = executor.eval(func_str)
    result = func(op_name, args_list)
    if op_name not in non_vec_operators:
        result = PVector(result)
    return result


def op_wrapper(op_name):
    return lambda *x: call_lua_op(op_name, *x)

