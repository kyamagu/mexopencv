/**
 * @file filter2D.cpp
 * @brief mex interface for cv::filter2D
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
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
    int ddepth = -1;
    Point anchor(-1,-1);
    double delta = 0;
    int borderType = cv::BORDER_DEFAULT;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key=="DDepth")
            ddepth = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Delta")
            delta = rhs[i+1].toDouble();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat()), dst,
        kernel(rhs[1].toMat());
    filter2D(src, dst, ddepth, kernel, anchor, delta, borderType);
    plhs[0] = MxArray(dst);
}
