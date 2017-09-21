#!/bin/bash
set -e
make clean
make
./test_mm_mul_simple 1>_x
diff _x good_output_1.txt

./test_mv_mul_simple 1>_x
diff _x good_output_2.txt
echo "Completed $0 in $PWD"
make clean
rm -f _*
