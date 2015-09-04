/**
 * @file BackgroundSubtractorMOG2_.cpp
 * @brief mex interface for cv::BackgroundSubtractorMOG2
 * @ingroup video
 * @author Kota Yamaguchi, Amro
 * @date 2015
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
map<int,Ptr<BackgroundSubtractorMOG2> > obj_;
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
        int history = 500;
        double varThreshold = 16;
        bool detectShadows = true;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="History")
                history = rhs[i+1].toInt();
            else if (key=="VarThreshold")
                varThreshold = rhs[i+1].toDouble();
            else if (key=="DetectShadows")
                detectShadows = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[++last_id] = createBackgroundSubtractorMOG2(
            history, varThreshold, detectShadows);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<BackgroundSubtractorMOG2> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
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
            if (key=="ObjName")
                objname = rhs[i+1].toString();
            else if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<BackgroundSubtractorMOG2>(rhs[2].toString(), objname) :
            Algorithm::load<BackgroundSubtractorMOG2>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing BackgroundSubtractorMOG2::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
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
            if (key=="LearningRate")
                learningRate = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat image(rhs[2].toMat()), fgmask;
        obj->apply(image, fgmask, learningRate);
        plhs[0] = MxArray(fgmask, mxLOGICAL_CLASS);
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
        if (prop == "BackgroundRatio")
            plhs[0] = MxArray(obj->getBackgroundRatio());
        else if (prop == "ComplexityReductionThreshold")
            plhs[0] = MxArray(obj->getComplexityReductionThreshold());
        else if (prop == "DetectShadows")
            plhs[0] = MxArray(obj->getDetectShadows());
        else if (prop == "History")
            plhs[0] = MxArray(obj->getHistory());
        else if (prop == "NMixtures")
            plhs[0] = MxArray(obj->getNMixtures());
        else if (prop == "ShadowThreshold")
            plhs[0] = MxArray(obj->getShadowThreshold());
        else if (prop == "ShadowValue")
            plhs[0] = MxArray(obj->getShadowValue());
        else if (prop == "VarInit")
            plhs[0] = MxArray(obj->getVarInit());
        else if (prop == "VarMax")
            plhs[0] = MxArray(obj->getVarMax());
        else if (prop == "VarMin")
            plhs[0] = MxArray(obj->getVarMin());
        else if (prop == "VarThreshold")
            plhs[0] = MxArray(obj->getVarThreshold());
        else if (prop == "VarThresholdGen")
            plhs[0] = MxArray(obj->getVarThresholdGen());
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized property");
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "BackgroundRatio")
            obj->setBackgroundRatio(rhs[3].toDouble());
        else if (prop == "ComplexityReductionThreshold")
            obj->setComplexityReductionThreshold(rhs[3].toDouble());
        else if (prop == "DetectShadows")
            obj->setDetectShadows(rhs[3].toBool());
        else if (prop == "History")
            obj->setHistory(rhs[3].toInt());
        else if (prop == "NMixtures")
            obj->setNMixtures(rhs[3].toInt());
        else if (prop == "ShadowThreshold")
            obj->setShadowThreshold(rhs[3].toDouble());
        else if (prop == "ShadowValue")
            obj->setShadowValue(rhs[3].toInt());
        else if (prop == "VarInit")
            obj->setVarInit(rhs[3].toDouble());
        else if (prop == "VarMax")
            obj->setVarMax(rhs[3].toDouble());
        else if (prop == "VarMin")
            obj->setVarMin(rhs[3].toDouble());
        else if (prop == "VarThreshold")
            obj->setVarThreshold(rhs[3].toDouble());
        else if (prop == "VarThresholdGen")
            obj->setVarThresholdGen(rhs[3].toDouble());
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized property");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
