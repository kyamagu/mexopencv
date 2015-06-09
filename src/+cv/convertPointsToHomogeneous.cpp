/**
 * @file convertPointsToHomogeneous.cpp
 * @brief mex interface for convertPointsToHomogeneous
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Process
    if (rhs[0].isNumeric()) {
        Mat src(rhs[0].toMat(CV_32F)), dst;
        convertPointsToHomogeneous(src, dst);
        plhs[0] = MxArray(dst.reshape(1,0));  // N-by-(3/4) numeric matrix
    }
    else if (rhs[0].isCell() && !rhs[0].isEmpty()) {
        mwSize n = rhs[0].at<MxArray>(0).numel();
        if (n==2) {
            vector<Point2f> src(rhs[0].toVector<Point2f>());
            vector<Point3f> dst;
            convertPointsToHomogeneous(src, dst);
            plhs[0] = MxArray(dst);  // 1xN cell-array {[x,y,z], ...}
            //plhs[0] = MxArray(Mat(dst,false).reshape(1,0));  // N-by-3 numeric matrix
        }
        else if (n==3) {
            vector<Point3f> src(rhs[0].toVector<Point3f>());
            vector<Vec4f> dst;
            convertPointsToHomogeneous(src, dst);
            plhs[0] = MxArray(dst);  // 1xN cell-array {[x,y,z,w], ...}
            //plhs[0] = MxArray(Mat(dst, false).reshape(1, 0));  // N-by-4 numeric matrix
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");

}
