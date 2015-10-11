/**
 * @file calcOpticalFlowDF.cpp
 * @brief mex interface for cv::optflow::OpticalFlowDeepFlow
 * @ingroup optflow
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/video.hpp"
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
    Mat from(rhs[0].toMat(CV_8U)), to(rhs[1].toMat(CV_8U)), flow;
    Ptr<DenseOpticalFlow> p = createOptFlow_DeepFlow();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create OpticalFlowDeepFlow");
    p->calc(from, to, flow);
    plhs[0] = MxArray(flow);
}
