/**
 * @file getAffineTransform.cpp
 * @brief mex interface for getAffineTransform
 * @author Kota Yamaguchi
 * @date 2012
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
    if (nrhs!=2 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    if (!rhs[0].isNumeric() || rhs[0].rows()!=3 || rhs[0].cols()!=2 ||
        !rhs[1].isNumeric() || rhs[1].rows()!=3 || rhs[1].cols()!=2)
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    
    // Process
    Point2f src[] = {Point2f(rhs[0].at<float>(0),rhs[0].at<float>(3)),
                     Point2f(rhs[0].at<float>(1),rhs[0].at<float>(4)),
                     Point2f(rhs[0].at<float>(2),rhs[0].at<float>(5))};
    Point2f dst[] = {Point2f(rhs[1].at<float>(0),rhs[1].at<float>(3)),
                     Point2f(rhs[1].at<float>(1),rhs[1].at<float>(4)),
                     Point2f(rhs[1].at<float>(2),rhs[1].at<float>(5))};
    Mat t = getAffineTransform(src, dst);
    plhs[0] = MxArray(t);
}
