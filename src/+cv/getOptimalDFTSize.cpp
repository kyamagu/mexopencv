/**
 * @file getOptimalDFTSize.cpp
 * @brief mex interface for cv::getOptimalDFTSize
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
    nargchk(nrhs==1 && nlhs<=1);

    // Process
    int vecsize = MxArray(prhs[0]).toInt();
    int N = getOptimalDFTSize(vecsize);
    plhs[0] = MxArray(N);
}
