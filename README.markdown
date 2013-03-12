mexopencv
=========

Collection and a development kit of MATLAB MEX functions for OpenCV library

The package provides MATLAB MEX functions that interface a hundred of
OpenCV APIs. Also the package contains C++ class that converts between
MATLAB's native data type and OpenCV data types. The package is suitable for
fast prototyping of OpenCV application in MATLAB, use of OpenCV as an external
toolbox in MATLAB, and development of a custom MEX function.

Contents
========

The project tree is organized as follows.

    +cv/             OpenCV or custom API directory
    +mexopencv/      mexopencv utility API directory
    Doxyfile         config file for doxygen
    Makefile         make script
    README.markdown  this file
    doc/             directory for documentation
    include/         header files
    lib/             directory for compiled C++ library files
    samples/         directory for sample application codes
    src/             directory for C++ source files
    src/+cv/         directory for MEX source files
    src/+cv/private/ directory for private MEX source files
    test/            directory for test scripts and resources
    utils/           directory for utilities

Build
=====

Prerequisite:

 * Unix: MATLAB, OpenCV (>=2.4.0), g++, make, pkg-config
 * Windows: MATLAB, OpenCV (>=2.4.0), supported compiler

For OpenCV older than v2.4.0, check out the corresponding v2.x branch.

Unix
----

First make sure you have OpenCV installed in the system. If not, install the
package available in your package manager (e.g., libopencv-dev in Debian/Ubuntu,
opencv-devel in Fedora, opencv in Macports), or install the source package from
http://opencv.willowgarage.com/wiki/ . Make sure `pkg-config` command can
identify OpenCV path. If you have all the prerequisite, go to the mexopencv
directory and type:

    $ make

This will build and place all MEX functions inside `+cv/`.
Specify your MATLAB directory if you install MATLAB other than
`/usr/local/matlab`,

    $ make MATLABDIR=/Applications/MATLAB_R2012a.app

Optionally you can test the library functionality.

    $ make test

Developer documentation can be generated with doxygen if installed.

    $ make doc

This will create HTML and LaTeX files under `doc/`.

### Error: Invalid MEX file or Segmentation fault

If MATLAB says 'Library not loaded' or any other error in the test, it's likely
the compatibility issue between a system library and MATLAB's internal library.
You might be able to fix this issue by preloading the library file. On Linux,
set the correct library path in `LD_PRELOAD` environmental variable. For
example, if you see `GLIBCXX_3.4.15` error in mex, use the following to start
MATLAB.

    $ LD_PRELOAD=/usr/lib/libstdc++.so.6 matlab

Note that you need to find the correct path to the shared object. For example,
`/usr/lib64/` instead of `/usr/lib/`. You can use `locate` command to find the
location of the shared object. On Mac OS X, this environmental variable is
named `DYLD_INSERT_LIBRARIES`.

To find what library is incompatible, use `ldd` command both in the Unix shell
and within MATLAB to one of the compiled MEX-files. For example,

    $ ldd +cv/imread.mexa64    # within UNIX shell

    >> !ldd +cv/imread.mexa64  % within MATLAB

If the output of the `ldd` command gives you different line, that library is
likely to be incompatible. Try to preload such a library before launching
MATLAB. On Mac, you can use `otool -L` command instead.

Windows
-------

