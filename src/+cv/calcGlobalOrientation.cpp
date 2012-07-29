/**
 * @file calcGlobalOrientation.cpp
 * @brief mex interface for calcGlobalOrientation
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
    if (nrhs<5 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Process
    Mat orientation(rhs[0].toMat());
    Mat mask(rhs[1].toMat());
    Mat mhi(rhs[2].toMat(CV_32F));
    double timestamp = rhs[3].toDouble();
    double duration = rhs[4].toDouble();
    double d = calcGlobalOrientation(orientation,mask,mhi,timestamp,duration);
    plhs[0] = MxArray(d);
}
