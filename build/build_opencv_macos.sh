if [ -d dist ]
then
   rm -rf dist/*
else
   mkdir dist
fi

if [ -d build ]
then
   rm -rf build/*
else
   mkdir build
fi

python3=OFF
if [ $python3 == "ON" ]
then
   python_executable=$(which python3)
   python_numpy_include=$(python3 -c "import numpy; print(numpy.get_include())")
   python_include=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
else
   python_executable=""
   python_numpy_include=""
   python_include=""
fi

cd build
cmake -D CMAKE_BUILD_TYPE=Release \
   -D OPENCV_EXTRA_MODULES_PATH=../contrib/modules \
   -D BUILD_TESTS=OFF \
   -D BUILD_PERF_TESTS=OFF \
   -D CMAKE_INSTALL_PREFIX=../dist \
   -D BUILD_opencv_world=ON \
   -D BUILD_opencv_python2=OFF \
   -D BUILD_opencv_python3=$python3 \
   -D PYTHON3_EXECUTABLE=$python_executable \
   -D PYTHON3_NUMPY_INCLUDE_DIRS=$python_numpy_include \
   -D PYTHON3_INCLUDE_DIR=$python_include \
   -D OPENCV_GENERATE_PKGCONFIG=ON \
   -D OPENCV_ENABLE_NONFREE=ON \
   -D INSTALL_C_EXAMPLES=OFF \
   -D WITH_PROTOBUF=ON \
   -D BUILD_opencv_stereo=ON \
   ../opencv

cmake --build . --target install --config Release

cd ..
