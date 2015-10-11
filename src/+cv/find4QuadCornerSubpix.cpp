/**
 * @file find4QuadCornerSubpix.cpp
 * @brief mex interface for cv::find4QuadCornerSubpix
 * @ingroup calib3d
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Size region_size(3,3);
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "RegionSize")
            region_size = rhs[i+1].toSize();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    Mat img(rhs[0].toMat(CV_8U));
    bool success = false;
    if (rhs[1].isNumeric()) {
        Mat corners(rhs[1].toMat(CV_32F));
        success = find4QuadCornerSubpix(img, corners, region_size);
        plhs[0] = MxArray(corners);
    }
    else if (rhs[1].isCell()) {
        vector<Point2f> corners(rhs[1].toVector<Point2f>());
        success = find4QuadCornerSubpix(img, corners, region_size);
        plhs[0] = MxArray(corners);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    if (nlhs > 1)
        plhs[1] = MxArray(success);
}
