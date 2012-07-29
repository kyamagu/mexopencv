/**
 * @file invert.cpp
 * @brief mex interface for invert
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Methods
 */
const ConstMap<std::string,int> Methods = ConstMap<std::string,int>
    ("LU",DECOMP_LU)
    ("SVD",DECOMP_SVD)
    ("Cholesky",DECOMP_CHOLESKY);
}

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
    if (nrhs<1 || (nrhs%2)!=1 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Execute function
    Mat src(rhs[0].toMat()), dst;
    int method = DECOMP_LU;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Method")
            method = Methods[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s",key.c_str());
    }
    
    double d = invert(src,dst,method);
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(d);
}
