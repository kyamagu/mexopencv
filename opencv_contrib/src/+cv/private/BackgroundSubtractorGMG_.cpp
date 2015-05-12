/**
 * @file BackgroundSubtractorGMG_.cpp
 * @brief mex interface for BackgroundSubtractorGMG_
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    if (nrhs<2 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // constructor call
    if (method == "new") {
        if ((nrhs%2)!=0 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        int initializationFrames = 120;
        double decisionThreshold = 0.8;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="InitializationFrames")
                initializationFrames = rhs[i+1].toInt();
            else if (key=="DecisionThreshold")
                decisionThreshold = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[++last_id] = createBackgroundSubtractorGMG(
            initializationFrames, decisionThreshold);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<BackgroundSubtractorGMG> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "clear") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->clear();
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->save(rhs[2].toString());
    }
    else if (method == "load") {
        if (nrhs<3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="ObjName")
                objname = rhs[i+1].toString();
            else if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
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
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
        //*/
    }
    else if (method == "empty") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "apply") {
        if (nrhs<3 || (nrhs%2)!=1 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        double learningRate = -1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="LearningRate")
                learningRate = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat image(rhs[2].toMat()), fgmask;
        obj->apply(image, fgmask, learningRate);
        plhs[0] = MxArray(fgmask,mxLOGICAL_CLASS);
    }
    else if (method == "getBackgroundImage") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat backgroundImage;
        obj->getBackgroundImage(backgroundImage);
        plhs[0] = MxArray(backgroundImage);
    }
    else if (method == "get") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "BackgroundPrior")
            plhs[0] = MxArray(obj->getBackgroundPrior());
        else if (prop == "DecisionThreshold")
            plhs[0] = MxArray(obj->getDecisionThreshold());
        else if (prop == "DefaultLearningRate")
            plhs[0] = MxArray(obj->getDefaultLearningRate());
        else if (prop == "MaxFeatures")
            plhs[0] = MxArray(obj->getMaxFeatures());
        else if (prop == "MaxVal")
            plhs[0] = MxArray(obj->getMaxVal());
        else if (prop == "MinVal")
            plhs[0] = MxArray(obj->getMinVal());
        else if (prop == "NumFrames")
            plhs[0] = MxArray(obj->getNumFrames());
        else if (prop == "QuantizationLevels")
            plhs[0] = MxArray(obj->getQuantizationLevels());
        else if (prop == "SmoothingRadius")
            plhs[0] = MxArray(obj->getSmoothingRadius());
        else if (prop == "UpdateBackgroundModel")
            plhs[0] = MxArray(obj->getUpdateBackgroundModel());
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized property");
    }
    else if (method == "set") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "BackgroundPrior")
            obj->setBackgroundPrior(rhs[3].toDouble());
        else if (prop == "DecisionThreshold")
            obj->setDecisionThreshold(rhs[3].toDouble());
        else if (prop == "DefaultLearningRate")
            obj->setDefaultLearningRate(rhs[3].toDouble());
        else if (prop == "MaxFeatures")
            obj->setMaxFeatures(rhs[3].toInt());
        else if (prop == "MaxVal")
            obj->setMaxVal(rhs[3].toDouble());
        else if (prop == "MinVal")
            obj->setMinVal(rhs[3].toDouble());
        else if (prop == "NumFrames")
            obj->setNumFrames(rhs[3].toInt());
        else if (prop == "QuantizationLevels")
            obj->setQuantizationLevels(rhs[3].toInt());
        else if (prop == "SmoothingRadius")
            obj->setSmoothingRadius(rhs[3].toInt());
        else if (prop == "UpdateBackgroundModel")
            obj->setUpdateBackgroundModel(rhs[3].toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized property");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
