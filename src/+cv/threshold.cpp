/**
 * @file threshold.cpp
 * @brief mex interface for threshold
 * @author Kota Yamaguchi
 * @date 2012
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
    if (nrhs<2 || ((nrhs%2)!=0) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    double thresh = 0.5;
    double maxVal = 1.0;
    int thresholdType = THRESH_TRUNC;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="MaxValue")
            maxVal = rhs[i+1].toDouble();
        else if (key=="Method")
            thresholdType = ThreshType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Second argument
    if (rhs[1].isNumeric())
        thresh = rhs[1].toDouble();
    else if (rhs[1].isChar())
        thresholdType |= THRESH_OTSU;
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");

    // Process
    Mat src(rhs[0].toMat()), dst;
    double result = threshold(src, dst, thresh, maxVal, thresholdType);
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(result);
}
