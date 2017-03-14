/**
 * @file LearningBasedWB_.cpp
 * @brief mex interface for cv::xphoto::LearningBasedWB
 * @ingroup xphoto
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/xphoto.hpp"
using namespace std;
using namespace cv;
using namespace cv::xphoto;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<LearningBasedWB> > obj_;
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
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        string path_to_model;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "PathToModel")
                path_to_model = rhs[i+1].toString();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createLearningBasedWB(path_to_model);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<LearningBasedWB> obj = obj_[id];
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<LearningBasedWB>(rhs[2].toString(), objname) :
            Algorithm::load<LearningBasedWB>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing LearningBasedWB::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
        //*/
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "balanceWhite") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat(rhs[2].isUint16() ? CV_16U : CV_8U)),
            dst;
        obj->balanceWhite(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "extractSimpleFeatures") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat(rhs[2].isUint16() ? CV_16U : CV_8U)),
            dst;
        obj->extractSimpleFeatures(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "RangeMaxVal")
            plhs[0] = MxArray(obj->getRangeMaxVal());
        else if (prop == "SaturationThreshold")
            plhs[0] = MxArray(obj->getSaturationThreshold());
        else if (prop == "HistBinNum")
            plhs[0] = MxArray(obj->getHistBinNum());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "RangeMaxVal")
            obj->setRangeMaxVal(rhs[3].toInt());
        else if (prop == "SaturationThreshold")
            obj->setSaturationThreshold(rhs[3].toFloat());
        else if (prop == "HistBinNum")
            obj->setHistBinNum(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
