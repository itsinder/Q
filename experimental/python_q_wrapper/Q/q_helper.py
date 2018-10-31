from Q import utils, executor
from p_vector import PVector


def call_lua_op(op_name, *args):
    args_list = []
    for val in args:
        if type(val) == list:
            val = utils.to_lua_table(val)
        if type(val) == dict:
            val = utils.to_lua_table(val)
        if isinstance(val, PVector):
            val = val.get_base_vec()
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
    return PVector(result)


def print_csv(vec, opfile=None):
    """print the vector contents"""
    if not (isinstance(vec, PVector) or type(vec) == list):
        assert(False)  # Raise exception

    func_str = \
        """
        function(vec, opfile)
            return Q.print_csv(vec, {opfile = opfile})
        end
        """

    # if input is list, convert it to table
    if type(vec) == list:
        vec = [ x.get_base_vec() for x in vec ]
        vec = utils.to_lua_table(vec)
    else:
        vec = vec.get_base_vec()
    func = executor.eval(func_str)
    result = func(vec, opfile)
    return result
