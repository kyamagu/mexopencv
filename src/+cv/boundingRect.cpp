/**
 * @file boundingRect.cpp
 * @brief mex interface for cv::boundingRect
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
    nargchk(nrhs==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Rect r;
    if (rhs[0].isNumeric() || rhs[0].isLogical()) {
        // points or mask
        Mat curve(rhs[0].toMat(
            rhs[0].isUint8() || rhs[0].isLogical() ? CV_8U :
            (rhs[0].isFloat() ? CV_32F : CV_32S)));
        r = boundingRect(curve);
    }
    else if (rhs[0].isCell()) {
        // points
        if (!rhs[0].isEmpty() && rhs[0].at<MxArray>(0).isFloat()) {
            vector<Point2f> curve(rhs[0].toVector<Point2f>());
            r = boundingRect(curve);
        }
        else {
            vector<Point> curve(rhs[0].toVector<Point>());
            r = boundingRect(curve);
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(r);
}
