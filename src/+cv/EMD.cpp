/**
 * @file EMD.cpp
 * @brief mex interface for EMD
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    int distType = CV_DIST_L2;
    Mat cost;
    float lowerBound = 0;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DistType")
            distType = (rhs[i+1].isChar()) ?
                DistType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Cost")
            cost = rhs[i+1].toMat();
        else if (key=="LowerBound")
            lowerBound = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    if (distType==CV_DIST_USER && cost.empty())
        mexErrMsgIdAndTxt("mexopencv:error","Cost matrix empty");

    // Process
    Mat signature1(rhs[0].toMat()), signature2(rhs[1].toMat()), flow;
    double d;
    if (distType==CV_DIST_USER)
        d = EMD(signature1, signature2, distType, cost);
    else
        d = EMD(signature1, signature2, distType, cost, &lowerBound, flow);

    plhs[0] = MxArray(d);
    if (nlhs>1)
        plhs[1] = MxArray(lowerBound);
    if (nlhs>2)
        plhs[2] = MxArray(flow);
}
