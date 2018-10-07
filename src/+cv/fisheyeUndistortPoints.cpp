/**
 * @file fisheyeUndistortPoints.cpp
 * @brief mex interface for cv::fisheye::undistortPoints
 * @ingroup calib3d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
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
        if (key == "R")
            R = rhs[i+1].toMat(CV_64F);
        else if (key == "P")
            P = rhs[i+1].toMat(CV_64F);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat distorted(rhs[0].toMat(CV_64F)), undistorted,
        K(rhs[1].toMat(CV_64F)),
        D(rhs[2].toMat(CV_64F));
    bool cn1 = (distorted.channels() == 1);
    if (cn1) distorted = distorted.reshape(2,0);
    fisheye::undistortPoints(distorted, undistorted, K, D, R, P);
    if (cn1) undistorted = undistorted.reshape(1,0);
    plhs[0] = MxArray(undistorted);
}
