#!/usr/bin/make -f

# ============================================================================
#                              mexopencv Makefile
# ============================================================================
#
# The following configuration parameters are recognized:
#
# WITH_OCTAVE           Switch between MATLAB or Octave mode.
#                       Boolean, if not set, assumes MATLAB by default.
# MATLABDIR             MATLAB/Octave root directory.
# MATLAB                MATLAB/Octave executable.
# MEX                   MATLAB/Octave MEX compiler frontend.
# MEXEXT                extension of MEX-files.
# DOXYGEN               Doxygen executable used to generate documentation.
# NO_CV_PKGCONFIG_HACK  Boolean. If not set, we attempt to fix the output of
#                       pkg-config for OpenCV.
# PKG_CONFIG_OPENCV     Name of the OpenCV 3.0 package in pkg-config. By
#                       default, opencv.
# CFLAGS                Extra flags to give to the C/C++ MEX compiler.
# LDFLAGS               Extra flags to give to compiler when it invokes the
#                       linker.
# TEST_CONTRIB          Boolean, controls whether to run opencv_contrib tests
#                       as well as core opencv tests. false by default.
#
# The above settings can be defined as shell environment variables and/or
# specified on the command line as arguments to make:
#
#    export VAR=value
#    make VAR=value
#
# The following targets are available:
#
# all      Builds mexopencv.
# contrib  Builds the extra modules. Needs opencv_contrib.
# clean    Deletes temporary and generated files.
# doc      Generates source documentation using Doxygen.
# test     Run MATLAB unit-tests.
#
# Note that the Makefile uses pkg-config to locate OpenCV, so you need to have
# the opencv.pc file accessible from the PKG_CONFIG_PATH environment variable.
#
# Required OpenCV version: 3.0
#
# ============================================================================

# programs
ifndef WITH_OCTAVE
MATLABDIR  ?= /usr/local/matlab
MEX        ?= $(MATLABDIR)/bin/mex
MATLAB     ?= $(MATLABDIR)/bin/matlab -nodisplay -noFigureWindows -nosplash
else
MATLABDIR  ?= /usr
MEX        ?= $(MATLABDIR)/bin/mkoctfile --mex
MATLAB     ?= $(MATLABDIR)/bin/octave-cli --no-gui --no-window-system --quiet
endif
DOXYGEN    ?= doxygen

# mexopencv directories
TARGETDIR  = +cv
TSDIR      = +test
INCLUDEDIR = include
LIBDIR     = lib
SRCDIR     = src
PRIVATEDIR = private
CONTRIBDIR = opencv_contrib

# file extensions
OBJEXT     ?= o
LIBEXT     ?= a
ifndef WITH_OCTAVE
MEXEXT     ?= $(shell $(MATLABDIR)/bin/mexext)
else
MEXEXT     ?= mex
endif
ifeq ($(MEXEXT),)
    $(error "MEX extension not set")
endif

