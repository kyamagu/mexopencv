/**
 * @file clipLine.cpp
 * @brief mex interface for clipLine
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
    if (nrhs!=3 || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Execute function
    Point pt1(rhs[1].toPoint()), pt2(rhs[2].toPoint());
    if (rhs[0].numel()==2)
        plhs[0] = MxArray(clipLine(rhs[0].toSize(), pt1, pt2));
    else if (rhs[0].numel()==4)
        plhs[0] = MxArray(clipLine(rhs[0].toRect(), pt1, pt2));
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    if (nlhs>1)
        plhs[1] = MxArray(pt1);
    if (nlhs>2)
        plhs[2] = MxArray(pt2);
}
