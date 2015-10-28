/**
 * @file MSER_.cpp
 * @brief mex interface for cv::MSER
 * @ingroup features2d
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
map<int,Ptr<MSER> > obj_;
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
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = createMSER(rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<MSER> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
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
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<MSER>(rhs[2].toString(), objname) :
            Algorithm::load<MSER>(rhs[2].toString(), objname));
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
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat mask;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            Mat image(rhs[2].toMat(CV_8U));
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
                    for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                        masks.push_back(it->toMat(CV_8U));
                }
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(CV_8U));
            }
            vector<vector<KeyPoint> > keypoints;
            obj->detect(images, keypoints, masks);
            plhs[0] = MxArray(keypoints);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "detectRegions") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat image(rhs[2].toMat(CV_8U));
        vector<vector<Point> > msers;
        vector<Rect> bboxes;
        obj->detectRegions(image, msers, bboxes);
        plhs[0] = MxArray(msers);
        if (nlhs > 1)
            plhs[1] = MxArray(bboxes);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Delta")
            plhs[0] = MxArray(obj->getDelta());
        else if (prop == "MaxArea")
            plhs[0] = MxArray(obj->getMaxArea());
        else if (prop == "MinArea")
            plhs[0] = MxArray(obj->getMinArea());
        else if (prop == "Pass2Only")
            plhs[0] = MxArray(obj->getPass2Only());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Delta")
            obj->setDelta(rhs[3].toInt());
        else if (prop == "MaxArea")
            obj->setMaxArea(rhs[3].toInt());
        else if (prop == "MinArea")
            obj->setMinArea(rhs[3].toInt());
        else if (prop == "Pass2Only")
            obj->setPass2Only(rhs[3].toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    //else if (method == "defaultNorm")
    //else if (method == "descriptorSize")
    //else if (method == "descriptorType")
    //else if (method == "compute")
    //else if (method == "detectAndCompute")
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
