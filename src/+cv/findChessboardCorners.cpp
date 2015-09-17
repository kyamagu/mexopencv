/**
 * @file findChessboardCorners.cpp
 * @brief mex interface for cv::findChessboardCorners
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = cv::CALIB_CB_ADAPTIVE_THRESH + cv::CALIB_CB_NORMALIZE_IMAGE;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "AdaptiveThresh")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_CB_ADAPTIVE_THRESH);
        else if (key == "NormalizeImage")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_CB_NORMALIZE_IMAGE);
        else if (key == "FilterQuads")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_CB_FILTER_QUADS);
        else if (key == "FastCheck")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_CB_FAST_CHECK);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    Size patternSize(rhs[1].toSize());
    vector<Point2f> corners;
    bool ok = findChessboardCorners(image, patternSize, corners, flags);
    plhs[0] = MxArray(corners);
    if (nlhs > 1)
        plhs[1] = MxArray(ok);
}
