/**
 * @file resize.cpp
 * @brief mex interface for resize
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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int interpolation=INTER_LINEAR;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Interpolation")
            interpolation = InterType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Decide second arguments
    Size dsize;
    double fx = 0, fy = 0;
    if (rhs[1].numel()==1)
        fx = fy = rhs[1].toDouble();        
    else if (rhs[1].numel()==2)
        dsize = rhs[1].toSize();
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid second argument");
    
    // Apply
    Mat src(rhs[0].toMat()), dst;
    resize(src, dst, dsize, fx, fy, interpolation);
    plhs[0] = MxArray(dst);
}
