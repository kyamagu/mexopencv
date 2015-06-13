/**
 * @file copyMakeBorder.cpp
 * @brief mex interface for copyMakeBorder
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
    if (nrhs<5 || (nrhs%2)==0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    int borderType = cv::BORDER_DEFAULT;
    Scalar value;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key=="Value")
            value = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat()), dst;
    int top = rhs[1].toInt(),
        bottom = rhs[2].toInt(),
        left = rhs[3].toInt(),
        right = rhs[4].toInt();
    copyMakeBorder(src, dst, top, bottom, left, right, borderType, value);
    plhs[0] = MxArray(dst);
}
