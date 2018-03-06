/**
 * @file SeamFinder_.cpp
 * @brief mex interface for cv::detail::SeamFinder
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
map<int,Ptr<SeamFinder> > obj_;
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
        obj_[++last_id] = createSeamFinder(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<SeamFinder> obj = obj_[id];
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
    else if (method == "find") {
        nargchk(nrhs==5 && nlhs<=1);

        vector<Point> corners(rhs[3].toVector<Point>());
        vector<UMat> src, masks;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            src.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                src.push_back(it->toMat().getUMat(ACCESS_READ));
        }
        {
            vector<MxArray> arr(rhs[4].toVector<MxArray>());
            masks.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                masks.push_back(it->toMat(CV_8U).getUMat(ACCESS_RW));
        }
        obj->find(src, corners, masks);
        vector<Mat> masks_;
        masks_.reserve(masks.size());
        for (vector<UMat>::const_iterator it = masks.begin(); it != masks.end(); ++it)
            masks_.push_back(it->getMat(ACCESS_READ));
        plhs[0] = MxArray(masks_);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
