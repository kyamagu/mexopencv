/**
 * @file DualTVL1OpticalFlow_.cpp
 * @brief mex interface for cv::DualTVL1OpticalFlow
 * @ingroup video
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DualTVL1OpticalFlow> > obj_;
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
        obj_[++last_id] = createOptFlow_DualTVL1();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<DualTVL1OpticalFlow> obj = obj_[id];
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
        nargchk(nrhs>=3 && (nrhs%2)!=0 && nlhs==0);
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
            Algorithm::loadFromString<DualTVL1OpticalFlow>(rhs[2].toString(), objname) :
            Algorithm::load<DualTVL1OpticalFlow>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing DualTVL1OpticalFlow::create()
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
    else if (method == "calc") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        Mat flow;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InitialFlow")
                flow = rhs[i+1].toMat(CV_32F);
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat I0(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_8U)),
            I1(rhs[3].toMat(rhs[3].isSingle() ? CV_32F : CV_8U));
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
        if (prop == "Epsilon")
            plhs[0] = MxArray(obj->getEpsilon());
        else if (prop == "Gamma")
            plhs[0] = MxArray(obj->getGamma());
        else if (prop == "InnerIterations")
            plhs[0] = MxArray(obj->getInnerIterations());
        else if (prop == "Lambda")
            plhs[0] = MxArray(obj->getLambda());
        else if (prop == "MedianFiltering")
            plhs[0] = MxArray(obj->getMedianFiltering());
        else if (prop == "OuterIterations")
            plhs[0] = MxArray(obj->getOuterIterations());
        else if (prop == "ScalesNumber")
            plhs[0] = MxArray(obj->getScalesNumber());
        else if (prop == "ScaleStep")
            plhs[0] = MxArray(obj->getScaleStep());
        else if (prop == "Tau")
            plhs[0] = MxArray(obj->getTau());
        else if (prop == "Theta")
            plhs[0] = MxArray(obj->getTheta());
        else if (prop == "UseInitialFlow")
            plhs[0] = MxArray(obj->getUseInitialFlow());
        else if (prop == "WarpingsNumber")
            plhs[0] = MxArray(obj->getWarpingsNumber());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Epsilon")
            obj->setEpsilon(rhs[3].toDouble());
        else if (prop == "Gamma")
            obj->setGamma(rhs[3].toDouble());
        else if (prop == "InnerIterations")
            obj->setInnerIterations(rhs[3].toInt());
        else if (prop == "Lambda")
            obj->setLambda(rhs[3].toDouble());
        else if (prop == "MedianFiltering")
            obj->setMedianFiltering(rhs[3].toInt());
        else if (prop == "OuterIterations")
            obj->setOuterIterations(rhs[3].toInt());
        else if (prop == "ScalesNumber")
            obj->setScalesNumber(rhs[3].toInt());
        else if (prop == "ScaleStep")
            obj->setScaleStep(rhs[3].toDouble());
        else if (prop == "Tau")
            obj->setTau(rhs[3].toDouble());
        else if (prop == "Theta")
            obj->setTheta(rhs[3].toDouble());
        else if (prop == "UseInitialFlow")
            obj->setUseInitialFlow(rhs[3].toBool());
        else if (prop == "WarpingsNumber")
            obj->setWarpingsNumber(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
