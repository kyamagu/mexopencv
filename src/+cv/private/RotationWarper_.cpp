/**
 * @file RotationWarper_.cpp
 * @brief mex interface for cv::detail::RotationWarper
 * @ingroup stitching
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "mexopencv_stitching.hpp"
#include "opencv2/stitching.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::detail;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<RotationWarper> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=4 && nlhs<=1);
        obj_[++last_id] = createRotationWarper(
            rhs[2].toString(), rhs.begin() + 4, rhs.end(), rhs[3].toFloat());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<RotationWarper> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "buildMaps") {
        nargchk(nrhs==5 && nlhs<=3);
        Size src_size(rhs[2].toSize());
        Mat K(rhs[3].toMat(CV_32F)),
            R(rhs[4].toMat(CV_32F)),
            xmap, ymap;
        Rect bbox = obj->buildMaps(src_size, K, R, xmap, ymap);
        plhs[0] = MxArray(xmap);
        if (nlhs > 1)
            plhs[1] = MxArray(ymap);
        if (nlhs > 2)
            plhs[2] = MxArray(bbox);
    }
    else if (method == "warpPoint") {
        nargchk(nrhs==5 && nlhs<=1);
        Point2f pt(rhs[2].toPoint2f());
        Mat K(rhs[3].toMat(CV_32F)), R(rhs[4].toMat(CV_32F));
        Point2f uv = obj->warpPoint(pt, K, R);
        plhs[0] = MxArray(uv);
    }
    else if (method == "warp") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=2);
        int interp_mode = cv::INTER_LINEAR;
        int border_mode = cv::BORDER_CONSTANT;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InterpMode")
                interp_mode = (rhs[i+1].isChar()) ?
                    InterpType[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "BorderMode")
                border_mode = (rhs[i+1].isChar()) ?
                    BorderType[rhs[i+1].toString()] : rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat src(rhs[2].toMat()), dst;
        Mat K(rhs[3].toMat(CV_32F)), R(rhs[4].toMat(CV_32F));
        Point tl = obj->warp(src, K, R, interp_mode, border_mode, dst);
        plhs[0] = MxArray(dst);
        if (nlhs > 1)
            plhs[1] = MxArray(tl);
    }
    else if (method == "warpBackward") {
        nargchk(nrhs>=6 && (nrhs%2)==0 && nlhs<=1);
        int interp_mode = cv::INTER_LINEAR;
        int border_mode = cv::BORDER_CONSTANT;
        for (int i=6; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InterpMode")
                interp_mode = (rhs[i+1].isChar()) ?
                    InterpType[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "BorderMode")
                border_mode = (rhs[i+1].isChar()) ?
                    BorderType[rhs[i+1].toString()] : rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat src(rhs[2].toMat()), dst;
        Mat K(rhs[3].toMat(CV_32F)), R(rhs[4].toMat(CV_32F));
        Size dst_size(rhs[5].toSize());
        obj->warpBackward(src, K, R, interp_mode, border_mode, dst_size, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "warpRoi") {
        nargchk(nrhs==5 && nlhs<=1);
        Size src_size(rhs[2].toSize());
        Mat K(rhs[3].toMat(CV_32F)), R(rhs[4].toMat(CV_32F));
        Rect bbox = obj->warpRoi(src_size, K, R);
        plhs[0] = MxArray(bbox);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Scale")
            plhs[0] = MxArray(obj->getScale());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Scale")
            obj->setScale(rhs[3].toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
