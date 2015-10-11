/**
 * @file writeOpticalFlow.cpp
 * @brief mex interface for cv::optflow::writeOpticalFlow
 * @ingroup optflow
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/optflow.hpp"
using namespace std;
using namespace cv;
using namespace cv::optflow;

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
    string path(rhs[0].toString());
    Mat flow(rhs[1].toMat(CV_32F));
    bool success = writeOpticalFlow(path, flow);
    if (nlhs > 0)
        plhs[0] = MxArray(success);
    else if (!success)
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to write to disk");
}
