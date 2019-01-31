
int
forward_join(
    int32_t *X.
    int nX,
    int32_t *Y,
    int nY,
    int32_t *Z,
    int nZ,
    uint32_t delta
    )
{
  int status = 0;
  uint64_t xidx = 0; uint64_t yidx = 0;
  int32_t *max_X = X + nX;
  int32_t *max_Y = Y + nY;
  for ( ; ; ) {
    if ( X == max_X ) { break; }
    if ( Y == max_Y ) { break; }
    int32_t xval = *X;
    int32_t yval = *Y;
    if ( xval + delta >= yval ) {
    }
  }
BYE:
  return status;
}
