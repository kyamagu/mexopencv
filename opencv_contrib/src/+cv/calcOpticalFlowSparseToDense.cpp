/**
 * @file calcOpticalFlowSparseToDense.cpp
 * @brief mex interface for cv::optflow::calcOpticalFlowSparseToDense
 * @ingroup optflow
 * @author Amro
 * @date 2016
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int grid_step = 8;
    int k = 128;
    float sigma = 0.05f;
    bool use_post_proc = true;
    float fgs_lambda = 500.0f;
    float fgs_sigma = 1.5f;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "GridStep")
            grid_step = rhs[i+1].toInt();
        else if (key == "K")
            k = rhs[i+1].toInt();
        else if (key == "Sigma")
            sigma = rhs[i+1].toFloat();
        else if (key == "UsePostProcessing")
            use_post_proc = rhs[i+1].toBool();
        else if (key == "FGSLambda")
            fgs_lambda = rhs[i+1].toFloat();
        else if (key == "FGSSigma")
            fgs_sigma = rhs[i+1].toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat from(rhs[0].toMat(CV_8U)), to(rhs[1].toMat(CV_8U)), flow;
    calcOpticalFlowSparseToDense(from, to, flow,
        grid_step, k, sigma, use_post_proc, fgs_lambda, fgs_sigma);
    plhs[0] = MxArray(flow);
}
