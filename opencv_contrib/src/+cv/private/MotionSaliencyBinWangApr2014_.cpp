/**
 * @file MotionSaliencyBinWangApr2014_.cpp
 * @brief mex interface for cv::saliency::MotionSaliencyBinWangApr2014
 * @ingroup saliency
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/saliency.hpp"
using namespace std;
using namespace cv;
using namespace cv::saliency;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<MotionSaliencyBinWangApr2014> > obj_;
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
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = MotionSaliencyBinWangApr2014::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<MotionSaliencyBinWangApr2014> obj = obj_[id];
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
            Algorithm::loadFromString<MotionSaliencyBinWangApr2014>(rhs[2].toString(), objname) :
            Algorithm::load<MotionSaliencyBinWangApr2014>(rhs[2].toString(), objname));
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
    else if (method == "computeSaliency") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat image(rhs[2].toMat(CV_8U)),
            saliencyMap;
        bool b = obj->computeSaliency(image, saliencyMap);
        if (!b)
            mexErrMsgIdAndTxt("mexopencv:error", "computeSaliency failed");
        plhs[0] = MxArray(saliencyMap);
    }
    else if (method == "setImagesize") {
        nargchk(nrhs==4 && nlhs==0);
        int W = rhs[2].toInt(),
            H = rhs[3].toInt();
        obj->setImagesize(W, H);
    }
    else if (method == "init") {
        nargchk(nrhs==2 && nlhs==0);
        bool b = obj->init();
        if (!b)
            mexErrMsgIdAndTxt("mexopencv:error", "init failed");
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "ImageWidth")
            plhs[0] = MxArray(obj->getImageWidth());
        else if (prop == "ImageHeight")
            plhs[0] = MxArray(obj->getImageHeight());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "ImageWidth")
            obj->setImageWidth(rhs[3].toInt());
        else if (prop == "ImageHeight")
            obj->setImageHeight(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
