
#include "q_incs.h"
#include "fj_state_rec_type.h"

int
forward_join(
    int64_t *from_uuid, // [n_from] link field 
    int32_t *from_time, // [n_from] link field 
    int32_t *from_valu, // [n_from] value field 
    int n_from,

    int64_t *to_uuid, // [n_to] link field
    int32_t *to_time, // [n_to] link field 
    int32_t *to_valu, // [n_to] value field 
    int n_to,

    uint32_t delta
    )
{
  int status = 0;

  uint64_t tidx = 0; //
  uint64_t fidx = 0; // 

  for ( uint64_t i = 0; i < n_to; i++ ) {
    to_valu[i] = -1;
  }
  for ( ; ; ) {
    int64_t s_from_uuid = from_uuid[fidx];
    int64_t s_to_uuid   = to_uuid[tidx];
    if ( s_from_uuid < s_to_uuid )  {
      fidx++; continue;
    }
    if ( s_from_uuid > s_to_uuid )  {
      tidx++; continue;
    }
    // Now, s_from_uuid == s_to_uuid 
    int32_t s_from_time = from_time[fidx];
    int32_t s_to_time   = to_time[tidx];
    if ( s_from_time + delta < s_to_time ) {
      fidx++; continue;
    }
    int32_t s_from_valu = from_valu[fidx];
    if ( s_from_time > s_to_time ) {
      fidx++; continue;
    }
    to_valu[tidx] = s_from_valu;
    tidx++;
    if ( tidx == n_to ) {
      break;
    }
    fidx++;
    if ( fidx == n_from ) {
      break;
    }
  }
BYE:
/* Who updates
  ptr_state->from_index = g_fidx;
  ptr_state->to_index   = g_tidx;
  uint32_t from_chunk_num;
  uint32_t to_chunk_num;
*/
  return status;
}
