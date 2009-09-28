LDFLAGS=-Llua5.1
CFLAGS=-I/usr/include/lua5.1 -Wall

collision.so: collision.o
	gcc -shared -o $@ $^ ${LDFLAGS}

clean:
	rm -f collision.so
