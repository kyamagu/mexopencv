/**
 * @file projectPoints.cpp
 * @brief mex interface for projectPoints
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
    if (nrhs<4 || ((nrhs%2)!=1) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat rvec(rhs[1].toMat(CV_32F)), tvec(rhs[2].toMat(CV_32F));
    Mat cameraMatrix(rhs[3].toMat(CV_32F));
    Mat distCoeffs = (nrhs>4) ? rhs[4].toMat(CV_32F) : Mat();
    Mat objectPoints(rhs[0].toMat(CV_32F));
    vector<Point2f> imagePoints;
    projectPoints(objectPoints, rvec, tvec, cameraMatrix, distCoeffs, imagePoints);
    plhs[0] = MxArray(imagePoints);
}
