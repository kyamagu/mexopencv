/**
 * @file FarnebackOpticalFlow_.cpp
 * @brief mex interface for cv::FarnebackOpticalFlow
 * @ingroup video
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/video.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<FarnebackOpticalFlow> > obj_;
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

    // constructor call
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = FarnebackOpticalFlow::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<FarnebackOpticalFlow> obj = obj_[id];
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
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)!=0 && nlhs==0);
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
            Algorithm::loadFromString<FarnebackOpticalFlow>(rhs[2].toString(), objname) :
            Algorithm::load<FarnebackOpticalFlow>(rhs[2].toString(), objname));
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "calc") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        Mat flow;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InitialFlow")
                flow = rhs[i+1].toMat(CV_32F);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat I0(rhs[2].toMat(CV_8U)),
            I1(rhs[3].toMat(CV_8U));
        obj->calc(I0, I1, flow);
        plhs[0] = MxArray(flow);
    }
    else if (method == "collectGarbage") {
        nargchk(nrhs==2 && nlhs==0);
        obj->collectGarbage();
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "NumLevels")
            plhs[0] = MxArray(obj->getNumLevels());
        else if (prop == "PyrScale")
            plhs[0] = MxArray(obj->getPyrScale());
        else if (prop == "FastPyramids")
            plhs[0] = MxArray(obj->getFastPyramids());
        else if (prop == "WinSize")
            plhs[0] = MxArray(obj->getWinSize());
        else if (prop == "NumIters")
            plhs[0] = MxArray(obj->getNumIters());
        else if (prop == "PolyN")
            plhs[0] = MxArray(obj->getPolyN());
        else if (prop == "PolySigma")
            plhs[0] = MxArray(obj->getPolySigma());
        else if (prop == "Flags")
            plhs[0] = MxArray(obj->getFlags());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "NumLevels")
            obj->setNumLevels(rhs[3].toInt());
        else if (prop == "PyrScale")
            obj->setPyrScale(rhs[3].toDouble());
        else if (prop == "FastPyramids")
            obj->setFastPyramids(rhs[3].toBool());
        else if (prop == "WinSize")
            obj->setWinSize(rhs[3].toInt());
        else if (prop == "NumIters")
            obj->setNumIters(rhs[3].toInt());
        else if (prop == "PolyN")
            obj->setPolyN(rhs[3].toInt());
        else if (prop == "PolySigma")
            obj->setPolySigma(rhs[3].toDouble());
        else if (prop == "Flags")  //TODO: expose props for flag values
            obj->setFlags(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
