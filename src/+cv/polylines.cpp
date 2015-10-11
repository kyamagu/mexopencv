/**
 * @file polylines.cpp
 * @brief mex interface for cv::polylines
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool isClosed = true;
    Scalar color;
    int thickness = 1;
    int lineType = cv::LINE_8;
    int shift = 0;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="Thickness")
            thickness = (rhs[i+1].isChar()) ?
                ThicknessType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="LineType")
            lineType = (rhs[i+1].isChar()) ?
                LineType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Shift")
            shift = rhs[i+1].toInt();
        else if (key=="Closed")
            isClosed = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat img(rhs[0].toMat());
    vector<vector<Point> > pts(MxArrayToVectorVectorPoint<int>(rhs[1]));
    polylines(img, pts, isClosed, color, thickness, lineType, shift);
    plhs[0] = MxArray(img);
}
