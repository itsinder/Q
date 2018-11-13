from Q import executor
from constants import *


class PScalar:
    def __init__(self, val=None, qtype=None, base_scalar=None):
        if base_scalar:
            self.base_scalar = base_scalar
        else:
            if not val or not qtype:
                raise Exception("Provide appropriate argument to PScalar constructor")
            self.base_scalar = self.new(val, qtype)

    def new(self, val, qtype):
        """create a scalar"""
        func_str = \
            """
            function(val, qtype)
                local Scalar = require 'libsclr'
                return Scalar.new(val, qtype)
            end
            """
        func = executor.eval(func_str)
        result = func(val, qtype)
        return result

    def get_base_scalar(self):
        """return base scalar"""
        return self.base_scalar

    def to_num(self):
        """convert scalar to number"""
        func_str = scalar_func_str.format(fn_name="to_num")
        func = executor.eval(func_str)
        result = func(self.base_scalar)
        return result

    def fldtype(self):
        """return fldtype (qtype) of a scalar"""
        func_str = scalar_func_str.format(fn_name="fldtype")
        func = executor.eval(func_str)
        result = func(self.base_scalar)
        return result

    def qtype(self):
        """return fldtype (qtype) of a scalar"""
        return self.fldtype()

    def to_str(self):
        """convert scalar to string"""
        func_str = scalar_func_str.format(fn_name="to_str")
        func = executor.eval(func_str)
        result = func(self.base_scalar)
        return result

    def to_cmem(self):
        """convert scalar to cmem"""
        func_str = scalar_func_str.format(fn_name="to_cmem")
        func = executor.eval(func_str)
        result = func(self.base_scalar)
        return result

    def conv(self, qtype):
        """convert scalar to other qtype"""
        func_str = \
            """
            function(scalar, qtype)
                return scalar:conv(qtype)
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_scalar, qtype)
        return self

    def abs(self):
        """convert scalar to absolute"""
        func_str = scalar_func_str.format(fn_name="abs")
        func = executor.eval(func_str)
        result = func(self.base_scalar)
        return result

    def __add__(self, other):
        """add two scalars"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="+")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __sub__(self, other):
        """subtract two scalars"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="-")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __mul__(self, other):
        """multiply two scalars"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="*")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __div__(self, other):
        """multiply two scalars"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="/")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __ne__(self, other):
        """check whether two scalars are not equal"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="~=")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __eq__(self, other):
        """check whether two scalars are equal"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="==")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __ge__(self, other):
        """check whether first scalar is greater than or equal to second scalar"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op=">=")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __gt__(self, other):
        """check whether first scalar is greater than second scalar"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op=">")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __le__(self, other):
        """check whether first scalar is less than or equal to second scalar"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="<=")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __lt__(self, other):
        """check whether first scalar is less than second scalar"""
        if not isinstance(other, PScalar):
            raise Exception("Second argument is not of type PScalar")
        func_str = scalar_arith_func_str.format(op="<")
        func = executor.eval(func_str)
        result = func(self.base_scalar, other.base_scalar)
        return PScalar(base_scalar=result)

    def __abs__(self):
        return self.abs()

    def __str__(self):
        """string representation of scalar"""
        return self.to_str()
