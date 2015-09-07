/**
 * @file borderInterpolate.cpp
 * @brief mex interface for cv::borderInterpolate
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int borderType = cv::BORDER_DEFAULT;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    int p = rhs[0].toInt(),
        len = rhs[1].toInt(), loc;
    loc = borderInterpolate(p, len, borderType);
    plhs[0] = MxArray(loc);
}
