/**
 * @file threshold.cpp
 * @brief mex interface for cv::threshold
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// automatic threshold type for option processing
const ConstMap<string,int> AutoThresholdTypesMap = ConstMap<string,int>
    ("Otsu",     cv::THRESH_OTSU)
    ("Triangle", cv::THRESH_TRIANGLE);
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
    double maxVal = 1.0;
    int thresholdType = cv::THRESH_TRUNC;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="MaxValue")
            maxVal = rhs[i+1].toDouble();
        else if (key=="Method")
            thresholdType = ThreshType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Second argument
    double thresh = 0;
    if (rhs[1].isChar())
        thresholdType |= AutoThresholdTypesMap[rhs[1].toString()];
    else
        thresh = rhs[1].toDouble();

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint8() ? CV_8U :
        (rhs[0].isInt16() ? CV_16S : CV_32F))), dst;
    thresh = threshold(src, dst, thresh, maxVal, thresholdType);
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(thresh);
}
