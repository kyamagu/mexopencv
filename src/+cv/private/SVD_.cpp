/**
 * @file SVD_.cpp
 * @brief mex interface for cv::SVD
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
map<int,Ptr<SVD> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = makePtr<SVD>();
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (method == "backSubst_static") {
        nargchk(nrhs==6 && nlhs<=1);
        Mat w(rhs[2].toMat()),
            u(rhs[3].toMat()),
            vt(rhs[4].toMat()),
            src(rhs[5].toMat()),
            dst;
        SVD::backSubst(w, u, vt, src, dst);
        plhs[0] = MxArray(dst);
        return;
    }
    else if (method == "solveZ_static") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat()), dst;
        SVD::solveZ(src, dst);
        plhs[0] = MxArray(dst);
        return;
    }
    else if (method == "compute_static") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=3);
        int flags = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Flags")
                flags = rhs[i+1].toInt();
            else if (key=="ModifyA")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), SVD::MODIFY_A);
            else if (key=="NoUV")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), SVD::NO_UV);
            else if (key=="FullUV")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), SVD::FULL_UV);
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat src(rhs[2].toMat()), w, u, vt;
        SVD::compute(src, w, u, vt, flags);
        plhs[0] = MxArray(w);
        if (nlhs>1)
            plhs[1] = MxArray(u);
        if (nlhs>2)
            plhs[2] = MxArray(vt);
        return;
    }

    // Big operation switch
    Ptr<SVD> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "compute") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        int flags = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Flags")
                flags = rhs[i+1].toInt();
            else if (key=="ModifyA")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), SVD::MODIFY_A);
            else if (key=="NoUV")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), SVD::NO_UV);
            else if (key=="FullUV")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), SVD::FULL_UV);
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat src(rhs[2].toMat());
        obj->operator()(src, flags);
    }
    else if (method == "backSubst") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat()), dst;
        obj->backSubst(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "u")
            plhs[0] = MxArray(obj->u);
        else if (prop == "vt")
            plhs[0] = MxArray(obj->vt);
        else if (prop == "w")
            plhs[0] = MxArray(obj->w);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "u")
            obj->u = rhs[3].toMat();
        else if (prop == "vt")
            obj->vt = rhs[3].toMat();
        else if (prop == "w")
            obj->w = rhs[3].toMat();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
