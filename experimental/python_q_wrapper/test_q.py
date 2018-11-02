import Q
import sys
import os
from Q.p_vector import PVector

def test_mk_col():
    """Test the Q.mk_col() functionality
    Input is list, output is PVector"""

    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.I1)
    Q.print_csv(vec)
    print("Successfully executed Q.mk_col test")


def test_print_csv():
    """Test Q.print_csv() with opfile=None (default)
    This will print the vector values to stdout"""

    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    Q.print_csv(vec)
    print("Successfully executed Q.print_csv test")


def test_print_csv_str():
    """Test Q.print_csv() with opfile=""
    This will return the string representation of vector"""

    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    result = Q.print_csv(vec, {'opfile' : ""})
    sys.stdout.write(result)
    print("Successfully executed Q.print_csv test")


def test_print_csv_list():
    """Test Q.print_csv() with list of vectors as input"""

    in_vals = [1, 2, 3, 4]
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.mk_col(in_vals, Q.I1)
    Q.print_csv([vec1, vec2])
    print("Successfully executed Q.print_csv with list as input")


def test_print_csv_to_file():
    """Test Q.print_csv() with opfile=file
    This will write the print_csv output to file"""

    in_vals = [1, 2, 3, 4]
    file_name = "result.txt"
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.mk_col(in_vals, Q.I1)
    Q.print_csv([vec1, vec2], {'opfile':file_name})
    assert(os.path.exists(file_name))
    os.system("cat %s" % file_name)
    os.remove(file_name)
    assert(not os.path.exists(file_name))
    print("Successfully executed Q.print_csv with opfile as file")


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


def test_vec_concat():
    """Test the vector methods concatenation"""

    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : 5 }
    vec1 = Q.const(in_val).set_name("new_vec").eval()
    assert(isinstance(vec1, PVector))
    Q.print_csv(vec1)
    assert(vec1.get_name() == "new_vec")
    print("Successfully executed vector method concat test")


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


def test_vec_persist():
    """Test the vec persist method"""

    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : 5 }
    vec1 = Q.const(in_val)
    in_val = { 'val' : 25, 'qtype' : Q.I1, 'len' : 5 }
    vec2 = Q.const(in_val)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).persist(True).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully executed Q operator concat test with persist flag to true")


if __name__ == "__main__":
    test_mk_col()
    print("==========================")
    test_print_csv()
    print("==========================")
    test_print_csv_str()
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
    test_vec_persist()
