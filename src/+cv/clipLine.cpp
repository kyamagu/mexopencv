/**
 * @file clipLine.cpp
 * @brief mex interface for cv::clipLine
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
    nargchk(nrhs==3 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    bool rect_variant = (rhs[0].numel() == 4);

    // Process
    Point pt1(rhs[1].toPoint()), pt2(rhs[2].toPoint());
    bool inside = false;
    if (!rect_variant)
        inside = clipLine(rhs[0].toSize(), pt1, pt2);
    else
        inside = clipLine(rhs[0].toRect(), pt1, pt2);
    plhs[0] = MxArray(inside);
    if (nlhs>1)
        plhs[1] = MxArray(pt1);
    if (nlhs>2)
        plhs[2] = MxArray(pt2);
}
