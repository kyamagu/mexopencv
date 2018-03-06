/**
 * @file drawMarker.cpp
 * @brief mex interface for cv::drawMarker
 * @ingroup imgproc
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
using namespace std;
using namespace cv;

namespace {
/// Marker types for option processing
const ConstMap<string,int> MarkerTypeMap = ConstMap<string,int>
    ("Cross",        cv::MARKER_CROSS)
    ("+",            cv::MARKER_CROSS)
    ("TiltedCross",  cv::MARKER_TILTED_CROSS)
    ("x",            cv::MARKER_TILTED_CROSS)
    ("Star",         cv::MARKER_STAR)
    ("*",            cv::MARKER_STAR)
    ("Diamond",      cv::MARKER_DIAMOND)
    ("d",            cv::MARKER_DIAMOND)
    ("Square",       cv::MARKER_SQUARE)
    ("s",            cv::MARKER_SQUARE)
    ("TriangleUp",   cv::MARKER_TRIANGLE_UP)
    ("^",            cv::MARKER_TRIANGLE_UP)
    ("TriangleDown", cv::MARKER_TRIANGLE_DOWN)
    ("v",            cv::MARKER_TRIANGLE_DOWN);
}

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
    Scalar color;
    int markerType = cv::MARKER_CROSS;
    int markerSize = 20;
    int thickness = 1;
    int line_type = cv::LINE_8;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Color")
            color = (rhs[i+1].isChar()) ?
                ColorType[rhs[i+1].toString()] : rhs[i+1].toScalar();
        else if (key == "MarkerType")
            markerType = (rhs[i+1].isChar()) ?
                MarkerTypeMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "MarkerSize")
            markerSize = rhs[i+1].toInt();
        else if (key == "Thickness")
            thickness = (rhs[i+1].isChar()) ?
                ThicknessType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "LineType")
            line_type = (rhs[i+1].isChar()) ?
                LineType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img(rhs[0].toMat());
    Point position(rhs[1].toPoint());
    drawMarker(img, position, color, markerType, markerSize, thickness,
        line_type);
    plhs[0] = MxArray(img);
}
