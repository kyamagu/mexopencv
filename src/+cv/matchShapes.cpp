/**
 * @file matchShapes.cpp
 * @brief mex interface for cv::matchShapes
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Shape matching methods for option processing
const ConstMap<string,int> ShapeMatchMethodsMap = ConstMap<string,int>
    ("I1", CV_CONTOURS_MATCH_I1)
    ("I2", CV_CONTOURS_MATCH_I2)
    ("I3", CV_CONTOURS_MATCH_I3);
}

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
    int method = CV_CONTOURS_MATCH_I1;
    double parameter = 0;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Method")
            method = ShapeMatchMethodsMap[rhs[i+1].toString()];
        else if (key=="Parameter")
            parameter = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    double result = 0;
    if ((rhs[0].isNumeric() || rhs[0].isLogical()) &&
        (rhs[1].isNumeric() || rhs[1].isLogical())) {
        Mat contour1(rhs[0].toMat()), // CV_8U, CV_16U, CV_16S, CV_32F, CV_64F
            contour2(rhs[1].toMat());
        result = matchShapes(contour1, contour2, method, parameter);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> contour1(rhs[0].toVector<Point2f>()),
                        contour2(rhs[1].toVector<Point2f>());
        result = matchShapes(contour1, contour2, method, parameter);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(result);
}
