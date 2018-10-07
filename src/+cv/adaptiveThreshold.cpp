/**
 * @file adaptiveThreshold.cpp
 * @brief mex interface for cv::adaptiveThreshold
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
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
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double maxValue = 255;
    int adaptiveMethod = cv::ADAPTIVE_THRESH_MEAN_C;
    int thresholdType = cv::THRESH_BINARY;
    int blockSize = 3;
    double C = 5;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MaxValue")
            maxValue = rhs[i+1].toDouble();
        else if (key == "Method")
            adaptiveMethod = AdaptiveMethod[rhs[i+1].toString()];
        else if (key == "Type")
            thresholdType = ThreshType[rhs[i+1].toString()];
        else if (key == "BlockSize")
            blockSize = rhs[i+1].toInt();
        else if (key == "C")
            C = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    adaptiveThreshold(src, dst, maxValue, adaptiveMethod, thresholdType,
        blockSize, C);
    plhs[0] = MxArray(dst);
}
