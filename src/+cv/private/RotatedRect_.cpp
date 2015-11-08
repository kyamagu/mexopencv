/**
 * @file RotatedRect_.cpp
 * @brief mex interface for cv::RotatedRect
 * @ingroup core
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());

    if (method == "points") {
        nargchk(nrhs==2 && nlhs<=1);
        RotatedRect rect(rhs[1].toRotatedRect());
        Point2f pt[4];
        rect.points(pt);
        vector<Point2f> v(pt, pt+4);
        plhs[0] = MxArray(Mat(v).reshape(1,0));
    }
    else if (method == "boundingRect") {
        nargchk(nrhs==2 && nlhs<=1);
        RotatedRect rect(rhs[1].toRotatedRect());
        Rect r = rect.boundingRect();
        plhs[0] = MxArray(r);
    }
    else if (method == "from3points") {
        nargchk(nrhs==4 && nlhs<=1);
        Point2f pt1(rhs[1].toPoint2f()),
                pt2(rhs[2].toPoint2f()),
                pt3(rhs[3].toPoint2f());
        plhs[0] = MxArray(RotatedRect(pt1, pt2, pt3));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized method %s", method.c_str());
}
