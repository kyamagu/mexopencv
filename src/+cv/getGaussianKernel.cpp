/**
 * @file getGaussianKernel.cpp
 * @brief mex interface for getGaussianKernel
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
    if ((nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int ksize=5;
    double sigma=-1;
    int ktype=CV_64F;
    for (int i=0; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="KSize")
            ksize = rhs[i+1].toInt();
        else if (key=="Sigma")
            sigma = rhs[i+1].toDouble();
        else if (key=="KType")
            ktype = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    plhs[0] = MxArray(getGaussianKernel(ksize, sigma, ktype));
}
