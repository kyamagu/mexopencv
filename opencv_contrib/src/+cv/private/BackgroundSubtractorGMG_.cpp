/**
 * @file BackgroundSubtractorGMG_.cpp
 * @brief mex interface for cv::bgsegm::BackgroundSubtractorGMG
 * @ingroup bgsegm
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/bgsegm.hpp"
using namespace std;
using namespace cv;
using namespace cv::bgsegm;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<BackgroundSubtractorGMG> > obj_;
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
        int initializationFrames = 120;
        double decisionThreshold = 0.8;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InitializationFrames")
                initializationFrames = rhs[i+1].toInt();
            else if (key == "DecisionThreshold")
                decisionThreshold = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createBackgroundSubtractorGMG(
            initializationFrames, decisionThreshold);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<BackgroundSubtractorGMG> obj = obj_[id];
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<BackgroundSubtractorGMG>(rhs[2].toString(), objname) :
            Algorithm::load<BackgroundSubtractorGMG>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing BackgroundSubtractorGMG::create()
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
    else if (method == "apply") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        double learningRate = -1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "LearningRate")
                learningRate = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat(rhs[2].isFloat() ? CV_32F :
            (rhs[2].isUint16() ? CV_16U : CV_8U))), fgmask;
        obj->apply(image, fgmask, learningRate);
        plhs[0] = MxArray(fgmask);
    }
    else if (method == "getBackgroundImage") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat backgroundImage;
        obj->getBackgroundImage(backgroundImage);
        plhs[0] = MxArray(backgroundImage);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "MaxFeatures")
            plhs[0] = MxArray(obj->getMaxFeatures());
        else if (prop == "DefaultLearningRate")
            plhs[0] = MxArray(obj->getDefaultLearningRate());
        else if (prop == "NumFrames")
            plhs[0] = MxArray(obj->getNumFrames());
        else if (prop == "QuantizationLevels")
            plhs[0] = MxArray(obj->getQuantizationLevels());
        else if (prop == "BackgroundPrior")
            plhs[0] = MxArray(obj->getBackgroundPrior());
        else if (prop == "SmoothingRadius")
            plhs[0] = MxArray(obj->getSmoothingRadius());
        else if (prop == "DecisionThreshold")
            plhs[0] = MxArray(obj->getDecisionThreshold());
        else if (prop == "UpdateBackgroundModel")
            plhs[0] = MxArray(obj->getUpdateBackgroundModel());
        else if (prop == "MinVal")
            plhs[0] = MxArray(obj->getMinVal());
        else if (prop == "MaxVal")
            plhs[0] = MxArray(obj->getMaxVal());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "MaxFeatures")
            obj->setMaxFeatures(rhs[3].toInt());
        else if (prop == "DefaultLearningRate")
            obj->setDefaultLearningRate(rhs[3].toDouble());
        else if (prop == "NumFrames")
            obj->setNumFrames(rhs[3].toInt());
        else if (prop == "QuantizationLevels")
            obj->setQuantizationLevels(rhs[3].toInt());
        else if (prop == "BackgroundPrior")
            obj->setBackgroundPrior(rhs[3].toDouble());
        else if (prop == "SmoothingRadius")
            obj->setSmoothingRadius(rhs[3].toInt());
        else if (prop == "DecisionThreshold")
            obj->setDecisionThreshold(rhs[3].toDouble());
        else if (prop == "UpdateBackgroundModel")
            obj->setUpdateBackgroundModel(rhs[3].toBool());
        else if (prop == "MinVal")
            obj->setMinVal(rhs[3].toDouble());
        else if (prop == "MaxVal")
            obj->setMaxVal(rhs[3].toDouble());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
