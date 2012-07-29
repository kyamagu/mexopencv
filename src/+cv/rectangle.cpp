/**
 * @file rectangle.cpp
 * @brief mex interface for rectangle
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
    if (nrhs<2 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    bool _arg_format = (nrhs%2)==0;
    
    // Option processing
    Mat img = rhs[0].toMat();
    Scalar color;
    int thickness=1;
    int lineType=8;
    int shift=0;
    for (int i=(_arg_format)?2:3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="Thickness")
            thickness = rhs[i+1].toInt();
        else if (key=="LineType")
            lineType = (rhs[i+1].isChar()) ?
                LineType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Shift")
            shift = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Execute function
    if (!_arg_format) {
        Point pt1(rhs[1].toPoint()), pt2(rhs[2].toPoint());
        rectangle(img, pt1, pt2, color, thickness, lineType, shift);
    }
    else {
        Rect r(rhs[1].toRect());
        rectangle(img, r, color, thickness, lineType, shift);
    }
    plhs[0] = MxArray(img);
}
