Opencv and mexopencv compilation for MATLAB
===========================================

The steps:

1. Build OpenCV
2. Build Mexopencv
3. Preparing examples and documentation for MATLAB help system
4. Packaging

Compiling Opencv
----------------

For MacOSX, 

    ./build_opencv_macos.sh

For Windows 10,

    .\build_opencv_win64.bat

In either case the result will be in ./dist

Compiling Mexopencv
-------------------

For MacOSX, 

    ./build_mex_macos.sh

For Windows 10,

    .\build_mex_win64.bat

Preparing documentation
-----------------------

Start MATLAB, go to this directory and run publish_samples.m

Packaging the toolbox
---------------------

In MATLAB, double-click mexopencv_mac64.prj or mexopencv_win64.prj.