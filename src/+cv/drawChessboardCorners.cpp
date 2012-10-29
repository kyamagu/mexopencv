/**
 * @file drawChessboardCorners.cpp
 * @brief mex interface for drawChessboardCorners
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
    if (nrhs<3 || nrhs>4 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat image(rhs[0].toMat());
    Size patternSize(rhs[1].toSize());
    // Option processing
    bool patternWasFound = (nrhs>3) ? rhs[3].toBool() : true;
    
    if (rhs[2].isNumeric()) {
        Mat corners(rhs[2].toMat());
        drawChessboardCorners(image, patternSize, corners, patternWasFound);
    }
    else if (rhs[2].isCell()) {
        vector<Point2f> corners(rhs[2].toVector<Point2f>());
        drawChessboardCorners(image, patternSize, corners, patternWasFound);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(image);
}
