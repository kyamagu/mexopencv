/**
 * @file solvePnP.cpp
 * @brief mex interface for solvePnP
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Method used for solving the pose estimation problem.
const ConstMap<std::string,int> PnPMethod = ConstMap<std::string,int>
    ("Iterative", cv::SOLVEPNP_ITERATIVE)
    ("EPnP",      cv::SOLVEPNP_EPNP)
    ("P3P",       cv::SOLVEPNP_P3P)
    ("DLS",       cv::SOLVEPNP_DLS)
    ("UPnP",      cv::SOLVEPNP_UPNP);
}

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
    if (nrhs<3 || (nrhs%2)!=1 || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    Mat distCoeffs(4, 1, CV_64F);
    Mat rvec(3, 1, CV_64F), tvec(3, 1, CV_64F);
    bool useExtrinsicGuess = false;
    int flags = cv::SOLVEPNP_ITERATIVE;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else if (key=="UseExtrinsicGuess")
            useExtrinsicGuess = rhs[i+1].toBool();
        else if (key=="Rvec") {
            rvec = rhs[i+1].toMat(CV_64F);
            useExtrinsicGuess = true;
        }
        else if (key=="Tvec") {
            tvec = rhs[i+1].toMat(CV_64F);
            useExtrinsicGuess = true;
        }
        else if (key=="Method")
            flags = PnPMethod[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    bool success = false;
    Mat cameraMatrix(rhs[2].toMat(CV_64F));
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat objectPoints(rhs[0].toMat(CV_32F).reshape(3,0)),
            imagePoints(rhs[1].toMat(CV_32F).reshape(2,0));
        success = solvePnP(objectPoints, imagePoints, cameraMatrix, distCoeffs,
            rvec, tvec, useExtrinsicGuess, flags);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point3f> objectPoints(rhs[0].toVector<Point3f>());
        vector<Point2f> imagePoints(rhs[1].toVector<Point2f>());
        success = solvePnP(objectPoints, imagePoints, cameraMatrix, distCoeffs,
            rvec, tvec, useExtrinsicGuess, flags);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");

    plhs[0] = MxArray(rvec);
    if (nlhs>1)
        plhs[1] = MxArray(tvec);
    if (nlhs>2)
        plhs[2] = MxArray(success);
}
