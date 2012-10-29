/**
 * @file convertPointsFromHomogeneous.cpp
 * @brief mex interface for convertPointsFromHomogeneous
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

#define convertPointsFromHomogeneous convertPointsHomogeneous

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
    if (nrhs!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Process
    if (rhs[0].isNumeric()) {
        Mat src(rhs[0].toMat(CV_32F));
        int n = src.channels();
        if (n==3) {
            vector<Point2f> dst;
            convertPointsFromHomogeneous(src, dst);
            plhs[0] = MxArray(dst);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    
}
