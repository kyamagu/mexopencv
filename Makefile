MATLABDIR   ?= /usr/local/matlab
MEX         ?= $(MATLABDIR)/bin/mex
MV          ?= mv
RM          ?= rm
DOXYGEN     ?= doxygen
MEXEXT      ?= $(shell $(MATLABDIR)/bin/mexext)
MATLAB      ?= $(MATLABDIR)/bin/matlab
TARGETDIR   := +cv
INCLUDEDIR	:= include
LIBDIR      := lib
SRCDIR		:= src
MEXDIR		:= $(SRCDIR)/$(TARGETDIR)
SRCS        := $(wildcard $(MEXDIR)/*.cpp) $(wildcard $(MEXDIR)/private/*.cpp)
TARGETS     := $(subst $(MEXDIR), $(TARGETDIR), $(SRCS:.cpp=.$(MEXEXT)))
MEX_FLAGS   := -cxx -largeArrayDims -I$(INCLUDEDIR) -L$(LIBDIR) $(shell pkg-config --cflags --libs opencv)

VPATH       = $(TARGETDIR):$(SRCDIR):$(MEXDIR):$(TARGETDIR)/private:$(SRCDIR)/private

.PHONY : all clean doc test

all: $(TARGETS)

$(LIBDIR)/MxArray.o: $(SRCDIR)/MxArray.cpp $(INCLUDEDIR)/MxArray.hpp
	$(MEX) -c $(MEX_FLAGS) $< -outdir $(LIBDIR)

%.$(MEXEXT): %.cpp $(LIBDIR)/MxArray.o $(INCLUDEDIR)/mexopencv.hpp
	$(MEX) $(MEX_FLAGS) $(LIBDIR)/MxArray.o $< -o $@

clean:
	$(RM) -rf $(LIBDIR)/*.o $(TARGETDIR)/*.$(MEXEXT)

doc:
	$(DOXYGEN) Doxyfile

test:
	$(MATLAB) -nodisplay -r "cd test;try,UnitTest;catch e,disp(e.getReport);end;exit;"
