from Q import utils, executor
from p_vector import PVector
import constants as q_consts


non_vec_operators = [
    "print_csv",
    "load_csv"
]


def __update_args(val):
    if isinstance(val, PVector):
        return val.get_base_vec()
    elif type(val) == list:
        new_list = []
        for arg in val:
            new_list.append(__update_args(arg))
        return utils.to_lua_table(new_list)
    elif type(val) == dict:
        new_dict = {}
        for i, v in val.items():
            new_dict[i] = __update_args(v)
        return utils.to_lua_table(new_dict)
    else:
        return val


def call_lua_op(op_name, *args):
    args_list = []
    for val in args:
        val = __update_args(val)
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


# ==============================================

def array(in_vals, dtype=None):
    """Wrapper around Q.mk_col"""

    assert((type(in_vals) == list) or (type(in_vals) == tuple))
    if not dtype:
        val_type = type(in_vals[0])
        if val_type == int:
            dtype = q_consts.int64
        elif val_type == float:
            dtype = q_consts.float64
        else:
            raise Exception("input element type %s is not supported" % val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)

    # convert in_vals to lua table
    in_vals = utils.to_lua_table(in_vals)

    # call wrapper function
    return call_lua_op(q_consts.mk_col, in_vals, dtype)
