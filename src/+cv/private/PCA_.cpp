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
map<int,Ptr<PCA> > obj_;

/** Data arrangement options
 */
const ConstMap<std::string,int> DataAs = ConstMap<std::string,int>
    ("Row", PCA::DATA_AS_ROW)
    ("Col", PCA::DATA_AS_COL);
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

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj_[++last_id] = makePtr<PCA>();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<PCA> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "read") {
        if (nrhs<3 || (nrhs%2)==0 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error","Failed to open file");
        obj->read(fs.root());
    }
    else if (method == "write") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        FileStorage fs(rhs[2].toString(), FileStorage::WRITE);
        obj->write(fs);
    }
    else if (method == "compute") {
        if (nrhs<3 || (nrhs%2)!=1 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat mean;
        int flags = PCA::DATA_AS_ROW;
        int maxComponents = 0;
        double retainedVariance = 1.0;
        bool use_second_variant = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Mean")
                mean = rhs[i+1].toMat();
            else if (key=="DataAs")
                flags = DataAs[rhs[i+1].toString()];
            else if (key=="MaxComponents")
                maxComponents = rhs[i+1].toInt();
            else if (key=="RetainedVariance") {
                retainedVariance = rhs[i+1].toDouble();
                use_second_variant = true;
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat data(rhs[2].toMat());
        if (use_second_variant)
            obj->operator()(data, mean, flags, retainedVariance);
        else
            obj->operator()(data, mean, flags, maxComponents);
    }
    else if (method == "project") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->project(rhs[2].toMat()));
    }
    else if (method == "backProject") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->backProject(rhs[2].toMat()));
    }
    else if (method == "get") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "eigenvectors")
            plhs[0] = MxArray(obj->eigenvectors);
        else if (prop == "eigenvalues")
            plhs[0] = MxArray(obj->eigenvalues);
        else if (prop == "mean")
            plhs[0] = MxArray(obj->mean);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    else if (method == "set") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "eigenvectors")
            obj->eigenvectors = rhs[3].toMat();
        else if (prop == "eigenvalues")
            obj->eigenvalues = rhs[3].toMat();
        else if (prop == "mean")
            obj->mean = rhs[3].toMat();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
