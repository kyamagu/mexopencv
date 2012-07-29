/**
 * @file matMulDeriv.cpp
 * @brief mex interface for matMulDeriv
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
    if (nrhs!=2 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    Mat A(rhs[0].toMat(CV_32F)), B(rhs[1].toMat(CV_32F)), dABdA, dABdB;
    matMulDeriv(A, B, dABdA, dABdB);
    plhs[0] = MxArray(dABdA);
    if (nlhs>1)
        plhs[1] = MxArray(dABdB);
}
