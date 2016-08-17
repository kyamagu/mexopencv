#!/usr/bin/make -f

# ============================================================================
#                              mexopencv Makefile
# ============================================================================
#
# The following configuration parameters are recognized:
#
# WITH_OCTAVE           If set, enables Octave mode as opposed to MATLAB. The
#                       mode determines the default values of MATLAB/Octave
#                       programs. Not set by default, which implies MATLAB.
# MATLABDIR             MATLAB/Octave root directory.
# MATLAB                MATLAB/Octave executable.
# MEX                   MATLAB/Octave MEX compiler frontend.
# MEXEXT                MATLAB/Octave extension of MEX-files.
# DOXYGEN               Doxygen executable used to generate documentation.
# NO_CV_PKGCONFIG_HACK  If set, disables fixing the output of pkg-config with
#                       OpenCV. Not set by default, meaning hack is applied.
# PKG_CONFIG_OPENCV     Name of OpenCV 3.x pkg-config package. Default opencv.
# CFLAGS                Extra flags passed to the C/C++ MEX compiler.
# LDFLAGS               Extra flags passed to the linker by the compiler.
# TEST_CONTRIB          true/false to enable/disable opencv_contrib tests in
#                       addition to the base opencv tests. Default false.
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
# Required OpenCV version: >= 3.0.0
#
# ============================================================================

# programs
ifndef WITH_OCTAVE
MATLABDIR ?= /usr/local/matlab
MEX       ?= $(MATLABDIR)/bin/mex
MATLAB    ?= $(MATLABDIR)/bin/matlab -nodisplay -noFigureWindows -nosplash
else
MATLABDIR ?= /usr
MEX       ?= $(MATLABDIR)/bin/mkoctfile --mex
MATLAB    ?= $(MATLABDIR)/bin/octave-cli --no-gui --no-window-system --quiet
endif
DOXYGEN   ?= doxygen

# options
PKG_CONFIG_OPENCV ?= opencv
TEST_CONTRIB      ?= false

# file extensions
OBJEXT ?= o
LIBEXT ?= a
ifndef WITH_OCTAVE
MEXEXT ?= $(shell $(MATLABDIR)/bin/mexext)
else
MEXEXT ?= mex
endif
ifeq ($(MEXEXT),)
    $(error "MEX extension not set")
endif

# OpenCV flags
ifneq ($(shell pkg-config --exists --atleast-version=3 $(PKG_CONFIG_OPENCV); echo $$?), 0)
    $(error "OpenCV 3.x package was not found in pkg-config search path")
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
override CFLAGS  += -Iinclude $(CV_CFLAGS)
override LDFLAGS += -Llib -lMxArray $(CV_LDFLAGS)

# mexopencv files and targets
HEADERS  := $(wildcard include/*.hpp)
SRCS0    := $(wildcard src/*.cpp)
SRCS1    := $(wildcard src/+cv/*.cpp) \
            $(wildcard src/+cv/private/*.cpp) \
            $(wildcard src/+cv/+test/private/*.cpp)
SRCS2    := $(wildcard opencv_contrib/src/+cv/*.cpp) \
            $(wildcard opencv_contrib/src/+cv/private/*.cpp)
OBJECTS0 := $(subst src, lib, $(SRCS0:.cpp=.$(OBJEXT)))
TARGETS0 := lib/libMxArray.$(LIBEXT)
TARGETS1 := $(subst src/+cv, +cv, $(SRCS1:.cpp=.$(MEXEXT)))
TARGETS2 := $(subst opencv_contrib/src/+cv, opencv_contrib/+cv, $(SRCS2:.cpp=.$(MEXEXT)))

# search path for prerequisites of pattern rules
# Note that VPATH/vpath are designed to find sources, not targets!
# (http://make.mad-scientist.net/papers/how-not-to-use-vpath/)
vpath %.cpp src/+cv
vpath %.cpp src/+cv/private
vpath %.cpp src/+cv/+test/private
vpath %.cpp opencv_contrib/src/+cv
vpath %.cpp opencv_contrib/src/+cv/private

# special targets
.PHONY : all contrib clean doc test
.SUFFIXES: .cpp .$(OBJEXT) .$(LIBEXT) .$(MEXEXT)

# MxArray objects
lib/%.$(OBJEXT): src/%.cpp $(HEADERS)
ifndef WITH_OCTAVE
	$(MEX) -c $(CFLAGS) -outdir lib $<
else
	$(MEX) -c $(CFLAGS) -o $@ $<
endif

# MxArray library
$(TARGETS0): $(OBJECTS0)
	$(AR) -crs $@ $^

# MEX-files
+cv/%.$(MEXEXT) \
+cv/private/%.$(MEXEXT) \
+cv/+test/private/%.$(MEXEXT) \
opencv_contrib/+cv/%.$(MEXEXT) \
opencv_contrib/+cv/private/%.$(MEXEXT) \
: %.cpp $(TARGETS0)
ifndef WITH_OCTAVE
	$(MEX) $(CFLAGS) -output ${@:.$(MEXEXT)=} $< $(LDFLAGS)
else
	$(MEX) $(CFLAGS) -o ${@:.$(MEXEXT)=} $< $(LDFLAGS)
	$(RM) ./$(notdir $(<:.cpp=.$(OBJEXT)))
endif

# targets
all: $(TARGETS1)
contrib: $(TARGETS2)

clean:
	$(RM) -r \
        *.$(OBJEXT) \
        lib/*.$(LIBEXT) lib/*.$(OBJEXT) \
        +cv/*.$(MEXEXT) \
        +cv/private/*.$(MEXEXT) \
        +cv/+test/private/*.$(MEXEXT) \
        opencv_contrib/+cv/*.$(MEXEXT) \
        opencv_contrib/+cv/private/*.$(MEXEXT)

doc:
	$(DOXYGEN) Doxyfile

#TODO: https://savannah.gnu.org/bugs/?41699
# we can't always trust Octave's exit code on Windows! It throws 0xC0000005
# on exit (access violation), even when it runs just fine.
test:
ifndef WITH_OCTAVE
	$(MATLAB) -r "addpath(pwd);cd test;try,UnitTest($(TEST_CONTRIB));catch e,disp(e.getReport);end;exit;"
else
	$(MATLAB) --eval "addpath(pwd);cd test;try,UnitTest($(TEST_CONTRIB));catch e,disp(e);exit(1);end;exit(0);" || echo "Exit code: $$?"
endif
