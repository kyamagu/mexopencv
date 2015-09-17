/**
 * @file getOptimalNewCameraMatrix.cpp
 * @brief mex interface for cv::getOptimalNewCameraMatrix
 * @ingroup calib3d
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double alpha = 0.8;
    Size newImageSize;
    bool centerPrincipalPoint = false;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
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
    Mat cameraMatrix(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        distCoeffs(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F));
    Size imageSize(rhs[2].toSize());;
    Rect validPixROI;
    Mat A = getOptimalNewCameraMatrix(cameraMatrix, distCoeffs, imageSize,
        alpha, newImageSize, (nlhs>1 ? &validPixROI : NULL),
        centerPrincipalPoint);
    plhs[0] = MxArray(A);
    if (nlhs>1)
        plhs[1] = MxArray(validPixROI);
}
