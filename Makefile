IMPORT    = import
PREFIX    = /usr/local

DC      = ldc2
CFLAGS  = -O0 -gc -I${IMPORT} -release -wi
LDFLAGS = -L-lncurses -L-ltinfo
OBJS    = main.o box.o player.o util.o

all: virboxquest

virboxquest: ${OBJS}
	${DC} ${CFLAGS} ${LDFLAGS} -of$@ ${OBJS}

main.o: main.d
	${DC} ${CFLAGS} -c main.d
box.o: box.d
	${DC} ${CFLAGS} -c box.d
player.o: player.d
	${DC} ${CFLAGS} -c player.d
util.o: util.d
	${DC} ${CFLAGS} -c util.d

clean:
	rm -f virboxquest ${OBJS}

.PHONY: all clean
