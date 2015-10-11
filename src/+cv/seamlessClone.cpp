/**
 * @file seamlessClone.cpp
 * @brief mex interface for cv::seamlessClone
 * @ingroup photo
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/photo.hpp"
using namespace std;
using namespace cv;

namespace {
/// Cloning method types for option processing
const ConstMap<string,int> CloningMethodMap = ConstMap<string,int>
    ("NormalClone",        cv::NORMAL_CLONE)
    ("MixedClone",         cv::MIXED_CLONE)
    ("MonochromeTransfer", cv::MONOCHROME_TRANSFER);
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = cv::NORMAL_CLONE;
    bool flip = true;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Method")
            flags = CloningMethodMap[rhs[i+1].toString()];
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)),
        dst(rhs[1].toMat(CV_8U)),
        mask(rhs[2].toMat(CV_8U)),
        blend;
    Point p(rhs[3].toPoint());
    // MATLAB's default is RGB while OpenCV's is BGR
    if (flip && src.channels() == 3)
        cvtColor(src, src, cv::COLOR_RGB2BGR);
    if (flip && dst.channels() == 3)
        cvtColor(dst, dst, cv::COLOR_RGB2BGR);
    if (flip && mask.channels() == 3)
        cvtColor(mask, mask, cv::COLOR_RGB2BGR);
    seamlessClone(src, dst, mask, p, blend, flags);
    // OpenCV's default is BGR while MATLAB's is RGB
    if (flip && blend.channels() == 3)
        cvtColor(blend, blend, cv::COLOR_BGR2RGB);
    plhs[0] = MxArray(blend);
}
