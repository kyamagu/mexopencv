/**
 * @file Blender_.cpp
 * @brief mex interface for cv::detail::Blender
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
map<int,Ptr<Blender> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createBlender(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods
    else if (method == "createLaplacePyr") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        bool use_gpu = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "UseGPU")
                use_gpu = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat());
        int num_levels = rhs[3].toInt();
        vector<UMat> pyr;
        if (use_gpu)
            createLaplacePyrGpu(img, num_levels, pyr);
        else
            createLaplacePyr(img, num_levels, pyr);
        vector<Mat> pyr_;
        pyr_.reserve(pyr.size());
        for (vector<UMat>::const_iterator it = pyr.begin(); it != pyr.end(); ++it)
            pyr_.push_back(it->getMat(ACCESS_READ));
        plhs[0] = MxArray(pyr_);
        return;
    }
    else if (method == "restoreImageFromLaplacePyr") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        bool use_gpu = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "UseGPU")
                use_gpu = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<UMat> pyr;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            pyr.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                pyr.push_back(it->toMat(CV_16S).getUMat(ACCESS_RW));
        }
        if (use_gpu)
            restoreImageFromLaplacePyrGpu(pyr);
        else
            restoreImageFromLaplacePyr(pyr);
        plhs[0] = MxArray(!pyr.empty() ? pyr[0].getMat(ACCESS_READ) : Mat());
        return;
    }
    else if (method == "overlapRoi") {
        nargchk(nrhs==6 && nlhs<=2);
        Point tl1(rhs[2].toPoint()),
              tl2(rhs[3].toPoint());
        Size sz1(rhs[4].toSize()),
             sz2(rhs[5].toSize());
        Rect roi;
        bool success = overlapRoi(tl1, tl2, sz1, sz2, roi);
        if (nlhs > 1)
            plhs[1] = MxArray(success);
        else if (!success)
            mexErrMsgIdAndTxt("mexopencv:error", "Operation failed");
        plhs[0] = MxArray(roi);
        return;
    }
    else if (method == "resultRoi") {
        nargchk(nrhs==4 && nlhs<=1);
        vector<Point> corners(rhs[2].toVector<Point>());
        vector<Size> sizes(rhs[3].toVector<Size>());
        Rect roi = resultRoi(corners, sizes);
        plhs[0] = MxArray(roi);
        return;
    }
    else if (method == "resultRoiIntersection") {
        nargchk(nrhs==4 && nlhs<=1);
        vector<Point> corners(rhs[2].toVector<Point>());
        vector<Size> sizes(rhs[3].toVector<Size>());
        Rect roi = resultRoiIntersection(corners, sizes);
        plhs[0] = MxArray(roi);
        return;
    }
    else if (method == "resultTl") {
        nargchk(nrhs==3 && nlhs<=1);
        vector<Point> corners(rhs[2].toVector<Point>());
        Point tl = resultTl(corners);
        plhs[0] = MxArray(tl);
        return;
    }

    // Big operation switch
    Ptr<Blender> obj = obj_[id];
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
    else if (method == "prepare") {
        nargchk((nrhs==3 || nrhs==4) && nlhs==0);
        if (nrhs == 4) {
            vector<Point> corners(rhs[2].toVector<Point>());
            vector<Size> sizes(rhs[3].toVector<Size>());
            obj->prepare(corners, sizes);
        }
        else {
            Rect dst_roi(rhs[2].toRect());
            obj->prepare(dst_roi);
        }
    }
    else if (method == "feed") {
        nargchk(nrhs==5 && nlhs==0);
        Mat img(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_16S)),
            mask(rhs[3].toMat(CV_8U));
        Point tl(rhs[4].toPoint());
        obj->feed(img, mask, tl);
    }
    else if (method == "blend") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);
        Mat dst, dst_mask;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Dst")
                dst = rhs[i+1].toMat(rhs[i+1].isUint8() ? CV_8U : CV_16S);
            else if (key == "Mask")
                dst_mask = rhs[i+1].toMat(CV_8U);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->blend(dst, dst_mask);
        plhs[0] = MxArray(dst);
        if (nlhs > 1)
            plhs[1] = MxArray(dst_mask);
    }
    else if (method == "createWeightMaps") {
        Ptr<FeatherBlender> p = obj.dynamicCast<FeatherBlender>();
        if (p.empty())
            mexErrMsgIdAndTxt("mexopencv:error",
                "Only supported for FeatherBlender");
        vector<Point> corners(rhs[3].toVector<Point>());
        vector<UMat> masks, weight_maps;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            masks.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                masks.push_back(it->toMat(CV_8U).getUMat(ACCESS_READ));
        }
        Rect dst_roi = p->createWeightMaps(masks, corners, weight_maps);
        vector<Mat> weight_maps_;
        weight_maps_.reserve(weight_maps.size());
        for (vector<UMat>::const_iterator it = weight_maps.begin(); it != weight_maps.end(); ++it)
            weight_maps_.push_back(it->getMat(ACCESS_READ));
        plhs[0] = MxArray(weight_maps_);
        if (nlhs > 1)
            plhs[1] = MxArray(dst_roi);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
