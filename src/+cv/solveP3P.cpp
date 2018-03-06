/**
 * @file solveP3P.cpp
 * @brief mex interface for cv::solveP3P
 * @ingroup calib3d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/// Method used for solving the pose estimation problem.
const ConstMap<string,int> P3PMethod = ConstMap<string,int>
    ("P3P",       cv::SOLVEPNP_P3P)
    ("AP3P",      cv::SOLVEPNP_AP3P);
}

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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs + nrhs);

    // Option processing
    Mat distCoeffs;
    int flags = cv::SOLVEPNP_P3P;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else if (key == "Method")
            flags = P3PMethod[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Mat> rvecs, tvecs;
    int solutions = 0;
    Mat cameraMatrix(rhs[2].toMat(CV_64F));
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat objectPoints(rhs[0].toMat(CV_64F).reshape(3,0)),
            imagePoints(rhs[1].toMat(CV_64F).reshape(2,0));
        solutions = solveP3P(objectPoints, imagePoints, cameraMatrix, distCoeffs,
            rvecs, tvecs, flags);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point3d> objectPoints(rhs[0].toVector<Point3d>());
        vector<Point2d> imagePoints(rhs[1].toVector<Point2d>());
        solutions = solveP3P(objectPoints, imagePoints, cameraMatrix, distCoeffs,
            rvecs, tvecs, flags);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(rvecs);
    if (nlhs > 1)
        plhs[1] = MxArray(tvecs);
    if (nlhs > 2)
        plhs[2] = MxArray(solutions);
}
