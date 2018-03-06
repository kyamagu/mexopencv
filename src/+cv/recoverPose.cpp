/**
 * @file recoverPose.cpp
 * @brief mex interface for cv::recoverPose
 * @ingroup calib3d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=5);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix = Mat::eye(3, 3, CV_64F);
    double distanceThresh = 50.0;
    Mat mask;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "DistanceThreshold")
            distanceThresh = rhs[i+1].toDouble();
        else if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat E(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        R, t, triangulatedPoints;
    int good = 0;
    if (rhs[1].isNumeric() && rhs[2].isNumeric()) {
        Mat points1(rhs[1].toMat(CV_64F)),
            points2(rhs[2].toMat(CV_64F));
        good = recoverPose(E, points1, points2, cameraMatrix, R, t,
            distanceThresh, (nlhs>3 ? mask : noArray()),
            (nlhs>4 ? triangulatedPoints : noArray()));
    }
    else if (rhs[1].isCell() && rhs[2].isCell()) {
        vector<Point2d> points1(rhs[1].toVector<Point2d>()),
                        points2(rhs[2].toVector<Point2d>());
        good = recoverPose(E, points1, points2, cameraMatrix, R, t,
            distanceThresh, (nlhs>3 ? mask : noArray()),
            (nlhs>4 ? triangulatedPoints : noArray()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(R);
    if (nlhs > 1)
        plhs[1] = MxArray(t);
    if (nlhs > 2)
        plhs[2] = MxArray(good);
    if (nlhs > 3)
        plhs[3] = MxArray(mask);
    if (nlhs > 4)
        plhs[4] = MxArray(triangulatedPoints);
}
