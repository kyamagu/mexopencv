/**
 * @file ellipse.cpp
 * @brief mex interface for ellipse
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
    if (nrhs<3 || (nrhs%2)!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat img = rhs[0].toMat();
    Point center = rhs[1].toPoint();
    Size axes = rhs[2].toSize();
    double angle=0;
    double startAngle=0;
    double endAngle=360;
    Scalar color;
    int thickness=1;
    int lineType=8;
    int shift=0;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Angle")
            angle = rhs[i+1].toDouble();
        else if (key=="StartAngle")
            startAngle = rhs[i+1].toDouble();
        else if (key=="EndAngle")
            endAngle = rhs[i+1].toDouble();
        else if (key=="Color")
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
    ellipse(img, center, axes, angle, startAngle, endAngle, color, thickness,
        lineType, shift);
    plhs[0] = MxArray(img);
}
