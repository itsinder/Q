test_driver: positive_solver.c matrix_helpers.c test_driver.c macros.h positive_solver.h matrix_helpers.h
	gcc -O4 -Wall matrix_helpers.c positive_solver.c test_driver.c -llapack -llapacke -std=gnu99 -o test_driver

bench: positive_solver.c matrix_helpers.c test_driver.c macros.h positive_solver.h matrix_helpers.h
	gcc -O4 -Wall matrix_helpers.c positive_solver.c test_driver.c -llapack -llapacke -std=gnu99 -o test_driver
	./test_driver 1000 -b

debug: positive_solver.c matrix_helpers.c test_driver.c macros.h positive_solver.h matrix_helpers.h
	gcc -O4 -Wall -g matrix_helpers.c positive_solver.c test_driver.c -llapack -llapacke -std=gnu99 -o test_driver

test: test_driver
	valgrind ./test_driver 100

clean:
	rm test_driver
