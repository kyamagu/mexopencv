/**
 * @file convexHull.cpp
 * @brief mex interface for cv::convexHull
 * @ingroup imgproc
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool clockwise = false;
    bool returnPoints = true;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Clockwise")
            clockwise = rhs[i+1].toBool();
        else if (key=="ReturnPoints")
            returnPoints = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_32S));
        Mat hull;  // either points or indices depending on returnPoints
        convexHull(points, hull, clockwise, returnPoints);
        plhs[0] = MxArray(hull.reshape(1,0));  // Nx2 or Nx1
    }
    else if (rhs[0].isCell()) {
        vector<Point> points(rhs[0].toVector<Point>());
        if (returnPoints) {
            vector<Point> hull;
            convexHull(points, hull, clockwise, returnPoints);
            plhs[0] = MxArray(hull);
        }
        else {
            vector<int> hull;
            convexHull(points, hull, clockwise, returnPoints);
            plhs[0] = MxArray(hull);
        }
    }
}
