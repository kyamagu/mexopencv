/**
 * @file calcOpticalFlowFarneback.cpp
 * @brief mex interface for calcOpticalFlowFarneback
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
    
    Mat prevImg(rhs[0].toMat(CV_8U)), nextImg(rhs[1].toMat(CV_8U));
    Mat flow;
    double pyrScale=0.5;
    int levels=1;
    int winsize=3;
    int iterations=10;
    int polyN=5;
    double polySigma=1.1;
    int flags=0;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="InitialFlow") {
            flow = rhs[i+1].toMat(CV_32F);
            flags |= OPTFLOW_USE_INITIAL_FLOW;
        }
        else if (key=="PyrScale")
            pyrScale = rhs[i+1].toDouble();
        else if (key=="Levels")
            levels = rhs[i+1].toInt();
        else if (key=="WinSize")
            winsize = rhs[i+1].toInt();
        else if (key=="Iterations")
            iterations = rhs[i+1].toInt();
        else if (key=="PolyN")
            polyN = rhs[i+1].toInt();
        else if (key=="PolySigma")
            polySigma = rhs[i+1].toDouble();
        else if (key=="Gaussian")
            flags |= OPTFLOW_FARNEBACK_GAUSSIAN;
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    calcOpticalFlowFarneback(prevImg, nextImg, flow, pyrScale, levels, winsize,
        iterations, polyN, polySigma, flags);
    plhs[0] = MxArray(flow);
}
