/**
 * @file drawChessboardCorners.cpp
 * @brief mex interface for cv::drawChessboardCorners
 * @ingroup calib3d
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool patternWasFound = true;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "PatternWasFound")
            patternWasFound = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat());  // CV_8U/CV_16U/CV_32F, 1/3/4-channels
    Size patternSize(rhs[1].toSize());
    if (rhs[2].isNumeric()) {
        Mat corners(rhs[2].toMat(CV_32F));
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
