/**
 * @file FeatureDetector_.cpp
 * @brief mex interface for FeatureDetector
 * @author Kota Yamaguchi
 * @date 2012
 */
#include <typeinfo>
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<FeatureDetector> > obj_;

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
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (rhs[0].isChar() && nrhs==1) {
        // Constructor is called. Create a new object from argument
        string detectorType(rhs[0].toString());
        obj_[++last_id] = FeatureDetector::create(detectorType);
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
    Ptr<FeatureDetector> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "type") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "detect") {
        if (nrhs<3 || (nrhs%2)!=1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat mask;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        
        Mat image(rhs[2].toMat());
        vector<KeyPoint> keypoints;
        obj->detect(image, keypoints, mask);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "read") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        FileStorage fs(rhs[2].toString(),FileStorage::READ);
        obj->read(fs.root());
    }
    else if (method == "write") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        FileStorage fs(rhs[2].toString(),FileStorage::WRITE);
        obj->write(fs);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
