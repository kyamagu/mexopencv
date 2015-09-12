/**
 * @file minEnclosingTriangle.cpp
 * @brief mex interface for cv::minEnclosingTriangle
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
    nargchk(nrhs==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    vector<Point2f> triangle;
    double area = 0;
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(CV_32F).reshape(2,0));
        area = minEnclosingTriangle(points, triangle);
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> points(rhs[0].toVector<Point2f>());
        area = minEnclosingTriangle(points, triangle);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(triangle);
    if (nlhs>1)
        plhs[1] = MxArray(area);
}
