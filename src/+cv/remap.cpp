/**
 * @file remap.cpp
 * @brief mex interface for cv::remap
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Decide argument format
    bool separate_variant = (nrhs>=3 && rhs[2].isNumeric());
    nargchk((nrhs%2) == (separate_variant ? 1 : 0));

    // Option processing
    Mat dst;
    int interpolation = cv::INTER_LINEAR;
    int borderMode = cv::BORDER_CONSTANT;
    Scalar borderValue;
    for (int i=(separate_variant ? 3 : 2); i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Dst")
            dst = rhs[i+1].toMat();
        else if (key=="Interpolation")
            interpolation = (rhs[i+1].isChar()) ?
                InterpType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="BorderType")
            borderMode = (rhs[i+1].isChar()) ?
                BorderType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="BorderValue")
            borderValue = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat()),
        map1(rhs[1].toMat(rhs[1].isInt16() ? CV_16S : CV_32F)),
        map2;
    if (separate_variant)
        map2 = rhs[2].toMat(rhs[2].isUint16() ? CV_16U : CV_32F);
    remap(src, dst, map1, map2, interpolation, borderMode, borderValue);
    plhs[0] = MxArray(dst);
}
