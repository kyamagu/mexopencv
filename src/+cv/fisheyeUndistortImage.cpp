/**
 * @file fisheyeUndistortImage.cpp
 * @brief mex interface for cv::fisheye::undistortImage
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
    Mat Knew;
    Size new_size;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "NewCameraMatrix")
            Knew = rhs[i+1].toMat(CV_64F);
        else if (key == "NewImageSize")
            new_size = rhs[i+1].toSize();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat distorted(rhs[0].toMat()), undistorted,
        K(rhs[1].toMat(CV_64F)),
        D(rhs[2].toMat(CV_64F));
    fisheye::undistortImage(distorted, undistorted, K, D, Knew, new_size);
    plhs[0] = MxArray(undistorted);
}
