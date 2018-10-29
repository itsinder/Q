from Q import utils, executor
from p_vector import PVector


def mk_col(in_vals, qtype):
    """create a vector with specified elements"""
    assert(type(in_vals) == list)
    assert(type(qtype) == str)

    func_str = \
        """
        function(in_table, qtype)
            return Q.mk_col(in_table, qtype)
        end
        """
    func = executor.eval(func_str)
    in_table = utils.to_lua_table(in_vals)
    result = func(in_table, qtype)
    return PVector(result)


def print_csv(vec):
    """print the vector contents"""
    assert(isinstance(vec, PVector))

    func_str = \
        """
        function(vec)
            return Q.print_csv({vec}, {opfile = ""})
        end
        """
    func = executor.eval(func_str)
    result = func(vec.get_base_vec())
    return result


def const(val, qtype, length):
    """create a constant vector"""
    func_str = \
        """
        function(val, qtype, len)
            return Q.const( { val = val, qtype = qtype, len = len })
        end
        """
    func = executor.eval(func_str)
    result = func(val, qtype, length)
    return PVector(result)


def vvadd(vec1, vec2):
    """add two vectors"""
    assert(isinstance(vec1, PVector))
    assert(isinstance(vec2, PVector))

    func_str = \
        """
        function(vec1, vec2)
            return Q.vvadd(vec1, vec2)
        end
        """
    func = executor.eval(func_str)
    result = func(vec1.get_base_vec(), vec2.get_base_vec())
    return PVector(result)


def vvadd(vec1, vec2):
    """add two vectors"""
    assert(isinstance(vec1, PVector))
    assert(isinstance(vec2, PVector))

    func_str = \
        """
        function(vec1, vec2)
            return Q.vvadd(vec1, vec2)
        end
        """
    func = executor.eval(func_str)
    result = func(vec1.get_base_vec(), vec2.get_base_vec())
    return PVector(result)


def vvsub(vec1, vec2):
    """subtract two vectors"""
    assert(isinstance(vec1, PVector))
    assert(isinstance(vec2, PVector))

    func_str = \
        """
        function(vec1, vec2)
            return Q.vvsub(vec1, vec2)
        end
        """
    func = executor.eval(func_str)
    result = func(vec1.get_base_vec(), vec2.get_base_vec())
    return PVector(result)


def vveq(vec1, vec2):
    """returns comparison of vector"""
    assert(isinstance(vec2, PVector))
    assert(isinstance(vec2, PVector))

    func_str = \
        """
        function(vec1, vec2)
            return Q.vveq(vec1, vec2)
        end
        """
    func = executor.eval(func_str)
    result = func(vec1.get_base_vec(), vec2.get_base_vec())
    return PVector(result)

