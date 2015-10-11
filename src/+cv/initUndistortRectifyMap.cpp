/**
 * @file initUndistortRectifyMap.cpp
 * @brief mex interface for cv::initUndistortRectifyMap
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Map type specification
const ConstMap<string,int> M1Type = ConstMap<string,int>
    ("int16",   CV_16SC2)
    ("single1", CV_32FC1)
    ("single2", CV_32FC2);
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat R;
    int m1type = -1;  // (nlhs>1) ? CV_32FC1 : CV_32FC2
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="R")
            R = rhs[i+1].toMat(CV_64F);
        else if (key=="M1Type")
            m1type = (rhs[i+1].isChar()) ?
                M1Type[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat cameraMatrix(rhs[0].toMat(CV_64F)),
        distCoeffs(rhs[1].toMat(CV_64F)),
        newCameraMatrix(rhs[2].toMat(CV_64F)),
        map1, map2;
    Size size(rhs[3].toSize());
    initUndistortRectifyMap(cameraMatrix, distCoeffs, R, newCameraMatrix,
        size, m1type, map1, map2);
    plhs[0] = MxArray(map1);
    if (nlhs>1)
        plhs[1] = MxArray(map2);
}
