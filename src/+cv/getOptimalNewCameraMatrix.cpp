/**
 * @file getOptimalNewCameraMatrix.cpp
 * @brief mex interface for getOptimalNewCameraMatrix
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
    if (nrhs<3 || ((nrhs%2)!=1) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    Mat cameraMatrix(rhs[0].toMat(CV_32F));
    Mat distCoeffs(rhs[1].toMat(CV_32F));
    Size imageSize(rhs[2].toSize());;
    double alpha=0.8;
    Size newImageSize;
    bool centerPrincipalPoint=false;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Alpha")
            alpha = rhs[i+1].toDouble();
        else if (key=="NewImageSize")
            newImageSize = rhs[i+1].toSize();
        else if (key=="CenterPrincipalPoint")
            centerPrincipalPoint = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    // Process
    Rect validPixROI;
    Mat m = getOptimalNewCameraMatrix(cameraMatrix, distCoeffs, imageSize,
        alpha, newImageSize, &validPixROI, centerPrincipalPoint);
    plhs[0] = MxArray(m);
    if (nlhs>1)
        plhs[1] = MxArray(validPixROI);
}
