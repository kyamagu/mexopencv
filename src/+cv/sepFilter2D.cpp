/**
 * @file sepFilter2D.cpp
 * @brief mex interface for sepFilter2D
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
    if (nrhs<3 || (nrhs%2)!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Point anchor(-1,-1);
    int ddepth = -1;
    int delta = 0;
    int borderType = BORDER_DEFAULT;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key=="DDepth")
            ddepth = rhs[i+1].toInt();
        else if (key=="Delta")
            delta = rhs[i+1].toInt();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Convert mxArray to cv::Mat
    Mat img(rhs[0].toMat());
    Mat rowKernel(rhs[1].toMat()), columnKernel(rhs[2].toMat());
    
    // Apply filter 2D
    // There seems to be a bug in filter when BORDER_CONSTANT is used
    sepFilter2D(
        img,                    // src type
        img,                    // dst type
        ddepth,                 // dst depth
        rowKernel,              // 1D kernel
        columnKernel,           // 1D kernel
        anchor,                 // anchor point, center if (-1,-1)
        delta,                  // bias added after filtering
        borderType                // border type
        );
    
    // Convert cv::Mat to mxArray
    plhs[0] = MxArray(img);
}
