objects = task.o hash.o breaker.o

all: $(objects)
	nvcc -Xcompiler -O3 -Xcompiler -Wall -Xptxas -O3 $(objects) -o task

%.o: %.cu
	nvcc -Xcompiler -O3 -Xcompiler -Wall -Xptxas -O3 -I. -dc $< -o $@

clean:
	rm -f *.o task