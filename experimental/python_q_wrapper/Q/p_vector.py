from Q import executor
from constants import *


class PVector:
    def __init__(self, base_vec):
        self.base_vec = base_vec

    def get_base_vec(self):
        return self.base_vec

    def eval(self):
        """eval the vector"""
        func_str = vec_func_str.format(fn_name="eval")
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return self

    def length(self):
        """returns the vector length"""
        func_str = vec_func_str.format(fn_name="length")
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def qtype(self):
        """returns the qtype of vector"""
        func_str = vec_func_str.format(fn_name="qtype")
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def num_elements(self):
        """returns the num_elements of vector"""
        func_str = vec_func_str.format(fn_name="num_elements")
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def set_name(self, name):
        """sets the name of a vector"""
        func_str = vec_func_arg_str.format(fn_name="set_name")
        func = executor.eval(func_str)
        result = func(self.base_vec, name)
        return self

    def get_name(self):
        """returns the name of a vector"""
        func_str = vec_func_str.format(fn_name="get_name")
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def memo(self, is_memo):
        """sets the memo value for vector"""
        func_str = vec_func_arg_str.format(fn_name="memo")
        func = executor.eval(func_str)
        result = func(self.base_vec, is_memo)
        return self

    def is_memo(self):
        """returns memo value for vector"""
        func_str = vec_func_str.format(fn_name="is_memo")
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def persist(self, is_persist):
        """sets the persist flag for vector"""
        func_str = vec_func_arg_str.format(fn_name="persist")
        func = executor.eval(func_str)
        result = func(self.base_vec, is_persist)
        return self