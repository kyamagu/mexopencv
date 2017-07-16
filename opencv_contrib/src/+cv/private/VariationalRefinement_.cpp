/**
 * @file VariationalRefinement_.cpp
 * @brief mex interface for cv::optflow::VariationalRefinement
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
map<int,Ptr<VariationalRefinement> > obj_;
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
        obj_[++last_id] = createVariationalFlowRefinement();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<VariationalRefinement> obj = obj_[id];
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
            Algorithm::loadFromString<VariationalRefinement>(rhs[2].toString(), objname) :
            Algorithm::load<VariationalRefinement>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing VariationalRefinement::create()
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
        Mat I0(rhs[2].toMat(rhs[2].isFloat() ? CV_32F : CV_8U)),
            I1(rhs[3].toMat(rhs[3].isFloat() ? CV_32F : CV_8U));
        //HACK: function expects Mat to be allocated
        if (flow.empty()) flow.create(I0.size(), CV_32FC2);
        obj->calc(I0, I1, flow);
        plhs[0] = MxArray(flow);
    }
    else if (method == "calcUV") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        Mat flow_u, flow_v;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InitialFlowU")
                flow_u = rhs[i+1].toMat(CV_32F);
            else if (key == "InitialFlowV")
                flow_v = rhs[i+1].toMat(CV_32F);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat I0(rhs[2].toMat(rhs[2].isFloat() ? CV_32F : CV_8U)),
            I1(rhs[3].toMat(rhs[3].isFloat() ? CV_32F : CV_8U));
        //HACK: function expects Mat to be allocated
        if (flow_u.empty()) flow_u.create(I0.size(), CV_32FC1);
        if (flow_v.empty()) flow_v.create(I0.size(), CV_32FC1);
        obj->calcUV(I0, I1, flow_u, flow_v);
        plhs[0] = MxArray(flow_u);
        if (nlhs > 1)
            plhs[1] = MxArray(flow_v);
    }
    else if (method == "collectGarbage") {
        nargchk(nrhs==2 && nlhs==0);
        obj->collectGarbage();
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "FixedPointIterations")
            plhs[0] = MxArray(obj->getFixedPointIterations());
        else if (prop == "SorIterations")
            plhs[0] = MxArray(obj->getSorIterations());
        else if (prop == "Omega")
            plhs[0] = MxArray(obj->getOmega());
        else if (prop == "Alpha")
            plhs[0] = MxArray(obj->getAlpha());
        else if (prop == "Delta")
            plhs[0] = MxArray(obj->getDelta());
        else if (prop == "Gamma")
            plhs[0] = MxArray(obj->getGamma());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "FixedPointIterations")
            obj->setFixedPointIterations(rhs[3].toInt());
        else if (prop == "SorIterations")
            obj->setSorIterations(rhs[3].toInt());
        else if (prop == "Omega")
            obj->setOmega(rhs[3].toFloat());
        else if (prop == "Alpha")
            obj->setAlpha(rhs[3].toFloat());
        else if (prop == "Delta")
            obj->setDelta(rhs[3].toFloat());
        else if (prop == "Gamma")
            obj->setGamma(rhs[3].toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
