/**
 * @file EMDL1.cpp
 * @brief mex interface for cv::EMDL1
 * @ingroup shape
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/shape.hpp"
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
    Mat signature1(rhs[0].toMat(CV_32F)),
        signature2(rhs[1].toMat(CV_32F));
    float d = EMDL1(signature1, signature2);
    plhs[0] = MxArray(d);
}
