/**
 * @file blendLinear.cpp
 * @brief mex interface for cv::blendLinear
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
    nargchk(nrhs==4 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src1(rhs[0].toMat(rhs[0].isSingle() || rhs[0].isDouble() ? CV_32F : CV_8U)),
        src2(rhs[1].toMat(rhs[1].isSingle() || rhs[1].isDouble() ? CV_32F : CV_8U)),
        weights1(rhs[2].toMat(CV_32F)),
        weights2(rhs[3].toMat(CV_32F)),
        dst;
    blendLinear(src1, src2, weights1, weights2, dst);
    plhs[0] = MxArray(dst);
}
