CFLAGS = -Wall -fPIE
LD_FLAGS = -dead_strip
ARCH_UNI = -arch x86_64 -arch arm64

.PHONY: all clean

all: out/rwhod out/rwho out/ruptime out/rwhod.debug out/rwho.debug out/ruptime.debug

out/rwhod: out src/rwhod.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -o out/rwhod src/rwhod.c
out/rwho: out src/rwho.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -o out/rwho src/rwho.c
out/ruptime: out src/ruptime.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -o out/ruptime src/ruptime.c
out/rwhod.debug: out src/rwhod.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -DDEBUG -o out/rwhod.debug src/rwhod.c
out/rwho.debug: out src/rwho.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -DDEBUG -o out/rwho.debug src/rwho.c
out/ruptime.debug: out src/ruptime.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -DDEBUG -o out/ruptime.debug src/ruptime.c
clean:
	rm -f out/rwhod out/rwho out/ruptime out/rwhod.debug out/rwho.debug out/ruptime.debug
