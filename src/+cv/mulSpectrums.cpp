/**
 * @file mulSpectrums.cpp
 * @brief mex interface for cv::mulSpectrums
 * @ingroup core
 * @author Amro
 * @date 2017
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = 0;
    bool conjB = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Rows")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_ROWS);
        else if (key == "ConjB")
            conjB = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat a(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        b(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        c;
    mulSpectrums(a, b, c, flags, conjB);
    plhs[0] = MxArray(c);
}
