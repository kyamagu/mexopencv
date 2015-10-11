/**
 * @file intersectConvexConvex.cpp
 * @brief mex interface for cv::intersectConvexConvex
 * @ingroup imgproc
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool handleNested = true;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "HandleNested")
            handleNested = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Point2f> p1(rhs[0].toVector<Point2f>()),
                    p2(rhs[1].toVector<Point2f>()),
                    p12;
    float area = intersectConvexConvex(p1, p2, p12, handleNested);
    plhs[0] = MxArray(p12);
    if (nlhs > 1)
        plhs[1] = MxArray(area);
}
