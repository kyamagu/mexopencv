/**
 * @file RetinaFastToneMapping_.cpp
 * @brief mex interface for cv::bioinspired::RetinaFastToneMapping
 * @ingroup bioinspired
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/bioinspired.hpp"
using namespace std;
using namespace cv;
using namespace cv::bioinspired;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<RetinaFastToneMapping> > obj_;
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
        nargchk(nrhs==3 && nlhs<=1);
        obj_[++last_id] = RetinaFastToneMapping::create(rhs[2].toSize());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<RetinaFastToneMapping> obj = obj_[id];
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
            Algorithm::loadFromString<RetinaFastToneMapping>(rhs[2].toString(), objname) :
            Algorithm::load<RetinaFastToneMapping>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing RetinaFastToneMapping::create()
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
    else if (method == "setup") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        float photoreceptorsNeighborhoodRadius = 3.f;
        float ganglioncellsNeighborhoodRadius = 1.f;
        float meanLuminanceModulatorK = 1.f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "PhotoreceptorsNeighborhoodRadius")
                photoreceptorsNeighborhoodRadius = rhs[i+1].toFloat();
            else if (key == "GanglioncellsNeighborhoodRadius")
                ganglioncellsNeighborhoodRadius = rhs[i+1].toFloat();
            else if (key == "MeanLuminanceModulatorK")
                meanLuminanceModulatorK = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->setup(photoreceptorsNeighborhoodRadius,
            ganglioncellsNeighborhoodRadius, meanLuminanceModulatorK);
    }
    else if (method == "applyFastToneMapping") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat inputImage(rhs[2].toMat(CV_32F)),
            outputToneMappedImage;
        obj->applyFastToneMapping(inputImage, outputToneMappedImage);
        plhs[0] = MxArray(outputToneMappedImage);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
