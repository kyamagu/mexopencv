/**
 * @file warpAffine.cpp
 * @brief mex interface for warpAffine
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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat src(rhs[0].toMat());
    Size dsize = src.size();
    int interpolation=INTER_LINEAR;
    bool warp_inverse=false;
    int borderType=BORDER_CONSTANT;
    Scalar borderValue;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DSize")
            dsize = rhs[i+1].toSize();
        else if (key=="Interpolation")
            interpolation = InterType[rhs[i+1].toString()];
        else if (key=="WarpInverse")
            warp_inverse = rhs[i+1].toBool();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key=="BorderValue")
            borderValue = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    Mat M(rhs[1].toMat()), dst;
    int flags = interpolation | ((warp_inverse) ? cv::WARP_INVERSE_MAP : 0);
    warpAffine(src, dst, M, dsize, flags, borderType, borderValue);
    plhs[0] = MxArray(dst);
}
