/**
 * @file ellipse2Poly.cpp
 * @brief mex interface for cv::ellipse2Poly
 * @ingroup imgproc
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int angle = 0;
    int arcStart = 0;
    int arcEnd = 360;
    int delta = 5;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Angle")
            angle = rhs[i+1].toInt();
        else if (key=="StartAngle")
            arcStart = rhs[i+1].toInt();
        else if (key=="EndAngle")
            arcEnd = rhs[i+1].toInt();
        else if (key=="Delta")
            delta = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Point center(rhs[0].toPoint());
    Size axes(rhs[1].toSize());
    vector<Point> pts;
    ellipse2Poly(center, axes, angle, arcStart, arcEnd, delta, pts);
    plhs[0] = MxArray(pts);
}
