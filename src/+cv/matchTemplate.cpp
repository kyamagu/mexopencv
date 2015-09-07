/**
 * @file matchTemplate.cpp
 * @brief mex interface for cv::matchTemplate
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// type of the template matching operation
const ConstMap<string,int> MatchMethod = ConstMap<string,int>
    ("SqDiff",       cv::TM_SQDIFF)
    ("SqDiffNormed", cv::TM_SQDIFF_NORMED)
    ("CCorr",        cv::TM_CCORR)
    ("CCorrNormed",  cv::TM_CCORR_NORMED)
    ("CCoeff",       cv::TM_CCOEFF)
    ("CCoeffNormed", cv::TM_CCOEFF_NORMED);
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
    int method = cv::TM_SQDIFF;
    Mat mask;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Method")
            method = (rhs[i+1].isChar() ?
                MatchMethod[rhs[i+1].toString()] : rhs[i+1].toInt());
        else if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F)),
        templ(rhs[1].toMat(rhs[1].isUint8() ? CV_8U : CV_32F)),
        result;
    matchTemplate(image, templ, result, method, mask);
    plhs[0] = MxArray(result);
}
