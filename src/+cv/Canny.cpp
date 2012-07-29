/**
 * @file Canny.cpp
 * @brief mex interface for Canny
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
    double threshold1, threshold2;
    if (rhs[1].numel()==1) {
        threshold1 = rhs[1].toDouble();
        threshold2 = 0.4*threshold1;
    }
    else {
        Scalar_<double> s = rhs[1].toScalar();
        threshold1 = s[0];
        threshold2 = s[1];
    }
    
    int apertureSize=3;
    bool L2gradient=false;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="ApertureSize")
            apertureSize = rhs[i+1].toInt();
        else if (key=="L2Gradient")
            L2gradient = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat image(rhs[0].toMat(CV_8U)), edges;
    Canny(image, edges, threshold1, threshold2, apertureSize, L2gradient);
    plhs[0] = MxArray(edges);
}
