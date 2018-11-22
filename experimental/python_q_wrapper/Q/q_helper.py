from Q import utils, executor
from p_vector import PVector
from p_reducer import PReducer
from p_scalar import PScalar
import constants as q_consts
import math
from q_op_category import *



def __wrap_output(op_name, result):
    if op_name in number_as_output:
        # no action required
        pass
    elif op_name in string_as_output:
        # no action required
        pass
    elif op_name in reducer_as_output:
        # wrap it with PReducer
        result = PReducer(result)
    elif op_name in scalar_as_output:
        # wrap it with PScalar
        result = PScalar(base_scalar=result)
    elif op_name in table_as_output:
        # convert lua table to dict/list
        result = utils.to_list_or_dict(result)
        for key, val in result.items():
            result[key] = PVector(val)
    elif op_name in vec_as_output:
        # wrap it with PVector
        result = PVector(result)
    else:
        raise Exception("Output type is not supported for operator {}".format(op_name))
    return result


def call_lua_op(op_name, *args):
    args_list = []
    for val in args:
        val = utils.update_args(val)
        args_list.append(val)
    args_list = utils.to_table(args_list)

    func_str = \
        """
        function(op_name, args)
            return Q[op_name](unpack(args))
        end
        """
    func = executor.eval(func_str)
    try:
        result = func(op_name, args_list)
    except Exception as e:
        # TODO: Handle operator level failures properly
        print(str(e))
        result = None
    if result:
        result = __wrap_output(op_name, result)
    return result


def __get_default_dtype(val_type):
    if val_type == int:
        dtype = q_consts.int64
    elif val_type == float:
        dtype = q_consts.float64
    else:
        raise Exception("input element type %s is not supported" % val_type)
    return dtype


# ==============================================


def array(in_vals, dtype=None):
    """Wrapper around Q.mk_col"""

    assert((type(in_vals) == list) or (type(in_vals) == tuple))
    if not dtype:
        val_type = type(in_vals[0])
        dtype = __get_default_dtype(val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)

    # convert in_vals to lua table
    in_vals = utils.to_table(in_vals)

    # call wrapper function
    return call_lua_op(q_consts.MK_COL, in_vals, dtype)


def add(vec1, vec2):
    """Add two vectors, wrapper around Q.add"""

    if not isinstance(vec1, PVector):
        raise Exception("First argument is not of type PVector")

    if not (isinstance(vec2, PVector) or isinstance(vec2, PScalar)
            or type(vec2) == int or type(vec2) == float):
        raise Exception("Second argument type {} is not supported".format(type(vec2)))

    # call wrapper function
    return call_lua_op(q_consts.ADD, vec1, vec2)


def full(shape, fill_value, dtype=None):
    """Create a constant vector, wrapper around Q.const"""

    assert(type(shape) == int)
    if not dtype:
        val_type = type(fill_value)
        dtype = __get_default_dtype(val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)

    # call wrapper function
    in_val = {'val': fill_value, 'qtype': dtype, 'len': shape}
    return call_lua_op(q_consts.CONST, in_val)


def zeros(shape, dtype=None):
    """Create a constant vector with value zero"""
    return full(shape, 0, dtype)


def ones(shape, dtype=None):
    """Create a constant vector with value one"""
    return full(shape, 1, dtype)


def arange(start=0, stop=None, step=1, dtype=None):
    """Create a sequence according to inputs, wrapper around Q.seq()"""

    if not stop:
        stop = start
        start = 0
    if not (type(stop) == int or type(stop) == float):
        raise Exception("stop value can't be %s" % type(stop))
    if not dtype:
        val_type = type(stop)
        dtype = __get_default_dtype(val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)
    length = math.ceil(float(stop - start) / step)

    # call wrapper function
    in_val = {'start': start, 'by': step, 'qtype': dtype, 'len': length}
    return call_lua_op(q_consts.SEQ, in_val)


def sqrt(vec):
    pass


def exp(vec):
    pass
