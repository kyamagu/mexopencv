/**
 * @file EMD.cpp
 * @brief mex interface for cv::EMD
 * @ingroup imgproc
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int distType = cv::DIST_L2;
    Mat cost;
    float lowerBound = 0;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DistType")
            distType = (rhs[i+1].isChar()) ?
                DistType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "Cost")
            cost = rhs[i+1].toMat(CV_32F);
        else if (key == "LowerBound")
            lowerBound = rhs[i+1].toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    if (distType==cv::DIST_USER && cost.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "In case of user-defined distance, cost matrix must be defined");

    // Process
    Mat signature1(rhs[0].toMat(CV_32F)),
        signature2(rhs[1].toMat(CV_32F)),
        flow;
    float emd = EMD(signature1, signature2, distType, cost,
        (nlhs>1 && cost.empty() ? &lowerBound : NULL),
        (nlhs>2 ? flow : noArray()));
    plhs[0] = MxArray(emd);
    if (nlhs>1)
        plhs[1] = MxArray(lowerBound);
    if (nlhs>2)
        plhs[2] = MxArray(flow);
}
