gcc -O4 positive_solver.c driver.c aux_driver.c -std=gnu99 -o driver
valgrind ./driver 100
