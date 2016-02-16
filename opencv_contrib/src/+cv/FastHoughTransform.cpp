/**
 * @file FastHoughTransform.cpp
 * @brief mex interface for cv::ximgproc::FastHoughTransform
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
/// Option values hough transform angle range options
const ConstMap<string, int> AngleRangeOptionMap = ConstMap<string, int>
    ("ARO_0_45",    cv::ximgproc::ARO_0_45)
    ("ARO_45_90",   cv::ximgproc::ARO_45_90)
    ("ARO_90_135",  cv::ximgproc::ARO_90_135)
    ("ARO_315_0",   cv::ximgproc::ARO_315_0)
    ("ARO_315_45",  cv::ximgproc::ARO_315_45)
    ("ARO_45_135",  cv::ximgproc::ARO_45_135)
    ("ARO_315_135", cv::ximgproc::ARO_315_135)
    ("ARO_CTR_HOR", cv::ximgproc::ARO_CTR_HOR)
    ("ARO_CTR_VER", cv::ximgproc::ARO_CTR_VER);

/// Option values hough transform binary operations
const ConstMap<string, int> HoughOpMap = ConstMap<string, int>
    ("Minimum",  cv::ximgproc::FHT_MIN)
    ("Maximum",  cv::ximgproc::FHT_MAX)
    ("Addition", cv::ximgproc::FHT_ADD)
    ("Average",  cv::ximgproc::FHT_AVE);

/// Option values hough transform deskew options
const ConstMap<string, int> HoughDeskewOptionMap = ConstMap<string, int>
    ("Raw",    cv::ximgproc::HDO_RAW)
    ("Deskew", cv::ximgproc::HDO_DESKEW);
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
    int dstMatDepth = CV_32S;
    int angleRange = cv::ximgproc::ARO_315_135;
    int op = cv::ximgproc::FHT_ADD;
    int makeSkew = cv::ximgproc::HDO_DESKEW;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DDepth")
            dstMatDepth = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "AngleRange")
            angleRange = AngleRangeOptionMap[rhs[i+1].toString()];
        else if (key == "Op")
            angleRange = HoughOpMap[rhs[i+1].toString()];
        else if (key == "MakeSkew")
            makeSkew = HoughDeskewOptionMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat()), dst;
    FastHoughTransform(src, dst, dstMatDepth, angleRange, op, makeSkew);
    plhs[0] = MxArray(dst);
}
