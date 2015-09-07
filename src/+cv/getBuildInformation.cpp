/**
 * @file getBuildInformation.cpp
 * @brief mex interface for cv::getBuildInformation
 * @ingroup core
 * @author Amro
 * @date 2013
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
    nargchk(nrhs==0 && nlhs<=1);

    // Process
    string info = getBuildInformation();
    if (nlhs > 0)
        plhs[0] = MxArray(info);
    else
        mexPrintf("%s\n", info.c_str());
}
