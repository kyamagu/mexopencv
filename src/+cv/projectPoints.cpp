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
    if (nrhs<4 || (nrhs%2)!=0 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    Mat distCoeffs;
    double aspectRatio = 0;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else if (key=="AspectRatio")
            aspectRatio = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat rvec(rhs[1].toMat(CV_64F)), tvec(rhs[2].toMat(CV_64F));
    Mat cameraMatrix(rhs[3].toMat(CV_64F)), jacobian;
    if (rhs[0].isNumeric()) {
        Mat objectPoints(rhs[0].toMat(CV_64F)), imagePoints;
        projectPoints(objectPoints, rvec, tvec, cameraMatrix, distCoeffs,
            imagePoints, jacobian, aspectRatio);
        plhs[0] = MxArray(imagePoints);
    }
    else if (rhs[0].isCell()) {
        vector<Point3d> objectPoints(rhs[0].toVector<Point3d>());
        vector<Point2d> imagePoints;
        projectPoints(objectPoints, rvec, tvec, cameraMatrix, distCoeffs,
            imagePoints, jacobian, aspectRatio);
        plhs[0] = MxArray(imagePoints);
    }

    if (nlhs>1)
        plhs[1] = MxArray(jacobian);
}
