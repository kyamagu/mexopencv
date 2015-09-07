/**
 * @file invert.cpp
 * @brief mex interface for cv::invert
 * @ingroup core
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Inversion Methods
const ConstMap<string,int> InvMethods = ConstMap<string,int>
    ("LU",       cv::DECOMP_LU)
    ("SVD",      cv::DECOMP_SVD)
    ("EIG",      cv::DECOMP_EIG)
    ("Cholesky", cv::DECOMP_CHOLESKY);
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int method = cv::DECOMP_LU;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Method")
            method = InvMethods[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)), dst;
    double d = invert(src, dst, method);
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(d);
}
