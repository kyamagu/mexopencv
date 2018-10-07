/**
 * @file threshold.cpp
 * @brief mex interface for cv::threshold
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
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
    double maxval = 255;
    int type = cv::THRESH_BINARY;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MaxValue")
            maxval = rhs[i+1].toDouble();
        else if (key == "Type")
            type = ThreshType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Second argument
    double thresh = 0;
    if (rhs[1].isChar())
        type |= AutoThresholdTypesMap[rhs[1].toString()];
    else
        thresh = rhs[1].toDouble();

    // Process
    Mat src(rhs[0].toMat()),  // 8u, 16s, 16u, 32f, 64f
        dst;
    thresh = threshold(src, dst, thresh, maxval, type);
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(thresh);
}
