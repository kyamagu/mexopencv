/**
 * @file ellipse.cpp
 * @brief mex interface for cv::ellipse
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // cv::ellipse has two overloaded variants
    bool rrect_variant = rhs[1].isStruct();
    nargchk(rrect_variant ? ((nrhs%2)==0) : (nrhs>=3 && (nrhs%2)==1));

    // Option processing
    double angle = 0;
    double startAngle = 0;
    double endAngle = 360;
    Scalar color;
    int thickness = 1;
    int lineType = cv::LINE_8;
    int shift = 0;
    for (int i=(rrect_variant ? 2 : 3); i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Angle" && !rrect_variant)
            angle = rhs[i+1].toDouble();
        else if (key=="StartAngle" && !rrect_variant)
            startAngle = rhs[i+1].toDouble();
        else if (key=="EndAngle" && !rrect_variant)
            endAngle = rhs[i+1].toDouble();
        else if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="Thickness")
            thickness = (rhs[i+1].isChar()) ?
                ThicknessType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="LineType")
            lineType = (rhs[i+1].isChar()) ?
                LineType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Shift" && !rrect_variant)
            shift = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img(rhs[0].toMat());
    if (!rrect_variant) {
        Point center(rhs[1].toPoint());
        Size axes(rhs[2].toSize());
        ellipse(img, center, axes, angle, startAngle, endAngle,
            color, thickness, lineType, shift);
    }
    else {
        RotatedRect box(rhs[1].toRotatedRect());
        ellipse(img, box, color, thickness, lineType);
    }
    plhs[0] = MxArray(img);
}
