/**
 * @file perspectiveTransform.cpp
 * @brief mex interface for cv::perspectiveTransform
 * @ingroup core
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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat mtx(rhs[1].toMat(CV_64F));
    if (rhs[0].isNumeric()) {
        Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)), dst;
        bool cn1 = (src.channels() == 1 && (src.cols == 2 || src.cols == 3));
        if (cn1) src = src.reshape(src.cols, 0);  // Nx2/Nx3 -> Nx1x2/Nx1x3
        perspectiveTransform(src, dst, mtx);
        if (cn1) dst = dst.reshape(1, 0);         // Nx1x2/Nx1x3 -> Nx2/Nx3
        plhs[0] = MxArray(dst);
    }
    else if (rhs[0].isCell() && !rhs[0].isEmpty()) {
        mwSize n = rhs[0].at<MxArray>(0).numel();
        if (n == 2) {
            vector<Point2f> src(rhs[0].toVector<Point2f>()), dst;
            perspectiveTransform(src, dst, mtx);
            plhs[0] = MxArray(dst);
        }
        else if (n == 3) {
            vector<Point3f> src(rhs[0].toVector<Point3f>()), dst;
            perspectiveTransform(src, dst, mtx);
            plhs[0] = MxArray(dst);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
}
