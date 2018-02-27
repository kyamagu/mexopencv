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
        if (rhs[1].isNumeric() && rhs[1].numel() == 2 &&
            rhs[2].isNumeric() && rhs[2].numel() == 2) {
            Point2d pt1(rhs[1].toPoint_<double>()),
                    pt2(rhs[2].toPoint_<double>());
            Rect2d rect(pt1, pt2);
            plhs[0] = MxArray(rect);
        }
        else {
            vector<Point2d> pts1(rhs[1].toVector<Point2d>()),
                            pts2(rhs[2].toVector<Point2d>());
            if (pts1.size() != pts2.size())
                mexErrMsgIdAndTxt("mexopencv:error", "Length mismatch");
            vector<Rect2d> rects;
            rects.reserve(pts1.size());
            for (size_t i = 0; i < pts1.size(); ++i)
                rects.push_back(Rect2d(pts1[i], pts2[i]));
            plhs[0] = (rhs[1].isCell() && rhs[2].isCell()) ?
                MxArray(rects) : MxArray(Mat(rects, false).reshape(1, 0));
        }
    }
    else if (method == "tl") {
        nargchk(nrhs==2 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4) {
            Rect2d rect(rhs[1].toRect_<double>());
            Point2d pt = rect.tl();
            plhs[0] = MxArray(pt);  // 1x2 vector [x,y]
        }
        else {
            vector<Rect2d> rects(MxArrayToVectorRect<double>(rhs[1]));
            vector<Point2d> pts;
            pts.reserve(rects.size());
            for (size_t i = 0; i < rects.size(); ++i)
                pts.push_back(rects[i].tl());
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(pts) : MxArray(Mat(pts, false).reshape(1, 0));
        }
    }
    else if (method == "br") {
        nargchk(nrhs==2 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4) {
            Rect2d rect(rhs[1].toRect_<double>());
            Point2d pt = rect.br();
            plhs[0] = MxArray(pt);  // 1x2 vector [x,y]
        }
        else {
            vector<Rect2d> rects(MxArrayToVectorRect<double>(rhs[1]));
            vector<Point2d> pts;
            pts.reserve(rects.size());
            for (size_t i = 0; i < rects.size(); ++i)
                pts.push_back(rects[i].br());
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(pts) : MxArray(Mat(pts, false).reshape(1, 0));
        }
    }
    else if (method == "size") {
        nargchk(nrhs==2 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4) {
            Rect2d rect(rhs[1].toRect_<double>());
            Size2d sz = rect.size();
            plhs[0] = MxArray(sz);  // 1x2 vector [w,h]
        }
        else {
            vector<Rect2d> rects(MxArrayToVectorRect<double>(rhs[1]));
            vector<Size2d> sz;
            sz.reserve(rects.size());
            for (size_t i = 0; i < rects.size(); ++i)
                sz.push_back(rects[i].size());
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(sz) : MxArray(Mat(sz, false).reshape(1, 0));
        }
    }
    else if (method == "area") {
        nargchk(nrhs==2 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4) {
            Rect2d rect(rhs[1].toRect_<double>());
            double a = rect.area();
            plhs[0] = MxArray(a);
        }
        else {
            vector<Rect2d> rects(MxArrayToVectorRect<double>(rhs[1]));
            vector<double> va;
            va.reserve(rects.size());
            for (size_t i = 0; i < rects.size(); ++i)
                va.push_back(rects[i].area());
            plhs[0] = MxArray(va);
        }
    }
    else if (method == "contains") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect2d rect(rhs[1].toRect_<double>());
        if (rhs[2].isNumeric() && rhs[2].numel() == 2) {
            Point2d pt(rhs[2].toPoint_<double>());
            plhs[0] = MxArray(rect.contains(pt));
        }
        else {
            vector<Point2d> pts(rhs[2].toVector<Point2d>());
            vector<bool> vb;
            vb.reserve(pts.size());
            for (size_t i = 0; i < pts.size(); ++i)
                vb.push_back(rect.contains(pts[i]));
            plhs[0] = MxArray(vb);
        }
    }
    else if (method == "adjustPosition") {
        nargchk(nrhs==3 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4 &&
            rhs[2].isNumeric() && rhs[2].numel() == 2) {
            Rect2d rect(rhs[1].toRect_<double>());
            Point2d pt(rhs[2].toPoint_<double>());
            rect += pt;
            plhs[0] = MxArray(rect);
        }
        else {
            vector<Rect2d> rects(MxArrayToVectorRect<double>(rhs[1]));
            if (rhs[2].isNumeric() && rhs[2].numel() == 2) {
                Point2d pt(rhs[2].toPoint_<double>());
                for (size_t i = 0; i < rects.size(); ++i)
                    rects[i] += pt;
            }
            else {
                vector<Point2d> pts(rhs[2].toVector<Point2d>());
                if (rects.size() != pts.size())
                    mexErrMsgIdAndTxt("mexopencv:error", "Length mismatch");
                for (size_t i = 0; i < rects.size(); ++i)
                    rects[i] += pts[i];
            }
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(rects) : MxArray(Mat(rects, false).reshape(1, 0));
        }
    }
    else if (method == "adjustSize") {
        nargchk(nrhs==3 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4 &&
            rhs[2].isNumeric() && rhs[2].numel() == 2) {
            Rect2d rect(rhs[1].toRect_<double>());
            Size2d sz(rhs[2].toSize_<double>());
            rect += sz;
            plhs[0] = MxArray(rect);
        }
        else {
            vector<Rect2d> rects(MxArrayToVectorRect<double>(rhs[1]));
            if (rhs[2].isNumeric() && rhs[2].numel() == 2) {
                Size2d sz(rhs[2].toSize_<double>());
                for (size_t i = 0; i < rects.size(); ++i)
                    rects[i] += sz;
            }
            else {
                vector<Size2d> sz(MxArrayToVectorSize<double>(rhs[2]));
                if (rects.size() != sz.size())
                    mexErrMsgIdAndTxt("mexopencv:error", "Length mismatch");
                for (size_t i = 0; i < rects.size(); ++i)
                    rects[i] += sz[i];
            }
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(rects) : MxArray(Mat(rects, false).reshape(1, 0));
        }
    }
    else if (method == "intersect") {
        nargchk(nrhs==3 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4 &&
            rhs[2].isNumeric() && rhs[2].numel() == 4) {
            Rect2d rect1(rhs[1].toRect_<double>()),
                   rect2(rhs[2].toRect_<double>());
            rect1 &= rect2;
            plhs[0] = MxArray(rect1);
        }
        else {
            vector<Rect2d> rects1(MxArrayToVectorRect<double>(rhs[1]));
            if (rhs[2].isNumeric() && rhs[2].numel() == 4) {
                Rect2d rect2(rhs[2].toRect_<double>());
                for (size_t i = 0; i < rects1.size(); ++i)
                    rects1[i] &= rect2;
            }
            else {
                vector<Rect2d> rects2(MxArrayToVectorRect<double>(rhs[2]));
                if (rects1.size() != rects2.size())
                    mexErrMsgIdAndTxt("mexopencv:error", "Length mismatch");
                for (size_t i = 0; i < rects1.size(); ++i)
                    rects1[i] &= rects2[i];
            }
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(rects1) : MxArray(Mat(rects1, false).reshape(1, 0));
        }
    }
    else if (method == "union") {
        nargchk(nrhs==3 && nlhs<=1);
        if (rhs[1].isNumeric() && rhs[1].numel() == 4 &&
            rhs[2].isNumeric() && rhs[2].numel() == 4) {
            Rect2d rect1(rhs[1].toRect_<double>()),
                   rect2(rhs[2].toRect_<double>());
            rect1 |= rect2;
            plhs[0] = MxArray(rect1);
        }
        else {
            vector<Rect2d> rects1(MxArrayToVectorRect<double>(rhs[1]));
            if (rhs[2].isNumeric() && rhs[2].numel() == 4) {
                Rect2d rect2(rhs[2].toRect_<double>());
                for (size_t i = 0; i < rects1.size(); ++i)
                    rects1[i] |= rect2;
            }
            else {
                vector<Rect2d> rects2(MxArrayToVectorRect<double>(rhs[2]));
                if (rects1.size() != rects2.size())
                    mexErrMsgIdAndTxt("mexopencv:error", "Length mismatch");
                for (size_t i = 0; i < rects1.size(); ++i)
                    rects1[i] |= rects2[i];
            }
            plhs[0] = (rhs[1].isCell()) ?
                MxArray(rects1) : MxArray(Mat(rects1, false).reshape(1, 0));
        }
    }
    else if (method == "crop") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        Mat img(rhs[1].toMat());
        Rect rect(rhs[2].toRect());
        Mat roi(img, rect);
        if (nrhs == 3) {
            // get ROI
            plhs[0] = MxArray(roi.clone());  //HACK: clone was needed here!
        }
        else {
            // set ROI
            Mat roi_new(rhs[3].toMat(img.depth()));
            CV_Assert(roi_new.size() == rect.size() &&
                roi_new.type() == img.type());
            roi_new.copyTo(roi);
            plhs[0] = MxArray(img);
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
