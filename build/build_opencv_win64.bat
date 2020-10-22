rem Use visual studio 2019
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat
rem call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
set lib_output=vc16

if exist dist (
    del /F /S /Q dist
) else (
    mkdir dist
)

if exist build (
    del /F /S /Q build
) else (
    mkdir build
)

set python3=OFF
if  %python3% == "ON" (
   set python_executable=$(which python3)
   set python_numpy_include=$(python3 -c "import numpy; print(numpy.get_include())")
   set python_include=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
) else (
   set python_executable=""
   set python_numpy_include=""
   set python_include=""
)

cd build

cmake -G"Visual Studio 16 2019"  ^
   -D CMAKE_BUILD_TYPE=Release ^
   -D OPENCV_EXTRA_MODULES_PATH=..\contrib\modules ^
   -D BUILD_TESTS=OFF ^
   -D BUILD_PERF_TESTS=OFF ^
   -D CMAKE_INSTALL_PREFIX=..\dist ^
   -D BUILD_opencv_world=ON ^
   -D BUILD_opencv_python2=OFF ^
   -D BUILD_opencv_python3=%python3% ^
   -D PYTHON3_EXECUTABLE=%python_executable% ^
   -D PYTHON3_NUMPY_INCLUDE_DIRS=%python_numpy_include% ^
   -D PYTHON3_INCLUDE_DIR=%python_include% ^
   -D OPENCV_GENERATE_PKGCONFIG=ON ^
   -D OPENCV_ENABLE_NONFREE=ON ^
   -D INSTALL_C_EXAMPLES=OFF ^
   -D WITH_PROTOBUF=ON ^
   -D BUILD_opencv_stereo=ON ^
   -D WITH_CUDA=0 ^
   ..\opencv

rem cmake --build . --target install --config Release
msbuild /p:Configuration=Release ..\build\ALL_BUILD.vcxproj
msbuild /p:Configuration=Release ..\build\INSTALL.vcxproj

cd ..


