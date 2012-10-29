/**
 * @file CascadeClassifier_.cpp
 * @brief mex interface for CascadeClassifier_
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
map<int,CascadeClassifier> obj_;

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
    if (nrhs<1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Determine argument format between (filename,...) or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (nrhs==1 && rhs[0].isChar()) {
        // Constructor is called. Allocate a new classifier from filename
        obj_[++last_id] = CascadeClassifier(rhs[0].toString());
        if (obj_[last_id].empty()) {
            obj_.erase(last_id);
            mexErrMsgIdAndTxt("mexopencv:error","Invalid path or file specified");
        }
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
    CascadeClassifier& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs>0)
            mexErrMsgIdAndTxt("mexopencv:error","Output argument not assigned");
        obj_.erase(id);
    }
    else if (method == "empty") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.empty());
    }
    else if (method == "load") {
        if (nrhs!=3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.load(rhs[2].toString()));
    }
    else if (method == "detectMultiScale") {
        if (nrhs<3 || (nrhs%2)!=1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        
        // Option processing
        double scaleFactor=1.1;
        int minNeighbors=3, flags=0;
        Size minSize, maxSize;
        for (int i=3; i<rhs.size(); i+=2) {
            string key = rhs[i].toString();
            if (key=="ScaleFactor")
                scaleFactor = rhs[i+1].toDouble();
            else if (key=="MinNeighbors")
                minNeighbors = rhs[i+1].toInt();
            else if (key=="Flags")
                flags = rhs[i+1].toInt();
            else if (key=="MinSize")
                minSize = rhs[i+1].toSize();
            else if (key=="MaxSize")
                maxSize = rhs[i+1].toSize();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        
        // Run
        Mat image(rhs[2].toMat());
        vector<Rect> objects;
        obj.detectMultiScale(image, objects, scaleFactor, minNeighbors, flags,
                             minSize, maxSize);
        plhs[0] = MxArray(objects);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
