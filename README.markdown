mexopencv
=========

Collection and a development kit of matlab mex functions for OpenCV library


Contents
========

The project tree is organized as follows.

    +cv/            directory to put compiled mex files
    Doxyfile        config file for doxygen
    Makefile        make script
    README.markdown this file
    doc/            directory for documentation
    include/        header files
    matlab/         simlink to +cv
    src/            directory for c++ source files
    src/matlab/     directory for mex source files
    test/           directory for test scripts and resources


Compile
=======

Prerequisite: GNU make, matlab, opencv, pkg-config

First make sure you have OpenCV installed in the system. Then,

    $ make

will build all mex functions in located in `+cv/` (or `matlab/`).
Specify your matlab directory if you install matlab other than /usr/local/matlab

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

This will create html and latex files under `doc/`.


Usage
=====

Once mex functions are compiled, you can add path to the project directory and
call mex functions within matlab using package name `cv`.

    addpath('/path/to/mexopencv');
    result = cv.filter2D(img, kern);    % with package name 'cv'
    import cv.*;
    result = filter2D(img, kern);       % no need to specify 'cv' after import

Or, you can add path to matlab/ directory.
 
    addpath('/path/to/mexopencv/matlab');
    result = filter2D(img, kern);       % no need to specify 'cv'

Note that some functions such as `cv.imread` overloads Matlab's builtin method.
Use the scoped name when you need to avoid name collision.

Check a list of functions available by `help` command in matlab.

    help cv;    % shows list of functions
    help cv.filter2D; % shows documentation of filter2D

Developing a new mex function
=============================

All you need to do is to add your mex source file in src/matlab/. If you
want to add a mex function called myfunc, create src/matlab/myfunc.cpp.
The minimum contents of the myfunc.cpp would look like this:

    #include "mexopencv.hpp"
    void mexFunction( int nlhs, mxArray *plhs[],
                      int nrhs, const mxArray *prhs[] )
    {
    	// Check arguments
        if (nlhs!=1 || nrhs!=1)
            mexErrMsgIdAndTxt("myfunc:invalidArgs","Wrong number of arguments");
        
        // Convert MxArray to cv::Mat
        cv::Mat mat = MxArray(prhs[0]).toMat();
        
        // Do whatever you want
        
        // Convert cv::Mat back to mxArray*
        plhs[0] = MxArray(mat);
    }

This example simply copies an input to cv::Mat object and then copies again to
the output. Notice how the `MxArray` class provided by mexopencv converts
mxArray to cv::Mat object. Of course you would want to do something more with
the object. Once you create a file, type 'make' to build your new function. The
compiled mex function will be located under `+cv/` and accessible through
`cv.myfunc` within matlab.

The `mexopencv.hpp` header contains a class `MxArray` to manipulate `mxArray`
object. Mostly this class is used to convert between opencv data types and
mxArray.

    cv::Mat m     = MxArray(prhs[0]).toMat();   # Pixels
    int i         = MxArray(prhs[0]).toInt();
    double d      = MxArray(prhs[0]).toDouble();
    bool b        = MxArray(prhs[0]).toBool();
    std::string s = MxArray(prhs[0]).toString();
    cv::Mat arr   = MxArray(prhs[0]).toArray(); # N-D array

    mxArray* plhs[0] = MxArray(m);
    mxArray* plhs[0] = MxArray(i);
    mxArray* plhs[0] = MxArray(d);
    mxArray* plhs[0] = MxArray(b);
    mxArray* plhs[0] = MxArray(s);
    mxArray* plhs[0] = MxArray::fromArray(arr);


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
resource file necessary for testing. An example of testing class is shown below:

    classdef TestMyFunc
        methods (Static)
            function test_1
                src = imread('/path/to/myimg');
                ref = 1;             % reference output
                dst = myfunc(src);   % execute
                assert(dst == ref);  % check the output
            end
            
            function test_error_1
                try
                    myfunc('foo'); % myfunc should throw an error
                    throw('UnitTest:Fail');
                catch e
                    assert(strcmp(e.identifier,'mexopencv:error'));
                end
            end
        end
    end

Documenting
-----------

You can create a Matlab help documentation for mex function by having the same
file with '.m' extension. For example, on linux 64-bit architecture, the help
file for filter2D.mexa64 would be filter2D.m. Inside the help file should be
only matlab comments. An example is shown below:

    %MYFUNC  brief description about myfunc
    %
    % Detailed description of function continues
    % ...

License
=======

The code may be redistributed under BSD license.
