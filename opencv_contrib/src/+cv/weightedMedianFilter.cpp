/**
 * @file weightedMedianFilter.cpp
 * @brief mex interface for cv::ximgproc::weightedMedianFilter
 * @ingroup ximgproc
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

namespace {
/// weight type options of weighted median filter
const ConstMap<string, int> WeightTypeMap = ConstMap<string, int>
    ("EXP", cv::ximgproc::WMF_EXP)
    ("IV1", cv::ximgproc::WMF_IV1)
    ("IV2", cv::ximgproc::WMF_IV2)
    ("COS", cv::ximgproc::WMF_COS)
    ("JAC", cv::ximgproc::WMF_JAC)
    ("OFF", cv::ximgproc::WMF_OFF);
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
    int r = 7;
    double sigma = 25.5;
    int weightType = cv::ximgproc::WMF_EXP;
    Mat mask;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Radius")
            r = rhs[i+1].toInt();
        else if (key == "Sigma")
            sigma = rhs[i+1].toDouble();
        else if (key == "WeightType")
            weightType = WeightTypeMap[rhs[i+1].toString()];
        else if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F)),
        joint(rhs[1].toMat(CV_8U)),
        dst;
    weightedMedianFilter(joint, src, dst,
        r, sigma, weightType, mask);
    plhs[0] = MxArray(dst);
}
