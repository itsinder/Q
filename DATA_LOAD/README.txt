read https://www.lua.org/pil/12.html before proceeding

There are severak ways in which data can be read into Q. For now, we shall focus
on reading from CSV files. By CSV we mean 

records are terminated by eoln character '\n'

fields are separated by comma character

fields may be enclosed by a double-quote character e.g., 1,"foo",2.3

note that a single record can span multiple lines

a null value can be represented either by 2 consecutive double-quote
characters e.g., the following lines are identical

foo,,2
foo,"",2
"foo,"","2"

all rows must have the same number of fields 

Three characters have special meanings - comma, double quote and
eoln. When we want these to occur as part of the value, they must be
preceded by a back-slash. So, we really have 4 special characters. For
example, the following value has 6 characters (1) a (2) b (3) c (4)
comma (5) backslash and (6) double quote

"abc\,\\\""

The Q operator that loads a CSV file is as follows

X = load(data="foo.csv", meta_data = M, has_hdr_line = true)

where M is a table that has N+1 values, one for each of the N columns
that we expect to find in foo.csv

What does M look like?

M = { { name = "", ignore = true, field_type = "" }

      { name = "def", ignore = false, field_type = "int32_t" },

      { name = "def", ignore = false, field_type = "integer" },

      { name = "ghi", ignore = false, field_type = "number" },

      { name = "jkl", "ignore = false, field_type = "string", dictionary = "" },

      { name = "mno", "ignore = false, field_type = "string", dictionary = "D1" },

    }

Let's go through these lines one at a time. The table has 6 columns.

The first line says that the first column should be ignored - hence we
do not need to provide a name or a field type

The second line says that we expect all values of the second column to
be valid values for a variable of type int32_t and that the resulting
vector is of type int32_t

The third line says that we expect all values of the third column to
be valid values for a variable of type int64_t and that the resulting
vector is of type int8_t, int16_t, int32_t or int64_t. The smallest
field that can accomodate the values will be used.

The third line says that we expect all values of the third column to
be valid values for a variable of type double_t and that the resulting
vector is of type int8_t, int16_t, int32_t, int64_t, float, double. If
all values can be represented by an integer, the smallest integer
field will be used. Else, float will be used if it causes no loss;
else, double.

In order to explain Lines 5 and 6, we need to introduce the concept of
a dictionary.









