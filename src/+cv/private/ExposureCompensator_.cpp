/**
 * @file ExposureCompensator_.cpp
 * @brief mex interface for cv::detail::ExposureCompensator
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
map<int,Ptr<ExposureCompensator> > obj_;
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
        obj_[++last_id] = createExposureCompensator(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<ExposureCompensator> obj = obj_[id];
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
    else if (method == "feed") {
        nargchk(nrhs==5 && nlhs==0);
        vector<Point> corners(rhs[2].toVector<Point>());
        vector<UMat> images, masks;
        {
            vector<MxArray> arr(rhs[3].toVector<MxArray>());
            images.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                images.push_back(it->toMat(CV_8U).getUMat(ACCESS_READ).clone());
        }
        {
            vector<MxArray> arr(rhs[4].toVector<MxArray>());
            masks.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                masks.push_back(it->toMat(CV_8U).getUMat(ACCESS_READ).clone());
        }
        obj->feed(corners, images, masks);
    }
    else if (method == "apply") {
        nargchk(nrhs==6 && nlhs<=1);
        int index = rhs[2].toInt();
        Point corner(rhs[3].toPoint());
        Mat image(rhs[4].toMat());  // CV_8U
        Mat mask(rhs[5].toMat(CV_8U));
        obj->apply(index, corner, image, mask);
        plhs[0] = MxArray(image);
    }
    else if (method == "gains") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<GainCompensator> p = obj.dynamicCast<GainCompensator>();
        if (p.empty())
            mexErrMsgIdAndTxt("mexopencv:error",
                "Method only supported for GainCompensator");
        vector<double> g(p->gains());
        plhs[0] = MxArray(g);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
