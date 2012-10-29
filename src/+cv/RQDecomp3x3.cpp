/**
 * @file RQDecomp3x3.cpp
 * @brief mex interface for RQDecomp3x3
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
    if (nrhs!=1 || nlhs>5)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Process
    Mat M(rhs[0].toMat(CV_32F));
    Mat R, Q;
    Mat Qx, Qy, Qz;
    RQDecomp3x3(M, R, Q, Qx, Qy, Qz);
    plhs[0] = MxArray(R);
    if (nlhs>1)
        plhs[1] = MxArray(Q);
    if (nlhs>2)
        plhs[2] = MxArray(Qx);
    if (nlhs>3)
        plhs[3] = MxArray(Qy);
    if (nlhs>4)
        plhs[4] = MxArray(Qz);
}
