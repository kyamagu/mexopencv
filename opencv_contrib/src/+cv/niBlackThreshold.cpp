/**
 * @file niBlackThreshold.cpp
 * @brief mex interface for cv::ximgproc::niBlackThreshold
 * @ingroup ximgproc
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

namespace {
/// binarization methods map for option processing
const ConstMap<string,int> BinarizationMethodsMap = ConstMap<string,int>
    ("Niblack", cv::ximgproc::BINARIZATION_NIBLACK)
    ("Sauvola", cv::ximgproc::BINARIZATION_SAUVOLA)
    ("Wolf",    cv::ximgproc::BINARIZATION_WOLF)
    ("Nick",    cv::ximgproc::BINARIZATION_NICK);
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

    // Option processing
    double maxValue = 255;
    int type = cv::THRESH_BINARY;
    int blockSize = 5;
    int binarizationMethod = cv::ximgproc::BINARIZATION_NIBLACK;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MaxValue")
            maxValue = rhs[i+1].toDouble();
        else if (key == "Type")
            type = ThreshType[rhs[i+1].toString()];
        else if (key == "BlockSize")
            blockSize = rhs[i+1].toInt();
        else if (key == "Method")
            binarizationMethod = BinarizationMethodsMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)),  // 8u for Sauvola, otherwise any depth
        dst;
    double k = rhs[1].toDouble();
    niBlackThreshold(src, dst, maxValue, type, blockSize, k, binarizationMethod);
    plhs[0] = MxArray(dst);
}
