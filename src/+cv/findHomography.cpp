/**
 * @file findHomography.cpp
 * @brief mex interface for cv::findHomography
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Estimation methods for option processing
const ConstMap<string,int> Method = ConstMap<string,int>
    ("0",      0)
    ("Ransac", cv::RANSAC)
    ("LMedS",  cv::LMEDS)
    ("Rho",    cv::RHO);
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
    int method = 0;
    double ransacReprojThreshold = 3.0;
    int maxIters = 2000;
    double confidence = 0.995;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Method")
            method = (rhs[i+1].isChar()) ?
                Method[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="RansacReprojThreshold")
            ransacReprojThreshold = rhs[i+1].toDouble();
        else if (key=="MaxIters")
            maxIters = rhs[i+1].toInt();
        else if (key=="Confidence")
            confidence = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat mask, H;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points1(rhs[0].toMat(CV_32F).reshape(2,0)),  // CV_32FC2
            points2(rhs[1].toMat(CV_32F).reshape(2,0));
        H = findHomography(points1, points2, method, ransacReprojThreshold,
            (nlhs>1 ? mask : noArray()), maxIters, confidence);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> points1(rhs[0].toVector<Point2f>()),
                        points2(rhs[1].toVector<Point2f>());
        H = findHomography(points1, points2, method, ransacReprojThreshold,
            (nlhs>1 ? mask : noArray()), maxIters, confidence);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(H);
    if (nlhs>1)
        plhs[1] = MxArray(mask);
}
