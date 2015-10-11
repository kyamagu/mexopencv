/**
 * @file getTextSize.cpp
 * @brief mex interface for cv::getTextSize
 * @ingroup imgproc
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int fontFace = cv::FONT_HERSHEY_SIMPLEX;
    int fontStyle = 0;
    double fontScale = 1.0;
    int thickness = 1;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="FontFace")
            fontFace = FontFace[rhs[i+1].toString()];
        else if (key=="FontStyle")
            fontStyle = FontStyle[rhs[i+1].toString()];
        else if (key=="FontScale")
            fontScale = rhs[i+1].toDouble();
        else if (key=="Thickness")
            thickness = (rhs[i+1].isChar()) ?
                ThicknessType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option");
    }
    fontFace |= fontStyle;

    // Process
    const string text(rhs[0].toString());
    int baseLine = 0;
    Size s = getTextSize(text, fontFace, fontScale, thickness, &baseLine);
    plhs[0] = MxArray(s);
    if (nlhs>1)
        plhs[1] = MxArray(baseLine);
}
