
DEBUG = 0

ifeq ($(platform),)
platform = unix
ifeq ($(shell uname -a),)
   platform = win
else ifneq ($(findstring MINGW,$(shell uname -a)),)
   platform = win
else ifneq ($(findstring Darwin,$(shell uname -a)),)
   platform = osx
else ifneq ($(findstring win,$(shell uname -a)),)
   platform = win
endif
endif

LIBRETRO := dinothawr
LIBDIR = $(DESTDIR)/usr/lib/libretro
ASSETDIR = $(DESTDIR)/usr/share/dinothawr

ifeq ($(platform), unix)
   TARGET := $(LIBRETRO)_libretro.so
   fpic := -fPIC
   SHARED := -shared -Wl,--version-script=link.T -Wl,--no-undefined
else ifeq ($(platform), osx)
   TARGET := $(LIBRETRO)_libretro.dylib
   fpic := -fPIC
   SHARED := -dynamiclib
else
   CC = gcc
   CXX = g++
   TARGET := $(LIBRETRO)_libretro.dll
   SHARED := -shared -static-libgcc -static-libstdc++ -static -s -Wl,--version-script=link.T -Wl,--no-undefined
endif

ifeq ($(DEBUG), 1)
   CXXFLAGS += -O0 -g
   CFLAGS += -O0 -g
else
   CXXFLAGS += -O3
   CFLAGS += -O3
endif

HEADERS := $(wildcard *.hpp) $(wildcard */*.hpp) $(wildcard vorbis/*.h) $(wildcard ogg/*.h)
SOURCES := $(wildcard *.cpp) $(wildcard */*.cpp)
CSOURCES := $(wildcard ogg/*.c) $(wildcard vorbis/*.c)
OBJECTS := $(SOURCES:.cpp=.o) $(CSOURCES:.c=.o)
CXXFLAGS += -std=gnu++11 -ffast-math -Wall -pedantic $(fpic) -I. -DOV_EXCLUDE_STATIC_CALLBACKS
CFLAGS += -std=gnu99 -ffast-math $(fpic) -I. -Ivorbis

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(fpic) $(SHARED) $(INCLUDES) -o $@ $(OBJECTS) $(LIBS) -lm -lz

%.o: %.cpp $(HEADERS)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJECTS) $(TARGET)

install: all
	mkdir -p $(LIBDIR) || /bin/true
	install -m755 $(TARGET) $(LIBDIR)/dinothawr_libretro.so
	install -d -m755 $(ASSETDIR)
	cp -r dinothawr/* $(ASSETDIR)

.PHONY: clean install

