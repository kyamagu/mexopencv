/**
 * @file putText.cpp
 * @brief mex interface for putText
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
    if (nrhs<3 || (nrhs%2)!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat img = rhs[0].toMat();
    string text(rhs[1].toString());
    Point org(rhs[2].toPoint());
    int fontFace=FONT_HERSHEY_SIMPLEX;
    double fontScale=1.0;
    Scalar color;
    int thickness=1;
    int lineType=8;
    bool bottomLeftOrigin=false;
    int fontStyle=0;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="FontFace")
            fontFace = FontFace[rhs[i+1].toString()];
        else if (key=="FontScale")
            fontScale = rhs[i+1].toDouble();
        else if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="Thickness")
            thickness = rhs[i+1].toInt();
        else if (key=="LineType")
            lineType = (rhs[i+1].isChar()) ?
                LineType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="BottomLeftOrigin")
            bottomLeftOrigin = rhs[i+1].toBool();
        else if (key=="FontStyle")
            fontStyle = FontStyle[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Execute function
    putText(img, text, org, fontFace | fontStyle, fontScale, color, thickness,
        lineType, bottomLeftOrigin);
    plhs[0] = MxArray(img);
}