# mexopencv files and targets
HEADERS    := $(wildcard $(INCLUDEDIR)/*.hpp)
SRCS0      := $(wildcard $(SRCDIR)/*.cpp)
SRCS1      := $(wildcard $(SRCDIR)/$(TARGETDIR)/*.cpp) \
              $(wildcard $(SRCDIR)/$(TARGETDIR)/$(PRIVATEDIR)/*.cpp) \
              $(wildcard $(SRCDIR)/$(TARGETDIR)/$(TSDIR)/*.cpp) \
              $(wildcard $(SRCDIR)/$(TARGETDIR)/$(TSDIR)/$(PRIVATEDIR)/*.cpp)
SRCS2      := $(wildcard $(CONTRIBDIR)/$(SRCDIR)/$(TARGETDIR)/*.cpp) \
              $(wildcard $(CONTRIBDIR)/$(SRCDIR)/$(TARGETDIR)/$(PRIVATEDIR)/*.cpp)
OBJECTS0   := $(subst $(SRCDIR), $(LIBDIR), $(SRCS0:.cpp=.$(OBJEXT)))
TARGETS0   := $(LIBDIR)/libMxArray.$(LIBEXT)
TARGETS1   := $(subst $(SRCDIR)/$(TARGETDIR), $(TARGETDIR), $(SRCS1:.cpp=.$(MEXEXT)))
TARGETS2   := $(subst $(CONTRIBDIR)/$(SRCDIR)/$(TARGETDIR), $(CONTRIBDIR)/$(TARGETDIR), $(SRCS2:.cpp=.$(MEXEXT)))

# OpenCV flags
PKG_CONFIG_OPENCV ?= opencv
ifneq ($(shell pkg-config --exists --atleast-version=3 $(PKG_CONFIG_OPENCV); echo $$?), 0)
    $(error "OpenCV 3.0 package was not found in the pkg-config search path")
endif
CV_CFLAGS  := $(shell pkg-config --cflags $(PKG_CONFIG_OPENCV))
CV_LDFLAGS := $(shell pkg-config --libs $(PKG_CONFIG_OPENCV))
ifndef NO_CV_PKGCONFIG_HACK
LIB_SUFFIX := %.so %.dylib %.a %.la %.dll.a %.dll
CV_LDFLAGS := $(filter-out $(LIB_SUFFIX),$(CV_LDFLAGS)) \
              $(addprefix -L, \
                  $(sort $(dir $(filter $(LIB_SUFFIX),$(CV_LDFLAGS))))) \
              $(patsubst lib%, -l%, \
                  $(basename $(notdir $(filter $(LIB_SUFFIX),$(CV_LDFLAGS)))))
endif

# compiler/linker flags
ifndef WITH_OCTAVE
override CFLAGS  += -largeArrayDims -cxx
else
# -flto
# -fdata-sections -ffunction-sections -Wl,--gc-sections
override CFLAGS  += -O2 -s -fpermissive
endif
override CFLAGS  += -I$(INCLUDEDIR) $(CV_CFLAGS)
override LDFLAGS += -L$(LIBDIR) -lMxArray $(CV_LDFLAGS)

# search path for prerequisites of pattern rules
# Note that VPATH/vpath are designed to find sources, not targets!
# (http://make.mad-scientist.net/papers/how-not-to-use-vpath/)
vpath %.cpp $(SRCDIR)/$(TARGETDIR)
vpath %.cpp $(SRCDIR)/$(TARGETDIR)/$(PRIVATEDIR)
vpath %.cpp $(SRCDIR)/$(TARGETDIR)/$(TSDIR)/$(PRIVATEDIR)
vpath %.cpp $(CONTRIBDIR)/$(SRCDIR)/$(TARGETDIR)
vpath %.cpp $(CONTRIBDIR)/$(SRCDIR)/$(TARGETDIR)/$(PRIVATEDIR)

# special targets
.PHONY : all contrib clean doc test
.SUFFIXES: .cpp .$(OBJEXT) .$(LIBEXT) .$(MEXEXT)

# targets
all: $(TARGETS1)
contrib:  $(TARGETS2)

# MxArray objects
$(LIBDIR)/%.$(OBJEXT): $(SRCDIR)/%.cpp $(HEADERS)
ifndef WITH_OCTAVE
	$(MEX) -c $(CFLAGS) -outdir $(LIBDIR) $<
else
	$(MEX) -c $(CFLAGS) -o $@ $<
endif

# MxArray library
$(TARGETS0): $(OBJECTS0)
	$(AR) -crs $@ $^

# MEX-files
$(TARGETDIR)/%.$(MEXEXT) \
$(TARGETDIR)/$(PRIVATEDIR)/%.$(MEXEXT) \
$(TARGETDIR)/$(TSDIR)/$(PRIVATEDIR)/%.$(MEXEXT) \
$(CONTRIBDIR)/$(TARGETDIR)/%.$(MEXEXT) \
$(CONTRIBDIR)/$(TARGETDIR)/$(PRIVATEDIR)/%.$(MEXEXT) \
: %.cpp $(TARGETS0)
ifndef WITH_OCTAVE
	$(MEX) $(CFLAGS) -output ${@:.$(MEXEXT)=} $< $(LDFLAGS)
else
	$(MEX) $(CFLAGS) -o ${@:.$(MEXEXT)=} $< $(LDFLAGS)
	$(RM) ./$(notdir $(<:.cpp=.$(OBJEXT)))
endif

clean:
	$(RM) -r \
        *.$(OBJEXT) \
        $(LIBDIR)/*.$(LIBEXT) $(LIBDIR)/*.$(OBJEXT) \
        $(TARGETDIR)/*.$(MEXEXT) \
        $(TARGETDIR)/$(PRIVATEDIR)/*.$(MEXEXT) \
        $(TARGETDIR)/$(TSDIR)/$(PRIVATEDIR)/*.$(MEXEXT) \
        $(CONTRIBDIR)/$(TARGETDIR)/*.$(MEXEXT) \
        $(CONTRIBDIR)/$(TARGETDIR)/$(PRIVATEDIR)/*.$(MEXEXT)

doc:
	$(DOXYGEN) Doxyfile

# controls opencv_contrib testing
TEST_CONTRIB ?= false

#TODO: https://savannah.gnu.org/bugs/?41699
# we can't always trust Octave's exit code on Windows! It throws 0xC0000005
# on exit  (access violation), even when it runs just fine.
test:
ifndef WITH_OCTAVE
	$(MATLAB) -r "addpath(pwd);cd test;try,UnitTest($(TEST_CONTRIB));catch e,disp(e.getReport);end;exit;"
else
	$(MATLAB) --eval "addpath(pwd);cd test;try,UnitTest($(TEST_CONTRIB));catch e,disp(e);exit(1);end;exit(0);" || echo "Exit code: $$?"
endif
