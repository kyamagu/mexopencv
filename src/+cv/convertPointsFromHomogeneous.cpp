/**
 * @file convertPointsFromHomogeneous.cpp
 * @brief mex interface for cv::convertPointsFromHomogeneous
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
        // input is Nx3/Nx1x3/1xNx3 or Nx4/Nx1x4/1xNx4 matrix
        Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)), dst;
        bool cn1 = (src.channels() == 1);
        convertPointsFromHomogeneous(src, dst);
        if (cn1) dst = dst.reshape(1,0);// N-by-(2/3) numeric matrix
        plhs[0] = MxArray(dst);
    }
    else if (rhs[0].isCell() && !rhs[0].isEmpty()) {
        mwSize dims = rhs[0].at<MxArray>(0).numel();
        if (dims == 3) {
            // input is cell array {[x,y,z], [x,y,z], ..}
            vector<Point3d> src(rhs[0].toVector<Point3d>());
            vector<Point2d> dst;
            convertPointsFromHomogeneous(src, dst);
            plhs[0] = MxArray(dst);  // 1xN cell-array {[x,y], ...}
            //plhs[0] = MxArray(Mat(dst,false).reshape(1,0));  // N-by-2 numeric matrix
        }
        else if (dims == 4) {
            // input is cell array {[x,y,z,w], [x,y,z,w], ..}
            //vector<Vec4d> src(rhs[0].toVector<Vec4d>());
            vector<Vec4d> src(MxArrayToVectorVec<double,4>(rhs[0]));
            vector<Point3d> dst;
            convertPointsFromHomogeneous(src, dst);
            plhs[0] = MxArray(dst);  // 1xN cell-array {[x,y,z], ...}
            //plhs[0] = MxArray(Mat(dst,false).reshape(1,0));  // N-by-3 numeric matrix
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
}
