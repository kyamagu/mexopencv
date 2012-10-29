/**
 * @file findChessboardCorners.cpp
 * @brief mex interface for findChessboardCorners
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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat image(rhs[0].toMat());
    Size patternSize(rhs[1].toSize());
    
    // Option processing
    bool adaptiveThresh = true;
    bool normalizeImage = true;
    bool filterQuads = false;
    bool fastCheck = false;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="AdaptiveThresh")
            adaptiveThresh = rhs[i+1].toBool();
        else if (key=="NormalizeImage")
            normalizeImage = rhs[i+1].toBool();
        else if (key=="FilterQuads")
            filterQuads = rhs[i+1].toBool();
        else if (key=="FastCheck")
            fastCheck = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    int flags = ((adaptiveThresh) ? CV_CALIB_CB_ADAPTIVE_THRESH : 0) |
        ((normalizeImage) ? CV_CALIB_CB_NORMALIZE_IMAGE : 0) |
        ((filterQuads) ? CV_CALIB_CB_FILTER_QUADS : 0) |
        ((fastCheck) ? CALIB_CB_FAST_CHECK : 0);
    // Process
    vector<Point2f> corners;
    bool b = findChessboardCorners(image, patternSize, corners, flags);
    if (b)
        plhs[0] = MxArray(corners);
    else
        plhs[0] = MxArray(Mat());
}
