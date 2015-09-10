/**
 * @file undistortPoints.cpp
 * @brief mex interface for cv::undistortPoints
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat R, P;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="R")
            R = rhs[i+1].toMat(CV_64F);
        else if (key=="P")
            P = rhs[i+1].toMat(CV_64F);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)), dst,
        cameraMatrix(rhs[1].toMat(CV_64F)),
        distCoeffs(rhs[2].toMat(CV_64F));
    bool cn1 = (src.channels() == 1);
    if (cn1) src = src.reshape(2,0);
    undistortPoints(src, dst, cameraMatrix, distCoeffs, R, P);
    if (cn1) dst = dst.reshape(1,0);
    plhs[0] = MxArray(dst);
}
