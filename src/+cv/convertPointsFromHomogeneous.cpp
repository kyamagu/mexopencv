/**
 * @file convertPointsFromHomogeneous.cpp
 * @brief mex interface for convertPointsFromHomogeneous
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
        convertPointsFromHomogeneous(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (rhs[0].isCell()) {
        vector<MxArray> _src(rhs[0].toVector<MxArray>());
        if (_src.empty())
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
        int n = _src[0].numel();
        if (n==3) {
            vector<Point3f> src(rhs[0].toVector<Point3f>());
            vector<Point2f> dst;
            convertPointsFromHomogeneous(src, dst);
            plhs[0] = MxArray(dst);
        }
        else if (n==4) {
            vector<Vec4f> src;
            src.reserve(_src.size());
            for (vector<MxArray>::iterator it=_src.begin(); it<_src.end(); ++it)
                src.push_back(Vec4f((*it).at<float>(0),(*it).at<float>(1),
                                (*it).at<float>(2),(*it).at<float>(3)));
            vector<Point3f> dst;
            convertPointsFromHomogeneous(src, dst);
            plhs[0] = MxArray(dst);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    
}
