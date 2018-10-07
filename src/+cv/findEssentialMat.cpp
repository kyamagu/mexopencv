/**
 * @file findEssentialMat.cpp
 * @brief mex interface for cv::findEssentialMat
 * @ingroup calib3d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/// Estimation methods for option processing
const ConstMap<string,int> Method = ConstMap<string,int>
    ("Ransac", cv::RANSAC)
    ("LMedS",  cv::LMEDS);
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix = Mat::eye(3, 3, CV_64F);
    int method = cv::RANSAC;
    double prob = 0.999;
    double threshold = 1.0;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "Method")
            method = (rhs[i+1].isChar()) ?
                Method[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "Confidence")
            prob = rhs[i+1].toDouble();
        else if (key == "Threshold")
            threshold = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat E, mask;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points1(rhs[0].toMat(CV_64F)),
            points2(rhs[1].toMat(CV_64F));
        E = findEssentialMat(points1, points2, cameraMatrix, method,
            prob, threshold, (nlhs>1 ? mask : noArray()));
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2d> points1(rhs[0].toVector<Point2d>()),
                        points2(rhs[1].toVector<Point2d>());
        E = findEssentialMat(points1, points2, cameraMatrix, method,
            prob, threshold, (nlhs>1 ? mask : noArray()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(E);
    if (nlhs > 1)
        plhs[1] = MxArray(mask);
}
