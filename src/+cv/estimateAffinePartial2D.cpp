/**
 * @file estimateAffinePartial2D.cpp
 * @brief mex interface for cv::estimateAffinePartial2D
 * @ingroup calib3d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/// Estimation methods for option processing
const ConstMap<string,int> MethodsMap = ConstMap<string,int>
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
    int method = cv::RANSAC;
    double ransacReprojThreshold = 3.0;
    size_t maxIters = 2000;
    double confidence = 0.99;
    size_t refineIters = 10;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Method")
            method = MethodsMap[rhs[i+1].toString()];
        else if (key == "RansacThreshold")
            ransacReprojThreshold = rhs[i+1].toDouble();
        else if (key == "MaxIters")
            maxIters = rhs[i+1].toInt();
        else if (key == "Confidence")
            confidence = rhs[i+1].toDouble();
        else if (key == "RefineIters")
            refineIters = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat out, inliers;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat from(rhs[0].toMat(CV_32F).reshape(2,0)),  // CV_32FC2
            to(rhs[1].toMat(CV_32F).reshape(2,0));
        out = estimateAffinePartial2D(from, to, (nlhs>1 ? inliers : noArray()),
            method, ransacReprojThreshold, maxIters, confidence, refineIters);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> from(rhs[0].toVector<Point2f>()),
                        to(rhs[1].toVector<Point2f>());
        out = estimateAffinePartial2D(from, to, (nlhs>1 ? inliers : noArray()),
            method, ransacReprojThreshold, maxIters, confidence, refineIters);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(out);
    if (nlhs>1)
        plhs[1] = MxArray(inliers);
}
