import Q
import sys
import os
from Q.p_vector import PVector


def test_mk_col():
    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.I1)
    Q.print_csv(vec)
    print("Successfully exexuted Q.mk_col test")


def test_print_csv():
    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    Q.print_csv(vec)
    print("Successfully exexuted Q.print_csv test")


def test_print_csv_list():
    in_vals = [1, 2, 3, 4]
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.mk_col(in_vals, Q.I1)
    Q.print_csv([vec1, vec2])
    print("Successfully exexuted Q.print_csv with list as input")


def test_print_csv_to_file():
    in_vals = [1, 2, 3, 4]
    file_name = "result.txt"
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.mk_col(in_vals, Q.I1)
    Q.print_csv([vec1, vec2], opfile=file_name)
    assert(os.path.exists(file_name))
    os.system("cat %s" % file_name)
    os.remove(file_name)
    assert(not os.path.exists(file_name))
    print("Successfully exexuted Q.print_csv with opfile as file")


def test_const():
    length = 6
    val = 5
    qtype = Q.I1
    vec = Q.const(val=val, length=length, qtype=qtype)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == length)
    Q.print_csv(vec)
    print("Successfully exexuted Q.const test")


def test_vec_add():
    in_vals = [1, 2, 3, 4, 5]
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.const(val=5, length=len(in_vals), qtype=Q.I1)
    out = Q.vvadd(vec1, vec2)
    assert(out.num_elements() == 0)
    out.eval()
    assert(out.num_elements() == len(in_vals))
    Q.print_csv(out)
    print("Successfully exexuted vec_add test")


def test_vec_concat():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1).set_name("new_vec").eval()
    assert(isinstance(vec1, PVector))
    Q.print_csv(vec1)
    print(vec1.get_name())
    print("Successfully exexuted vector method concat test")


def test_op_concat():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1)
    vec2 = Q.const(val=25, length=5, qtype=Q.I1)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully exexuted Q operator concat test")


def test_op_concat_memo():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1).memo(False)
    vec2 = Q.const(val=25, length=5, qtype=Q.I1).memo(False)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2).memo(False), vec2).memo(False), vec1).memo(False).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully exexuted Q operator concat test with setting memo false")


def test_op_concat_persist():
    vec1 = Q.const(val=5, length=5, qtype=Q.I1)
    vec2 = Q.const(val=25, length=5, qtype=Q.I1)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).persist(True).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully exexuted Q operator concat test with persist flag to true")


if __name__ == "__main__":
    test_mk_col()
    print("==========================")
    test_print_csv()
    print("==========================")
    test_print_csv_list()
    print("==========================")
    test_print_csv_to_file()
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
    print("==========================")
    test_op_concat_persist()
