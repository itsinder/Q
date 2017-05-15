test_driver: positive_solver.c matrix_helpers.c test_driver.c macros.h positive_solver.h matrix_helpers.h
	gcc -O4 matrix_helpers.c positive_solver.c test_driver.c -std=gnu99 -o test_driver

debug: positive_solver.c matrix_helpers.c test_driver.c macros.h positive_solver.h matrix_helpers.h
	gcc -O4 -g matrix_helpers.c positive_solver.c test_driver.c -std=gnu99 -o test_driver

test: test_driver
	valgrind ./test_driver 100

clean:
	rm test_driver
