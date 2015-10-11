/**
 * @file KalmanFilter_.cpp
 * @brief mex interface for cv::KalmanFilter
 * @ingroup video
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<KalmanFilter> > obj_;
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
        obj_[++last_id] = makePtr<KalmanFilter>();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<KalmanFilter> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "init") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs==0);
        int dynamParams = rhs[2].toInt();
        int measureParams = rhs[3].toInt();
        int controlParams = 0;
        int type = CV_64F;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="ControlParams")
                controlParams = rhs[i+1].toInt();
            else if (key=="Type")
                type = (rhs[i+1].isChar()) ?
                    ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj->init(dynamParams, measureParams, controlParams, type);
    }
    else if (method == "predict") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        Mat control;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Control")
                control = rhs[i+1].toMat();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        plhs[0] = MxArray(obj->predict(control));
    }
    else if (method == "correct") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat measurement(rhs[2].toMat());
        plhs[0] = MxArray(obj->correct(measurement));
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "statePre")
            plhs[0] = MxArray(obj->statePre);
        else if (prop == "statePost")
            plhs[0] = MxArray(obj->statePost);
        else if (prop == "transitionMatrix")
            plhs[0] = MxArray(obj->transitionMatrix);
        else if (prop == "controlMatrix")
            plhs[0] = MxArray(obj->controlMatrix);
        else if (prop == "measurementMatrix")
            plhs[0] = MxArray(obj->measurementMatrix);
        else if (prop == "measurementNoiseCov")
            plhs[0] = MxArray(obj->measurementNoiseCov);
        else if (prop == "processNoiseCov")
            plhs[0] = MxArray(obj->processNoiseCov);
        else if (prop == "errorCovPre")
            plhs[0] = MxArray(obj->errorCovPre);
        else if (prop == "errorCovPost")
            plhs[0] = MxArray(obj->errorCovPost);
        else if (prop == "gain")
            plhs[0] = MxArray(obj->gain);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "statePre")
            obj->statePre = rhs[3].toMat();
        else if (prop == "statePost")
            obj->statePost = rhs[3].toMat();
        else if (prop == "transitionMatrix")
            obj->transitionMatrix = rhs[3].toMat();
        else if (prop == "controlMatrix")
            obj->controlMatrix = rhs[3].toMat();
        else if (prop == "measurementMatrix")
            obj->measurementMatrix = rhs[3].toMat();
        else if (prop == "measurementNoiseCov")
            obj->measurementNoiseCov = rhs[3].toMat();
        else if (prop == "processNoiseCov")
            obj->processNoiseCov = rhs[3].toMat();
        else if (prop == "errorCovPre")
            obj->errorCovPre = rhs[3].toMat();
        else if (prop == "errorCovPost")
            obj->errorCovPost = rhs[3].toMat();
        else if (prop == "gain")
            obj->gain = rhs[3].toMat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
