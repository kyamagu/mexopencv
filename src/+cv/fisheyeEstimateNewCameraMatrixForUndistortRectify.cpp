/**
 * @file fisheyeEstimateNewCameraMatrixForUndistortRectify.cpp
 * @brief mex interface for cv::fisheye::estimateNewCameraMatrixForUndistortRectify
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
    Mat R;
    double balance = 0.0;
    Size newImageSize;
    double fov_scale = 1.0;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "R")
            R = rhs[i+1].toMat(CV_64F);
        else if (key == "Balance")
            balance = rhs[i+1].toDouble();
        else if (key == "NewImageSize")
            newImageSize = rhs[i+1].toSize();
        else if (key == "FOVScale")
            fov_scale = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat K(rhs[0].toMat(CV_64F)),
        D(rhs[1].toMat(CV_64F)),
        P;
    Size imageSize(rhs[2].toSize());
    fisheye::estimateNewCameraMatrixForUndistortRectify(K, D, imageSize,
        R, P, balance, newImageSize, fov_scale);
    plhs[0] = MxArray(P);
}
