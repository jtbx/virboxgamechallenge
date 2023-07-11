IMPORT    = import
PREFIX    = /usr/local

DC      = ldc2
CFLAGS  = -O0 -gc -I${IMPORT} -release -wi
LDFLAGS = -L-lncurses -L-ltinfo
OBJS    = main.o box.o entity.o

all: virboxquest

virboxquest: ${OBJS}
	${DC} ${CFLAGS} ${LDFLAGS} -of$@ ${OBJS}

main.o: main.d
	${DC} ${CFLAGS} -of$@ -c main.d
box.o: box.d
	${DC} ${CFLAGS} -of$@ -c box.d
entity.o: entity.d
	${DC} ${CFLAGS} -of$@ -c entity.d

clean:
	rm -f virboxquest ${OBJS}

.PHONY: all clean
