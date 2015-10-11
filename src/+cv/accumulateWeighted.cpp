/**
 * @file accumulateWeighted.cpp
 * @brief mex interface for cv::accumulateWeighted
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat mask;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F)),
        dst(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F));
    double alpha = rhs[2].toDouble();
    accumulateWeighted(src, dst, alpha, mask);
    plhs[0] = MxArray(dst);
}
