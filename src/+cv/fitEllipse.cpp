/**
 * @file fitEllipse.cpp
 * @brief mex interface for cv::fitEllipse
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
    RotatedRect r;
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(rhs[0].isInt32() ? CV_32S : CV_32F));
        r = fitEllipse(points);
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> points(rhs[0].toVector<Point2f>());
        r = fitEllipse(points);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(r);
}
