import Q
from Q.p_scalar import PScalar


def test_scalar_new():
    """Create scalar using PScalar class"""
    val = 5
    qtype = Q.I1
    sclr = PScalar(val, qtype)
    assert(isinstance(sclr, PScalar))
    assert(sclr.to_num() == val)
    assert(sclr.qtype() == qtype)
    print(sclr)
    print("Successfully executed scalar creation test")


def test_scalar_arith():
    """Create two scalars and perform scalar arithmetic"""
    val1 = 5
    val2 = 10
    qtype = Q.I1
    sclr1 = PScalar(val1, qtype)
    sclr2 = PScalar(val2, qtype)
    assert(isinstance(sclr1, PScalar))
    assert(isinstance(sclr2, PScalar))
    assert(sclr1.to_num() == val1)
    assert(sclr1.qtype() == qtype)
    assert(sclr2.to_num() == val2)
    assert(sclr2.qtype() == qtype)
    # Add scalars
    sclr3 = sclr1 + sclr2
    assert(isinstance(sclr3, PScalar))
    assert(sclr3.to_num() == (val1 + val2))
    print(sclr3.qtype())
    print("Successfully executed scalar arithmetic test")


if __name__ == "__main__":
    test_scalar_new()
    print("==========================")
    test_scalar_arith()
    print("==========================")

