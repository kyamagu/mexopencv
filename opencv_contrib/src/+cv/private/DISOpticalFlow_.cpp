/**
 * @file DISOpticalFlow_.cpp
 * @brief mex interface for cv::optflow::DISOpticalFlow
 * @ingroup optflow
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/optflow.hpp"
using namespace std;
using namespace cv;
using namespace cv::optflow;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DISOpticalFlow> > obj_;

/// DIS preset types
const ConstMap<string,int> DISPresetMap = ConstMap<string,int>
    ("UltraFast", cv::optflow::DISOpticalFlow::PRESET_ULTRAFAST)
    ("Fast",      cv::optflow::DISOpticalFlow::PRESET_FAST)
    ("Medium",    cv::optflow::DISOpticalFlow::PRESET_MEDIUM);
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
        int preset = cv::optflow::DISOpticalFlow::PRESET_FAST;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Preset")
                preset = DISPresetMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createOptFlow_DIS(preset);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<DISOpticalFlow> obj = obj_[id];
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
            Algorithm::loadFromString<DISOpticalFlow>(rhs[2].toString(), objname) :
            Algorithm::load<DISOpticalFlow>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing DISOpticalFlow::create()
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
        if (prop == "FinestScale")
            plhs[0] = MxArray(obj->getFinestScale());
        else if (prop == "PatchSize")
            plhs[0] = MxArray(obj->getPatchSize());
        else if (prop == "PatchStride")
            plhs[0] = MxArray(obj->getPatchStride());
        else if (prop == "GradientDescentIterations")
            plhs[0] = MxArray(obj->getGradientDescentIterations());
        else if (prop == "VariationalRefinementIterations")
            plhs[0] = MxArray(obj->getVariationalRefinementIterations());
        else if (prop == "VariationalRefinementAlpha")
            plhs[0] = MxArray(obj->getVariationalRefinementAlpha());
        else if (prop == "VariationalRefinementDelta")
            plhs[0] = MxArray(obj->getVariationalRefinementDelta());
        else if (prop == "VariationalRefinementGamma")
            plhs[0] = MxArray(obj->getVariationalRefinementGamma());
        else if (prop == "UseMeanNormalization")
            plhs[0] = MxArray(obj->getUseMeanNormalization());
        else if (prop == "UseSpatialPropagation")
            plhs[0] = MxArray(obj->getUseSpatialPropagation());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "FinestScale")
            obj->setFinestScale(rhs[3].toInt());
        else if (prop == "PatchSize")
            obj->setPatchSize(rhs[3].toInt());
        else if (prop == "PatchStride")
            obj->setPatchStride(rhs[3].toInt());
        else if (prop == "GradientDescentIterations")
            obj->setGradientDescentIterations(rhs[3].toInt());
        else if (prop == "VariationalRefinementIterations")
            obj->setVariationalRefinementIterations(rhs[3].toInt());
        else if (prop == "VariationalRefinementAlpha")
            obj->setVariationalRefinementAlpha(rhs[3].toFloat());
        else if (prop == "VariationalRefinementDelta")
            obj->setVariationalRefinementDelta(rhs[3].toFloat());
        else if (prop == "VariationalRefinementGamma")
            obj->setVariationalRefinementGamma(rhs[3].toFloat());
        else if (prop == "UseMeanNormalization")
            obj->setUseMeanNormalization(rhs[3].toBool());
        else if (prop == "UseSpatialPropagation")
            obj->setUseSpatialPropagation(rhs[3].toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
