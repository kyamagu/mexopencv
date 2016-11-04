/**
 * @file Rect_.cpp
 * @brief mex interface for cv::Rect
 * @ingroup core
 * @author Amro
 * @date 2016
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
    nargchk(nrhs>=1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());

    if (method == "from2points") {
        nargchk(nrhs==3 && nlhs<=1);
        Point_<double> pt1(rhs[1].toPoint_<double>()),
                       pt2(rhs[2].toPoint_<double>());
        Rect_<double> rect(pt1, pt2);
        plhs[0] = MxArray(rect);

    }
    else if (method == "tl") {
        nargchk(nrhs==2 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        Point_<double> pt = rect.tl();
        plhs[0] = MxArray(pt);  // 1x2 vector [x,y]
    }
    else if (method == "br") {
        nargchk(nrhs==2 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        Point_<double> pt = rect.br();
        plhs[0] = MxArray(pt);  // 1x2 vector [x,y]
    }
    else if (method == "size") {
        nargchk(nrhs==2 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        Size_<double> sz = rect.size();
        plhs[0] = MxArray(sz);  // 1x2 vector [w,h]
    }
    else if (method == "area") {
        nargchk(nrhs==2 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        double a = rect.area();
        plhs[0] = MxArray(a);
    }
    else if (method == "contains") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        Point_<double> pt(rhs[2].toPoint_<double>());
        plhs[0] = MxArray(rect.contains(pt));
    }
    else if (method == "adjustPosition") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        Point_<double> pt(rhs[2].toPoint_<double>());
        rect += pt;
        plhs[0] = MxArray(rect);
    }
    else if (method == "adjustSize") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect_<double> rect(rhs[1].toRect_<double>());
        Size_<double> sz(rhs[2].toSize_<double>());
        rect += sz;
        plhs[0] = MxArray(rect);
    }
    else if (method == "intersect") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect_<double> rect1(rhs[1].toRect_<double>()),
                      rect2(rhs[2].toRect_<double>());
        rect1 &= rect2;
        plhs[0] = MxArray(rect1);
    }
    else if (method == "union") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect_<double> rect1(rhs[1].toRect_<double>()),
                      rect2(rhs[2].toRect_<double>());
        rect1 |= rect2;
        plhs[0] = MxArray(rect1);
    }
    else if (method == "crop") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat img(rhs[1].toMat());
        Rect rect(rhs[2].toRect());
        plhs[0] = MxArray(img(rect).clone());  //HACK: clone was needed here!
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
