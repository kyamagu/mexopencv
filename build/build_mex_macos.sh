export PKG_CONFIG_PATH=$(pwd)/dist/lib/pkgconfig
cd mexopencv

cp -R dist ../opencv

cd ..

make clean MATLABDIR=/Applications/MATLAB_R2019b.app PKG_CONFIG_OPENCV=opencv WITH_CONTRIB=1
make all MATLABDIR=/Applications/MATLAB_R2019b.app PKG_CONFIG_OPENCV=opencv WITH_CONTRIB=1  CXXFLAGS="CFLAGS='$CFLAGS -Wno-deprecated-declarations -Wno-potentially-evaluated-expression'" 
make contrib MATLABDIR=/Applications/MATLAB_R2019b.app PKG_CONFIG_OPENCV=opencv WITH_CONTRIB=1 LDFLAGS="-lopencv_img_hash" CXXFLAGS="CFLAGS='$CFLAGS -Wno-deprecated-declarations -Wno-potentially-evaluated-expression'" 

cp opencv_contrib/+cv/* +cv/
cp opencv_contrib/+cv/private/* +cv/private/

for f in +cv/*.mexmaci64
do
   install_name_tool -add_rpath @loader_path/../opencv/lib $f
done

for f in +cv/private/*.mexmaci64
do
   install_name_tool -add_rpath @loader_path/../../opencv/lib $f
done

for f in opencv_contrib/+cv/*.mexmaci64
do
   install_name_tool -add_rpath @loader_path/../../opencv/lib $f
done

for f in opencv_contrib/+cv/private/*.mexmaci64
do
   install_name_tool -add_rpath @loader_path/../../../opencv/lib $f
done

/Applications/MATLAB_R2019b.app/bin/matlab -nodesktop -sd . -r "addpath(pwd);addpath(fullfile(pwd, 'utils'));MDoc('-clean');MDoc('-wiki');MDoc; quit"
/Applications/MATLAB_R2019b.app/bin/matlab -nodesktop -sd . -r "publish_samples; quit"
