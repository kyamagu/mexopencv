/**
 * @file moments.cpp
 * @brief mex interface for moments
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
    bool binaryImage=false;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="BinaryImage")
            binaryImage = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat array((rhs[0].classID()==mxUINT8_CLASS) ?
        rhs[0].toMat(CV_8U) : rhs[0].toMat(CV_32F));
    plhs[0] = MxArray(moments(array, binaryImage));
}
