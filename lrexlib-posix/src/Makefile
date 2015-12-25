CC?=gcc
CXX?=g++
CFLAGS+=-O2 -fPIC -DVERSION="2.8.0" -DLUA_COMPAT_5_2
CXXFLAGS+=-O2 -fPIC -DVERSION="2.8.0" -DLUA_COMPAT_5_2
LIBS=common.o lposix.o 
all:: rex_posix $(LIBS)
rex_posix: $(LIBS)
	$(CC) -shared -o rex_posix.so $(LIBS)
common.o: common.h
lposix.o: common.h algo.h

clean:
	rm -f $(LIBS) rex_posix.so