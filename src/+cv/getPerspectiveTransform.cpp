/**
 * @file getPerspectiveTransform.cpp
 * @brief mex interface for cv::getPerspectiveTransform
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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat T;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat src(rhs[0].toMat(CV_32F)),
            dst(rhs[1].toMat(CV_32F));
        T = getPerspectiveTransform(src, dst);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> src(rhs[0].toVector<Point2f>()),
                        dst(rhs[1].toVector<Point2f>());
        T = getPerspectiveTransform(src, dst);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    plhs[0] = MxArray(T);
}
