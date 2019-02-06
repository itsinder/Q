
def is_p_vector(val):
    from Q.p_vector import PVector
    return isinstance(val, PVector)


def is_p_scalar(val):
    from Q.p_scalar import PScalar
    return isinstance(val, PScalar)
