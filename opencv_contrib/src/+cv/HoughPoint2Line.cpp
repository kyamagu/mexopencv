/**
 * @file HoughPoint2Line.cpp
 * @brief mex interface for cv::ximgproc::HoughPoint2Line
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

/// Option values hough transform deskew options
const ConstMap<string, int> HoughDeskewOptionMap = ConstMap<string, int>
    ("Raw",    cv::ximgproc::HDO_RAW)
    ("Deskew", cv::ximgproc::HDO_DESKEW);

/// Option values hough transform rules options
const ConstMap<string, int> RulesOptionMap = ConstMap<string, int>
    ("Strict",        cv::ximgproc::RO_STRICT)
    ("IgnoreBorders", cv::ximgproc::RO_IGNORE_BORDERS);
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
    int angleRange = cv::ximgproc::ARO_315_135;
    int makeSkew = cv::ximgproc::HDO_DESKEW;
    int rules = cv::ximgproc::RO_IGNORE_BORDERS;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "AngleRange")
            angleRange = AngleRangeOptionMap[rhs[i+1].toString()];
        else if (key == "MakeSkew")
            makeSkew = HoughDeskewOptionMap[rhs[i+1].toString()];
        else if (key == "Rules")
            rules = RulesOptionMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Point houghPoint(rhs[0].toPoint());
    Mat src(rhs[1].toMat());
    Vec4i line = HoughPoint2Line(houghPoint, src, angleRange, makeSkew, rules);
    plhs[0] = MxArray(line);
}
