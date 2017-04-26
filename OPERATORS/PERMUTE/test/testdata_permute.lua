return {
  {
    input = {
            mk_col({10, 20, 30, 40, 50, 60}, "I4"),
            mk_col({0, 5, 1, 4, 2, 3}, "I4"),
            true},
    output = "10,60,20,50,30,40,"
  },
  {
    input = {
            mk_col ({10, 20, 30, 40, 50, 60}, "I4"),
            mk_col({0, 5, 1, 4, 2, 3}, "I4"),
            false},
    output = "10,30,50,60,40,20,"
  },
  {
    input = {
            mk_col ({10, 20, 30, 40, 50, 60}, "I4"),
            mk_col({0, 5, 1, 4, 2, 3}, "F4"),
            false},
    fail = "idx column must be integer type"
  }
}