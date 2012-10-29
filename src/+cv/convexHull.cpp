/**
 * @file convexHull.cpp
 * @brief mex interface for convexHull
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
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    bool clockwise=false;
    bool returnPoints=true;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Clockwise")
            clockwise = rhs[i+1].toBool();
        //else if (key=="ReturnPoints")
        //    returnPoints = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(CV_32S));
        vector<Point> hull;
        convexHull(points, hull, clockwise, returnPoints);
        plhs[0] = MxArray(Mat(hull));
    }
    else if (rhs[0].isCell()) {
        vector<Point> points(rhs[0].toVector<Point>());
        vector<Point> hull;
        convexHull(points, hull, clockwise, returnPoints);
        plhs[0] = MxArray(hull);        
    }
}
