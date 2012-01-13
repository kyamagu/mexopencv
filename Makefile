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
MEXFLAGS    := -cxx -I$(INCLUDEDIR) $(shell pkg-config --cflags --libs opencv) -largeArrayDims

VPATH       = $(TARGETDIR):$(SRCDIR):$(MEXDIR)

.PHONY : all clean doc test

all: $(TARGETS)

MxArray.o: $(SRCDIR)/MxArray.cpp $(INCLUDEDIR)/MxArray.hpp
	$(MEX) $(MEXFLAGS) -c $<

%.$(MEXEXT): %.cpp MxArray.o $(INCLUDEDIR)/mexopencv.hpp
	$(MEX) $(MEXFLAGS) $< MxArray.o -o $@

clean:
	rm -rf *.o $(TARGETDIR)/*.$(MEXEXT)

doc:
	doxygen Doxyfile

test:
	$(MATLAB) -nodisplay -r "cd test;try,UnitTest;catch e,disp(e.getReport);end;exit;"