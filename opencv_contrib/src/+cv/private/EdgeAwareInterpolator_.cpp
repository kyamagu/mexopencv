/**
 * @file EdgeAwareInterpolator_.cpp
 * @brief mex interface for cv::ximgproc::EdgeAwareInterpolator
 * @ingroup ximgproc
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<EdgeAwareInterpolator> > obj_;
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = createEdgeAwareInterpolator();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<EdgeAwareInterpolator> obj = obj_[id];
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<EdgeAwareInterpolator>(rhs[2].toString(), objname) :
            Algorithm::load<EdgeAwareInterpolator>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing EdgeAwareInterpolator::create()
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
    else if (method == "interpolate") {
        nargchk(nrhs==6 && nlhs<=1);
        Mat from_image(rhs[2].toMat(CV_8U)),
            to_image(rhs[4].toMat(CV_8U)),
            dense_flow;
        vector<Point2f> from_points(rhs[3].toVector<Point2f>()),
                        to_points(rhs[5].toVector<Point2f>());
        obj->interpolate(from_image, from_points,
            to_image, to_points, dense_flow);
        plhs[0] = MxArray(dense_flow);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "K")
            plhs[0] = MxArray(obj->getK());
        else if (prop == "Sigma")
            plhs[0] = MxArray(obj->getSigma());
        else if (prop == "Lambda")
            plhs[0] = MxArray(obj->getLambda());
        else if (prop == "UsePostProcessing")
            plhs[0] = MxArray(obj->getUsePostProcessing());
        else if (prop == "FGSLambda")
            plhs[0] = MxArray(obj->getFGSLambda());
        else if (prop == "FGSSigma")
            plhs[0] = MxArray(obj->getFGSSigma());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "K")
            obj->setK(rhs[3].toInt());
        else if (prop == "Sigma")
            obj->setSigma(rhs[3].toFloat());
        else if (prop == "Lambda")
            obj->setLambda(rhs[3].toFloat());
        else if (prop == "UsePostProcessing")
            obj->setUsePostProcessing(rhs[3].toBool());
        else if (prop == "FGSLambda")
            obj->setFGSLambda(rhs[3].toFloat());
        else if (prop == "FGSSigma")
            obj->setFGSSigma(rhs[3].toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
