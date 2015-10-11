/**
 * @file recoverPose.cpp
 * @brief mex interface for cv::recoverPose
 * @ingroup calib3d
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=4);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double focal = 1.0;
    Point2d pp(0,0);
    Mat mask;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Focal")
            focal = rhs[i+1].toDouble();
        else if (key == "PrincipalPoint")
            pp = rhs[i+1].toPoint_<double>();
        else if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    Mat E(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        R, t;
    int good = 0;
    if (rhs[1].isNumeric() && rhs[2].isNumeric()) {
        Mat points1(rhs[1].toMat(CV_64F)),
            points2(rhs[2].toMat(CV_64F));
        good = recoverPose(E, points1, points2, R, t, focal, pp,
            (nlhs>3 ? mask : noArray()));
    }
    else if (rhs[1].isCell() && rhs[2].isCell()) {
        vector<Point2d> points1(rhs[1].toVector<Point2d>()),
                        points2(rhs[2].toVector<Point2d>());
        good = recoverPose(E, points1, points2, R, t, focal, pp,
            (nlhs>3 ? mask : noArray()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(R);
    if (nlhs > 1)
        plhs[1] = MxArray(t);
    if (nlhs > 2)
        plhs[2] = MxArray(good);
    if (nlhs > 3)
        plhs[3] = MxArray(mask);
}
