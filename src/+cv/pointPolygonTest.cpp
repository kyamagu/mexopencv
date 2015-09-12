/**
 * @file pointPolygonTest.cpp
 * @brief mex interface for cv::pointPolygonTest
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2013
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
    bool measureDist = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="MeasureDist")
            measureDist = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    double result = 0;
    Point2f pt(rhs[1].toPoint2f());
    if (rhs[0].isNumeric()) {
        Mat contour(rhs[0].toMat(rhs[0].isInt32() ? CV_32S : CV_32F));
        result = pointPolygonTest(contour, pt, measureDist);
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> contour(rhs[0].toVector<Point2f>());
        result = pointPolygonTest(contour, pt, measureDist);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(result);
}
