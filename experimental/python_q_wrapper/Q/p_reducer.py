from Q import executor
from constants import *
from p_scalar import PScalar


class PReducer:
    def __init__(self, base_reducer):
        self.base_reducer = base_reducer

    def eval(self):
        """eval the reducer"""
        func_str = vec_func_str.format(fn_name="eval")
        func = executor.eval(func_str)
        result = func(self.base_reducer)
        new_result = []
        if type(result) == tuple:
            for val in result:
                new_result.append(PScalar(base_scalar=val))
        result = tuple(new_result)
        return result

    def get_name(self):
        """returns the name of a reducer"""
        func_str = vec_func_str.format(fn_name="get_name")
        func = executor.eval(func_str)
        result = func(self.base_reducer)
        return result

    def set_name(self, name):
        """sets the name of a reducer"""
        func_str = vec_func_arg_str.format(fn_name="set_name")
        func = executor.eval(func_str)
        result = func(self.base_reducer, name)
        return self

    def value(self):
        """returns value of a reducer"""
        func_str = vec_func_str.format(fn_name="value")
        func = executor.eval(func_str)
        result = func(self.base_reducer)
        return PScalar(base_scalar=result)