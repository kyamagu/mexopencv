/**
 * @file undistort.cpp
 * @brief mex interface for cv::undistort
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
    Mat newCameraMatrix;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="NewCameraMatrix")
            newCameraMatrix = rhs[i+1].toMat(CV_64F);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat()), dst,
        cameraMatrix(rhs[1].toMat(CV_64F)),
        distCoeffs(rhs[2].toMat(CV_64F));
    undistort(src, dst, cameraMatrix, distCoeffs, newCameraMatrix);
    plhs[0] = MxArray(dst);
}
