/**
 * @file KalmanFilter_.cpp
 * @brief mex interface for KalmanFilter_
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,KalmanFilter> obj_;

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
    if (nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (nrhs==0) {
        // Constructor is called. Create a new object from argument
        obj_[++last_id] = KalmanFilter();
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (rhs[0].isNumeric() && rhs[0].numel()==1 && nrhs>1) {
        id = rhs[0].toInt();
        method = rhs[1].toString();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    
    // Big operation switch
    KalmanFilter& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "init") {
        if (nrhs<4 || (nrhs%2)!=0 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int dynamParams=rhs[2].toInt();
        int measureParams=rhs[3].toInt();
        int controlParams=0;
        int type=CV_64F;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="ControlParams")
                controlParams = rhs[i+1].toInt();
            else if (key=="type")
                type = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj.init(dynamParams,measureParams,controlParams,type);
    }
    else if (method == "predict") {
        if ((nrhs%2)!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat control;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Control")
                control = rhs[i+1].toMat();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        plhs[0] = MxArray(obj.predict(control));
    }
    else if (method == "correct") {
        if (nrhs!=3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat measurement(rhs[2].toMat());
        plhs[0] = MxArray(obj.correct(measurement));
    }
    else if (method == "statePre") {
        if (nrhs==3 && nlhs==0)
            obj.statePre = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.statePre);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "statePost") {
        if (nrhs==3 && nlhs==0)
            obj.statePost = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.statePost);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "transitionMatrix") {
        if (nrhs==3 && nlhs==0)
            obj.transitionMatrix = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.transitionMatrix);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "controlMatrix") {
        if (nrhs==3 && nlhs==0)
            obj.controlMatrix = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.controlMatrix);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "measurementMatrix") {
        if (nrhs==3 && nlhs==0)
            obj.measurementMatrix = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.measurementMatrix);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "processNoiseCov") {
        if (nrhs==3 && nlhs==0)
            obj.processNoiseCov = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.processNoiseCov);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "measurementNoiseCov") {
        if (nrhs==3 && nlhs==0)
            obj.measurementNoiseCov = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.measurementNoiseCov);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "errorCovPre") {
        if (nrhs==3 && nlhs==0)
            obj.errorCovPre = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.errorCovPre);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "gain") {
        if (nrhs==3 && nlhs==0)
            obj.gain = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.gain);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "errorCovPost") {
        if (nrhs==3 && nlhs==0)
            obj.errorCovPost = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.errorCovPost);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
