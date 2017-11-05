/**
 * @file ObjectnessBING_.cpp
 * @brief mex interface for cv::saliency::ObjectnessBING
 * @ingroup saliency
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/saliency.hpp"
using namespace std;
using namespace cv;
using namespace cv::saliency;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ObjectnessBING> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = ObjectnessBING::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<ObjectnessBING> obj = obj_[id];
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
            Algorithm::loadFromString<ObjectnessBING>(rhs[2].toString(), objname) :
            Algorithm::load<ObjectnessBING>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: ObjectnessBING read/write interface is non-conformant
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        // HACK: cast as base class since ObjectnessBING overrides read method
        (obj.staticCast<Saliency>())->read(fn);
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
    else if (method == "computeSaliency") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat image(rhs[2].toMat(CV_8U));
        vector<Vec4i> objectnessBoundingBox;
        bool b = obj->computeSaliency(image, objectnessBoundingBox);
        if (!b)
            mexErrMsgIdAndTxt("mexopencv:error", "computeSaliency failed");
        plhs[0] = MxArray(objectnessBoundingBox);
    }
    else if (method == "getobjectnessValues") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<float> objectnessValues(obj->getobjectnessValues());
        plhs[0] = MxArray(objectnessValues);
    }
    else if (method == "setTrainingPath") {
        nargchk(nrhs==3 && nlhs==0);
        string trainingPath(rhs[2].toString());
        obj->setTrainingPath(trainingPath);
    }
    else if (method == "setBBResDir") {
        nargchk(nrhs==3 && nlhs==0);
        string resultsDir(rhs[2].toString());
        obj->setBBResDir(resultsDir);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Base")
            plhs[0] = MxArray(obj->getBase());
        else if (prop == "NSS")
            plhs[0] = MxArray(obj->getNSS());
        else if (prop == "W")
            plhs[0] = MxArray(obj->getW());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Base")
            obj->setBase(rhs[3].toDouble());
        else if (prop == "NSS")
            obj->setNSS(rhs[3].toInt());
        else if (prop == "W")
            obj->setW(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
