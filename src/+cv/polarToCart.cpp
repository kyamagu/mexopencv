/**
 * @file polarToCart.cpp
 * @brief mex interface for cv::polarToCart
 * @ingroup core
 * @author Amro
 * @date 2017
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool angleInDegrees = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Degrees")
            angleInDegrees = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat mag,
        angle(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        x, y;
    if (!rhs[0].isEmpty())
        mag = rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F);
    polarToCart(mag, angle, x, y, angleInDegrees);
    plhs[0] = MxArray(x);
    if (nlhs > 1)
        plhs[1] = MxArray(y);
}
