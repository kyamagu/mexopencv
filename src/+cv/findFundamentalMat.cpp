/**
 * @file findFundamentalMat.cpp
 * @brief mex interface for cv::findFundamentalMat
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/// Method for option processing
const ConstMap<string,int> FMMethod = ConstMap<string,int>
    ("7Point", cv::FM_7POINT)
    ("8Point", cv::FM_8POINT)
    ("Ransac", cv::FM_RANSAC)
    ("LMedS",  cv::FM_LMEDS);
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
    int method = cv::FM_RANSAC;
    double ransacReprojThreshold = 3.0;
    double confidence = 0.99;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Method")
            method = FMMethod[rhs[i+1].toString()];
        else if (key == "RansacReprojThreshold")
            ransacReprojThreshold = rhs[i+1].toDouble();
        else if (key == "Confidence")
            confidence = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat F, mask;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points1(rhs[0].toMat(CV_32F)),
            points2(rhs[1].toMat(CV_32F));
        F = findFundamentalMat(points1, points2, method,
            ransacReprojThreshold, confidence,
            (nlhs>1 ? mask : noArray()));
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> points1(rhs[0].toVector<Point2f>()),
                        points2(rhs[1].toVector<Point2f>());
        F = findFundamentalMat(points1, points2, method,
            ransacReprojThreshold, confidence,
            (nlhs>1 ? mask : noArray()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(F);
    if (nlhs>1)
        plhs[1] = MxArray(mask);  // MxArray(mask,mxLOGICAL_CLASS)
}
