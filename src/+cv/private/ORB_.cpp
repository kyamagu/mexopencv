/**
 * @file ORB_.cpp
 * @brief mex interface for ORB
 * @author Amro, Kota Yamaguchi
 * @date 2015
 */
#include <typeinfo>
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ORB> > obj_;
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
    if (nrhs<2 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        if (nrhs<2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj_[++last_id] = createORB(rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<ORB> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "typeid") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "clear") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->clear();
    }
    else if (method == "load") {
        if (nrhs<3 || (nrhs%2)==0 || nlhs!=0)
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
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<ORB>(rhs[2].toString(), objname) :
            Algorithm::load<ORB>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "defaultNorm") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(NormTypeInv[obj->defaultNorm()]);
    }
    else if (method == "descriptorSize") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->descriptorSize());
    }
    else if (method == "descriptorType") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(ClassNameInvMap[obj->descriptorType()]);
    }
    else if (method == "detect") {
        if (nrhs<3 || (nrhs%2)!=1 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat mask;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
            }
            Mat image(rhs[2].toMat());
            vector<KeyPoint> keypoints;
            obj->detect(image, keypoints, mask);
            plhs[0] = MxArray(keypoints);
        }
        else if (rhs[2].isCell()) {  // second variant that accepts an image set
            vector<Mat> masks;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask") {
                    //masks = rhs[i+1].toVector<Mat>();
                    vector<MxArray> arr(rhs[i+1].toVector<MxArray>());
                    masks.clear();
                    masks.reserve(arr.size());
                    for (vector<MxArray>::const_iterator iter = arr.begin(); iter != arr.end(); iter++)
                        masks.push_back(iter->toMat(CV_8U));
                }
                else
                    mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
            }
            vector<Mat> images(rhs[2].toVector<Mat>());
            vector<vector<KeyPoint> > keypoints;
            obj->detect(images, keypoints, masks);
            plhs[0] = MxArray(keypoints);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "compute") {
        if (nrhs!=4 || nlhs>2)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat image(rhs[2].toMat()), descriptors;
            vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
            obj->compute(image, keypoints, descriptors);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = MxArray(keypoints);
        }
        else if (rhs[2].isCell()) { // second variant that accepts an image set
            vector<Mat> images(rhs[2].toVector<Mat>()), descriptors;
            vector<vector<KeyPoint> > keypoints(rhs[3].toVector(
                const_mem_fun_ref_t<vector<KeyPoint>, MxArray>(
                &MxArray::toVector<KeyPoint>)));
            obj->compute(images, keypoints, descriptors);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = MxArray(keypoints);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "detectAndCompute") {
        if (nrhs<3 || (nrhs%2)!=1 || nlhs>2)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        Mat mask;
        vector<KeyPoint> keypoints;
        bool useProvidedKeypoints = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else if (key == "Keypoints") {
                keypoints = rhs[i+1].toVector<KeyPoint>();
                useProvidedKeypoints = true;
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat()), descriptors;
        obj->detectAndCompute(image, mask, keypoints, descriptors, useProvidedKeypoints);
        plhs[0] = MxArray(keypoints);
        if (nlhs > 1)
            plhs[1] = MxArray(descriptors);
    }
    else if (method == "get") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "EdgeThreshold")
            plhs[0] = MxArray(obj->getEdgeThreshold());
        else if (prop == "FastThreshold")
            plhs[0] = MxArray(obj->getFastThreshold());
        else if (prop == "FirstLevel")
            plhs[0] = MxArray(obj->getFirstLevel());
        else if (prop == "MaxFeatures")
            plhs[0] = MxArray(obj->getMaxFeatures());
        else if (prop == "NLevels")
            plhs[0] = MxArray(obj->getNLevels());
        else if (prop == "PatchSize")
            plhs[0] = MxArray(obj->getPatchSize());
        else if (prop == "ScaleFactor")
            plhs[0] = MxArray(obj->getScaleFactor());
        else if (prop == "ScoreType")
            plhs[0] = MxArray(ORBScoreTypeInv[obj->getScoreType()]);
        else if (prop == "WTA_K")
            plhs[0] = MxArray(obj->getWTA_K());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "EdgeThreshold")
            obj->setEdgeThreshold(rhs[3].toInt());
        else if (prop == "FastThreshold")
            obj->setFastThreshold(rhs[3].toInt());
        else if (prop == "FirstLevel")
            obj->setFirstLevel(rhs[3].toInt());
        else if (prop == "MaxFeatures")
            obj->setMaxFeatures(rhs[3].toInt());
        else if (prop == "NLevels")
            obj->setNLevels(rhs[3].toInt());
        else if (prop == "PatchSize")
            obj->setPatchSize(rhs[3].toInt());
        else if (prop == "ScaleFactor")
            obj->setScaleFactor(rhs[3].toDouble());
        else if (prop == "ScoreType")
            obj->setScoreType(ORBScoreType[rhs[3].toString()]);
        else if (prop == "WTA_K")
            obj->setWTA_K(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
