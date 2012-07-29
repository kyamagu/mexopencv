/**
 * @file groupRectangles.cpp
 * @brief mex interface for groupRectangles
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

template <>
vector<Rect> MxArray::toVector<Rect>() const
{
    vector<Rect> vr;
    if (isNumeric())
        vr.push_back(toRect());
    else if (isCell()) {
        int n = numel();
        vector<MxArray> vm(toVector<MxArray>());
        vr.reserve(n);
        for (int i=0; i<n; ++i)
            vr.push_back(vm[i].toRect());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    return vr;
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
    // Check the number of arguments
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    vector<Rect> rectList(rhs[0].toVector<Rect>());
    int groupThreshold = rhs[1].toInt();
    double eps=0.2;
    
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="EPS")
            eps = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
    }
    
    groupRectangles(rectList,groupThreshold,eps);
    plhs[0] = MxArray(rectList);
}