Make sure you have OpenCV installed in the system and correctly set up `PATH`
system variable. See http://opencv.willowgarage.com/wiki/WindowsSystemPath for
the instruction. Your PATH variable should contain an appropriate path to the
dll files (e.g., `c:\opencv\build\x86\vc10\bin`). Be careful that the
architecture (x86 or x64) should match your MATLAB architecture but not your
OS. Also VC version (vc9 or vc10) should match the mex setup (and probably
MATLAB's internal runtime). For example, if you're running MATLAB 32-bit in
Windows 7 64-bit with Visual Studio 2010 Express, you should use x86 and vc10.

Also make sure you install a compiler supported by MATLAB. See
http://www.mathworks.com/support/sysreq/previous_releases.html for the list of
supported compilers for different versions of MATLAB. Maltab 64-bit users need
to install Windows SDK.

Once you satisfy the above requirement, in the MATLAB shell, type

    >> mexopencv.make

to build all MEX functions. By default, mexopencv assumes the OpenCV library is
installed in `C:\opencv`. If this is not the case, specify the path as an
argument.

    >> mexopencv.make('opencv_path', 'c:\your\path\to\opencv')

Note that if you build OpenCV from source, this path specification does not
work. You need to replace dll files in the OpenCV package with newly built
binaries. Or, you need to modify `+mexopencv/make.m` to correctly link your
MEX-files with the library.

To remove existing mexopencv binaries, use the following command.

    >> mexopencv.make('clean', true)

### Error: Invalid MEX-file or Segmentation fault

Test the following first.

 1. The system PATH is set up correctly. This is different from `addpath` in
    MATLAB. You must have the correct dll files visible in the system path,
    such as `c:\opencv\build\x86\vc10\bin` or `c:\opencv\build\x64\vc10\bin`
    depending on the MATLAB architecture and the compiler. See
    http://opencv.willowgarage.com/wiki/WindowsSystemPath
    After change, you must restart Windows.
 2. The mex compiler is correct. In Windows 64-bit environment, only Windows
    SDK compiler is supported. Check
    http://www.mathworks.com/support/sysreq/previous_releases.html
    Choose the supported compiler with `mex -setup` command within MATLAB.
    If you build MEX-files with a wrong compiler, first clean up files with
    `mexopencv.make('clean', true)` and build again.

If you still see the `Invalid MEX-file` and you are using the manually built
OpenCV dll's, check if you use the consistent `_SECURE_SCL` flag. The current
version of `mexopencv.make` script explicitly adds `_SECURE_SCL=1` flag in the
build command for Visual Studio compilers older than 2010,
so that the built MEX-files are compatible with the OpenCV binary
distribution. If you manually built OpenCV with different `_SECURE_SCL` flag,
edit `mexopencv.make` file and change the flag to use a consistent value.

When unspecified, the default value of the `_SECURE_SCL` flag depend on the
version of the Visual Studio compiler, and whether building is in "Debug"
or "Release" mode:

 - VS2010 and newer: In debug mode, the default value for `_SECURE_SCL` is 1.
   In release mode, the default value for `_SECURE_SCL` is 0.
 - VS2008 and older: The default value for `_SECURE_SCL` is 1.

Alternatively, you can change the default value for the `_SECURE_SCL` flag in
mex command.
To change the default configuration, which is created with the `mex -setup`
command in matlab, is located in the following path in recent versions of
Windows.

    C:\Users\(Username)\AppData\Roaming\MathWorks\MATLAB\(version)\mexopts.bat

Open this file and edit `/D_SECURE_SCL` option. Note that this is usually only
necessary for VS2008 and older.

If you see `Invalid MEX-file` error even when having the matched `_SECURE_SCL`
flag, it probably indicates some other compatibility issues. Please file a bug
report at http://github.com/kyamagu/mexopencv .

### Visual Studio 2008 compatibility issue

Users report incompatibility with Visual Studio 2008. Try not to use Visual
Studio 2008 with mexopencv. For this reason, mexopencv on Windows platform
do not work with MATLAB R2009b or earlier.

Nevertheless, if you want to try using Visual Studio 2008, obtain `stdint.h`
and use `mexopencv.make` to compile the package. Visual Studio 2008 or earlier
does not comply with C99 standard and lacks `stdint.h` header file. Luckily,
the header file is available on the Web. For example,
http://msinttypes.googlecode.com/svn/trunk/stdint.h

Place this file under `include` directory in the mexopencv package.

Usage
=====

Once MEX functions are compiled, you can add path to the project directory and
call MEX functions within MATLAB using package name `cv`.

    addpath('/path/to/mexopencv');
    result = cv.filter2D(img, kern);  % with package name 'cv'
    import cv.*;
    result = filter2D(img, kern);     % no need to specify 'cv' after imported

Note that some functions such as `cv.imread` overload MATLAB's builtin function
when imported. Use the scoped name when you need to avoid name collision. It is
also possible to import individual functions. Check `help import` in MATLAB.

Check a list of functions available by `help` command in MATLAB.

    >> help cv; % shows list of functions in package 'cv'

    Contents of cv:

    GaussianBlur                   - Smoothes an image using a Gaussian filter
    Laplacian                      - Calculates the Laplacian of an image
    VideoCapture                   - VideoCapture wrapper class
    ...

    >> help cv.VideoCapture; % shows documentation of VideoCapture

    VIDEOCAPTURE  VideoCapture wrapper class

     Class for video capturing from video files or cameras. The class
     provides MATLAB API for capturing video from cameras or for reading
     video files. Here is how the class can be used:
    ...

Look at the `samples/` directory for examples.

The mexopencv includes a simple documentation utility that generates HTML help
files for MATLAB. The following command creates a user documentation under
`doc/matlab/` directory.

    addpath('utils');
    MDoc;

Online documentation is available at
http://www.cs.stonybrook.edu/~kyamagu/mexopencv

You can test the functionality of compiled files by `UnitTest` class
located inside `test` directory.

    addpath('test');
    UnitTest;

Developing a new MEX function
=============================

All you need to do is to add your MEX source file in `src/+cv/`. If you
want to add a MEX function called `myfunc`, create `src/+cv/myfunc.cpp`.
The minimum contents of the `myfunc.cpp` would look like this:

    #include "mexopencv.hpp"
    void mexFunction(int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[])
    {
        // Check arguments
        if (nlhs!=1 || nrhs!=1)
            mexErrMsgIdAndTxt("myfunc:invalidArgs", "Wrong number of arguments");

        // Convert MxArray to cv::Mat
        cv::Mat mat = MxArray(prhs[0]).toMat();

        // Do whatever you want

        // Convert cv::Mat back to mxArray*
        plhs[0] = MxArray(mat);
    }

This example simply copies an input to `cv::Mat` object and then copies again to
the output. Notice how the `MxArray` class provided by mexopencv converts
`mxArray` to `cv::Mat` object. Of course you would want to do something more with
the object. Once you create a file, type `mexopencv.make` to build your new function.
The compiled MEX function will be located inside `+cv/` and accessible through
`cv.myfunc` within MATLAB.

The `mexopencv.hpp` header includes a class `MxArray` to manipulate `mxArray`
object. Mostly this class is used to convert between OpenCV data types and
`mxArray`.

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

    plhs[0] = MxArray(i);
    plhs[0] = MxArray(d);
    plhs[0] = MxArray(b);
    plhs[0] = MxArray(s);
    plhs[0] = MxArray(mat);
    plhs[0] = MxArray(ndmat);
    plhs[0] = MxArray(pt);
    plhs[0] = MxArray(siz);
    plhs[0] = MxArray(rct);
    plhs[0] = MxArray(sc);
    plhs[0] = MxArray(sp); // Only 2D float to double

Check `MxAraay.hpp` for the complete list of the conversion API.

If you rather want to develop a MATLAB function that internally calls a MEX
function, make use of the `+cv/private/` directory. Any function placed under
private directory is only accessible from `+cv/` directory. So, for example,
when you want to design a MATLAB class that wraps the various behavior of the
MEX function, define your class at `+cv/MyClass.m` and develop a MEX function
dedicated for that class in `src/+cv/private/MyClass_.cpp`. Inside of
`+cv/MyClass.m`, you can call `MyClass_()` without cv namescope.

Testing
-------

You can optionally add a testing script for your new function. The testing
convention in mexopencv is that testing scripts are all written as a static
function in a MATLAB class. For example, `test/unit_tests/TestFilter2D.m` is
a class that describes test cases for `filter2d` function. Inside of the class,
a couple of test cases are written as a static function whose name starts with
'test'.

If there is such a class inside `test/unit_tests/`, typing `make test` would
invoke all test cases and show your result. Use `test/` directory to place any
resource file necessary for testing. An example of testing class is shown below:

    classdef TestMyFunc
        methods (Static)
            function test_1
                src = imread(fullfile(mexopencv.root(),'test','myimg.png'));
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

You can create a MATLAB help documentation for MEX function by having the same
file with '.m' extension. For example, a help file for `filter2D.mex*` would be
`filter2D.m`. Inside the help file should be only MATLAB comments. An example
is shown below:

    %MYFUNC  brief description about myfunc
    %
    % Detailed description of function continues
    % ...

License
=======

The code may be redistributed under BSD license.
