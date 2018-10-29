import Q
import sys
from Q.p_vector import PVector


def test_mk_col():
    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.I1)
    sys.stdout.write(Q.print_csv(vec))
    print("Successfully exexuted Q.mk_col test")


def test_print_csv():
    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    result = Q.print_csv(vec)
    sys.stdout.write(result)
    print("Successfully exexuted Q.print_csv test")


def test_const():
    length = 6
    val = 5
    qtype = Q.I1
    vec = Q.const(val=val, length=length, qtype=qtype)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == length)
    sys.stdout.write(Q.print_csv(vec))
    print("Successfully exexuted Q.const test")


def test_vec_add():
    in_vals = [1, 2, 3, 4, 5]
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.const(val=5, length=len(in_vals), qtype=Q.I1)
    out = Q.vvadd(vec1, vec2)
    assert(out.num_elements() == 0)
    out.eval()
    assert(out.num_elements() == len(in_vals))
    sys.stdout.write(Q.print_csv(out))
    print("Successfully exexuted vec_add test")


def test_vec_concat():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1).set_name("new_vec").eval()
    assert(isinstance(vec1, PVector))
    sys.stdout.write(Q.print_csv(vec1))
    print(vec1.get_name())
    print("Successfully exexuted vector method concat test")


def test_op_concat():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1)
    vec2 = Q.const(val=25, length=5, qtype=Q.I1)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).eval()
    assert(isinstance(result, PVector))
    sys.stdout.write(Q.print_csv(result))
    print("Successfully exexuted Q operator concat test")


def test_op_concat_memo():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1).memo(False)
    vec2 = Q.const(val=25, length=5, qtype=Q.I1).memo(False)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2).memo(False), vec2).memo(False), vec1).memo(False).eval()
    assert(isinstance(result, PVector))
    sys.stdout.write(Q.print_csv(result))
    print("Successfully exexuted Q operator concat test with setting memo false")


def test_op_concat_persist():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1)
    vec2 = Q.const(val=25, length=5, qtype=Q.I1)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).persist(True).eval()
    assert(isinstance(result, PVector))
    sys.stdout.write(Q.print_csv(result))
    print("Successfully exexuted Q operator concat test with persist flag to true")


if __name__ == "__main__":
    """
    test_mk_col()
    print("==========================")
    test_print_csv()
    print("==========================")
    test_const()
    print("==========================")
    test_vec_add()
    print("==========================")
    test_vec_concat()
    print("==========================")
    test_op_concat()
    print("==========================")
    test_op_concat_memo()
    """
    print("==========================")
    test_op_concat_persist()
