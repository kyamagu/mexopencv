/**
 * @file HfsSegment_.cpp
 * @brief mex interface for cv::hfs::HfsSegment
 * @ingroup hfs
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/hfs.hpp"
using namespace std;
using namespace cv;
using namespace cv::hfs;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<HfsSegment> > obj_;

/// backends for option processing
enum { HFS_BACKEND_CPU, HFS_BACKEND_GPU };
const ConstMap<string, int> BackendsMap = ConstMap<string, int>
    ("CPU", HFS_BACKEND_CPU)
    ("GPU", HFS_BACKEND_GPU);
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
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        float segEgbThresholdI = 0.08f;
        int minRegionSizeI = 100;
        float segEgbThresholdII = 0.28f;
        int minRegionSizeII = 200;
        float spatialWeight = 0.6f;
        int slicSpixelSize = 8;
        int numSlicIter = 5;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "SegEgbThresholdI")
                segEgbThresholdI = rhs[i+1].toFloat();
            else if (key == "MinRegionSizeI")
                minRegionSizeI = rhs[i+1].toInt();
            else if (key == "SegEgbThresholdII")
                segEgbThresholdII = rhs[i+1].toFloat();
            else if (key == "MinRegionSizeII")
                minRegionSizeII = rhs[i+1].toInt();
            else if (key == "SpatialWeight")
                spatialWeight = rhs[i+1].toFloat();
            else if (key == "SlicSpixelSize")
                slicSpixelSize = rhs[i+1].toInt();
            else if (key == "NumSlicIter")
                numSlicIter = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        int height = rhs[2].toInt(),
            width = rhs[3].toInt();
        obj_[++last_id] = HfsSegment::create(height, width,
            segEgbThresholdI, minRegionSizeI, segEgbThresholdII,
            minRegionSizeII, spatialWeight, slicSpixelSize, numSlicIter);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<HfsSegment> obj = obj_[id];
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
            Algorithm::loadFromString<HfsSegment>(rhs[2].toString(), objname) :
            Algorithm::load<HfsSegment>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing HfsSegment::create()
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
    else if (method == "performSegment") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        bool ifDraw = true;
        int backend = HFS_BACKEND_CPU;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Draw")
                ifDraw = rhs[i+1].toBool();
            else if (key == "Backend")
                backend = BackendsMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat src(rhs[2].toMat()), dst;
        dst = (backend == HFS_BACKEND_CPU) ?
            obj->performSegmentCpu(src, ifDraw) :
            obj->performSegmentGpu(src, ifDraw);
        plhs[0] = MxArray(dst);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "SegEgbThresholdI")
            plhs[0] = MxArray(obj->getSegEgbThresholdI());
        else if (prop == "MinRegionSizeI")
            plhs[0] = MxArray(obj->getMinRegionSizeI());
        else if (prop == "SegEgbThresholdII")
            plhs[0] = MxArray(obj->getSegEgbThresholdII());
        else if (prop == "MinRegionSizeII")
            plhs[0] = MxArray(obj->getMinRegionSizeII());
        else if (prop == "SpatialWeight")
            plhs[0] = MxArray(obj->getSpatialWeight());
        else if (prop == "SlicSpixelSize")
            plhs[0] = MxArray(obj->getSlicSpixelSize());
        else if (prop == "NumSlicIter")
            plhs[0] = MxArray(obj->getNumSlicIter());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "SegEgbThresholdI")
            obj->setSegEgbThresholdI(rhs[3].toFloat());
        else if (prop == "MinRegionSizeI")
            obj->setMinRegionSizeI(rhs[3].toInt());
        else if (prop == "SegEgbThresholdII")
            obj->setSegEgbThresholdII(rhs[3].toFloat());
        else if (prop == "MinRegionSizeII")
            obj->setMinRegionSizeII(rhs[3].toInt());
        else if (prop == "SpatialWeight")
            obj->setSpatialWeight(rhs[3].toFloat());
        else if (prop == "SlicSpixelSize")
            obj->setSlicSpixelSize(rhs[3].toInt());
        else if (prop == "NumSlicIter")
            obj->setNumSlicIter(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
