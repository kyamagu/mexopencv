/**
 * @file getRotationMatrix2D.cpp
 * @brief mex interface for getRotationMatrix2D
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
    if (nrhs!=3 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    if (!rhs[0].isNumeric() || rhs[0].numel()!=2 ||
        !rhs[1].isNumeric() || rhs[1].numel()!=1 ||
        !rhs[2].isNumeric() || rhs[2].numel()!=1)
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    
    // Process
    Point2f center = rhs[0].toPoint_<float>();
    double angle = rhs[1].toDouble();
    double scale = rhs[2].toDouble();
    Mat t = getRotationMatrix2D(center, angle, scale);
    plhs[0] = MxArray(t);
}
