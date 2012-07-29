/**
 * @file undistort.cpp
 * @brief mex interface for undistort
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
    if (nrhs<3 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat src(rhs[0].toMat());
    Mat cameraMatrix(rhs[1].toMat());
    Mat distCoeffs(rhs[2].toMat());
    
    // Option processing
    Mat newCameraMatrix;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="NewCameraMatrix")
            newCameraMatrix = rhs[i+1].toMat(CV_32F);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat dst;
    undistort(src, dst, cameraMatrix, distCoeffs, newCameraMatrix);
    plhs[0] = MxArray(dst);
}
