/**
 * @file ellipse2Poly.cpp
 * @brief mex interface for ellipse2Poly
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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int angle=0;
    int startAngle=0;
    int endAngle=360;
    int delta=5;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Angle")
            angle = rhs[i+1].toInt();
        else if (key=="StartAngle")
            startAngle = rhs[i+1].toInt();
        else if (key=="EndAngle")
            endAngle = rhs[i+1].toInt();
        else if (key=="Delta")
            delta = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Execute function
    Point center(rhs[0].toPoint());
    Size axes(rhs[1].toSize());
    vector<Point> pts;
    ellipse2Poly(center, axes, angle, startAngle, endAngle, delta, pts);
    plhs[0] = MxArray(pts);
}
