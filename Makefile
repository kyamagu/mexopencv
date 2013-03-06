MATLABDIR   ?= /usr/local/matlab
MEX         ?= $(MATLABDIR)/bin/mex
MV          ?= mv
AR          ?= ar
RM          ?= rm
DOXYGEN     ?= doxygen
MEXEXT      ?= $(shell $(MATLABDIR)/bin/mexext)
MATLAB      ?= $(MATLABDIR)/bin/matlab
TARGETDIR   := +cv
INCLUDEDIR  := include
LIBDIR      := lib
SRCDIR	    := src
MEXDIR	    := $(SRCDIR)/$(TARGETDIR)
SRCS        := $(wildcard $(MEXDIR)/*.cpp) $(wildcard $(MEXDIR)/private/*.cpp)
TARGETS     := $(subst $(MEXDIR), $(TARGETDIR), $(SRCS:.cpp=.$(MEXEXT)))
C_FLAGS     := -cxx -largeArrayDims -I$(INCLUDEDIR) $(shell pkg-config --cflags opencv)
LD_FLAGS    := -L$(LIBDIR) $(shell pkg-config --libs opencv)

VPATH       = $(TARGETDIR):$(SRCDIR):$(MEXDIR):$(TARGETDIR)/private:$(SRCDIR)/private

.PHONY : all clean doc test

all: $(TARGETS)

$(LIBDIR)/libMxArray.a: $(SRCDIR)/MxArray.cpp $(INCLUDEDIR)/MxArray.hpp
	$(MEX) -c $(C_FLAGS) $< -outdir $(LIBDIR)
	$(AR) -cq $(LIBDIR)/libMxArray.a $(LIBDIR)/*.o
	$(RM) -f $(LIBDIR)/*.o

%.$(MEXEXT): %.cpp $(LIBDIR)/libMxArray.a $(INCLUDEDIR)/mexopencv.hpp
	$(MEX) $(C_FLAGS) $< -lMxArray $(LD_FLAGS) -o $@

clean:
	$(RM) -rf $(LIBDIR)/*.a $(TARGETDIR)/*.$(MEXEXT) $(TARGETDIR)/private/*.$(MEXEXT)

doc:
	$(DOXYGEN) Doxyfile

test:
	$(MATLAB) -nodisplay -r "cd test;try,UnitTest;catch e,disp(e.getReport);end;exit;"
