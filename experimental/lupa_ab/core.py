import json
from lua_executor import Executor


executor = Executor()


init_ab_str = \
    """
    function(config_file)
        ab = require 'Q/experimental/lupa_ab/core'
        return ab.init_ab(config_file)
    end
    """

sum_ab_str = \
    """
    function(ab_struct, json_body)
        ab = require 'Q/experimental/lupa_ab/core'
        return ab.sum_ab(ab_struct, json_body)
    end
    """

print_ab_str = \
    """
    function(ab_struct)
        ab = require 'Q/experimental/lupa_ab/core'
        return ab.print_ab(ab_struct)
    end
    """

free_ab_str = \
    """
    function(ab_struct)
        ab = require 'Q/experimental/lupa_ab/core'
        return ab.free_ab(ab_struct)
    end
    """


def init_ab(config_file):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(init_ab_str)
    result = func(config_file)
    return result


def sum_ab(ab_struct, factor):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(sum_ab_str)
    json_body = json.dumps({'factor': factor})
    result = func(ab_struct, json_body)
    return result


def print_ab(ab_struct):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(print_ab_str)
    result = func(ab_struct)
    return result


def free_ab(ab_struct):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(free_ab_str)
    result = func(ab_struct)
    return result

