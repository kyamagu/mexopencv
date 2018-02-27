/**
 * @file RidgeDetectionFilter_.cpp
 * @brief mex interface for cv::ximgproc::RidgeDetectionFilter
 * @ingroup ximgproc
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<RidgeDetectionFilter> > obj_;
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
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        int ddepth = CV_32F;
        int dx = 1;
        int dy = 1;
        int ksize = 3;
        int out_dtype = CV_8U;
        double scale = 1;
        double delta = 0;
        int borderType = cv::BORDER_DEFAULT;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "DDepth")
                ddepth = (rhs[i+1].isChar()) ?
                    ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "Dx")
                dx = rhs[i+1].toInt();
            else if (key == "Dy")
                dy = rhs[i+1].toInt();
            else if (key == "KSize")
                ksize = rhs[i+1].toInt();
            else if (key == "OutDType")
                out_dtype = (rhs[i+1].isChar()) ?
                    ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "Scale")
                scale = rhs[i+1].toDouble();
            else if (key == "Delta")
                delta = rhs[i+1].toDouble();
            else if (key == "BorderType")
                borderType = BorderType[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = RidgeDetectionFilter::create(ddepth, dx, dy, ksize,
            out_dtype, scale, delta, borderType);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<RidgeDetectionFilter> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<RidgeDetectionFilter>(rhs[2].toString(), objname) :
            Algorithm::load<RidgeDetectionFilter>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "getRidgeFilteredImage") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat img(rhs[2].toMat()), out;
        obj->getRidgeFilteredImage(img, out);
        plhs[0] = MxArray(out);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
