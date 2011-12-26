mexopencv
=========

Collection and development kit of matlab mex functions for OpenCV library


Contents
========

The project tree is organized as follows.

    +opencv/       directory to put compiled mex files
    Doxyfile       config file for doxygen
    Makefile       make script
    README         this file
    doc/           directory for documentation
    include/       header files
    matlab/        simlink to +opencv
    src/           directory for c++ source files
    src/matlab/    directory for mex source files
    test/          directory for test scripts and resources

As a sample implementation, two mex functions: filter2d.cpp and grabcut.cpp
are attached to mexopencv.


Compile
=======

Prerequisite: matlab, opencv, pkg-config

    $ make

This will build all mex functions in `matlab/` (or `+opencv/`).
Specify you matlab directory if you install matlab other than /usr/local/matlab

    $ make MATLABDIR=/path/to/matlab

Optionally you can test the library functionality

    $ make test

If matlab says 'Library not loaded' in the test, it's likely the compatibility
issue between a system library and matlab's internal library. You might be able
to fix this issue by preloading the library file. On linux, set the correct
library path in `LD_PRELOAD` environmental variable. On Mac OS X, this variable
is named `DYLD_INSERT_LIBRARIES`.

Documentation can be generated with doxygen (if installed)

    $ make doc

This will create html and latex files under doc/


Usage
=====

Once mex functions are compiled, you can add path to this directory and call
mex functions from matlab with package name 'opencv'

    addpath('/path/to/mexopencv');
    result = opencv.filter2d(img, kern);    % with package name opencv

Or, you can add path to matlab/ directory
 
    addpath('/path/to/mexopencv/matlab');
    result = filter2d(img, kern);           % no need to specify opencv


Developing a new mex function
=============================

All you need to do is to add your mex source file in src/matlab/. Suppose you
want to add a mex function called myfunc. Then, create src/matlab/myfunc.cpp.
The minimum contents of myfunc.cpp would look something like this:

    #include "cvmx.hpp"
    void mexFunction( int nlhs, mxArray *plhs[],
                      int nrhs, const mxArray *prhs[] )
    {
        if (nlhs!=1 || nrhs!=1)
            mexErrMsgIdAndTxt("myfunc:invalidArgs","Wrong number of arguments");
        cv::Mat m(cvmxArrayToMat(prhs[0]));
        plhs[0] = cvmxArrayFromMat(m);
    }

This example simply copies an input to cv::Mat object and then copies again to
the output. Of course you would want to do something more with the object.
Once you create a file, type 'make' to build your new function.

Two data conversion functions are defined in cvmx.hpp

    mxArray* cvmxArrayFromMat(const cv::Mat& mat, mxClassID classid=mxUNKNOWN_CLASS);
    cv::Mat cvmxArrayToMat(const mxArray *arr, int depth=CV_USRTYPE1);

These functions convert data between `mxArray` and `cv::Mat`.


Testing
-------

Optionally, you can add a testing script for your new function. The testing
convention in mexopencv is that testing scripts are all written as a static
function in a matlab class. For example, `test/unit_tests/TestFilter2D.m` is
a class that describes test cases for filter2d function. Inside of the class,
a couple of test cases are written as a static function whose name starts with
'test'.

If there is such a class inside `test/unit_tests/`, typing 'make test' would
invoke all test cases and show your result. Use test/ directory to place any
resouce file necessary for testing.
