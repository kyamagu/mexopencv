/**
 * @file DescriptorMatcher_.cpp
 * @brief mex interface for cv::DescriptorMatcher
 * @ingroup features2d
 * @author Kota Yamaguchi
 * @author Amro
 * @date 2012, 2015
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
map<int,Ptr<DescriptorMatcher> > obj_;
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
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createDescriptorMatcher(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<DescriptorMatcher> obj = obj_[id];
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
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
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
    else if (method == "isMaskSupported") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->isMaskSupported());
    }
    else if (method == "getTrainDescriptors") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getTrainDescriptors());
    }
    else if (method == "add") {
        nargchk(nrhs==3 && nlhs==0);
        vector<Mat> descriptors;
        {
            vector<MxArray> va(rhs[2].toVector<MxArray>());
            descriptors.reserve(va.size());
            for (vector<MxArray>::const_iterator it = va.begin(); it != va.end(); ++it)
                descriptors.push_back(it->toMat(
                    it->isUint8() ? CV_8U : CV_32F));
        }
        obj->add(descriptors);
    }
    else if (method == "train") {
        nargchk(nrhs==2 && nlhs==0);
        obj->train();
    }
    else if (method == "match") {
        nargchk(nrhs>=3 && nlhs<=1);
        Mat queryDescriptors(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F));
        vector<DMatch> matches;
        if (nrhs>=4 && rhs[3].isNumeric()) {  // first variant
            nargchk((nrhs%2)==0);
            Mat trainDescriptors(rhs[3].toMat(rhs[3].isUint8() ? CV_8U : CV_32F));
            Mat mask;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            obj->match(queryDescriptors, trainDescriptors, matches, mask);
        }
        else {  // second variant
            nargchk((nrhs%2)==1);
            vector<Mat> masks;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask") {
                    //masks = rhs[i+1].toVector<Mat>();
                    vector<MxArray> va(rhs[i+1].toVector<MxArray>());
                    masks.clear();
                    masks.reserve(va.size());
                    for (vector<MxArray>::const_iterator it = va.begin(); it != va.end(); ++it)
                        masks.push_back(it->toMat(CV_8U));
                }
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            obj->match(queryDescriptors, matches, masks);
        }
        plhs[0] = MxArray(matches);
    }
    else if (method == "knnMatch") {
        nargchk(nrhs>=4 && nlhs<=1);
        Mat queryDescriptors(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F));
        vector<vector<DMatch> > matches;
        if (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric()) {  // first variant
            nargchk((nrhs%2)==1);
            Mat trainDescriptors(rhs[3].toMat(rhs[3].isUint8() ? CV_8U : CV_32F));
            int k = rhs[4].toInt();
            Mat mask;
            bool compactResult = false;
            for (int i=5; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else if (key == "CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            obj->knnMatch(queryDescriptors, trainDescriptors, matches,
                k, mask, compactResult);
        }
        else {  // second variant
            nargchk((nrhs%2)==0);
            int k = rhs[3].toInt();
            vector<Mat> masks;
            bool compactResult = false;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask") {
                    //masks = rhs[i+1].toVector<Mat>();
                    vector<MxArray> va(rhs[i+1].toVector<MxArray>());
                    masks.clear();
                    masks.reserve(va.size());
                    for (vector<MxArray>::const_iterator it = va.begin(); it != va.end(); ++it)
                        masks.push_back(it->toMat(CV_8U));
                }
                else if (key == "CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            obj->knnMatch(queryDescriptors, matches, k, masks, compactResult);
        }
        plhs[0] = MxArray(matches);
    }
    else if (method == "radiusMatch") {
        nargchk(nrhs>=4 && nlhs<=1);
        Mat queryDescriptors(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F));
        vector<vector<DMatch> > matches;
        if (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric()) {  // first variant
            nargchk((nrhs%2)==1);
            Mat trainDescriptors(rhs[3].toMat(rhs[3].isUint8() ? CV_8U : CV_32F));
            float maxDistance = rhs[4].toFloat();
            Mat mask;
            bool compactResult = false;
            for (int i=5; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else if (key == "CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            obj->radiusMatch(queryDescriptors, trainDescriptors, matches,
                maxDistance, mask, compactResult);
        }
        else {  // second variant
            nargchk((nrhs%2)==0);
            float maxDistance = rhs[3].toFloat();
            vector<Mat> masks;
            bool compactResult = false;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask") {
                    //masks = rhs[i+1].toVector<Mat>();
                    vector<MxArray> va(rhs[i+1].toVector<MxArray>());
                    masks.clear();
                    masks.reserve(va.size());
                    for (vector<MxArray>::const_iterator it = va.begin(); it != va.end(); ++it)
                        masks.push_back(it->toMat(CV_8U));
                }
                else if (key == "CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            obj->radiusMatch(queryDescriptors, matches,
                maxDistance, masks, compactResult);
        }
        plhs[0] = MxArray(matches);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
