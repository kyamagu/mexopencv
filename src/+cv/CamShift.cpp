/**
 * @file CamShift.cpp
 * @brief mex interface for CamShift
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
    if (nrhs<2 || ((nrhs%2)!=0) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat probImage(rhs[0].toMat());
    Rect window(rhs[1].toRect());
    TermCriteria criteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 10, 1);
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    plhs[0] = MxArray(CamShift(probImage,window,criteria));
}
