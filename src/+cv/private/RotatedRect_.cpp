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
    nargchk(nrhs>=1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());

    if (method == "from3points") {
        nargchk(nrhs==4 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 2 &&
            rhs[2].isNumeric() && rhs[2].numel() == 2 &&
            rhs[3].isNumeric() && rhs[3].numel() == 2) {
            Point2f pt1(rhs[1].toPoint2f()),
                    pt2(rhs[2].toPoint2f()),
                    pt3(rhs[3].toPoint2f());
            plhs[0] = MxArray(RotatedRect(pt1, pt2, pt3));
        }
        else {
            vector<Point2f> pts1(rhs[1].toVector<Point2f>()),
                            pts2(rhs[2].toVector<Point2f>()),
                            pts3(rhs[3].toVector<Point2f>());
            if (pts1.size() != pts2.size() || pts1.size() != pts3.size())
                mexErrMsgIdAndTxt("mexopencv:error", "Length mismatch");
            vector<RotatedRect> rrects;
            rrects.reserve(pts1.size());
            for (size_t i = 0; i < pts1.size(); ++i)
                rrects.push_back(RotatedRect(pts1[i], pts2[i], pts3[i]));
            plhs[0] = MxArray(rrects);
        }
    }
    else if (method == "points") {
        nargchk(nrhs==2 && nlhs<=1);
        Point2f pts[4];
        if (rhs[1].numel() == 1) {
            RotatedRect rrect(rhs[1].toRotatedRect());
            rrect.points(pts);
            plhs[0] = MxArray(Mat(4, 2, CV_32F, pts));  // 4x2 matrix
        }
        else {
            vector<RotatedRect> rrects(rhs[1].toVector<RotatedRect>());
            vector<Mat> vvp;
            vvp.reserve(rrects.size());
            for (size_t i = 0; i < rrects.size(); ++i) {
                rrects[i].points(pts);
                vvp.push_back(Mat(4, 2, CV_32F, pts).clone());
            }
            plhs[0] = MxArray(vvp);  // cell array of 4x2 matrices
        }
    }
    else if (method == "boundingRect") {
        nargchk(nrhs==2 && nlhs<=1);
        if (rhs[1].numel() == 1) {
            RotatedRect rrect(rhs[1].toRotatedRect());
            Rect r = rrect.boundingRect();
            plhs[0] = MxArray(r);
        }
        else {
            vector<RotatedRect> rrects(rhs[1].toVector<RotatedRect>());
            vector<Rect> vr;
            vr.reserve(rrects.size());
            for (size_t i = 0; i < rrects.size(); ++i)
                vr.push_back(rrects[i].boundingRect());
            plhs[0] = MxArray(Mat(vr, false).reshape(1, 0));
        }
    }
    else if (method == "boundingRect2f") {
        nargchk(nrhs==2 && nlhs<=1);
        if (rhs[1].numel() == 1) {
            RotatedRect rrect(rhs[1].toRotatedRect());
            Rect2f r = rrect.boundingRect2f();
            plhs[0] = MxArray(r);
        }
        else {
            vector<RotatedRect> rrects(rhs[1].toVector<RotatedRect>());
            vector<Rect2f> vr;
            vr.reserve(rrects.size());
            for (size_t i = 0; i < rrects.size(); ++i)
                vr.push_back(rrects[i].boundingRect2f());
            plhs[0] = MxArray(Mat(vr, false).reshape(1, 0));
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
