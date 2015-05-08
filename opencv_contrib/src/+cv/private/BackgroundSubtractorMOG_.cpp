/**
 * @file BackgroundSubtractorMOG_.cpp
 * @brief mex interface for BackgroundSubtractorMOG_
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/video/background_segm.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,BackgroundSubtractorMOG> obj_;

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
    if (nrhs<2 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (nrhs>1 && rhs[0].isNumeric() && rhs[1].isChar()) {
        id = rhs[0].toInt();
        method = rhs[1].toString();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");

    // Big operation switch
    if (method == "new") {
        if (nrhs>4 && (nrhs%2)==1) {
            int history = rhs[2].toInt();
            int nmixtures = rhs[3].toInt();
            double backgroundRatio = rhs[4].toDouble();
            double noiseSigma=0;
            for (int i=5;i<nrhs;i+=2) {
                string key(rhs[i].toString());
                if (key=="NoiseSigma")
                    noiseSigma = rhs[i+1].toDouble();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj_[++last_id] = BackgroundSubtractorMOG(
                history,nmixtures,backgroundRatio,noiseSigma);
        }
        else if (nrhs==2)
            obj_[++last_id] = BackgroundSubtractorMOG();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
        plhs[0] = MxArray(last_id);
        return;
    }

    BackgroundSubtractorMOG& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "apply") {
        if (nrhs<3 || (nrhs%2)!=1 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        double learningRate=0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="LearningRate")
                learningRate = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat image(rhs[2].toMat()), fgmask;
        obj(image, fgmask, learningRate);
        plhs[0] = MxArray(fgmask,mxLOGICAL_CLASS);
    }
    else if (method == "getBackgroundImage") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat im;
        obj.getBackgroundImage(im);
        plhs[0] = MxArray(im);
    }
    else if (method == "history" || method == "nmixtures") {
        if (nrhs==3 && nlhs==0)
            obj.set(method, rhs[2].toInt());
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.get<int>(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "backgroundRatio" || method == "noiseSigma") {
        if (nrhs==3 && nlhs==0)
            obj.set(method, rhs[2].toDouble());
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.get<double>(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
