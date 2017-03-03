/**
 * @file GPCForest_.cpp
 * @brief mex interface for cv::optflow::GPCForest
 * @ingroup optflow
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/optflow.hpp"
using namespace std;
using namespace cv;
using namespace cv::optflow;

//HACK: most examples in opencv use nTrees=5
static const int nTrees = 5;
typedef cv::optflow::GPCForest<nTrees> GPCForest5;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<GPCForest5> > obj_;

/// GPC descriptor types for option processing
const ConstMap<string,GPCDescType> GPCDescTypeMap = ConstMap<string,GPCDescType>
    ("DCT", cv::optflow::GPC_DESCRIPTOR_DCT)
    ("WHT", cv::optflow::GPC_DESCRIPTOR_WHT);

/** Convert correspondences to struct array
 * @param correspondences vector of pairs of points
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<pair<Point2i,Point2i> >& correspondences)
{
    const char *fields[] = {"first", "second"};
    MxArray s = MxArray::Struct(fields, 2, 1, correspondences.size());
    for (mwIndex i = 0; i < correspondences.size(); ++i) {
        s.set("first",  correspondences[i].first,  i);
        s.set("second", correspondences[i].second, i);
    }
    return s;
}
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
        obj_[++last_id] = GPCForest5::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<GPCForest5> obj = obj_[id];
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
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<GPCForest5>(rhs[2].toString(), objname) :
            Algorithm::load<GPCForest5>(rhs[2].toString(), objname));
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
    else if (method == "train") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs==0);
        unsigned maxTreeDepth = 20;
        int minNumberOfSamples = 3;
        GPCDescType descriptorType = GPC_DESCRIPTOR_DCT;
        bool printProgress = false;  // default was true
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "MaxTreeDepth")
                maxTreeDepth = static_cast<unsigned>(rhs[i+1].toInt());
            else if (key == "MinNumberOfSamples")
                minNumberOfSamples = rhs[i+1].toInt();
            else if (key == "DescriptorType")
                descriptorType = GPCDescTypeMap[rhs[i+1].toString()];
            else if (key == "PrintProgress")
                printProgress = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        GPCTrainingParams params(
            maxTreeDepth, minNumberOfSamples, descriptorType, printProgress);
        if (!rhs[2].isCell() || !rhs[3].isCell() || !rhs[4].isCell())
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
        if (!rhs[2].isEmpty() && rhs[2].at<MxArray>(0).isChar()) {
            vector<string> imagesFrom(rhs[2].toVector<string>()),
                           imagesTo(rhs[3].toVector<string>()),
                           gt(rhs[4].toVector<string>());
            obj->train(
                vector<String>(imagesFrom.begin(), imagesFrom.end()),
                vector<String>(imagesTo.begin(), imagesTo.end()),
                vector<String>(gt.begin(), gt.end()),
                params);
        }
        else {
            vector<Mat> imagesFrom(rhs[2].toVector<Mat>()),
                        imagesTo(rhs[3].toVector<Mat>()),
                        gt(rhs[4].toVector<Mat>());
            obj->train(imagesFrom, imagesTo, gt, params);
        }
    }
    else if (method == "findCorrespondences") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        bool useOpenCL = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "UseOpenCL")
                useOpenCL = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        GPCMatchingParams params(useOpenCL);
        Mat imgFrom(rhs[2].toMat()),
            imgTo(rhs[3].toMat());
        vector<pair<Point2i,Point2i> > corr;
        obj->findCorrespondences(imgFrom, imgTo, corr, params);
        plhs[0] = toStruct(corr);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
