/**
 * @file findContours.cpp
 * @brief mex interface for cv::findContours
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Mode of the contour retrieval algorithm for option processing
const ConstMap<string,int> ContourMode = ConstMap<string,int>
    ("External",  cv::RETR_EXTERNAL)   // retrieve only the most external (top-level) contours
    ("List",      cv::RETR_LIST)       // retrieve all the contours without any hierarchical information
    ("CComp",     cv::RETR_CCOMP)      // retrieve the connected components (that can possibly be nested)
    ("Tree",      cv::RETR_TREE)       // retrieve all the contours and the whole hierarchy
    ("FloodFill", cv::RETR_FLOODFILL);

/// Type of the contour approximation algorithm for option processing
const ConstMap<string,int> ContourType = ConstMap<string,int>
    ("None",      cv::CHAIN_APPROX_NONE)
    ("Simple",    cv::CHAIN_APPROX_SIMPLE)
    ("TC89_L1",   cv::CHAIN_APPROX_TC89_L1)
    ("TC89_KCOS", cv::CHAIN_APPROX_TC89_KCOS);
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int mode = cv::RETR_EXTERNAL;
    int method = cv::CHAIN_APPROX_NONE;
    Point offset;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Mode")
            mode = ContourMode[rhs[i+1].toString()];
        else if (key=="Method")
            method = ContourType[rhs[i+1].toString()];
        else if (key=="Offset")
            offset = rhs[i+1].toPoint();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat(rhs[0].isInt32() ? CV_32S : CV_8U));
    vector<vector<Point> > contours;
    vector<Vec4i> hierarchy;
    findContours(image, contours, ((nlhs>1) ? hierarchy : noArray()),
        mode, method, offset);
    plhs[0] = MxArray(contours);
    if (nlhs > 1)
        plhs[1] = MxArray(hierarchy);
}
