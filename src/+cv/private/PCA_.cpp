/**
 * @file PCA_.cpp
 * @brief mex interface for PCA_
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,PCA> obj_;
/** Data arrangement options
 */
const ConstMap<std::string,int> DataAs = ConstMap<std::string,int>
    ("row",CV_PCA_DATA_AS_ROW)
    ("col",CV_PCA_DATA_AS_COL);
}

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
        obj_[++last_id] = PCA();
        plhs[0] = MxArray(last_id);
        return;
    }
    
    PCA& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "compute") {
        if (nrhs<3 || (nrhs%2)!=1 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat data(rhs[2].toMat());
        Mat mean;
        int flags=CV_PCA_DATA_AS_ROW;
        int maxComponents=0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Mean")
                mean = rhs[i+1].toMat();
            else if (key=="DataAs")
                flags = DataAs[rhs[i+1].toString()];
            else if (key=="MaxComponents")
                maxComponents = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj(data, mean, flags, maxComponents);
    }
    else if (method == "project") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.project(rhs[2].toMat()));
    }
    else if (method == "backProject") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.backProject(rhs[2].toMat()));
    }
    else if (method == "eigenvectors") {
        if (nrhs==3 && nlhs==0)
            obj.eigenvectors = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.eigenvectors);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "eigenvalues") {
        if (nrhs==3 && nlhs==0)
            obj.eigenvalues = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.eigenvalues);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else if (method == "mean") {
        if (nrhs==3 && nlhs==0)
            obj.mean = rhs[2].toMat();
        else if (nrhs==2 && nlhs==1)
            plhs[0] = MxArray(obj.mean);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
