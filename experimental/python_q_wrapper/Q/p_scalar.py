import Q.lua_executor as executor
from Q import constants as q_consts
from Q.validate import is_p_vector, is_p_scalar


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
        func = executor.eval_lua(q_consts.create_scalar_str)
        result = func(val, qtype)
        return result

    def get_base_scalar(self):
        """return base scalar"""
        return self.base_scalar

    def to_num(self):
        """convert scalar to number"""
        func_str = q_consts.scalar_func_str.format(fn_name="to_num")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def fldtype(self):
        """return fldtype (qtype) of a scalar"""
        func_str = q_consts.scalar_func_str.format(fn_name="fldtype")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def qtype(self):
        """return fldtype (qtype) of a scalar"""
        return self.fldtype()

    def to_str(self):
        """convert scalar to string"""
        func_str = q_consts.scalar_func_str.format(fn_name="to_str")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def to_cmem(self):
        """convert scalar to cmem"""
        func_str = q_consts.scalar_func_str.format(fn_name="to_cmem")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def conv(self, qtype):
        """convert scalar to other qtype"""
        func_str = q_consts.scalar_func_arg_str.format(fn_name="conv")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, qtype)
        return self

    def abs(self):
        """convert scalar to absolute"""
        func_str = q_consts.scalar_func_str.format(fn_name="abs")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def __add__(self, other):
        """add two scalars"""
        if not (is_p_vector(other) or is_p_scalar(other)
                or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, q_consts.I8)
        elif type(other) == float:
            other = PScalar(other, q_consts.F8)
        elif is_p_vector(other):
            return other.__add__(self)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="+")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return PScalar(base_scalar=result)

    def __sub__(self, other):
        """subtract two scalars"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="-")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return PScalar(base_scalar=result)

    def __mul__(self, other):
        """multiply two scalars"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="*")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return PScalar(base_scalar=result)

    def __div__(self, other):
        """multiply two scalars"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="/")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return PScalar(base_scalar=result)

    def __ne__(self, other):
        """check whether two scalars are not equal"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="~=")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return result

    def __eq__(self, other):
        """check whether two scalars are equal"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="==")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return result

    def __ge__(self, other):
        """check whether first scalar is greater than or equal to second scalar"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op=">=")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return result

    def __gt__(self, other):
        """check whether first scalar is greater than second scalar"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op=">")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return result

    def __le__(self, other):
        """check whether first scalar is less than or equal to second scalar"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="<=")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return result

    def __lt__(self, other):
        """check whether first scalar is less than second scalar"""
        if not (is_p_scalar(other) or type(other) == int or type(other) == float):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        if type(other) == int:
            other = PScalar(other, I8)
        elif type(other) == float:
            other = PScalar(other, F8)
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op="<")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return result

    def __abs__(self):
        return self.abs()

    def __str__(self):
        """string representation of scalar"""
        return self.to_str()
