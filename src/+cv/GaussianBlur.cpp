/**
 * @file GaussianBlur.cpp
 * @brief mex interface for GaussianBlur
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
    Size ksize(5,5);
    double sigmaX = 0;
    double sigmaY = 0;
    int borderType = BORDER_DEFAULT;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="KSize")
            ksize = rhs[i+1].toSize();
        else if (key=="SigmaX")
            sigmaX = rhs[i+1].toDouble();
        else if (key=="SigmaY")
            sigmaY = rhs[i+1].toDouble();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat src(rhs[0].toMat()), dst;
    GaussianBlur(src, dst, ksize, sigmaX, sigmaY, borderType);
    plhs[0] = MxArray(dst);
}
