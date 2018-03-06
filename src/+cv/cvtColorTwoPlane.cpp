/**
 * @file cvtColorTwoPlane.cpp
 * @brief mex interface for cv::cvtColorTwoPlane
 * @ingroup imgproc
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
using namespace std;
using namespace cv;

namespace {
/// Color conversion types for option processing
const ConstMap<string,int> ColorConv = ConstMap<string,int>
    ("YUV2RGB_NV12",    cv::COLOR_YUV2RGB_NV12)
    ("YUV2BGR_NV12",    cv::COLOR_YUV2BGR_NV12)
    ("YUV2RGB_NV21",    cv::COLOR_YUV2RGB_NV21)
    ("YUV2BGR_NV21",    cv::COLOR_YUV2BGR_NV21)
    ("YUV420sp2RGB",    cv::COLOR_YUV420sp2RGB)
    ("YUV420sp2BGR",    cv::COLOR_YUV420sp2BGR)
    ("YUV2RGBA_NV12",   cv::COLOR_YUV2RGBA_NV12)
    ("YUV2BGRA_NV12",   cv::COLOR_YUV2BGRA_NV12)
    ("YUV2RGBA_NV21",   cv::COLOR_YUV2RGBA_NV21)
    ("YUV2BGRA_NV21",   cv::COLOR_YUV2BGRA_NV21)
    ("YUV420sp2RGBA",   cv::COLOR_YUV420sp2RGBA)
    ("YUV420sp2BGRA",   cv::COLOR_YUV420sp2BGRA);
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
    nargchk(nrhs==3 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat ysrc(rhs[0].toMat(CV_8U)),
        uvsrc(rhs[1].toMat(CV_8U)),
        dst;
    int code = ColorConv[rhs[2].toString()];
    cvtColorTwoPlane(ysrc, uvsrc, dst, code);
    plhs[0] = MxArray(dst);
}
