/**
 * @file triangulatePoints.cpp
 * @brief mex interface for cv::triangulatePoints
 * @ingroup calib3d
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
    nargchk(nrhs==4 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat projMatr1(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        projMatr2(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        points4D;
    if (rhs[2].isNumeric() && rhs[3].isNumeric()) {
        Mat projPoints1(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
            projPoints2(rhs[3].toMat(rhs[3].isSingle() ? CV_32F : CV_64F));
        triangulatePoints(projMatr1, projMatr2, projPoints1, projPoints2,
            points4D);
    }
    else if (rhs[2].isCell() && rhs[3].isCell()) {
        vector<Point2d> projPoints1(rhs[2].toVector<Point2d>()),
                        projPoints2(rhs[3].toVector<Point2d>());
        triangulatePoints(projMatr1, projMatr2, projPoints1, projPoints2,
            points4D);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(points4D);  // 4xN
}
