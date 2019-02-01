
int
forward_join(
    int32_t *from_t, //  link field 
    int n1,
    int32_t *from_v. // value field 
    int n1,
    int32_t *to_t, // link field
    int n2,
    int32_t *to_v, // value field 
    int n2,
    uint32_t delta
    )
{
  int status = 0;
  uint64_t fidx = 0; // from index
  uint64_t tidx = 0; // to index
  for ( ; ; ) {
    int32_t s_from_t = *from_t;
    int32_t s_from_v = *from_v;
    int32_t s_to_t   = *to_t;
    if ( s_from_t + delta >= s_to_t ) {
      *to_v = s_from_v;
    }
  }
BYE:
  return status;
}
