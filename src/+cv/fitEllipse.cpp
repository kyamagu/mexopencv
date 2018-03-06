/**
 * @file fitEllipse.cpp
 * @brief mex interface for cv::fitEllipse, cv::fitEllipseDirect, cv::fitEllipseAMS
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
using namespace std;
using namespace cv;

namespace {
/// Fit ellipse methods
enum {FIT_ELLIPSE_LINEAR, FIT_ELLIPSE_DIRECT, FIT_ELLIPSE_AMS};

/// Fit ellipse algorithm for option processing
const ConstMap<string,int> FitEllipseAlgMap = ConstMap<string,int>
    ("Linear", FIT_ELLIPSE_LINEAR)
    ("Direct", FIT_ELLIPSE_DIRECT)
    ("AMS",    FIT_ELLIPSE_AMS);
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int method = FIT_ELLIPSE_LINEAR;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Method")
            method = FitEllipseAlgMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    RotatedRect r;
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(rhs[0].isInt32() ? CV_32S : CV_32F));
        switch (method) {
            case FIT_ELLIPSE_LINEAR:
                r = fitEllipse(points);
                break;
            case FIT_ELLIPSE_DIRECT:
                r = fitEllipseDirect(points);
                break;
            case FIT_ELLIPSE_AMS:
                r = fitEllipseAMS(points);
                break;
        }
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> points(rhs[0].toVector<Point2f>());
        switch (method) {
            case FIT_ELLIPSE_LINEAR:
                r = fitEllipse(points);
                break;
            case FIT_ELLIPSE_DIRECT:
                r = fitEllipseDirect(points);
                break;
            case FIT_ELLIPSE_AMS:
                r = fitEllipseAMS(points);
                break;
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(r);
}
