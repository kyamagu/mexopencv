/**
 * @file erode.cpp
 * @brief mex interface for cv::erode
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat kernel;
    Point anchor(-1,-1);
    int iterations = 1;
    int borderType = cv::BORDER_CONSTANT;
    Scalar borderValue = morphologyDefaultBorderValue();
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Element")
            kernel = rhs[i+1].toMat(CV_8U);
        else if (key=="Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key=="Iterations")
            iterations = rhs[i+1].toInt();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key=="BorderValue")
            borderValue = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat()), dst;
    erode(src, dst, kernel, anchor, iterations, borderType, borderValue);
    plhs[0] = MxArray(dst);
}
