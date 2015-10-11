/**
 * @file applyColorMap.cpp
 * @brief mex interface for cv::applyColorMap
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// colormap types for option processing
const ConstMap<string,int> ColormapTypesMap = ConstMap<string,int>
    ("Autumn",  cv::COLORMAP_AUTUMN)
    ("Bone",    cv::COLORMAP_BONE)
    ("Jet",     cv::COLORMAP_JET)
    ("Winter",  cv::COLORMAP_WINTER)
    ("Rainbow", cv::COLORMAP_RAINBOW)
    ("Ocean",   cv::COLORMAP_OCEAN)
    ("Summer",  cv::COLORMAP_SUMMER)
    ("Spring",  cv::COLORMAP_SPRING)
    ("Cool",    cv::COLORMAP_COOL)
    ("Hsv",     cv::COLORMAP_HSV)
    ("Pink",    cv::COLORMAP_PINK)
    ("Hot",     cv::COLORMAP_HOT)
    ("Parula",  cv::COLORMAP_PARULA);
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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    int colormap = ColormapTypesMap[rhs[1].toString()];
    applyColorMap(src, dst, colormap);
    cvtColor(dst, dst, cv::COLOR_BGR2RGB);  // flip 3rd dim
    plhs[0] = MxArray(dst);
}
