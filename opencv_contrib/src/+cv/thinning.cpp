/**
 * @file thinning.cpp
 * @brief mex interface for cv::ximgproc::thinning
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
/// Thinning techniques for option processing
const ConstMap<string,int> ThinningTypesMap = ConstMap<string,int>
    ("ZhangSuen", cv::ximgproc::THINNING_ZHANGSUEN)
    ("GuoHall",   cv::ximgproc::THINNING_GUOHALL);
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
    int thinningType = cv::ximgproc::THINNING_ZHANGSUEN;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "ThinningType")
            thinningType = ThinningTypesMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    thinning(src, dst, thinningType);
    plhs[0] = MxArray(dst);
}
