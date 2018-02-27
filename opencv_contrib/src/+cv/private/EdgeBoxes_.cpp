/**
 * @file EdgeBoxes_.cpp
 * @brief mex interface for cv::ximgproc::EdgeBoxes
 * @ingroup ximgproc
 * @author Amro
 * @date 2018
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
map<int,Ptr<EdgeBoxes> > obj_;
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
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        float alpha = 0.65f;
        float beta = 0.75f;
        float eta = 1;
        float minScore = 0.01f;
        int maxBoxes = 10000;
        float edgeMinMag = 0.1f;
        float edgeMergeThr = 0.5f;
        float clusterMinMag = 0.5f;
        float maxAspectRatio = 3;
        float minBoxArea = 1000;
        float gamma = 2;
        float kappa = 1.5f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Alpha")
                alpha = rhs[i+1].toFloat();
            else if (key == "Beta")
                beta = rhs[i+1].toFloat();
            else if (key == "Eta")
                eta = rhs[i+1].toFloat();
            else if (key == "MinScore")
                minScore = rhs[i+1].toFloat();
            else if (key == "MaxBoxes")
                maxBoxes = rhs[i+1].toInt();
            else if (key == "EdgeMinMag")
                edgeMinMag = rhs[i+1].toFloat();
            else if (key == "EdgeMergeThr")
                edgeMergeThr = rhs[i+1].toFloat();
            else if (key == "ClusterMinMag")
                clusterMinMag = rhs[i+1].toFloat();
            else if (key == "MaxAspectRatio")
                maxAspectRatio = rhs[i+1].toFloat();
            else if (key == "MinBoxArea")
                minBoxArea = rhs[i+1].toFloat();
            else if (key == "Gamma")
                gamma = rhs[i+1].toFloat();
            else if (key == "Kappa")
                kappa = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createEdgeBoxes(alpha, beta, eta, minScore,
            maxBoxes, edgeMinMag, edgeMergeThr, clusterMinMag, maxAspectRatio,
            minBoxArea, gamma, kappa);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<EdgeBoxes> obj = obj_[id];
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
            Algorithm::loadFromString<EdgeBoxes>(rhs[2].toString(), objname) :
            Algorithm::load<EdgeBoxes>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing EdgeBoxes::create()
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
    else if (method == "getBoundingBoxes") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat edge_map(rhs[2].toMat(CV_32F)),
            orientation_map(rhs[3].toMat(CV_32F));
        vector<Rect> boxes;
        obj->getBoundingBoxes(edge_map, orientation_map, boxes);
        plhs[0] = MxArray(boxes);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Alpha")
            plhs[0] = MxArray(obj->getAlpha());
        else if (prop == "Beta")
            plhs[0] = MxArray(obj->getBeta());
        else if (prop == "Eta")
            plhs[0] = MxArray(obj->getEta());
        else if (prop == "MinScore")
            plhs[0] = MxArray(obj->getMinScore());
        else if (prop == "MaxBoxes")
            plhs[0] = MxArray(obj->getMaxBoxes());
        else if (prop == "EdgeMinMag")
            plhs[0] = MxArray(obj->getEdgeMinMag());
        else if (prop == "EdgeMergeThr")
            plhs[0] = MxArray(obj->getEdgeMergeThr());
        else if (prop == "ClusterMinMag")
            plhs[0] = MxArray(obj->getClusterMinMag());
        else if (prop == "MaxAspectRatio")
            plhs[0] = MxArray(obj->getMaxAspectRatio());
        else if (prop == "MinBoxArea")
            plhs[0] = MxArray(obj->getMinBoxArea());
        else if (prop == "Gamma")
            plhs[0] = MxArray(obj->getGamma());
        else if (prop == "Kappa")
            plhs[0] = MxArray(obj->getKappa());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Alpha")
            obj->setAlpha(rhs[3].toFloat());
        else if (prop == "Beta")
            obj->setBeta(rhs[3].toFloat());
        else if (prop == "Eta")
            obj->setEta(rhs[3].toFloat());
        else if (prop == "MinScore")
            obj->setMinScore(rhs[3].toFloat());
        else if (prop == "MaxBoxes")
            obj->setMaxBoxes(rhs[3].toInt());
        else if (prop == "EdgeMinMag")
            obj->setEdgeMinMag(rhs[3].toFloat());
        else if (prop == "EdgeMergeThr")
            obj->setEdgeMergeThr(rhs[3].toFloat());
        else if (prop == "ClusterMinMag")
            obj->setClusterMinMag(rhs[3].toFloat());
        else if (prop == "MaxAspectRatio")
            obj->setMaxAspectRatio(rhs[3].toFloat());
        else if (prop == "MinBoxArea")
            obj->setMinBoxArea(rhs[3].toFloat());
        else if (prop == "Gamma")
            obj->setGamma(rhs[3].toFloat());
        else if (prop == "Kappa")
            obj->setKappa(rhs[3].toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
