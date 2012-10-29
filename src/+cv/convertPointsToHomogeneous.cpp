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
        convertPointsToHomogeneous(src,dst);
        plhs[0] = MxArray(dst);
    }
    else if (rhs[0].isCell()) {
        vector<MxArray> _src(rhs[0].toVector<MxArray>());
        int n = _src[0].numel();
        if (n==2) {
            vector<Point2f> src(rhs[0].toVector<Point2f>());
            vector<Point3f> dst;
            dst.reserve(src.size());
            convertPointsToHomogeneous(src, dst);
            plhs[0] = MxArray(dst);
        }
        else if (n==3) {
            vector<Point3f> src(rhs[0].toVector<Point3f>());
            vector<Vec4f> dst;
            convertPointsToHomogeneous(src, dst);
            vector<Mat> _dst;
            _dst.reserve(dst.size());
            for (vector<Vec4f>::iterator it=dst.begin(); it<dst.end(); ++it)
                _dst.push_back(Mat(*it));
            plhs[0] = MxArray(_dst);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    
}
