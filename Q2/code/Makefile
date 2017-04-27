doc:
	echo "future to make docs"

test: bin
	(cd code/test; make all)

bin: 
	(cd code/src; make all)

all: doc test bin
	echo "done"

clean:
	(cd code/src; make clean)
	(cd code/test; make clean)
