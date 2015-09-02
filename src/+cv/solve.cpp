/**
 * @file solve.cpp
 * @brief mex interface for cv::solve
 * @ingroup core
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// matrix decomposition types for option processing
const ConstMap<string,int> DecompTypesMap = ConstMap<string,int>
    ("LU",       cv::DECOMP_LU)
    ("SVD",      cv::DECOMP_SVD)
    ("EIG",      cv::DECOMP_EIG)
    ("Cholesky", cv::DECOMP_CHOLESKY)
    ("QR",       cv::DECOMP_QR);
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = cv::DECOMP_LU;
    bool is_normal = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Method")
            flags = DecompTypesMap[rhs[i+1].toString()];
        else if (key == "IsNormal")
            is_normal = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    flags |= (is_normal ? cv::DECOMP_NORMAL : 0);

    // Process
    Mat src1(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        src2(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        dst;
    bool ret = solve(src1, src2, dst, flags);
    plhs[0] = MxArray(dst);
    if (nlhs > 1)
        plhs[1] = MxArray(ret);
}
