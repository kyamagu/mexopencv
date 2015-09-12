/**
 * @file rotatedRectangleIntersection.cpp
 * @brief mex interface for cv::rotatedRectangleIntersection
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// types of intersection between rectangles
const ConstMap<int,string> RectIntersectInvMap = ConstMap<int,string>
    (cv::INTERSECT_NONE,    "None")
    (cv::INTERSECT_PARTIAL, "Partial")
    (cv::INTERSECT_FULL,    "Full");
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
    nargchk(nrhs==2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    RotatedRect rect1(rhs[0].toRotatedRect()),
                rect2(rhs[1].toRotatedRect());
    vector<Point2f> intersection;
    int result = rotatedRectangleIntersection(rect1, rect2, intersection);
    plhs[0] = MxArray(intersection);
    if (nlhs > 1)
        plhs[1] = MxArray(RectIntersectInvMap[result]);
}
