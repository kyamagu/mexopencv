/**
 * @file FeaturesFinder_.cpp
 * @brief mex interface for cv::detail::FeaturesFinder
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
map<int,Ptr<FeaturesFinder> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createFeaturesFinder(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<FeaturesFinder> obj = obj_[id];
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
    else if (method == "collectGarbage") {
        nargchk(nrhs==2 && nlhs==0);
        obj->collectGarbage();
    }
    /*
    else if (method == "isThreadSafe") {
        nargchk(nrhs==2 && nlhs<=1);
        bool tf = obj->isThreadSafe();
        plhs[0] = MxArray(tf);
    }
    */
    else if (method == "find") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        Mat image(rhs[2].toMat());
        ImageFeatures features;
        if (nrhs == 4) {
            vector<Rect> rois(rhs[3].toVector<Rect>());
            obj->operator()(image, features, rois);
        }
        else
            obj->operator()(image, features);
        plhs[0] = toStruct(features);
    }
    else if (method == "findParallel") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        vector<Mat> images(rhs[2].toVector<Mat>());
        vector<ImageFeatures> features;
        if (nrhs == 4) {
            //vector<vector<Rect> > rois(rhs[3].toVector<vector<Rect>>());
            vector<vector<Rect> > rois(rhs[3].toVector(
                const_mem_fun_ref_t<vector<Rect>, MxArray>(
                    &MxArray::toVector<Rect>)));
            obj->operator()(images, features, rois);
        }
        else
            obj->operator()(images, features);
        plhs[0] = toStruct(features);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
