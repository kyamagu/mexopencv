/**
 * @file norm.cpp
 * @brief mex interface for cv::norm
 * @ingroup core
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

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
    nargchk(nrhs>=1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // cv::norm has two overloaded variants
    bool diff_variant = (nrhs>1 && rhs[1].isNumeric());
    nargchk((nrhs%2) == (diff_variant ? 0 : 1));

    // Option processing
    int normType = cv::NORM_L2;
    bool relative = false;
    Mat mask;
    for (int i=(diff_variant ? 2 : 1); i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "NormType")
            normType = NormType[rhs[i+1].toString()];
        else if (key == "Relative")
            relative = rhs[i+1].toBool();
        else if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    normType |= (relative ? cv::NORM_RELATIVE : 0);

    // Process
    double nrm;
    Mat src1(rhs[0].toMat());
    if (diff_variant) {
        Mat src2(rhs[1].toMat());
        nrm = norm(src1, src2, normType, mask);
    }
    else
        nrm = norm(src1, normType, mask);
    plhs[0] = MxArray(nrm);
}
