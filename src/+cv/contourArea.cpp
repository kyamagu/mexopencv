/**
 * @file contourArea.cpp
 * @brief mex interface for cv::contourArea
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
    bool oriented = false;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Oriented")
            oriented = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    double a = 0;
    if (rhs[0].isNumeric()) {
        Mat curve(rhs[0].toMat(CV_32F));
        a = contourArea(curve, oriented);
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> curve(rhs[0].toVector<Point2f>());
        a = contourArea(curve, oriented);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(a);
}
