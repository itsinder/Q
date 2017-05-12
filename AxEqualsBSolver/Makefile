driver: positive_solver.c matrix_helpers.c aux_driver.c driver.c macros.h positive_solver.h matrix_helpers.h aux_driver.h
	gcc -O4 matrix_helpers.c positive_solver.c aux_driver.c driver.c -std=gnu99 -o driver

debug: positive_solver.c matrix_helpers.c aux_driver.c driver.c macros.h positive_solver.h matrix_helpers.h aux_driver.h
	gcc -O4 -g matrix_helpers.c positive_solver.c aux_driver.c driver.c -std=gnu99 -o driver

test: driver
	valgrind ./driver 100

clean:
	rm driver
