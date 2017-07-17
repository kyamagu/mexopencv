/**
 * @file magnitude.cpp
 * @brief mex interface for cv::magnitude
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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat x(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        y(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        mag;
    magnitude(x, y, mag);
    plhs[0] = MxArray(mag);
}
