/**
 * @file pyrMeanShiftFiltering.cpp
 * @brief mex interface for pyrMeanShiftFiltering
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

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
    if (nrhs<1 || (nrhs%2)!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    double sp = 5;
    double sr = 10;
    int maxLevel=1;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="SP")
            sp = rhs[i+1].toDouble();
        else if (key=="SR")
            sr = rhs[i+1].toDouble();
        else if (key=="MaxLevel")
            maxLevel = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat src(rhs[0].toMat()), dst;
    pyrMeanShiftFiltering(src, dst, sp, sr, maxLevel);
    plhs[0] = MxArray(dst);
}
