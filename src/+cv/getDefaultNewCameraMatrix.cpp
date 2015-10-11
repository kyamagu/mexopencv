/**
 * @file getDefaultNewCameraMatrix.cpp
 * @brief mex interface for cv::getDefaultNewCameraMatrix
 * @ingroup imgproc
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Size imgsize;
    bool centerPrincipalPoint = false;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "ImgSize")
            imgsize = rhs[i+1].toSize();
        else if (key == "CenterPrincipalPoint")
            centerPrincipalPoint = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat cameraMatrix(rhs[0].toMat(CV_64F));
    Mat newCameraMatrix = getDefaultNewCameraMatrix(cameraMatrix,
        imgsize, centerPrincipalPoint);
    plhs[0] = MxArray(newCameraMatrix);
}
