/**
 * @file addWeighted.cpp
 * @brief mex interface for cv::addWeighted
 * @ingroup core
 * @author Amro
 * @date 2016
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
    nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int dtype = -1;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DType")
            dtype = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src1(rhs[0].toMat()),
        src2(rhs[2].toMat()),
        dst;
    double alpha = rhs[1].toDouble(),
        beta = rhs[3].toDouble(),
        gamma = rhs[4].toDouble();
    addWeighted(src1, alpha, src2, beta, gamma, dst, dtype);
    plhs[0] = MxArray(dst);
}
