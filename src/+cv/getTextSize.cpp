/**
 * @file getTextSize.cpp
 * @brief mex interface for getTextSize
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
    if (nrhs<1 || (nrhs%2)!=1 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    const string text(rhs[0].toString());
    int fontFace = cv::FONT_HERSHEY_SIMPLEX;
    double fontScale = 1.0;
    int thickness = 1;
    int fontStyle = 0;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="FontFace")
            fontFace = FontFace[rhs[i+1].toString()];
        else if (key=="FontScale")
            fontScale = rhs[i+1].toDouble();
        else if (key=="Thickness")
            thickness = rhs[i+1].toInt();
        else if (key=="FontStyle")
            fontStyle = FontStyle[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option");
    }

    // Execute function
    int baseLine = 0;
    Size s = getTextSize(text, fontFace | fontStyle, fontScale, thickness,
        &baseLine);
    plhs[0] = MxArray(s);
    if (nlhs>1)
        plhs[1] = MxArray(baseLine);
}
