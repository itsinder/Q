return {
  {
    input = {
            col_from_tab("I4", {10, 20, 30, 40, 50, 60}),
            col_from_tab("I4", {0, 5, 1, 4, 2, 3}),
            true},
    output = "10,60,20,50,30,40,"
  },
  {
    input = {
            col_from_tab ("I4", {10, 20, 30, 40, 50, 60}),
            col_from_tab("I4", {0, 5, 1, 4, 2, 3}),
            false},
    output = "10,30,50,60,40,20,"
  },
  {
    input = {
            col_from_tab ("I4", {10, 20, 30, 40, 50, 60}),
            col_from_tab("F4", {0, 5, 1, 4, 2, 3}),
            false},
    fail = "idx column must be integer type"
  }
}