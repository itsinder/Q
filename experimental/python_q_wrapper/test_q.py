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


if __name__ == "__main__":
    test_mk_col()
    print("==========================")
    test_print_csv()
    print("==========================")
    test_const()
    print("==========================")
    test_vec_add()
