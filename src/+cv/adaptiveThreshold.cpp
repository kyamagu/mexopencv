/**
 * @file adaptiveThreshold.cpp
 * @brief mex interface for cv::adaptiveThreshold
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Adaptive thresholding type map for option processing
const ConstMap<string,int> AdaptiveMethod = ConstMap<string,int>
    ("Mean",     cv::ADAPTIVE_THRESH_MEAN_C)
    ("Gaussian", cv::ADAPTIVE_THRESH_GAUSSIAN_C);
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 *
 * This is the entry point of the function
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int adaptiveMethod = cv::ADAPTIVE_THRESH_MEAN_C;
    int thresholdType = cv::THRESH_BINARY;
    int blockSize = 3;
    double C = 5;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="AdaptiveMethod")
            adaptiveMethod = AdaptiveMethod[rhs[i+1].toString()];
        else if (key=="ThresholdType")
            thresholdType = ThreshType[rhs[i+1].toString()];
        else if (key=="BlockSize")
            blockSize = rhs[i+1].toInt();
        else if (key=="C")
            C = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    double maxValue = rhs[1].toDouble();
    adaptiveThreshold(src, dst, maxValue, adaptiveMethod, thresholdType,
        blockSize, C);
    plhs[0] = MxArray(dst);
}
