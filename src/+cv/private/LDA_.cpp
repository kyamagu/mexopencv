/**
 * @file LDA_.cpp
 * @brief mex interface for LDA_
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<LDA> > obj_;
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
    if (nrhs<2 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int num_components = 0;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="NumComponents")
                num_components = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[++last_id] = makePtr<LDA>(num_components);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<LDA> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "load") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->load(rhs[2].toString());
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->save(rhs[2].toString());
    }
    else if (method == "compute") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat labels(rhs[3].toMat());
        if (rhs[2].isCell()) {
            vector<Mat> src(rhs[2].toVector<Mat>());
            obj->compute(src, labels);
        }
        else {
            Mat src(rhs[2].toMat());
            obj->compute(src, labels);
        }
    }
    else if (method == "project") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat src(rhs[2].toMat());
        plhs[0] = MxArray(obj->project(src));
    }
    else if (method == "reconstruct") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat src(rhs[2].toMat());
        plhs[0] = MxArray(obj->reconstruct(src));
    }
    else if (method == "get") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "eigenvalues")
            plhs[0] = MxArray(obj->eigenvalues());
        else if (prop == "eigenvectors")
            plhs[0] = MxArray(obj->eigenvectors());
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
