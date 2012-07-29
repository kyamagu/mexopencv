/**
 * @file erode.cpp
 * @brief mex interface for erode
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
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat element;
    Point anchor(-1,-1);
    int iterations = 1;
    int borderType = BORDER_CONSTANT;
    Scalar borderValue = morphologyDefaultBorderValue();
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Element")
            element = rhs[i+1].toMat(CV_8U);
        else if (key=="Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key=="Iterations")
            iterations = rhs[i+1].toInt();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key=="BorderType")
            borderValue = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat src(rhs[0].toMat()), dst;
    erode(src, dst, element, anchor, iterations, borderType, borderValue);
    plhs[0] = MxArray(dst);
}
