/**
 * @file applyColorMap.cpp
 * @brief mex interface for cv::applyColorMap
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
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
    ("HSV",     cv::COLORMAP_HSV)
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool flip = true;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    if (rhs[1].isChar()) {
        int colormap = ColormapTypesMap[rhs[1].toString()];
        applyColorMap(src, dst, colormap);
    }
    else {
        Mat userColor(rhs[1].toMat(CV_8U));
        if (flip && userColor.channels() == 3 && src.channels() == 3)
            cvtColor(userColor, userColor, cv::COLOR_BGR2RGB);
        applyColorMap(src, dst, userColor);
    }
    // OpenCV's default is BGR while MATLAB's is RGB
    if (flip && dst.channels() == 3)
        cvtColor(dst, dst, cv::COLOR_BGR2RGB);  // flip 3rd dim
    plhs[0] = MxArray(dst);
}
