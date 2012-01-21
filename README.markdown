mexopencv
=========

Collection and a development kit of matlab mex functions for OpenCV library


Contents
========

The project tree is organized as follows.

    +cv/            directory to put compiled mex files, wrappers, or help files
    Doxyfile        config file for doxygen
    Makefile        make script
    README.markdown this file
    doc/            directory for documentation
    include/        header files
    samples/        directory for sample application codes
    src/            directory for c++ source files
    src/+cv/        directory for mex source files
    src/+cv/private directory for private mex source files
    test/           directory for test scripts and resources


Compile
=======

Prerequisite:

Windows: matlab, opencv (>=2.3.1), Visual C++

Unix: matlab, opencv (>=2.3.1), g++, GNU make, pkg-config

Unix
----

First make sure you have OpenCV installed in the system. Then,

    $ make

will build all mex functions located inside `+cv/`.
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


Windows
-------

Make sure you have OpenCV installed in the system and correctly set up PATH
system variable. Then, in the matlab shell,

    >> cv.make

to build all mex functions. By default, mexopencv assumes the OpenCV library is
installed in C:\opencv. If this is different, specify the path as an argument.

    >> cv.make('opencv_path', 'c:\your\path\to\opencv')


Usage
=====

Once mex functions are compiled, you can add path to the project directory and
call mex functions within matlab using package name `cv`.

    addpath('/path/to/mexopencv');
    result = cv.filter2D(img, kern);  % with package name 'cv'
    import cv.*;
    result = filter2D(img, kern);     % no need to specify 'cv' after imported

Note that some functions such as `cv.imread` overload Matlab's builtin function
when imported. Use the scoped name when you need to avoid name collision.

Check a list of functions available by `help` command in matlab.

    >> help cv; % shows list of functions in package 'cv'
    
    Contents of cv:
    
    GaussianBlur                   - Smoothes an image using a Gaussian filter
    Laplacian                      - Calculates the Laplacian of an image
    VideoCapture                   - VideoCapture wrapper class
    ...
    
    >> help cv.VideoCapture; % shows documentation of VideoCapture
    
    VIDEOCAPTURE  VideoCapture wrapper class
    
     Class for video capturing from video files or cameras. The class
     provides Matlab API for capturing video from cameras or for reading
     video files. Here is how the class can be used:
    ...

Look at the `samples/` directory for an example of an application.


Developing a new mex function
=============================

All you need to do is to add your mex source file in src/+cv/. If you
want to add a mex function called myfunc, create src/+cv/myfunc.cpp.
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
compiled mex function will be located inside `+cv/` and accessible through
`cv.myfunc` within matlab.

The `mexopencv.hpp` header contains a class `MxArray` to manipulate `mxArray`
object. Mostly this class is used to convert between opencv data types and
mxArray.

    int i            = MxArray(prhs[0]).toInt();
    double d         = MxArray(prhs[0]).toDouble();
    bool b           = MxArray(prhs[0]).toBool();
    std::string s    = MxArray(prhs[0]).toString();
    cv::Mat mat      = MxArray(prhs[0]).toMat();   // For pixels
    cv::Mat ndmat    = MxArray(prhs[0]).toMatND(); // For N-D array
    cv::Point pt     = MxArray(prhs[0]).toPoint();
    cv::Size siz     = MxArray(prhs[0]).toSize();
    cv::Rect rct     = MxArray(prhs[0]).toRect();
    cv::Scalar sc    = MxArray(prhs[0]).toScalar();
    cv::SparseMat sp = MxArray(prhs[0]).toSparseMat(); // Only double to float

    mxArray* plhs[0] = MxArray(i);
    mxArray* plhs[0] = MxArray(d);
    mxArray* plhs[0] = MxArray(b);
    mxArray* plhs[0] = MxArray(s);
    mxArray* plhs[0] = MxArray(mat);
    mxArray* plhs[0] = MxArray(ndmat);
    mxArray* plhs[0] = MxArray(pt);
    mxArray* plhs[0] = MxArray(siz);
    mxArray* plhs[0] = MxArray(rct);
    mxArray* plhs[0] = MxArray(sc);
    mxArray* plhs[0] = MxArray(sp); // Only 2D float to double

If you rather want to develop a matlab function that internally calls a mex
function, make use of the `+cv/private` directory. Any function placed under
private directory is only accessible from `+cv/` directory. So, for example,
when you want to design a matlab class that wraps the various behavior of the
mex function, define your class at `+cv/MyClass.m` and develop a mex function
dedicated for that class in `src/+cv/private/MyClass_.cpp`. Inside of
`+cv/MyClass.m`, you can call `MyClass_()` without cv namescope.


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
                ref = [1,2,3];                  % reference output
                dst = cv.myfunc(src);           % execute your function
                assert(all(dst(:) == ref(:)));  % check the output
            end
            
            function test_error_1
                try
                    cv.myfunc('foo');           % myfunc should throw an error
                    error('UnitTest:Fail','myfunc incorrectly returned');
                catch e
                    assert(strcmp(e.identifier,'mexopencv:error'));
                end
            end
        end
    end

In Windows, add path to the `test` directory and invoke `UnitTest` to run all
the test routines.

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
