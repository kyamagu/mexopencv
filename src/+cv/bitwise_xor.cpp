/**
 * @file bitwise_xor.cpp
 * @brief mex interface for cv::bitwise_xor
 * @ingroup core
 * @author Amro
 * @date 2016
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat mask, dst;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else if (key == "Dest")
            dst = rhs[i+1].toMat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src1(rhs[0].toMat()),
        src2(rhs[1].toMat());
    bitwise_xor(src1, src2, dst, mask);
    plhs[0] = MxArray(dst);
}
