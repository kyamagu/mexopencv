/**
 * @file correctMatches.cpp
 * @brief mex interface for cv::correctMatches
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
    nargchk(nrhs==3 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat F(rhs[0].toMat(CV_64F));
    if (rhs[1].isNumeric() && rhs[2].isNumeric()) {
        Mat points1(rhs[1].toMat(CV_64F)),
            points2(rhs[2].toMat(CV_64F)),
            newPoints1, newPoints2;
        correctMatches(F, points1.reshape(2,1), points2.reshape(2,1),
            newPoints1, newPoints2);  // function requires 1xNx2 input points
        if (points1.channels() == 1)  // 1xNx2 -> Nx2 (to match input)
            newPoints1 = newPoints1.reshape(1, newPoints1.cols);
        if (points2.channels() == 1)
            newPoints2 = newPoints2.reshape(1, newPoints2.cols);
        plhs[0] = MxArray(newPoints1);
        if (nlhs > 1)
            plhs[1] = MxArray(newPoints2);
    }
    else if (rhs[1].isCell() && rhs[2].isCell()) {
        vector<Point2d> points1(rhs[1].toVector<Point2d>()),
                        points2(rhs[2].toVector<Point2d>()),
                        newPoints1, newPoints2;
        correctMatches(F, points1, points2, newPoints1, newPoints2);
        plhs[0] = MxArray(newPoints1);
        if (nlhs > 1)
            plhs[1] = MxArray(newPoints2);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
}
