/**
 * @file morphologyEx.cpp
 * @brief mex interface for cv::morphologyEx
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
using namespace std;
using namespace cv;

namespace {
/// Type map for morphological operation for option processing
const ConstMap<string,int> MorphType = ConstMap<string,int>
    ("Erode",    cv::MORPH_ERODE)
    ("Dilate",   cv::MORPH_DILATE)
    ("Open",     cv::MORPH_OPEN)
    ("Close",    cv::MORPH_CLOSE)
    ("Gradient", cv::MORPH_GRADIENT)
    ("Tophat",   cv::MORPH_TOPHAT)
    ("Blackhat", cv::MORPH_BLACKHAT)
    ("HitMiss",  cv::MORPH_HITMISS);
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int op = MorphType[rhs[1].toString()];

    // Option processing
    Mat kernel;
    Point anchor(-1,-1);
    int iterations = 1;
    int borderType = cv::BORDER_CONSTANT;
    Scalar borderValue = morphologyDefaultBorderValue();
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Element")
            // structuring element is normally binary, but HitMiss uses 0/+1/-1
            kernel = rhs[i+1].toMat(op == cv::MORPH_HITMISS ? CV_32S : CV_8U);
        else if (key == "Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key == "Iterations")
            iterations = rhs[i+1].toInt();
        else if (key == "BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key == "BorderValue")
            borderValue = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat()), dst;
    morphologyEx(src, dst, op, kernel, anchor, iterations,
        borderType, borderValue);
    plhs[0] = MxArray(dst);
}
