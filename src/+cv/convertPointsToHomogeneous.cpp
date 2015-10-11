/**
 * @file convertPointsToHomogeneous.cpp
 * @brief mex interface for cv::convertPointsToHomogeneous
 * @ingroup calib3d
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
    if (rhs[0].isNumeric()) {
        // input is Nx2/Nx1x2/1xNx2 or Nx3/Nx1x3/1xNx3 matrix
        Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)), dst;
        bool cn1 = (src.channels() == 1);
        convertPointsToHomogeneous(src, dst);
        if (cn1) dst = dst.reshape(1,0);  // N-by-(3/4) numeric matrix
        plhs[0] = MxArray(dst);
    }
    else if (rhs[0].isCell() && !rhs[0].isEmpty()) {
        mwSize dim = rhs[0].at<MxArray>(0).numel();
        if (dim == 2) {
            // input is cell array {[x,y], [x,y], ..}
            vector<Point2d> src(rhs[0].toVector<Point2d>());
            vector<Point3d> dst;
            convertPointsToHomogeneous(src, dst);
            plhs[0] = MxArray(dst);  // 1xN cell-array {[x,y,z], ...}
            //plhs[0] = MxArray(Mat(dst,false).reshape(1,0));  // N-by-3 numeric matrix
        }
        else if (dim == 3) {
            // input is cell array {[x,y,z], [x,y,z], ..}
            vector<Point3d> src(rhs[0].toVector<Point3d>());
            vector<Vec4d> dst;
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
