/**
 * @file Rodrigues.cpp
 * @brief mex interface for cv::Rodrigues
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
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
    nargchk(nrhs==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        dst, jacobian;
    Rodrigues(src, dst, (nlhs>1 ? jacobian : noArray()));
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(jacobian);
}
