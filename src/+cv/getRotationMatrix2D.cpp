/**
 * @file getRotationMatrix2D.cpp
 * @brief mex interface for cv::getRotationMatrix2D
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
    nargchk(nrhs==3 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Point2f center(rhs[0].toPoint2f());
    double angle = rhs[1].toDouble(),
           scale = rhs[2].toDouble();
    Mat M = getRotationMatrix2D(center, angle, scale);
    plhs[0] = MxArray(M);
}
