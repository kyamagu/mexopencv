/**
 * @file updateMotionHistory.cpp
 * @brief mex interface for updateMotionHistory
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
    if (nrhs<4 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Process
    Mat silhouette(rhs[0].toMat(CV_8U)), mhi(rhs[1].toMat(CV_32F));
    double timestamp = rhs[2].toDouble(), duration = rhs[3].toDouble();
    updateMotionHistory(silhouette,mhi,timestamp,duration);
    plhs[0] = MxArray(mhi);
}
