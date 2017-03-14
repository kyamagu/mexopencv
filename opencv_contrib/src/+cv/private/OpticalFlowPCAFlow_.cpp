/**
 * @file OpticalFlowPCAFlow_.cpp
 * @brief mex interface for cv::optflow::OpticalFlowPCAFlow
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
map<int,Ptr<OpticalFlowPCAFlow> > obj_;
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
        string pathToPrior;
        Size basisSize(18,14);
        float sparseRate = 0.024f;
        float retainedCornersFraction = 0.2f;
        float occlusionsThreshold = 0.0003f;
        float dampingFactor = 0.00002f;
        float claheClip = 14;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Prior")
                pathToPrior = rhs[i+1].toString();
            else if (key == "BasisSize")
                basisSize = rhs[i+1].toSize();
            else if (key == "SparseRate")
                sparseRate = rhs[i+1].toFloat();
            else if (key == "RetainedCornersFraction")
                retainedCornersFraction = rhs[i+1].toFloat();
            else if (key == "OcclusionsThreshold")
                occlusionsThreshold = rhs[i+1].toFloat();
            else if (key == "DampingFactor")
                dampingFactor = rhs[i+1].toFloat();
            else if (key == "ClaheClip")
                claheClip = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Ptr<PCAPrior> prior;
        if (!pathToPrior.empty())
            prior = makePtr<PCAPrior>(pathToPrior.c_str());
        obj_[++last_id] = makePtr<OpticalFlowPCAFlow>(prior, basisSize,
            sparseRate, retainedCornersFraction, occlusionsThreshold,
            dampingFactor, claheClip);
        //obj_[++last_id] = createOptFlow_PCAFlow();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<OpticalFlowPCAFlow> obj = obj_[id];
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
            Algorithm::loadFromString<OpticalFlowPCAFlow>(rhs[2].toString(), objname) :
            Algorithm::load<OpticalFlowPCAFlow>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing OpticalFlowPCAFlow::create()
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
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
