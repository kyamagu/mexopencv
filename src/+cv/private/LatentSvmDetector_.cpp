/**
 * @file LatentSvmDetector_.cpp
 * @brief mex interface for LatentSvmDetector
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,LatentSvmDetector> obj_;

/// Alias for argument number check
inline void nargchk(bool cond)
{
    if (!cond)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
}

/** Convert object detections to struct array
 * @param vo vector of detections
 */
mxArray* ObjectDetection2Struct(
    const vector<LatentSvmDetector::ObjectDetection> vo,
    const vector<string>& classNames)
{
    const char* fields[] = {"rect","score","class"};
    MxArray m(fields,3,1,vo.size());
    for (int i=0; i<vo.size(); ++i) {
        m.set("rect", vo[i].rect, i);
        m.set("score", vo[i].score, i);
        m.set("class", classNames[vo[i].classID], i);
    }
    return m;
}

} // local scope

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
    nargchk(nrhs>=2 && nlhs<=2);
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());
    
    // Constructor call
    if (method == "new") {
        nargchk(nlhs<=1 && nrhs<=4);
        obj_[++last_id] = LatentSvmDetector();
        // Due to the buggy implementation of LatentSvmDetector in OpenCV
        // we cannot use the constructor syntax other than empty args.
        plhs[0] = MxArray(last_id);
        return;
    }
    
    // Big operation switch
    LatentSvmDetector& obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj.clear();
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.empty());
    }
    else if (method == "load") {
        nargchk(nrhs<=4 && nlhs<=1);
        plhs[0] = (nrhs==3) ? MxArray(obj.load(rhs[2].toVector<string>())) :
            MxArray(obj.load(rhs[2].toVector<string>(), rhs[3].toVector<string>()));
    }
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        Mat image((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<LatentSvmDetector::ObjectDetection> objectDetections;
        float overlapThreshold=0.5f;
        int numThreads=-1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="OverlapThreshold")
                overlapThreshold = rhs[i+1].toDouble();
            else if (key=="NumThreads")
                numThreads = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }
        obj.detect(image,objectDetections,overlapThreshold,numThreads);
        plhs[0] = ObjectDetection2Struct(objectDetections, obj.getClassNames());
    }
    else if (method == "getClassNames") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.getClassNames());
    }
    else if (method == "getClassCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(static_cast<int>(obj.getClassCount()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation %s", method.c_str());
}
