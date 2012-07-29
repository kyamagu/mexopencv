/**
 * @file StereoSGBM_.cpp
 * @brief mex interface for StereoSGBM_
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
map<int,StereoSGBM> obj_;

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
        obj_[++last_id] = StereoSGBM();
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (rhs[0].isChar() ) {
        // Constructor is called. Create a new object from argument
        if ((nrhs%2)!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int minDisparity=0;
        int numDisparities=64;
        int SADWindowSize=7;
        int P1=0;
        int P2=0;
        int disp12MaxDiff=0;
        int preFilterCap=0;
        int uniquenessRatio=0;
        int speckleWindowSize=0;
        int speckleRange=0;
        bool fullDP=false;
        for (int i=0; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MinDisparity")
                minDisparity = rhs[i+1].toInt();
            else if (key=="NumDisparities")
                numDisparities = rhs[i+1].toInt();
            else if (key=="SADWindowSize")
                SADWindowSize = rhs[i+1].toInt();
            else if (key=="P1")
                P1 = rhs[i+1].toInt();
            else if (key=="P2")
                P2 = rhs[i+1].toInt();
            else if (key=="Disp12MaxDiff")
                disp12MaxDiff = rhs[i+1].toInt();
            else if (key=="PreFilterCap")
                preFilterCap = rhs[i+1].toInt();
            else if (key=="UniquenessRatio")
                uniquenessRatio = rhs[i+1].toInt();
            else if (key=="SpeckleWindowSize")
                speckleWindowSize = rhs[i+1].toInt();
            else if (key=="SpeckleRange")
                speckleRange = rhs[i+1].toInt();
            else if (key=="FullDP")
                fullDP = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[++last_id] = StereoSGBM(minDisparity, numDisparities,
            SADWindowSize, P1, P2, disp12MaxDiff, preFilterCap, uniquenessRatio,
            speckleWindowSize, speckleRange, fullDP);
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
    StereoSGBM& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "compute") {
        if (nrhs<4 || (nrhs%2)!=0 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat left(rhs[2].toMat(CV_8U)), right(rhs[3].toMat(CV_8U));
        Mat disparity;
        obj(left,right,disparity);
        plhs[0] = MxArray(disparity);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
