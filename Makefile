MATLABDIR   ?= /usr/local/matlab
MEX         ?= $(MATLABDIR)/bin/mex
MEXEXT      ?= $(shell $(MATLABDIR)/bin/mexext)
MATLAB      ?= $(MATLABDIR)/bin/matlab
TARGETDIR   := matlab
INCLUDEDIR	:= include
SRCDIR		:= src
MEXDIR		:= $(SRCDIR)/$(TARGETDIR)
SRCS        := $(wildcard $(MEXDIR)/*.cpp)
TARGETS     := $(subst $(MEXDIR), $(TARGETDIR), $(SRCS:.cpp=.$(MEXEXT)))
MEXFLAGS    := -cxx -I$(INCLUDEDIR) $(shell pkg-config --cflags --libs opencv)

VPATH       = $(TARGETDIR):$(SRCDIR):$(MEXDIR)

.PHONY : all clean doc test

all: $(TARGETS)

cvmx.o: $(SRCDIR)/cvmx.cpp $(INCLUDEDIR)/cvmx.hpp
	$(MEX) $(MEXFLAGS) -c $<

%.$(MEXEXT): %.cpp cvmx.o
	$(MEX) $(MEXFLAGS) $< cvmx.o -o $@

clean:
	rm -rf *.o $(TARGETDIR)/*.$(MEXEXT)

doc:
	doxygen Doxyfile

test:
	$(MATLAB) -nodisplay -r "cd test;try,UnitTest;catch e,disp(e.getReport);end;exit;"