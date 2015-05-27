/**
 * @file calibrateCamera.cpp
 * @brief mex interface for calibrateCamera
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
    if (nrhs<3 || ((nrhs%2)!=1) || nlhs>5)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    Mat cameraMatrix(Mat::eye(3,3,CV_32FC1));
    Mat distCoeffs;
    int flags = 0;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_32F);
        else if (key=="DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_32F);
        else if (key=="UseIntrinsicGuess" && rhs[i+1].toBool())
            flags |= cv::CALIB_USE_INTRINSIC_GUESS;
        else if (key=="FixPrincipalPoint" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_PRINCIPAL_POINT;
        else if (key=="FixAspectRatio" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_ASPECT_RATIO;
        else if (key=="ZeroTangentDist" && rhs[i+1].toBool())
            flags |= cv::CALIB_ZERO_TANGENT_DIST;
        else if (key=="FixK1" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_K1;
        else if (key=="FixK2" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_K2;
        else if (key=="FixK3" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_K3;
        else if (key=="FixK4" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_K4;
        else if (key=="FixK5" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_K5;
        else if (key=="FixK6" && rhs[i+1].toBool())
            flags |= cv::CALIB_FIX_K6;
        else if (key=="RationalModel" && rhs[i+1].toBool())
            flags |= cv::CALIB_RATIONAL_MODEL;
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    vector<vector<Point3f> > objectPoints(MxArrayToVectorVectorPoint3<float>(rhs[0]));
    vector<vector<Point2f> > imagePoints(MxArrayToVectorVectorPoint<float>(rhs[1]));
    Size imageSize(rhs[2].toSize());
    vector<Mat> rvecs, tvecs;
    double d = calibrateCamera(objectPoints, imagePoints, imageSize,
        cameraMatrix, distCoeffs, rvecs, tvecs, flags);
    plhs[0] = MxArray(cameraMatrix);
    if (nlhs>1)
        plhs[1] = MxArray(distCoeffs);
    if (nlhs>2)
        plhs[2] = MxArray(d);
    if (nlhs>3)
        plhs[3] = MxArray(rvecs);
    if (nlhs>4)
        plhs[4] = MxArray(tvecs);
}
