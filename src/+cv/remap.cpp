/**
 * @file remap.cpp
 * @brief mex interface for remap
 * @author Kota Yamaguchi
 * @date 2012
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
    if (nrhs<2 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Decide argument format
    Mat map2;
    int opts = 2; // start of optional args
    if (nrhs>2 && rhs[2].isNumeric()) {
        map2 = (rhs[2].classID()==mxUINT16_CLASS) ? 
            rhs[2].toMat(CV_16U) : rhs[2].toMat(CV_32F);
        opts = 3;
    }
    
    // Option processing
    int interpolation=INTER_LINEAR;
    int borderType=BORDER_CONSTANT;
    Scalar borderValue;
    for (int i=opts; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Interpolation") {
            interpolation = InterType[rhs[i+1].toString()];
            if (interpolation==INTER_AREA)
                mexErrMsgIdAndTxt("mexopencv:error","'Area' is not supported");
        }
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key=="BorderValue")
            borderValue = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Apply
    Mat src(rhs[0].toMat()), dst;
    Mat map1 = (rhs[1].classID()==mxINT16_CLASS && rhs[1].ndims()>2) ?
        rhs[1].toMat(CV_16S) : rhs[1].toMat(CV_32F); 
    remap(src, dst, map1, map2, interpolation, borderType, borderValue);
    plhs[0] = MxArray(dst);
}
