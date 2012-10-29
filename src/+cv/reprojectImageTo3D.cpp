/**
 * @file reprojectImageTo3D.cpp
 * @brief mex interface for reprojectImageTo3D
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
    int depth=-1;
    bool handleMissingValues=false;
    for (int i=5; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Depth")
            depth = rhs[i+1].toInt();
        else if (key=="HandleMissingValues")
            handleMissingValues = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat disparity(rhs[0].toMat()), _3dImage;
    Mat Q(rhs[1].toMat(CV_32F));
    reprojectImageTo3D(disparity, _3dImage, Q, handleMissingValues, depth);
    plhs[0] = MxArray(_3dImage);
}
