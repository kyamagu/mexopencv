/**
 * @file getBuildInformation.cpp
 * @brief mex interface for getBuildInformation
 * @author Amro
 * @date 2013
 */
#include "mexopencv.hpp"

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
    if (nrhs>0 || nlhs>1) {
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    }

    // get info
    std::string info = cv::getBuildInformation();
    if (nlhs > 0) {
        plhs[0] = MxArray(info);
    } else {
        mexPrintf("%s\n", info.c_str());
    }
}
