/**
 * @file sqrBoxFilter.cpp
 * @brief mex interface for cv::sqrBoxFilter
 * @ingroup imgproc
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int ddepth = -1;
    Size ksize(5,5);
    Point anchor(-1,-1);
    bool normalize = true;
    int borderType = cv::BORDER_DEFAULT;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DDepth")
            ddepth = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "KSize")
            ksize = rhs[i+1].toSize();
        else if (key == "Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key == "Normalize")
            normalize = rhs[i+1].toBool();
        else if (key == "BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat()), dst;
    sqrBoxFilter(src, dst, ddepth, ksize, anchor, normalize, borderType);
    plhs[0] = MxArray(dst);
}
