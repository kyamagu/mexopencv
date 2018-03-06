/**
 * @file Timelapser_.cpp
 * @brief mex interface for cv::detail::Timelapser
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
map<int,Ptr<Timelapser> > obj_;

/// time lapser types
const ConstMap<std::string, int> TimelapserTypesMap = ConstMap<std::string, int>
    ("AsIs", cv::detail::Timelapser::AS_IS)
    ("Crop", cv::detail::Timelapser::CROP);
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
        nargchk(nrhs==3 && nlhs<=1);
        string type(rhs[2].toString());
        obj_[++last_id] = Timelapser::createDefault(TimelapserTypesMap[type]);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<Timelapser> obj = obj_[id];
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
    else if (method == "initialize") {
        nargchk(nrhs==4 && nlhs==0);
        vector<Point> corners(rhs[2].toVector<Point>());
        vector<Size> sizes(rhs[3].toVector<Size>());
        obj->initialize(corners, sizes);
    }
    else if (method == "process") {
        nargchk(nrhs==5 && nlhs==0);
        Mat img(rhs[2].toMat(CV_16S));
        Mat mask(rhs[3].toMat(CV_8U));
        Point tl(rhs[4].toPoint());
        obj->process(img, mask, tl);
    }
    else if (method == "getDst") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat dst(obj->getDst().getMat(ACCESS_READ));
        plhs[0] = MxArray(dst);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
