/**
 * @file Sobel.cpp
 * @brief mex interface for Sobel
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
    int ddepth=-1;
    int xorder=1;
    int yorder=0;
    int ksize=3;
    double scale=1;
    double delta=0;
    int borderType=BORDER_DEFAULT;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DDepth")
            ddepth = rhs[i+1].toInt();
        else if (key=="XOrder")
            xorder = rhs[i+1].toInt();
        else if (key=="YOrder")
            yorder = rhs[i+1].toInt();
        else if (key=="KSize")
            ksize = rhs[i+1].toInt();
        else if (key=="Scale")
            scale = rhs[i+1].toDouble();
        else if (key=="Delta")
            delta = rhs[i+1].toDouble();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Execute function
    Mat img(rhs[0].toMat());
    Sobel(img, img, ddepth, xorder, yorder, ksize, scale, delta, borderType);
    plhs[0] = MxArray(img);
}
