/**
 * @file DescriptorExtractor_.cpp
 * @brief mex interface for DescriptorExtractor
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/nonfree/nonfree.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DescriptorExtractor> > obj_;

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
    if (nrhs<1 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    if (last_id==0)
        initModule_nonfree();
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (rhs[0].isChar() && nrhs==1) {
        // Constructor is called. Create a new object from argument
        string descriptorExtractorType(rhs[0].toString());
        obj_[++last_id] = DescriptorExtractor::create(descriptorExtractorType);
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
    Ptr<DescriptorExtractor> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "size") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->descriptorSize());
    }
    else if (method == "type") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->descriptorType());
    }
    else if (method == "compute") {
        if (nrhs!=4)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat image(rhs[2].toMat()), descriptors;
        vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
        obj->compute(image, keypoints, descriptors);
        plhs[0] = MxArray(descriptors);
        if (nlhs>1)
            plhs[1] = MxArray(keypoints);
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
