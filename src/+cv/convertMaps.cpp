/**
 * @file convertMaps.cpp
 * @brief mex interface for convertMaps
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
    if (nrhs<2 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Decide argument format
    Mat map2;
    int opts = 1; // start of optional args
    if (nrhs>1 && rhs[1].isNumeric()) {
        map2 = (rhs[1].classID()==mxUINT16_CLASS) ? 
            rhs[1].toMat(CV_16U) : rhs[1].toMat(CV_32F);
        opts = 2;
    }
    
    // Option processing
    int dstmaptype = CV_16SC2;
    bool nninterpolation = false;
    for (int i=opts; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DstMapType")
            dstmaptype = rhs[i+1].toInt();
        else if (key=="NNInterpolation")
            nninterpolation = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Apply
    Mat dst1, dst2;
    Mat map1 = (rhs[0].classID()==mxINT16_CLASS && rhs[0].ndims()>2) ?
        rhs[0].toMat(CV_16S) : rhs[0].toMat(CV_32F);
    convertMaps(map1, map2, dst1, dst2, dstmaptype, nninterpolation);
    plhs[0] = MxArray(dst1);
    if (nlhs>1)
        plhs[1] = MxArray(dst2);
}
