/**
 * @file StereoBM_.cpp
 * @brief mex interface for StereoBM_
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Methods for option processing
 */
const ConstMap<std::string,int> Preset = ConstMap<std::string,int>
    ("Basic",    StereoBM::BASIC_PRESET)
    ("FishEye",    StereoBM::FISH_EYE_PRESET)
    ("Narrow",    StereoBM::NARROW_PRESET);

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,StereoBM> obj_;

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
        obj_[++last_id] = StereoBM();
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
    StereoBM& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "init") {
        if ((nrhs%2)!=0 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int preset=StereoBM::BASIC_PRESET;
        int ndisparities=0;
        int SADWindowSize=21;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Preset")
                preset = Preset[rhs[i+1].toString()];
            else if (key=="NDisparities")
                ndisparities = rhs[i+1].toInt();
            else if (key=="SADWindowSize")
                SADWindowSize = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj.init(preset, ndisparities, SADWindowSize);
    }
    else if (method == "compute") {
        if (nrhs<4 || (nrhs%2)!=0 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat left(rhs[2].toMat(CV_8U)), right(rhs[3].toMat(CV_8U));
        Mat disparity;
        int disptype=CV_16S;
        for (int i=4; i<nrhs; ++i) {
            string key(rhs[i].toString());
            if (key=="Disptype")
                disptype = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj(left,right,disparity,disptype);
        plhs[0] = MxArray(disparity);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
