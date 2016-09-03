/**
 * @file LDA_.cpp
 * @brief mex interface for cv::LDA
 * @ingroup core
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
    // Check the number of arguments
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
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
    // static method calls
    else if (method == "subspaceProject") {
        nargchk(nrhs==5 && nlhs<=1);
        Mat W(rhs[2].toMat(CV_64F)),
            mean(rhs[3].toMat(CV_64F)),
            src(rhs[4].toMat(CV_64F)),
            dst;
        dst = LDA::subspaceProject(W, mean, src);
        plhs[0] = MxArray(dst);
        return;
    }
    else if (method == "subspaceReconstruct") {
        nargchk(nrhs==5 && nlhs<=1);
        Mat W(rhs[2].toMat(CV_64F)),
            mean(rhs[3].toMat(CV_64F)),
            src(rhs[4].toMat(CV_64F)),
            dst;
        dst = LDA::subspaceReconstruct(W, mean, src);
        plhs[0] = MxArray(dst);
        return;
    }

    // Big operation switch
    Ptr<LDA> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "load") {
        nargchk(nrhs==3 && nlhs==0);
        obj->load(rhs[2].toString());
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "compute") {
        nargchk(nrhs==4 && nlhs==0);
        Mat labels(rhs[3].toMat(CV_32S));
        if (rhs[2].isCell()) {
            vector<Mat> src(rhs[2].toVector<Mat>());
            obj->compute(src, labels);
        }
        else {
            Mat src(rhs[2].toMat(CV_64F));
            obj->compute(src, labels);
        }
    }
    else if (method == "project") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat(CV_64F));
        plhs[0] = MxArray(obj->project(src));
    }
    else if (method == "reconstruct") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat(CV_64F));
        plhs[0] = MxArray(obj->reconstruct(src));
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
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
