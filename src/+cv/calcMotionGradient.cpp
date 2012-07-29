/**
 * @file calcMotionGradient.cpp
 * @brief mex interface for calcMotionGradient
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
    if (nrhs<3 || (nrhs%2)!=1 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int apertureSize=3;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="ApertureSize")
            apertureSize = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat mhi(rhs[0].toMat(CV_32F)), mask, orientation;
    double delta1 = rhs[1].toDouble(), delta2 = rhs[2].toDouble();
    calcMotionGradient(mhi,mask,orientation,delta1,delta2,apertureSize);
    plhs[0] = MxArray(mask);
    if (nlhs>1)
        plhs[1] = MxArray(orientation);
}
