/**
 * @file TickMeter_.cpp
 * @brief mex interface for cv::TickMeter and related functions
 * @ingroup core
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<TickMeter> > obj_;

/** MxArray constructor from 64-bit integer.
 * @param i int value.
 * @return MxArray object, a scalar int64 array.
 */
MxArray toMxArray(int64_t i)
{
    MxArray arr(mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL));
    if (arr.isNull())
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    arr.set(0, i);
    return arr;
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
        obj_[++last_id] = makePtr<TickMeter>();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method calls
    else if (method == "getTickCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = toMxArray(getTickCount());
        return;
    }
    else if (method == "getTickFrequency") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(getTickFrequency());
        return;
    }
    else if (method == "getCPUTickCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = toMxArray(getCPUTickCount());
        return;
    }

    // Big operation switch
    Ptr<TickMeter> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "start") {
        nargchk(nrhs==2 && nlhs==0);
        obj->start();
    }
    else if (method == "stop") {
        nargchk(nrhs==2 && nlhs==0);
        obj->stop();
    }
    else if (method == "reset") {
        nargchk(nrhs==2 && nlhs==0);
        obj->reset();
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "TimeTicks")
            plhs[0] = toMxArray(obj->getTimeTicks());
        else if (prop == "TimeMicro")
            plhs[0] = MxArray(obj->getTimeMicro());
        else if (prop == "TimeMilli")
            plhs[0] = MxArray(obj->getTimeMilli());
        else if (prop == "TimeSec")
            plhs[0] = MxArray(obj->getTimeSec());
        else if (prop == "Counter")
            plhs[0] = toMxArray(obj->getCounter());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
