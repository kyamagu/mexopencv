/**
 * @file logPolar.cpp
 * @brief mex interface for cv::logPolar
 * @ingroup imgproc
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = cv::INTER_LINEAR;
    bool fillOutliersFlag = true;
    bool invMapFlag = false;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Interpolation")
            flags = (rhs[i+1].isChar()) ?
                InterpType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "FillOutliers")
            fillOutliersFlag = rhs[i+1].toBool();
        else if (key == "InverseMap")
            invMapFlag = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    flags |= (fillOutliersFlag ? cv::WARP_FILL_OUTLIERS : 0);
    flags |= (invMapFlag ? cv::WARP_INVERSE_MAP : 0);

    // Process
    Mat src(rhs[0].toMat()), dst;
    Point2f center(rhs[1].toPoint2f());
    double M = rhs[2].toDouble();
    logPolar(src, dst, center, M, flags);
    plhs[0] = MxArray(dst);
}
