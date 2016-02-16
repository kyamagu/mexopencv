/**
 * @file covarianceEstimation.cpp
 * @brief mex interface for cv::ximgproc::covarianceEstimation
 * @ingroup ximgproc
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

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
    Mat src(rhs[0].toMat(CV_32F)),
        dst;
    Vec2i windowSize(rhs[1].toVec<int,2>());
    int windowRows = windowSize[0],
        windowCols = windowSize[1];
    covarianceEstimation(src, dst, windowRows, windowCols);
    plhs[0] = MxArray(dst);
}
