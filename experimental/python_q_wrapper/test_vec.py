import Q
from Q.p_vector import PVector


def test_vec_concat():
    """Test the vector methods concatenation"""

    in_val = { 'val' : 5, 'qtype' : Q.I1, 'len' : 5 }
    vec1 = Q.const(in_val).set_name("new_vec").eval()
    assert(isinstance(vec1, PVector))
    Q.print_csv(vec1)
    assert(vec1.get_name() == "new_vec")
    print("Successfully executed vector method concat test")


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
    test_vec_concat()
    print("==========================")
    test_vec_persist()
    print("==========================")