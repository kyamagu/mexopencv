/**
 * @file calcBlurriness.cpp
 * @brief mex interface for cv::videostab::calcBlurriness
 * @ingroup videostab
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/videostab.hpp"
using namespace std;
using namespace cv;
using namespace cv::videostab;

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

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat frame(rhs[0].toMat());
    float blurriness = calcBlurriness(frame);
    plhs[0] = MxArray(blurriness);
}
