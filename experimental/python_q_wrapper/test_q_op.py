import Q
from Q.p_vector import PVector


def test_const():
    """Test the Q.const() functionality
    It creates a constant vector with specified value and length"""

    length = 6
    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : length }
    vec = Q.const(in_val)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == length)
    Q.print_csv(vec)
    print("Successfully executed Q.const test")


def test_vec_add():
    """Test Q.vvadd() functionality
    It performs sum of two vectors"""

    in_vals = [1, 2, 3, 4, 5]
    vec1 = Q.mk_col(in_vals, Q.I1)
    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : 5 }
    vec2 = Q.const(in_val)
    out = Q.vvadd(vec1, vec2)
    assert(out.num_elements() == 0)
    out.eval()
    assert(out.num_elements() == len(in_vals))
    Q.print_csv(out)
    print("Successfully executed vec_add test")


def test_op_concat():
    """Test the Q operator concatenation"""

    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : 5 }
    vec1 = Q.const(in_val)
    in_val = { 'val' : 25, 'qtype' : Q.I1, 'len' : 5 }
    vec2 = Q.const(in_val)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully executed Q operator concat test")


def test_op_concat_memo():
    """Test the Q operator concatenation with setting memo to false"""

    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : 5 }
    vec1 = Q.const(in_val).memo(False)
    in_val = { 'val' : 25, 'qtype' : Q.I1, 'len' : 5 }
    vec2 = Q.const(in_val).memo(False)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2).memo(False), vec2).memo(False), vec1).memo(False).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully executed Q operator concat test with setting memo false")


if __name__ == "__main__":
    test_const()
    print("==========================")
    test_vec_add()
    print("==========================")
    test_op_concat()
    print("==========================")
    test_op_concat_memo()
    print("==========================")
